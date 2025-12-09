<#
.SYNOPSIS
    Tests connectivity to Microsoft 365 services

.DESCRIPTION
    This script tests connections to Microsoft Graph, Exchange Online, Teams, and SharePoint
    to verify that modules are installed and authentication works correctly.

.PARAMETER Interactive
    Use interactive authentication (prompts for credentials)

.PARAMETER TestAll
    Test all services (default: only tests Microsoft Graph)

.EXAMPLE
    .\Test-M365Connection.ps1 -Interactive
    Tests connection to Microsoft Graph with interactive login

.EXAMPLE
    .\Test-M365Connection.ps1 -Interactive -TestAll
    Tests connections to all Microsoft 365 services

.NOTES
    Author: Master Agent
    Date: 2024-01-01
    Version: 1.0
    Requires: PowerShell 5.1 or higher
#>

[CmdletBinding()]
param(
    [switch]$Interactive,
    [switch]$TestAll
)

#region Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Error' { Write-Host $logMessage -ForegroundColor Red }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Test-ModuleInstalled {
    param([string]$ModuleName)
    
    $module = Get-Module -ListAvailable -Name $ModuleName | Select-Object -First 1
    return ($null -ne $module)
}

function Test-MicrosoftGraphConnection {
    Write-Log "`n=== Testing Microsoft Graph ===" -Level Info
    
    if (-not (Test-ModuleInstalled -ModuleName "Microsoft.Graph.Authentication")) {
        Write-Log "Microsoft Graph module not installed" -Level Error
        return $false
    }
    
    try {
        if ($Interactive) {
            Write-Log "Connecting to Microsoft Graph (interactive)..." -Level Info
            Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome
        }
        else {
            Write-Log "Checking existing Microsoft Graph connection..." -Level Info
        }
        
        $context = Get-MgContext
        
        if ($context) {
            Write-Log "✓ Connected to Microsoft Graph" -Level Success
            Write-Log "  Tenant ID: $($context.TenantId)" -Level Info
            Write-Log "  Account: $($context.Account)" -Level Info
            Write-Log "  Scopes: $($context.Scopes -join ', ')" -Level Info
            return $true
        }
        else {
            Write-Log "Not connected to Microsoft Graph" -Level Warning
            Write-Log "  Run with -Interactive to connect" -Level Info
            return $false
        }
    }
    catch {
        Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level Error
        return $false
    }
    finally {
        if ($Interactive) {
            Disconnect-MgGraph -ErrorAction SilentlyContinue
        }
    }
}

function Test-ExchangeOnlineConnection {
    Write-Log "`n=== Testing Exchange Online ===" -Level Info
    
    if (-not (Test-ModuleInstalled -ModuleName "ExchangeOnlineManagement")) {
        Write-Log "Exchange Online module not installed" -Level Error
        return $false
    }
    
    try {
        if ($Interactive) {
            Write-Log "Connecting to Exchange Online (interactive)..." -Level Info
            Connect-ExchangeOnline -ShowBanner:$false
        }
        else {
            Write-Log "Checking existing Exchange Online connection..." -Level Info
        }
        
        $orgConfig = Get-OrganizationConfig -ErrorAction Stop
        
        if ($orgConfig) {
            Write-Log "✓ Connected to Exchange Online" -Level Success
            Write-Log "  Organization: $($orgConfig.Name)" -Level Info
            Write-Log "  Identity: $($orgConfig.Identity)" -Level Info
            return $true
        }
        else {
            Write-Log "Not connected to Exchange Online" -Level Warning
            return $false
        }
    }
    catch {
        Write-Log "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level Error
        Write-Log "  Run with -Interactive to connect" -Level Info
        return $false
    }
    finally {
        if ($Interactive) {
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}

function Test-TeamsConnection {
    Write-Log "`n=== Testing Microsoft Teams ===" -Level Info
    
    if (-not (Test-ModuleInstalled -ModuleName "MicrosoftTeams")) {
        Write-Log "Microsoft Teams module not installed" -Level Error
        return $false
    }
    
    try {
        if ($Interactive) {
            Write-Log "Connecting to Microsoft Teams (interactive)..." -Level Info
            Connect-MicrosoftTeams | Out-Null
        }
        else {
            Write-Log "Checking existing Teams connection..." -Level Info
        }
        
        $teamsConfig = Get-CsTenant -ErrorAction Stop
        
        if ($teamsConfig) {
            Write-Log "✓ Connected to Microsoft Teams" -Level Success
            Write-Log "  Tenant ID: $($teamsConfig.TenantId)" -Level Info
            return $true
        }
        else {
            Write-Log "Not connected to Microsoft Teams" -Level Warning
            return $false
        }
    }
    catch {
        Write-Log "Failed to connect to Microsoft Teams: $($_.Exception.Message)" -Level Error
        Write-Log "  Run with -Interactive to connect" -Level Info
        return $false
    }
    finally {
        if ($Interactive) {
            Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue
        }
    }
}

function Test-SharePointConnection {
    Write-Log "`n=== Testing SharePoint Online ===" -Level Info
    
    if (-not (Test-ModuleInstalled -ModuleName "PnP.PowerShell")) {
        Write-Log "SharePoint PnP module not installed" -Level Error
        return $false
    }
    
    Write-Log "SharePoint connection requires tenant URL" -Level Info
    Write-Log "  Use: Connect-PnPOnline -Url 'https://yourtenant-admin.sharepoint.com' -Interactive" -Level Info
    Write-Log "  Skipping SharePoint test (requires manual connection)" -Level Warning
    
    return $null
}

#endregion

#region Main Script

Write-Log "`n=== Microsoft 365 Connection Test ===" -Level Info
Write-Log "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level Info
Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" -Level Info
Write-Log "Interactive Mode: $Interactive" -Level Info
Write-Log "Test All Services: $TestAll`n" -Level Info

$results = @{
    MicrosoftGraph = $null
    ExchangeOnline = $null
    Teams = $null
    SharePoint = $null
}

# Always test Microsoft Graph
$results.MicrosoftGraph = Test-MicrosoftGraphConnection

if ($TestAll) {
    $results.ExchangeOnline = Test-ExchangeOnlineConnection
    $results.Teams = Test-TeamsConnection
    $results.SharePoint = Test-SharePointConnection
}

# Summary
Write-Log "`n=== Connection Test Summary ===" -Level Info

$testResults = @(
    @{ Service = "Microsoft Graph"; Status = $results.MicrosoftGraph }
)

if ($TestAll) {
    $testResults += @(
        @{ Service = "Exchange Online"; Status = $results.ExchangeOnline }
        @{ Service = "Microsoft Teams"; Status = $results.Teams }
        @{ Service = "SharePoint Online"; Status = $results.SharePoint }
    )
}

foreach ($result in $testResults) {
    if ($result.Status -eq $true) {
        Write-Log "✓ $($result.Service): Connected" -Level Success
    }
    elseif ($result.Status -eq $false) {
        Write-Log "✗ $($result.Service): Not connected" -Level Error
    }
    else {
        Write-Log "- $($result.Service): Skipped" -Level Warning
    }
}

Write-Log "`n=== Next Steps ===" -Level Info
if (-not $Interactive) {
    Write-Log "Run with -Interactive to test authentication" -Level Info
}
if (-not $TestAll) {
    Write-Log "Run with -TestAll to test all services" -Level Info
}
Write-Log "Review SETUP_GUIDE.md for configuration details" -Level Info

#endregion

