<#
.SYNOPSIS
    Generates a comprehensive MFA/2FA status report for all Microsoft 365 users.

.DESCRIPTION
    This script analyzes Multi-Factor Authentication (MFA) status for all users in your
    Microsoft 365 tenant. It provides detailed information about:
    
    - Which users have MFA enabled/disabled
    - Authentication methods registered (Authenticator app, SMS, FIDO2, Windows Hello)
    - Admin accounts without MFA (Critical risk)
    - MFA adoption percentage
    - Risk analysis for each user
    - Last sign-in activity
    
    The script generates three report formats:
    - HTML: Interactive dashboard with statistics and filtering
    - CSV: Detailed user data for analysis
    - JSON: Machine-readable format with statistics

.PARAMETER OutputPath
    Path where reports will be saved. Defaults to current directory.

.PARAMETER ExportFormat
    Output format(s). Valid values: HTML, CSV, JSON, All. Default is All.

.PARAMETER IncludeDisabledUsers
    Include disabled user accounts in the report. Default is true.

.PARAMETER AdminsOnly
    Generate report for administrator accounts only.

.EXAMPLE
    .\Get-MFAUserReport.ps1
    
    Generates MFA report for all users in all formats.

.EXAMPLE
    .\Get-MFAUserReport.ps1 -OutputPath "C:\Reports" -ExportFormat HTML
    
    Generates HTML MFA report only in specified directory.

.EXAMPLE
    .\Get-MFAUserReport.ps1 -AdminsOnly
    
    Generates MFA report for administrator accounts only.

.EXAMPLE
    .\Get-MFAUserReport.ps1 -IncludeDisabledUsers:$false
    
    Generates MFA report excluding disabled user accounts.

.NOTES
    Author: Security Administrator Agent
    Date: 2025-12-02
    Version: 1.1
    Requires: 
        - Microsoft.Graph module
        - Permissions: User.Read.All, UserAuthenticationMethod.Read.All
        - PowerShell 5.1 or later
    
.LINK
    https://learn.microsoft.com/en-us/graph/api/authentication-list-methods
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('HTML', 'CSV', 'JSON', 'All')]
    [string]$ExportFormat = 'All',
    
    [Parameter(Mandatory=$false)]
    [bool]$IncludeDisabledUsers = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$AdminsOnly
)

#Requires -Version 5.1

# Script variables
$script:StartTime = Get-Date

#region Helper Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Error' { Write-Error $logMessage }
        'Warning' { Write-Warning $logMessage }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Invoke-GraphWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,
        
        [int]$MaxRetries = 3,
        [int]$BaseDelaySeconds = 2
    )
    
    $attempt = 0
    
    do {
        try {
            return & $ScriptBlock
        }
        catch {
            $attempt++
            
            if ($_.Exception.Response.StatusCode -eq 429 -or 
                $_.Exception.Response.StatusCode -eq 503) {
                
                $retryAfter = $BaseDelaySeconds * [Math]::Pow(2, $attempt - 1)
                
                if ($attempt -le $MaxRetries) {
                    Write-Warning "Request throttled (Attempt $attempt/$MaxRetries). Waiting $retryAfter seconds..."
                    Start-Sleep -Seconds $retryAfter
                }
                else {
                    Write-Error "Max retries ($MaxRetries) exceeded due to throttling"
                    throw
                }
            }
            else {
                throw
            }
        }
    } while ($attempt -le $MaxRetries)
}

#endregion

#region Main MFA Report Function

Write-Log "========================================" -Level Info
Write-Log "MFA/2FA User Report Generator" -Level Info
Write-Log "========================================" -Level Info

try {
    # Validate output path
    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
        Write-Log "Created output directory: $OutputPath" -Level Info
    }
    
    # Check Microsoft Graph connection
    Write-Log "Checking Microsoft Graph connection..." -Level Info
    
    try {
        $context = Get-MgContext -ErrorAction SilentlyContinue
        if (-not $context) {
            Write-Log "Not connected to Microsoft Graph. Connecting..." -Level Warning
            Connect-MgGraph -Scopes "User.Read.All", "UserAuthenticationMethod.Read.All", "Directory.Read.All" -NoWelcome
            Write-Log "Connected to Microsoft Graph successfully" -Level Success
        } else {
            Write-Log "Already connected to Microsoft Graph as $($context.Account)" -Level Success
        }
    }
    catch {
        Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level Error
        Write-Log "Please run: Connect-MgGraph -Scopes 'User.Read.All','UserAuthenticationMethod.Read.All'" -Level Error
        exit 1
    }
    
    # Collect user data
    Write-Log "Retrieving user accounts..." -Level Info
    
    $users = Invoke-GraphWithRetry -ScriptBlock {
        Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,AccountEnabled,UserType,CreatedDateTime,SignInActivity -ErrorAction Stop
    }
    
    # Filter users if needed
    if (-not $IncludeDisabledUsers) {
        $users = $users | Where-Object { $_.AccountEnabled -eq $true }
        Write-Log "Filtering to enabled users only" -Level Info
    }
    
    # Filter to admins only if requested
    if ($AdminsOnly) {
        Write-Log "Filtering to administrator accounts only..." -Level Info
        $adminUsers = @()
        foreach ($user in $users) {
            try {
                $memberOf = Invoke-GraphWithRetry -ScriptBlock {
                    Get-MgUserMemberOf -UserId $user.Id -All -ErrorAction SilentlyContinue
                }
                
                $adminGroups = $memberOf | Where-Object {
                    $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.directoryRole' -and
                    $_.AdditionalProperties.displayName -match "Administrator"
                }
                
                if ($adminGroups.Count -gt 0) {
                    $adminUsers += $user
                }
            } catch {
                # Silently continue
            }
        }
        $users = $adminUsers
        Write-Log "Found $($users.Count) administrator accounts" -Level Info
    }
    
    $totalUsers = $users.Count
    $processedUsers = 0
    $mfaUsers = @()
    
    Write-Log "Analyzing MFA status for $totalUsers users..." -Level Info
    
    foreach ($user in $users) {
        $processedUsers++
        Write-Progress -Activity "Analyzing MFA Status" `
            -Status "Processing user $processedUsers of $totalUsers: $($user.UserPrincipalName)" `
            -PercentComplete (($processedUsers / $totalUsers) * 100)
        
        try {
            # Get authentication methods
            $authMethods = Invoke-GraphWithRetry -ScriptBlock {
                Get-MgUserAuthenticationMethod -UserId $user.Id -ErrorAction SilentlyContinue
            }
            
            # Parse authentication methods
            $hasMicrosoftAuthenticator = $false
            $hasPhone = $false
            $hasSMS = $false
            $hasEmail = $false
            $hasFIDO2 = $false
            $hasSoftwareOath = $false
            $hasWindowsHello = $false
            $methodsList = @()
            
            foreach ($method in $authMethods) {
                $methodType = $method.AdditionalProperties.'@odata.type'
                
                switch -Wildcard ($methodType) {
                    "*microsoftAuthenticator*" {
                        $hasMicrosoftAuthenticator = $true
                        $methodsList += "Microsoft Authenticator"
                    }
                    "*phone*" {
                        $hasPhone = $true
                        $phoneType = $method.AdditionalProperties.phoneType
                        if ($phoneType -eq "mobile") {
                            $hasSMS = $true
                            $methodsList += "Phone (Mobile/SMS)"
                        } else {
                            $methodsList += "Phone (Office)"
                        }
                    }
                    "*email*" {
                        $hasEmail = $true
                        $methodsList += "Email"
                    }
                    "*fido2*" {
                        $hasFIDO2 = $true
                        $methodsList += "FIDO2 Security Key"
                    }
                    "*softwareOath*" {
                        $hasSoftwareOath = $true
                        $methodsList += "Software OATH Token"
                    }
                    "*windowsHello*" {
                        $hasWindowsHello = $true
                        $methodsList += "Windows Hello for Business"
                    }
                    "*password*" {
                        # Password is always present, don't add to methods list
                    }
                    default {
                        if ($methodType) {
                            $methodsList += $methodType -replace '#microsoft.graph.', ''
                        }
                    }
                }
            }
            
            # Determine MFA status
            $mfaEnabled = $authMethods.Count -gt 1
            $mfaMethodCount = $methodsList.Count
            $mfaStatus = if ($mfaEnabled) { "Enabled" } else { "Disabled" }
            
            # Get last sign-in
            $lastSignIn = if ($user.SignInActivity.LastSignInDateTime) {
                $user.SignInActivity.LastSignInDateTime
            } else {
                "Never"
            }
            
            # Check if user is admin
            $isAdmin = $false
            if (-not $AdminsOnly) {  # Skip if we already filtered to admins
                try {
                    $memberOf = Invoke-GraphWithRetry -ScriptBlock {
                        Get-MgUserMemberOf -UserId $user.Id -All -ErrorAction SilentlyContinue
                    }
                    
                    $adminGroups = $memberOf | Where-Object {
                        $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.directoryRole' -and
                        $_.AdditionalProperties.displayName -match "Administrator"
                    }
                    
                    $isAdmin = $adminGroups.Count -gt 0
                } catch {
                    # Silently continue
                }
            } else {
                $isAdmin = $true  # All users in report are admins
            }
            
            # Determine risk level
            $riskLevel = "Low"
            if (-not $mfaEnabled) {
                if ($isAdmin) {
                    $riskLevel = "Critical"
                } elseif ($user.AccountEnabled) {
                    $riskLevel = "High"
                } else {
                    $riskLevel = "Medium"
                }
            } elseif ($mfaEnabled -and $hasSMS -and -not $hasMicrosoftAuthenticator -and -not $hasFIDO2) {
                $riskLevel = "Medium"
            }
            
            # Create user MFA object
            $mfaUser = [PSCustomObject]@{
                DisplayName = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                AccountEnabled = $user.AccountEnabled
                UserType = $user.UserType
                MFAStatus = $mfaStatus
                MFAMethodCount = $mfaMethodCount
                MFAMethods = ($methodsList -join "; ")
                HasMicrosoftAuthenticator = $hasMicrosoftAuthenticator
                HasPhoneAuth = $hasPhone
                HasSMS = $hasSMS
                HasEmail = $hasEmail
                HasFIDO2 = $hasFIDO2
                HasSoftwareOATH = $hasSoftwareOath
                HasWindowsHello = $hasWindowsHello
                IsAdmin = $isAdmin
                LastSignIn = $lastSignIn
                RiskLevel = $riskLevel
                CreatedDateTime = $user.CreatedDateTime
            }
            
            $mfaUsers += $mfaUser
            
        } catch {
            Write-Log "Error processing user $($user.UserPrincipalName): $($_.Exception.Message)" -Level Warning
        }
    }
    
    Write-Progress -Activity "Analyzing MFA Status" -Completed
    
    # Generate statistics
    $stats = @{
        TotalUsers = $mfaUsers.Count
        MFAEnabled = ($mfaUsers | Where-Object { $_.MFAStatus -eq 'Enabled' }).Count
        MFADisabled = ($mfaUsers | Where-Object { $_.MFAStatus -eq 'Disabled' }).Count
        AdminsWithoutMFA = ($mfaUsers | Where-Object { $_.IsAdmin -eq $true -and $_.MFAStatus -eq 'Disabled' }).Count
        EnabledUsersWithoutMFA = ($mfaUsers | Where-Object { $_.AccountEnabled -eq $true -and $_.MFAStatus -eq 'Disabled' }).Count
        UsingAuthenticatorApp = ($mfaUsers | Where-Object { $_.HasMicrosoftAuthenticator -eq $true }).Count
        UsingSMSOnly = ($mfaUsers | Where-Object { $_.HasSMS -eq $true -and $_.HasMicrosoftAuthenticator -eq $false -and $_.HasFIDO2 -eq $false }).Count
        UsingFIDO2 = ($mfaUsers | Where-Object { $_.HasFIDO2 -eq $true }).Count
        UsingWindowsHello = ($mfaUsers | Where-Object { $_.HasWindowsHello -eq $true }).Count
        CriticalRisk = ($mfaUsers | Where-Object { $_.RiskLevel -eq 'Critical' }).Count
        HighRisk = ($mfaUsers | Where-Object { $_.RiskLevel -eq 'High' }).Count
        MediumRisk = ($mfaUsers | Where-Object { $_.RiskLevel -eq 'Medium' }).Count
    }
    
    $mfaPercentage = if ($stats.TotalUsers -gt 0) {
        [math]::Round(($stats.MFAEnabled / $stats.TotalUsers) * 100, 2)
    } else {
        0
    }
    
    Write-Log "========================================" -Level Success
    Write-Log "MFA Analysis Complete!" -Level Success
    Write-Log "========================================" -Level Success
    Write-Log "Total Users: $($stats.TotalUsers)" -Level Info
    Write-Log "MFA Enabled: $($stats.MFAEnabled) ($mfaPercentage%)" -Level Success
    Write-Log "MFA Disabled: $($stats.MFADisabled)" -Level $(if ($stats.MFADisabled -gt 0) { 'Warning' } else { 'Info' })
    Write-Log "Admins Without MFA: $($stats.AdminsWithoutMFA)" -Level $(if ($stats.AdminsWithoutMFA -gt 0) { 'Error' } else { 'Info' })
    Write-Log "Critical Risk Users: $($stats.CriticalRisk)" -Level $(if ($stats.CriticalRisk -gt 0) { 'Error' } else { 'Info' })
    
    # Export reports
    Write-Log "========================================" -Level Info
    Write-Log "Exporting Reports" -Level Info
    Write-Log "========================================" -Level Info
    
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $exportedFiles = @()
    
    # CSV Export
    if ($ExportFormat -eq 'All' -or $ExportFormat -eq 'CSV') {
        $csvPath = Join-Path $OutputPath "MFA_User_Report_$timestamp.csv"
        $mfaUsers | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Write-Log "CSV report exported to: $csvPath" -Level Success
        $exportedFiles += $csvPath
    }
    
    # JSON Export
    if ($ExportFormat -eq 'All' -or $ExportFormat -eq 'JSON') {
        $jsonPath = Join-Path $OutputPath "MFA_User_Report_$timestamp.json"
        $jsonReport = @{
            GeneratedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Statistics = $stats
            MFAAdoptionPercentage = $mfaPercentage
            Users = $mfaUsers
        }
        $jsonReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
        Write-Log "JSON report exported to: $jsonPath" -Level Success
        $exportedFiles += $jsonPath
    }
    
    # HTML Export
    if ($ExportFormat -eq 'All' -or $ExportFormat -eq 'HTML') {
        $htmlPath = Join-Path $OutputPath "MFA_User_Report_$timestamp.html"
        
        # Generate HTML content (embedded for standalone script)
        . {
            $css = @"
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; border-radius: 10px; margin-bottom: 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    h1 { margin: 0 0 10px 0; font-size: 32px; }
    .subtitle { opacity: 0.9; font-size: 16px; margin: 5px 0; }
    .stats-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
    .stat-card { background-color: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); text-align: center; }
    .stat-label { font-size: 13px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 10px; }
    .stat-value { font-size: 36px; font-weight: bold; margin: 10px 0; }
    .stat-green { color: #4caf50; }
    .stat-red { color: #f44336; }
    .stat-orange { color: #ff9800; }
    .stat-blue { color: #2196f3; }
    .stat-purple { color: #9c27b0; }
    .gauge-container { grid-column: span 2; background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; }
    .gauge-value { font-size: 60px; font-weight: bold; color: white; }
    .section { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 20px; }
    .section h2 { margin-top: 0; color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    thead { background-color: #667eea; color: white; }
    th { padding: 12px; text-align: left; font-weight: 600; }
    td { padding: 12px; border-bottom: 1px solid #e0e0e0; }
    tr:hover { background-color: #f5f5f5; }
    .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
    .badge-enabled { background-color: #4caf50; color: white; }
    .badge-disabled { background-color: #f44336; color: white; }
    .badge-critical { background-color: #d32f2f; color: white; }
    .badge-high { background-color: #f57c00; color: white; }
    .badge-medium { background-color: #ffa726; color: white; }
    .badge-low { background-color: #66bb6a; color: white; }
    .badge-yes { background-color: #2196f3; color: white; }
    .badge-no { background-color: #9e9e9e; color: white; }
    .filter-buttons { margin: 20px 0; }
    .filter-btn { padding: 8px 16px; margin: 5px; border: none; border-radius: 5px; cursor: pointer; background-color: #667eea; color: white; font-size: 14px; }
    .filter-btn:hover { background-color: #5568d3; }
    .filter-btn.active { background-color: #764ba2; }
    .footer { text-align: center; margin-top: 40px; padding: 20px; background-color: white; border-radius: 10px; color: #666; font-size: 14px; }
</style>
"@
            
            $tableRows = ""
            foreach ($user in $mfaUsers | Sort-Object RiskLevel,DisplayName) {
                $mfaStatusBadge = if ($user.MFAStatus -eq 'Enabled') { "<span class='badge badge-enabled'>Enabled</span>" } else { "<span class='badge badge-disabled'>Disabled</span>" }
                $riskBadge = switch ($user.RiskLevel) {
                    'Critical' { "<span class='badge badge-critical'>Critical</span>" }
                    'High' { "<span class='badge badge-high'>High</span>" }
                    'Medium' { "<span class='badge badge-medium'>Medium</span>" }
                    'Low' { "<span class='badge badge-low'>Low</span>" }
                }
                $adminBadge = if ($user.IsAdmin) { "<span class='badge badge-yes'>Yes</span>" } else { "<span class='badge badge-no'>No</span>" }
                $enabledBadge = if ($user.AccountEnabled) { "<span class='badge badge-enabled'>Enabled</span>" } else { "<span class='badge badge-no'>Disabled</span>" }
                
                $tableRows += "<tr class='user-row' data-risk='$($user.RiskLevel)' data-mfa='$($user.MFAStatus)' data-admin='$($user.IsAdmin)'><td>$($user.DisplayName)</td><td>$($user.UserPrincipalName)</td><td>$enabledBadge</td><td>$mfaStatusBadge</td><td>$($user.MFAMethods)</td><td>$adminBadge</td><td>$riskBadge</td><td>$($user.LastSignIn)</td></tr>"
            }
            
            @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MFA/2FA User Report</title>
    $css
</head>
<body>
    <div class='header'>
        <h1>🔐 MFA/2FA User Report</h1>
        <div class='subtitle'>Microsoft 365 Multi-Factor Authentication Status</div>
        <div class='subtitle'>Generated: $(Get-Date -Format 'dddd, MMMM dd, yyyy - HH:mm:ss')</div>
    </div>
    <div class='stats-container'>
        <div class='stat-card gauge-container'>
            <div class='stat-label'>MFA Adoption Rate</div>
            <div class='gauge-value'>$([math]::Round($mfaPercentage, 1))%</div>
            <div style='font-size: 14px; margin-top: 10px;'>$($stats.MFAEnabled) of $($stats.TotalUsers) users</div>
        </div>
        <div class='stat-card'><div class='stat-label'>Total Users</div><div class='stat-value stat-blue'>$($stats.TotalUsers)</div></div>
        <div class='stat-card'><div class='stat-label'>MFA Enabled</div><div class='stat-value stat-green'>$($stats.MFAEnabled)</div></div>
        <div class='stat-card'><div class='stat-label'>MFA Disabled</div><div class='stat-value stat-red'>$($stats.MFADisabled)</div></div>
        <div class='stat-card'><div class='stat-label'>Admins Without MFA</div><div class='stat-value stat-red'>$($stats.AdminsWithoutMFA)</div></div>
        <div class='stat-card'><div class='stat-label'>Critical Risk</div><div class='stat-value stat-red'>$($stats.CriticalRisk)</div></div>
        <div class='stat-card'><div class='stat-label'>Using Authenticator App</div><div class='stat-value stat-green'>$($stats.UsingAuthenticatorApp)</div></div>
        <div class='stat-card'><div class='stat-label'>Using FIDO2</div><div class='stat-value stat-purple'>$($stats.UsingFIDO2)</div></div>
        <div class='stat-card'><div class='stat-label'>SMS Only</div><div class='stat-value stat-orange'>$($stats.UsingSMSOnly)</div></div>
        <div class='stat-card'><div class='stat-label'>Windows Hello</div><div class='stat-value stat-blue'>$($stats.UsingWindowsHello)</div></div>
    </div>
    <div class='section'>
        <h2>User Details</h2>
        <div class='filter-buttons'>
            <button class='filter-btn active' onclick='filterTable("all")'>All Users</button>
            <button class='filter-btn' onclick='filterTable("mfa-disabled")'>MFA Disabled</button>
            <button class='filter-btn' onclick='filterTable("admins-no-mfa")'>Admins Without MFA</button>
            <button class='filter-btn' onclick='filterTable("critical")'>Critical Risk</button>
            <button class='filter-btn' onclick='filterTable("high")'>High Risk</button>
        </div>
        <table id='userTable'>
            <thead><tr><th>Display Name</th><th>User Principal Name</th><th>Account Status</th><th>MFA Status</th><th>MFA Methods</th><th>Is Admin</th><th>Risk Level</th><th>Last Sign-In</th></tr></thead>
            <tbody>$tableRows</tbody>
        </table>
    </div>
    <div class='section'>
        <h2>📊 MFA Method Distribution</h2>
        <ul style='font-size: 16px; line-height: 2;'>
            <li><strong>Microsoft Authenticator App:</strong> $($stats.UsingAuthenticatorApp) users (✅ Recommended)</li>
            <li><strong>FIDO2 Security Keys:</strong> $($stats.UsingFIDO2) users (✅ Most Secure)</li>
            <li><strong>Windows Hello for Business:</strong> $($stats.UsingWindowsHello) users (✅ Recommended)</li>
            <li><strong>SMS Only:</strong> $($stats.UsingSMSOnly) users (⚠️ Less Secure - Consider upgrading)</li>
        </ul>
    </div>
    <div class='section'>
        <h2>🎯 Recommendations</h2>
        <ol style='font-size: 16px; line-height: 2;'>
            <li><strong>Immediate Action:</strong> Enable MFA for all $($stats.AdminsWithoutMFA) administrators without MFA</li>
            <li><strong>High Priority:</strong> Enable MFA for $($stats.EnabledUsersWithoutMFA) active users without MFA</li>
            <li><strong>Security Upgrade:</strong> Migrate $($stats.UsingSMSOnly) SMS-only users to Microsoft Authenticator or FIDO2</li>
            <li><strong>Best Practice:</strong> Implement Conditional Access policies to enforce MFA for all users</li>
            <li><strong>Advanced Security:</strong> Deploy FIDO2 security keys for privileged accounts</li>
        </ol>
    </div>
    <div class='footer'>
        <strong>Microsoft 365 MFA/2FA User Report</strong><br>
        Powered by PowerShell Automation | Security Administrator Agent<br>
        This report contains confidential security information
    </div>
    <script>
        function filterTable(filter) {
            const rows = document.querySelectorAll('.user-row');
            const buttons = document.querySelectorAll('.filter-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            rows.forEach(row => {
                const risk = row.getAttribute('data-risk');
                const mfa = row.getAttribute('data-mfa');
                const isAdmin = row.getAttribute('data-admin') === 'True';
                let show = false;
                switch(filter) {
                    case 'all': show = true; break;
                    case 'mfa-disabled': show = mfa === 'Disabled'; break;
                    case 'admins-no-mfa': show = isAdmin && mfa === 'Disabled'; break;
                    case 'critical': show = risk === 'Critical'; break;
                    case 'high': show = risk === 'High'; break;
                }
                row.style.display = show ? '' : 'none';
            });
        }
    </script>
</body>
</html>
"@
        }
        
        $html | Out-File -FilePath $htmlPath -Encoding UTF8
        Write-Log "HTML report exported to: $htmlPath" -Level Success
        $exportedFiles += $htmlPath
        
        # Try to open HTML
        try {
            Start-Process $htmlPath
        } catch {
            Write-Log "Could not open browser automatically" -Level Warning
        }
    }
    
    Write-Log "========================================" -Level Success
    Write-Log "Report Generation Complete!" -Level Success
    Write-Log "========================================" -Level Success
    Write-Log "Exported files:" -Level Success
    foreach ($file in $exportedFiles) {
        Write-Log "  - $file" -Level Success
    }
    
    # Return summary
    return [PSCustomObject]@{
        TotalUsers = $stats.TotalUsers
        MFAEnabled = $stats.MFAEnabled
        MFADisabled = $stats.MFADisabled
        AdminsWithoutMFA = $stats.AdminsWithoutMFA
        MFAPercentage = $mfaPercentage
        Statistics = $stats
        Duration = (Get-Date) - $script:StartTime
        ExportedFiles = $exportedFiles
    }
    
} catch {
    Write-Log "Critical error: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    throw
}

#endregion

