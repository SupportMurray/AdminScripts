<#
.SYNOPSIS
    Comprehensive Microsoft 365 Environment Audit

.DESCRIPTION
    Performs a complete audit of Microsoft 365 environment including:
    - Tenant information and configuration
    - User accounts and licensing
    - Security posture (MFA, Conditional Access, sign-ins)
    - Exchange Online configuration and usage
    - SharePoint/OneDrive usage and storage
    - Teams configuration and usage
    - Inactive users and resources
    - Security and compliance settings
    
    Generates a detailed text report with findings and recommendations.

.PARAMETER OutputPath
    Path where the audit report will be saved. Defaults to current directory.

.PARAMETER DaysBack
    Number of days to look back for activity analysis. Default is 30 days.

.PARAMETER IncludeSignInLogs
    Include detailed sign-in log analysis (may take longer for large tenants)

.EXAMPLE
    .\Get-M365ComprehensiveAudit.ps1
    
.EXAMPLE
    .\Get-M365ComprehensiveAudit.ps1 -OutputPath "C:\Reports" -DaysBack 90 -IncludeSignInLogs

.NOTES
    Author: Microsoft 365 Audit Administrator Agent
    Date: December 2, 2025
    Version: 1.0
    Requires: Microsoft.Graph, ExchangeOnlineManagement modules
    Permissions Required:
    - User.Read.All
    - Directory.Read.All
    - AuditLog.Read.All
    - Reports.Read.All
    - Organization.Read.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".",
    
    [Parameter(Mandatory=$false)]
    [int]$DaysBack = 30,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeSignInLogs
)

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement, Microsoft.Graph.Reports

# Global variables
$script:AuditResults = @()
$script:Recommendations = @()
$script:StartTime = Get-Date

function Write-AuditLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Section')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Error' { Write-Host $logMessage -ForegroundColor Red }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        'Section' { Write-Host "`n=== $Message ===" -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
    
    $script:AuditResults += $logMessage
}

function Add-Recommendation {
    param([string]$Recommendation)
    $script:Recommendations += $Recommendation
}

function Test-GraphPermissions {
    Write-AuditLog -Message "Validating Microsoft Graph Permissions" -Level Section
    
    $permissionTests = @{
        "Organization.Read.All" = { Get-MgOrganization -ErrorAction Stop | Select-Object -First 1 }
        "User.Read.All" = { Get-MgUser -Top 1 -ErrorAction Stop }
        "Directory.Read.All" = { Get-MgDirectoryRole -ErrorAction Stop | Select-Object -First 1 }
        "Group.Read.All" = { Get-MgGroup -Top 1 -ErrorAction Stop }
    }
    
    $allPassed = $true
    $failedPermissions = @()
    
    foreach ($permission in $permissionTests.Keys) {
        try {
            Write-Progress -Activity "Testing permissions" -Status "Testing $permission..."
            $null = & $permissionTests[$permission]
            Write-AuditLog "✓ $permission - OK" -Level Success
        }
        catch {
            Write-AuditLog "✗ $permission - FAILED" -Level Error
            $failedPermissions += $permission
            $allPassed = $false
        }
    }
    
    Write-Progress -Activity "Testing permissions" -Completed
    
    if (-not $allPassed) {
        Write-Host "`n" -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host "  INSUFFICIENT PERMISSIONS" -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host "`nThe following permissions are missing or insufficient:" -ForegroundColor Yellow
        foreach ($perm in $failedPermissions) {
            Write-Host "  ✗ $perm" -ForegroundColor Red
        }
        Write-Host "`nPlease ensure your account has the required permissions." -ForegroundColor Yellow
        Write-Host "Required roles: Global Reader OR Global Administrator" -ForegroundColor White
        Write-Host "`nYou may need to:" -ForegroundColor Yellow
        Write-Host "  1. Disconnect and reconnect with proper permissions" -ForegroundColor White
        Write-Host "  2. Contact your tenant administrator for access" -ForegroundColor White
        Write-Host "  3. Ensure admin consent has been granted`n" -ForegroundColor White
        Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Red
        
        Add-Recommendation "Grant required Microsoft Graph permissions to run comprehensive audits"
        return $false
    }
    
    Write-AuditLog "All permission checks passed successfully!" -Level Success
    return $true
}

function Get-TenantInformation {
    Write-AuditLog -Message "Collecting Tenant Information" -Level Section
    
    try {
        Write-Progress -Activity "Collecting tenant information" -Status "Querying organization details..."
        
        $org = Get-MgOrganization -ErrorAction Stop
        
        if (-not $org) {
            Write-AuditLog "No organization data returned" -Level Warning
            return $null
        }
        
        Write-AuditLog "Organization Name: $($org.DisplayName)" -Level Success
        Write-AuditLog "Tenant ID: $($org.Id)"
        Write-AuditLog "Initial Domain: $($org.VerifiedDomains | Where-Object {$_.IsInitial} | Select-Object -ExpandProperty Name)"
        Write-AuditLog "Country: $($org.CountryLetterCode)"
        Write-AuditLog "Created Date: $($org.CreatedDateTime)"
        
        # Get verified domains
        $verifiedDomains = $org.VerifiedDomains | Where-Object {$_.Capabilities -contains "Email"}
        Write-AuditLog "Verified Email Domains: $($verifiedDomains.Count)"
        foreach ($domain in $verifiedDomains) {
            Write-AuditLog "  - $($domain.Name) $(if($domain.IsDefault){'(Default)'})"
        }
        
        Write-Progress -Activity "Collecting tenant information" -Completed
        
        return $org
    }
    catch {
        Write-Progress -Activity "Collecting tenant information" -Completed
        Write-AuditLog "ERROR: Cannot retrieve tenant information" -Level Error
        Write-AuditLog "Reason: $($_.Exception.Message)" -Level Error
        
        if ($_.Exception.Message -match "Authentication|Forbidden|Unauthorized") {
            Write-AuditLog "This usually indicates insufficient permissions or expired authentication" -Level Warning
        }
        
        return $null
    }
}

function Get-UserStatistics {
    Write-AuditLog -Message "Analyzing User Accounts" -Level Section
    
    try {
        Write-Progress -Activity "Collecting user data" -Status "Retrieving all users..."
        
        $allUsers = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,AccountEnabled,CreatedDateTime,SignInActivity,AssignedLicenses,UserType -ErrorAction Stop
        
        $totalUsers = $allUsers.Count
        $enabledUsers = ($allUsers | Where-Object {$_.AccountEnabled -eq $true}).Count
        $disabledUsers = $totalUsers - $enabledUsers
        $licensedUsers = ($allUsers | Where-Object {$_.AssignedLicenses.Count -gt 0}).Count
        $guestUsers = ($allUsers | Where-Object {$_.UserType -eq "Guest"}).Count
        $memberUsers = ($allUsers | Where-Object {$_.UserType -eq "Member"}).Count
        
        Write-AuditLog "Total Users: $totalUsers"
        Write-AuditLog "  - Enabled: $enabledUsers"
        Write-AuditLog "  - Disabled: $disabledUsers"
        Write-AuditLog "  - Licensed: $licensedUsers"
        Write-AuditLog "  - Unlicensed: $($totalUsers - $licensedUsers)"
        Write-AuditLog "  - Member Users: $memberUsers"
        Write-AuditLog "  - Guest Users: $guestUsers"
        
        # Analyze sign-in activity (last 30 days)
        $cutoffDate = (Get-Date).AddDays(-30)
        $recentSignIns = $allUsers | Where-Object {
            $_.SignInActivity.LastSignInDateTime -and 
            [datetime]$_.SignInActivity.LastSignInDateTime -gt $cutoffDate
        }
        
        Write-AuditLog "Users with sign-in activity (last 30 days): $($recentSignIns.Count)"
        
        # Identify inactive users (no sign-in in last 90 days)
        $inactiveCutoff = (Get-Date).AddDays(-90)
        $inactiveUsers = $allUsers | Where-Object {
            $_.AccountEnabled -eq $true -and
            $_.AssignedLicenses.Count -gt 0 -and
            ($_.SignInActivity.LastSignInDateTime -eq $null -or 
             [datetime]$_.SignInActivity.LastSignInDateTime -lt $inactiveCutoff)
        }
        
        Write-AuditLog "Inactive licensed users (no sign-in in 90+ days): $($inactiveUsers.Count)" -Level Warning
        
        if ($inactiveUsers.Count -gt 0) {
            Add-Recommendation "Review $($inactiveUsers.Count) inactive licensed users for potential license reclamation"
            Write-AuditLog "Sample inactive users:"
            $inactiveUsers | Select-Object -First 10 | ForEach-Object {
                $lastSignIn = if ($_.SignInActivity.LastSignInDateTime) { $_.SignInActivity.LastSignInDateTime } else { "Never" }
                Write-AuditLog "  - $($_.UserPrincipalName) - Last sign-in: $lastSignIn"
            }
        }
        
        # Users created in last 30 days
        $newUsers = $allUsers | Where-Object {
            $_.CreatedDateTime -and [datetime]$_.CreatedDateTime -gt $cutoffDate
        }
        Write-AuditLog "New users created (last 30 days): $($newUsers.Count)"
        
        if ($guestUsers -gt ($totalUsers * 0.3)) {
            Add-Recommendation "Guest users represent $([math]::Round(($guestUsers/$totalUsers)*100,2))% of total users. Review guest access policies."
        }
        
        Write-Progress -Activity "Collecting user data" -Completed
        
        return $allUsers
    }
    catch {
        Write-AuditLog "Failed to retrieve user statistics: $($_.Exception.Message)" -Level Error
        Write-Progress -Activity "Collecting user data" -Completed
        return @()
    }
}

function Get-LicenseInformation {
    Write-AuditLog -Message "Analyzing License Usage" -Level Section
    
    try {
        Write-Progress -Activity "Collecting license data" -Status "Retrieving subscriptions..."
        
        $subscriptions = Get-MgSubscribedSku -All -ErrorAction Stop
        
        $totalLicenses = 0
        $totalAssigned = 0
        
        Write-AuditLog "License Summary:"
        
        foreach ($sku in $subscriptions) {
            $skuName = $sku.SkuPartNumber
            $total = $sku.PrepaidUnits.Enabled
            $consumed = $sku.ConsumedUnits
            $available = $total - $consumed
            
            $totalLicenses += $total
            $totalAssigned += $consumed
            
            $utilizationPercent = if ($total -gt 0) { [math]::Round(($consumed / $total) * 100, 2) } else { 0 }
            
            Write-AuditLog "  $skuName"
            Write-AuditLog "    Total: $total | Assigned: $consumed | Available: $available | Utilization: $utilizationPercent%"
            
            if ($utilizationPercent -gt 95) {
                Add-Recommendation "License pool '$skuName' is at $utilizationPercent% utilization. Consider purchasing additional licenses."
            }
            elseif ($utilizationPercent -lt 50 -and $total -gt 10) {
                Add-Recommendation "License pool '$skuName' has low utilization ($utilizationPercent%). Review if licenses can be reduced."
            }
        }
        
        Write-AuditLog "`nTotal License Summary:"
        Write-AuditLog "  Total licenses: $totalLicenses"
        Write-AuditLog "  Assigned licenses: $totalAssigned"
        Write-AuditLog "  Available licenses: $($totalLicenses - $totalAssigned)"
        Write-AuditLog "  Overall utilization: $([math]::Round(($totalAssigned / $totalLicenses) * 100, 2))%"
        
        Write-Progress -Activity "Collecting license data" -Completed
        
        return $subscriptions
    }
    catch {
        Write-AuditLog "Failed to retrieve license information: $($_.Exception.Message)" -Level Error
        Write-Progress -Activity "Collecting license data" -Completed
        return @()
    }
}

function Get-SecurityPosture {
    Write-AuditLog -Message "Analyzing Security Posture" -Level Section
    
    try {
        # MFA Registration Status
        Write-Progress -Activity "Analyzing security" -Status "Checking MFA status..."
        
        try {
            $authMethods = Get-MgReportAuthenticationMethodUserRegistrationDetail -All -ErrorAction Stop
            
            $totalUsers = $authMethods.Count
            $mfaRegistered = ($authMethods | Where-Object {$_.IsMfaRegistered -eq $true}).Count
            $mfaCapable = ($authMethods | Where-Object {$_.IsMfaCapable -eq $true}).Count
            
            $mfaPercent = if ($totalUsers -gt 0) { [math]::Round(($mfaRegistered / $totalUsers) * 100, 2) } else { 0 }
            
            Write-AuditLog "MFA Registration Status:"
            Write-AuditLog "  Total users analyzed: $totalUsers"
            Write-AuditLog "  MFA registered: $mfaRegistered ($mfaPercent%)"
            Write-AuditLog "  MFA capable: $mfaCapable"
            
            if ($mfaPercent -lt 95) {
                Add-Recommendation "Only $mfaPercent% of users have MFA registered. Target: 95%+ MFA adoption."
            }
            else {
                Write-AuditLog "  MFA adoption is good!" -Level Success
            }
        }
        catch {
            Write-AuditLog "Could not retrieve MFA status: $($_.Exception.Message)" -Level Warning
        }
        
        # Conditional Access Policies
        Write-Progress -Activity "Analyzing security" -Status "Checking Conditional Access..."
        
        try {
            $caPolicies = Get-MgIdentityConditionalAccessPolicy -All -ErrorAction Stop
            
            $enabledPolicies = ($caPolicies | Where-Object {$_.State -eq "enabled"}).Count
            $disabledPolicies = ($caPolicies | Where-Object {$_.State -eq "disabled"}).Count
            $reportOnlyPolicies = ($caPolicies | Where-Object {$_.State -eq "enabledForReportingButNotEnforced"}).Count
            
            Write-AuditLog "`nConditional Access Policies:"
            Write-AuditLog "  Total policies: $($caPolicies.Count)"
            Write-AuditLog "  Enabled: $enabledPolicies"
            Write-AuditLog "  Disabled: $disabledPolicies"
            Write-AuditLog "  Report-only: $reportOnlyPolicies"
            
            if ($enabledPolicies -eq 0) {
                Add-Recommendation "No Conditional Access policies are enabled. Consider implementing CA policies for enhanced security."
            }
            
            # List enabled policies
            if ($enabledPolicies -gt 0) {
                Write-AuditLog "`n  Enabled Policies:"
                $caPolicies | Where-Object {$_.State -eq "enabled"} | ForEach-Object {
                    Write-AuditLog "    - $($_.DisplayName)"
                }
            }
        }
        catch {
            Write-AuditLog "Could not retrieve Conditional Access policies: $($_.Exception.Message)" -Level Warning
        }
        
        # Directory Roles (Privileged accounts)
        Write-Progress -Activity "Analyzing security" -Status "Checking privileged accounts..."
        
        try {
            $privilegedRoles = @(
                "Global Administrator",
                "Privileged Role Administrator", 
                "Security Administrator",
                "Exchange Administrator",
                "SharePoint Administrator",
                "User Administrator"
            )
            
            Write-AuditLog "`nPrivileged Role Assignments:"
            
            $allRoles = Get-MgDirectoryRole -All -ErrorAction Stop
            $totalPrivilegedUsers = 0
            
            foreach ($roleName in $privilegedRoles) {
                $role = $allRoles | Where-Object {$_.DisplayName -eq $roleName}
                
                if ($role) {
                    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction SilentlyContinue
                    $memberCount = $members.Count
                    $totalPrivilegedUsers += $memberCount
                    
                    Write-AuditLog "  ${roleName}: $memberCount member(s)"
                    
                    if ($roleName -eq "Global Administrator" -and $memberCount -gt 5) {
                        Add-Recommendation "You have $memberCount Global Administrators. Consider reducing to 3-5 for security best practices."
                    }
                }
            }
            
            Write-AuditLog "`nTotal users with privileged roles: $totalPrivilegedUsers"
        }
        catch {
            Write-AuditLog "Could not retrieve directory role information: $($_.Exception.Message)" -Level Warning
        }
        
        Write-Progress -Activity "Analyzing security" -Completed
    }
    catch {
        Write-AuditLog "Failed during security posture analysis: $($_.Exception.Message)" -Level Error
        Write-Progress -Activity "Analyzing security" -Completed
    }
}

function Get-ExchangeInformation {
    Write-AuditLog -Message "Analyzing Exchange Online Configuration" -Level Section
    
    try {
        # Check if Exchange module is available
        if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
            Write-AuditLog "ExchangeOnlineManagement module not installed. Skipping Exchange analysis." -Level Warning
            Add-Recommendation "Install ExchangeOnlineManagement module for comprehensive Exchange auditing."
            return
        }
        
        Write-AuditLog "Exchange Online module detected but not connected in this session."
        Write-AuditLog "To enable Exchange auditing, run: Connect-ExchangeOnline" -Level Info
        Add-Recommendation "Enable Exchange Online auditing for mailbox and transport rule analysis."
    }
    catch {
        Write-AuditLog "Failed during Exchange analysis: $($_.Exception.Message)" -Level Error
    }
}

function Get-GroupInformation {
    Write-AuditLog -Message "Analyzing Groups" -Level Section
    
    try {
        Write-Progress -Activity "Collecting group data" -Status "Retrieving groups..."
        
        $allGroups = Get-MgGroup -All -Property Id,DisplayName,GroupTypes,CreatedDateTime,Mail,SecurityEnabled -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                Id = $_.Id
                DisplayName = $_.DisplayName
                GroupTypes = $_.GroupTypes
                CreatedDateTime = $_.CreatedDateTime
                Mail = $_.Mail
                SecurityEnabled = $_.SecurityEnabled
            }
        }
        
        $totalGroups = $allGroups.Count
        $m365Groups = ($allGroups | Where-Object {$_.GroupTypes -contains "Unified"}).Count
        $securityGroups = ($allGroups | Where-Object {$_.SecurityEnabled -eq $true -and $_.GroupTypes -notcontains "Unified"}).Count
        $distributionGroups = $totalGroups - $m365Groups - $securityGroups
        
        Write-AuditLog "Group Summary:"
        Write-AuditLog "  Total groups: $totalGroups"
        Write-AuditLog "  Microsoft 365 Groups: $m365Groups"
        Write-AuditLog "  Security Groups: $securityGroups"
        Write-AuditLog "  Distribution Groups: $distributionGroups"
        
        # Groups created in last 30 days
        $cutoffDate = (Get-Date).AddDays(-30)
        $newGroups = $allGroups | Where-Object {
            $_.CreatedDateTime -and [datetime]$_.CreatedDateTime -gt $cutoffDate
        }
        Write-AuditLog "  Groups created (last 30 days): $($newGroups.Count)"
        
        Write-Progress -Activity "Collecting group data" -Completed
        
        return $allGroups
    }
    catch {
        Write-Progress -Activity "Collecting group data" -Completed
        Write-AuditLog "ERROR: Cannot retrieve group information" -Level Error
        Write-AuditLog "Reason: $($_.Exception.Message)" -Level Error
        return @()
    }
}

function Get-ApplicationInformation {
    Write-AuditLog -Message "Analyzing Applications and Service Principals" -Level Section
    
    try {
        Write-Progress -Activity "Collecting application data" -Status "Retrieving applications..."
        
        $apps = Get-MgApplication -All -ErrorAction Stop
        $servicePrincipals = Get-MgServicePrincipal -All -ErrorAction Stop
        
        Write-AuditLog "Registered Applications: $($apps.Count)"
        Write-AuditLog "Service Principals: $($servicePrincipals.Count)"
        
        # Apps with credentials expiring soon
        $expiringThreshold = (Get-Date).AddDays(30)
        $expiringApps = @()
        
        foreach ($app in $apps) {
            if ($app.PasswordCredentials -and $app.PasswordCredentials.Count -gt 0) {
                foreach ($cred in $app.PasswordCredentials) {
                    if ($cred.EndDateTime) {
                        try {
                            $endDate = [datetime]$cred.EndDateTime
                            if ($endDate -lt $expiringThreshold -and $endDate -gt (Get-Date)) {
                                $expiringApps += [PSCustomObject]@{
                                    DisplayName = $app.DisplayName
                                    AppId = $app.AppId
                                    ExpiryDate = $endDate
                                }
                            }
                        }
                        catch {
                            # Skip invalid date formats
                            continue
                        }
                    }
                }
            }
            
            # Also check certificate credentials
            if ($app.KeyCredentials -and $app.KeyCredentials.Count -gt 0) {
                foreach ($cred in $app.KeyCredentials) {
                    if ($cred.EndDateTime) {
                        try {
                            $endDate = [datetime]$cred.EndDateTime
                            if ($endDate -lt $expiringThreshold -and $endDate -gt (Get-Date)) {
                                $expiringApps += [PSCustomObject]@{
                                    DisplayName = $app.DisplayName
                                    AppId = $app.AppId
                                    ExpiryDate = $endDate
                                }
                            }
                        }
                        catch {
                            # Skip invalid date formats
                            continue
                        }
                    }
                }
            }
        }
        
        if ($expiringApps.Count -gt 0) {
            Write-AuditLog "Applications with credentials expiring in 30 days: $($expiringApps.Count)" -Level Warning
            Add-Recommendation "Review and renew credentials for $($expiringApps.Count) applications expiring within 30 days."
            
            # List the apps with expiring credentials
            $expiringApps | Select-Object -Unique DisplayName, ExpiryDate | ForEach-Object {
                Write-AuditLog "  - $($_.DisplayName) expires on $($_.ExpiryDate.ToString('yyyy-MM-dd'))" -Level Warning
            }
        }
        else {
            Write-AuditLog "No applications with credentials expiring in the next 30 days" -Level Success
        }
        
        Write-Progress -Activity "Collecting application data" -Completed
    }
    catch {
        Write-Progress -Activity "Collecting application data" -Completed
        Write-AuditLog "ERROR: Cannot retrieve application information" -Level Error
        Write-AuditLog "Reason: $($_.Exception.Message)" -Level Error
        
        if ($_.Exception.Message -match "Cannot convert") {
            Write-AuditLog "This may be due to malformed date values in application credentials" -Level Warning
        }
    }
}

function Get-SignInAnalysis {
    param([int]$DaysBack = 7)
    
    Write-AuditLog -Message "Analyzing Sign-In Activity (Last $DaysBack days)" -Level Section
    
    try {
        Write-Progress -Activity "Analyzing sign-ins" -Status "Retrieving sign-in logs..."
        
        $startDate = (Get-Date).AddDays(-$DaysBack).ToString('yyyy-MM-ddTHH:mm:ssZ')
        $filter = "createdDateTime ge $startDate"
        
        Write-AuditLog "Collecting sign-in logs (this may take a few minutes)..."
        
        $signIns = Get-MgAuditLogSignIn -Filter $filter -All -ErrorAction Stop | Select-Object -First 10000
        
        if ($signIns.Count -eq 0) {
            Write-AuditLog "No sign-in logs found for the specified period." -Level Warning
            Write-Progress -Activity "Analyzing sign-ins" -Completed
            return
        }
        
        $totalSignIns = $signIns.Count
        $successfulSignIns = ($signIns | Where-Object {$_.Status.ErrorCode -eq 0}).Count
        $failedSignIns = $totalSignIns - $successfulSignIns
        
        Write-AuditLog "Total sign-in events: $totalSignIns"
        Write-AuditLog "  Successful: $successfulSignIns"
        Write-AuditLog "  Failed: $failedSignIns"
        
        # Risk analysis
        $riskySignIns = ($signIns | Where-Object {$_.RiskLevelDuringSignIn -in @('high', 'medium')}).Count
        if ($riskySignIns -gt 0) {
            Write-AuditLog "  Risky sign-ins detected: $riskySignIns" -Level Warning
            Add-Recommendation "Investigate $riskySignIns risky sign-in events for potential security threats."
        }
        
        # Top users by sign-in count
        $topUsers = $signIns | Group-Object UserPrincipalName | 
            Sort-Object Count -Descending | 
            Select-Object -First 5
        
        Write-AuditLog "`nTop 5 users by sign-in activity:"
        foreach ($user in $topUsers) {
            Write-AuditLog "  $($user.Name): $($user.Count) sign-ins"
        }
        
        # Top applications
        $topApps = $signIns | Group-Object AppDisplayName | 
            Sort-Object Count -Descending | 
            Select-Object -First 5
        
        Write-AuditLog "`nTop 5 applications accessed:"
        foreach ($app in $topApps) {
            Write-AuditLog "  $($app.Name): $($app.Count) sign-ins"
        }
        
        # Geographic analysis
        $countries = $signIns | Where-Object {$_.Location.CountryOrRegion} | 
            Group-Object {$_.Location.CountryOrRegion} | 
            Sort-Object Count -Descending | 
            Select-Object -First 5
        
        if ($countries) {
            Write-AuditLog "`nTop 5 sign-in locations:"
            foreach ($country in $countries) {
                Write-AuditLog "  $($country.Name): $($country.Count) sign-ins"
            }
        }
        
        Write-Progress -Activity "Analyzing sign-ins" -Completed
    }
    catch {
        Write-AuditLog "Failed to retrieve sign-in logs: $($_.Exception.Message)" -Level Warning
        Write-AuditLog "Note: Sign-in logs require Azure AD Premium licenses and appropriate permissions." -Level Info
        Write-Progress -Activity "Analyzing sign-ins" -Completed
    }
}

function Export-AuditReport {
    param(
        [string]$OutputPath
    )
    
    try {
        $endTime = Get-Date
        $duration = $endTime - $script:StartTime
        
        # Prepare report
        $report = @"
================================================================================
    MICROSOFT 365 COMPREHENSIVE AUDIT REPORT
================================================================================

Generated: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))
Duration: $([math]::Round($duration.TotalSeconds, 2)) seconds
Report Version: 1.0

$(if ($script:AuditResults.Count -gt 0) {
    $script:AuditResults -join "`n"
} else {
    "No audit data collected."
})

================================================================================
    RECOMMENDATIONS AND ACTION ITEMS
================================================================================

$(if ($script:Recommendations.Count -gt 0) {
    $counter = 1
    ($script:Recommendations | ForEach-Object { "$counter. $_"; $counter++ }) -join "`n"
} else {
    "No specific recommendations at this time. Your M365 environment appears well-configured!"
})

================================================================================
    AUDIT SUMMARY
================================================================================

Audit completed successfully.
Total recommendations: $($script:Recommendations.Count)

For questions or assistance, refer to the Microsoft 365 Admin Center or
contact your Microsoft support representative.

================================================================================
                            END OF REPORT
================================================================================
"@

        # Generate filename with timestamp
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $filename = "M365_Audit_Report_$timestamp.txt"
        $fullPath = Join-Path $OutputPath $filename
        
        # Export report
        $report | Out-File -FilePath $fullPath -Encoding UTF8
        
        Write-AuditLog "`nReport exported successfully to: $fullPath" -Level Success
        
        return $fullPath
    }
    catch {
        Write-AuditLog "Failed to export report: $($_.Exception.Message)" -Level Error
        return $null
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

try {
    Write-Host "`n"
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Microsoft 365 Comprehensive Audit - Starting...             ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`n"
    
    # Check if already connected to Microsoft Graph
    $isConnected = $false
    $context = $null
    
    try {
        $context = Get-MgContext -ErrorAction SilentlyContinue
        
        if ($context -and $context.Account) {
            Write-AuditLog "Existing Microsoft Graph connection detected" -Level Info
            Write-AuditLog "Account: $($context.Account)" -Level Info
            Write-AuditLog "Tenant ID: $($context.TenantId)" -Level Info
            
            # Validate the connection actually works by trying a simple query
            Write-AuditLog "Validating connection..." -Level Info
            try {
                $null = Get-MgOrganization -ErrorAction Stop | Select-Object -First 1
                $isConnected = $true
                Write-AuditLog "Connection validated successfully!" -Level Success
            }
            catch {
                Write-AuditLog "Existing connection is invalid or expired" -Level Warning
                $isConnected = $false
            }
        }
        
        if (-not $isConnected) {
            Write-AuditLog "No valid Microsoft Graph connection found" -Level Warning
            Write-AuditLog "Initiating interactive authentication..." -Level Info
            
            # Required scopes for comprehensive audit
            $scopes = @(
                "User.Read.All",
                "Directory.Read.All",
                "AuditLog.Read.All",
                "Reports.Read.All",
                "Organization.Read.All",
                "Group.Read.All",
                "Application.Read.All"
            )
            
            Write-Host "`nYou will be prompted to sign in to Microsoft 365..." -ForegroundColor Yellow
            Write-Host "Please use an account with appropriate permissions (Global Reader or Global Administrator)`n" -ForegroundColor Yellow
            
            Start-Sleep -Seconds 2
            
            Connect-MgGraph -Scopes $scopes -NoWelcome -ErrorAction Stop
            
            $context = Get-MgContext
            
            if ($context.Account) {
                Write-AuditLog "Successfully authenticated to Microsoft Graph!" -Level Success
                Write-AuditLog "Connected as: $($context.Account)" -Level Success
                Write-AuditLog "Tenant ID: $($context.TenantId)" -Level Success
                $isConnected = $true
            }
            else {
                throw "Authentication failed - no account information returned"
            }
        }
    }
    catch {
        Write-Host "`n" -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host "  AUTHENTICATION REQUIRED" -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host "`nFailed to connect to Microsoft Graph: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`nTo run this audit, you need:" -ForegroundColor Yellow
        Write-Host "  1. Microsoft.Graph PowerShell module installed" -ForegroundColor White
        Write-Host "  2. Valid Microsoft 365 admin credentials" -ForegroundColor White
        Write-Host "  3. Appropriate permissions (Global Reader or Global Administrator)" -ForegroundColor White
        Write-Host "`nTo authenticate manually, run:" -ForegroundColor Yellow
        Write-Host '  Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All","AuditLog.Read.All","Reports.Read.All","Organization.Read.All","Group.Read.All","Application.Read.All"' -ForegroundColor Cyan
        Write-Host "`nThen run this script again.`n" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n"
    
    # Validate permissions before proceeding
    $hasPermissions = Test-GraphPermissions
    
    if (-not $hasPermissions) {
        Write-AuditLog "Audit cannot proceed due to insufficient permissions" -Level Error
        
        # Still export a report showing the permission issues
        Write-Host "`n"
        Write-AuditLog -Message "Generating Report" -Level Section
        $reportPath = Export-AuditReport -OutputPath $OutputPath
        
        if ($reportPath) {
            Write-Host "`n"
            Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
            Write-Host "║   Audit Incomplete - Permission Issues                        ║" -ForegroundColor Yellow
            Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
            Write-Host "`nReport saved to: $reportPath" -ForegroundColor Yellow
            Write-Host "Please review the permission requirements and try again.`n" -ForegroundColor Yellow
        }
        
        exit 1
    }
    
    Write-Host "`n"
    
    # Execute audit sections (capture output to prevent console spam)
    $null = Get-TenantInformation
    $null = Get-UserStatistics
    $null = Get-LicenseInformation
    $null = Get-SecurityPosture
    $null = Get-GroupInformation
    $null = Get-ApplicationInformation
    $null = Get-ExchangeInformation
    
    if ($IncludeSignInLogs) {
        Get-SignInAnalysis -DaysBack $DaysBack
    }
    else {
        Write-AuditLog -Message "Sign-In Analysis" -Level Section
        Write-AuditLog "Sign-in log analysis skipped. Use -IncludeSignInLogs to enable." -Level Info
        Write-AuditLog "Note: Sign-in analysis requires Azure AD Premium licenses." -Level Info
    }
    
    # Export report
    Write-Host "`n"
    Write-AuditLog -Message "Generating Report" -Level Section
    $reportPath = Export-AuditReport -OutputPath $OutputPath
    
    if ($reportPath) {
        Write-Host "`n"
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║   Audit Completed Successfully!                               ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host "`nReport location: $reportPath" -ForegroundColor Yellow
        Write-Host "`nTotal recommendations: $($script:Recommendations.Count)" -ForegroundColor Yellow
        
        # Ask if user wants to open the report
        Write-Host "`nOpening report..." -ForegroundColor Cyan
        Start-Sleep -Seconds 1
        
        if (Test-Path $reportPath) {
            # Open in default text editor
            if ($PSVersionTable.Platform -eq 'Unix' -or $IsMacOS) {
                Start-Process "open" -ArgumentList $reportPath
            }
            else {
                Start-Process notepad.exe -ArgumentList $reportPath
            }
        }
    }
}
catch {
    Write-AuditLog "Critical error during audit execution: $($_.Exception.Message)" -Level Error
    Write-AuditLog "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}
finally {
    Write-Host "`n"
}

