<#
.SYNOPSIS
    Initializes Microsoft 365 session with proper authentication for script testing

.DESCRIPTION
    Helper script for agents to authenticate to Microsoft 365 services before testing scripts.
    Handles authentication, verifies connection, and provides feedback.
    
.PARAMETER Services
    Services to connect to: Graph, Exchange, Teams, SharePoint, All

.PARAMETER Scopes
    Custom Microsoft Graph scopes (optional, uses comprehensive defaults)

.PARAMETER Silent
    Suppress welcome messages and use minimal output

.EXAMPLE
    .\Initialize-M365Session.ps1
    Connects to Microsoft Graph with default comprehensive scopes

.EXAMPLE
    .\Initialize-M365Session.ps1 -Services All
    Connects to all Microsoft 365 services

.EXAMPLE
    .\Initialize-M365Session.ps1 -Scopes "User.Read.All","Group.Read.All"
    Connects with custom scopes

.NOTES
    Author: Master Agent
    Date: 2024-12-02
    Version: 1.0
    Purpose: Ensure agents can authenticate for script testing
#>

[CmdletBinding()]
param(
    [ValidateSet('Graph', 'Exchange', 'Teams', 'SharePoint', 'All')]
    [string[]]$Services = @('Graph'),
    
    [string[]]$Scopes = @(),
    
    [switch]$Silent
)

#region Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    if ($Silent -and $Level -ne 'Error') { return }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Error' { Write-Host $logMessage -ForegroundColor Red }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

#endregion

#region Main Script

if (-not $Silent) {
    Write-Log "=== Initializing Microsoft 365 Session ===" -Level Info
}

# Expand 'All' to all services
if ($Services -contains 'All') {
    $Services = @('Graph', 'Exchange', 'Teams', 'SharePoint')
}

# Define default comprehensive scopes if not provided
if ($Scopes.Count -eq 0) {
    $Scopes = @(
        # User and Group Management
        "User.ReadWrite.All",
        "Group.ReadWrite.All",
        
        # Directory and Identity
        "Directory.Read.All",
        "Directory.ReadWrite.All",
        
        # Audit and Reports
        "AuditLog.Read.All",
        "Reports.Read.All",
        
        # Organization
        "Organization.Read.All",
        
        # Security
        "SecurityEvents.Read.All",
        "SecurityEvents.ReadWrite.All",
        "IdentityRiskEvent.Read.All",
        
        # Policy
        "Policy.Read.All",
        "Policy.ReadWrite.ConditionalAccess",
        
        # Application
        "Application.Read.All",
        
        # Device
        "Device.Read.All",
        
        # Mail
        "Mail.Read",
        
        # Sites (SharePoint)
        "Sites.Read.All"
    )
}

$connectionStatus = @{
    Graph = $false
    Exchange = $false
    Teams = $false
    SharePoint = $false
}

# Connect to Microsoft Graph
if ($Services -contains 'Graph') {
    Write-Log "Connecting to Microsoft Graph..." -Level Info
    Write-Log "  Requesting scopes: $($Scopes.Count) permissions" -Level Info
    
    try {
        # Check if already connected
        $existingContext = Get-MgContext -ErrorAction SilentlyContinue
        
        if ($existingContext -and $existingContext.Account) {
            Write-Log "  Already connected as: $($existingContext.Account)" -Level Info
            
            # Check if we have required scopes
            $hasAllScopes = $true
            foreach ($scope in $Scopes) {
                if ($existingContext.Scopes -notcontains $scope) {
                    $hasAllScopes = $false
                    break
                }
            }
            
            if (-not $hasAllScopes) {
                Write-Log "  Reconnecting with required scopes..." -Level Warning
                Disconnect-MgGraph -ErrorAction SilentlyContinue
                Connect-MgGraph -Scopes $Scopes -NoWelcome -ErrorAction Stop
            }
        }
        else {
            Connect-MgGraph -Scopes $Scopes -NoWelcome -ErrorAction Stop
        }
        
        $context = Get-MgContext
        $connectionStatus.Graph = $true
        
        Write-Log "✓ Connected to Microsoft Graph" -Level Success
        Write-Log "  Account: $($context.Account)" -Level Info
        Write-Log "  Tenant: $($context.TenantId)" -Level Info
        
        # Test connection
        try {
            $testUser = Get-MgUser -Top 1 -ErrorAction Stop
            Write-Log "  Connection verified (able to query users)" -Level Success
        }
        catch {
            Write-Log "  Warning: Connected but unable to query users. Check permissions." -Level Warning
        }
    }
    catch {
        Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level Error
        $connectionStatus.Graph = $false
    }
}

# Connect to Exchange Online
if ($Services -contains 'Exchange') {
    Write-Log "`nConnecting to Exchange Online..." -Level Info
    
    try {
        # Check if already connected
        $existingSession = Get-PSSession | Where-Object {
            $_.ConfigurationName -eq 'Microsoft.Exchange' -and 
            $_.State -eq 'Opened'
        }
        
        if ($existingSession) {
            Write-Log "  Already connected to Exchange Online" -Level Info
        }
        else {
            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
        }
        
        # Test connection
        $org = Get-OrganizationConfig -ErrorAction Stop
        $connectionStatus.Exchange = $true
        
        Write-Log "✓ Connected to Exchange Online" -Level Success
        Write-Log "  Organization: $($org.Name)" -Level Info
    }
    catch {
        Write-Log "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level Error
        $connectionStatus.Exchange = $false
    }
}

# Connect to Microsoft Teams
if ($Services -contains 'Teams') {
    Write-Log "`nConnecting to Microsoft Teams..." -Level Info
    
    try {
        # Check if already connected
        try {
            $tenant = Get-CsTenant -ErrorAction Stop
            Write-Log "  Already connected to Microsoft Teams" -Level Info
        }
        catch {
            Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
            $tenant = Get-CsTenant -ErrorAction Stop
        }
        
        $connectionStatus.Teams = $true
        Write-Log "✓ Connected to Microsoft Teams" -Level Success
        Write-Log "  Tenant ID: $($tenant.TenantId)" -Level Info
    }
    catch {
        Write-Log "Failed to connect to Microsoft Teams: $($_.Exception.Message)" -Level Error
        $connectionStatus.Teams = $false
    }
}

# Connect to SharePoint Online
if ($Services -contains 'SharePoint') {
    Write-Log "`nConnecting to SharePoint Online..." -Level Info
    
    # Check for configuration
    if (Test-Path "$PSScriptRoot/.env.ps1") {
        . "$PSScriptRoot/.env.ps1"
        if ($Global:M365Config -and $Global:M365Config.SharePointAdminUrl) {
            try {
                Connect-PnPOnline -Url $Global:M365Config.SharePointAdminUrl -Interactive -ErrorAction Stop
                $connectionStatus.SharePoint = $true
                Write-Log "✓ Connected to SharePoint Online" -Level Success
            }
            catch {
                Write-Log "Failed to connect to SharePoint: $($_.Exception.Message)" -Level Error
                $connectionStatus.SharePoint = $false
            }
        }
        else {
            Write-Log "SharePoint Admin URL not configured in .env.ps1" -Level Warning
            Write-Log "  Add: SharePointAdminUrl = 'https://yourtenant-admin.sharepoint.com'" -Level Info
        }
    }
    else {
        Write-Log "SharePoint requires .env.ps1 configuration. See .env.ps1.example" -Level Warning
    }
}

# Summary
Write-Log "`n=== Connection Summary ===" -Level Info
$successCount = ($connectionStatus.Values | Where-Object {$_ -eq $true}).Count
$attemptedCount = $Services.Count

Write-Log "Successfully connected: $successCount of $attemptedCount services" -Level $(if ($successCount -eq $attemptedCount) { 'Success' } else { 'Warning' })

foreach ($service in $Services) {
    if ($connectionStatus[$service]) {
        Write-Log "  ✓ $service" -Level Success
    }
    else {
        Write-Log "  ✗ $service" -Level Error
    }
}

if (-not $Silent) {
    Write-Log "`n=== Ready for Testing ===" -Level Success
    Write-Log "You can now test your scripts with Microsoft 365 access" -Level Info
    Write-Log "Use Disconnect-M365Services.ps1 when done" -Level Info
}

# Return connection status for scripting
return $connectionStatus

#endregion

