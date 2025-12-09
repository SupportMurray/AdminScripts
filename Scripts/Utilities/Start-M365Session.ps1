<#
.SYNOPSIS
    Starts an interactive Microsoft 365 PowerShell session

.DESCRIPTION
    Connects to Microsoft 365 services and starts an interactive PowerShell session
    with helpful information and quick commands available.

.PARAMETER Services
    Services to connect to: Graph, Exchange, Teams, SharePoint, All

.EXAMPLE
    .\Start-M365Session.ps1
    Starts session connected to Microsoft Graph

.EXAMPLE
    .\Start-M365Session.ps1 -Services All
    Starts session connected to all services

.NOTES
    Author: Master Agent
    Date: 2024-12-02
    Version: 1.0
#>

[CmdletBinding()]
param(
    [ValidateSet('Graph', 'Exchange', 'Teams', 'SharePoint', 'All')]
    [string[]]$Services = @('Graph')
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

function Show-WelcomeBanner {
    Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          Microsoft 365 PowerShell Session                      ║" -ForegroundColor Cyan
    Write-Host "║          Connected and Ready                                   ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

function Show-QuickCommands {
    Write-Host "`n═══ Quick Commands ═══" -ForegroundColor Yellow
    Write-Host "  Get-MgUser -All | Select DisplayName, UserPrincipalName" -ForegroundColor Gray
    Write-Host "  Get-MgGroup -All | Select DisplayName" -ForegroundColor Gray
    Write-Host "  Get-MgSubscribedSku | Select SkuPartNumber, ConsumedUnits" -ForegroundColor Gray
    Write-Host "  Get-MgAuditLogSignIn -Top 10 | Select UserPrincipalName, CreatedDateTime" -ForegroundColor Gray
    Write-Host "`n  Type 'exit' to disconnect and close session`n" -ForegroundColor Gray
}

#endregion

#region Main Script

Clear-Host
Write-Log "=== Starting Microsoft 365 Session ===" -Level Info

# Expand 'All' to all services
if ($Services -contains 'All') {
    $Services = @('Graph', 'Exchange', 'Teams')
}

# Connect to Microsoft Graph
if ($Services -contains 'Graph') {
    Write-Log "Connecting to Microsoft Graph..." -Level Info
    
    try {
        Connect-MgGraph -Scopes @(
            "User.ReadWrite.All",
            "Group.ReadWrite.All", 
            "Directory.Read.All",
            "AuditLog.Read.All",
            "Reports.Read.All",
            "Organization.Read.All"
        ) -NoWelcome
        
        $context = Get-MgContext
        Write-Log "✓ Connected to Microsoft Graph" -Level Success
        Write-Log "  Account: $($context.Account)" -Level Info
        Write-Log "  Tenant: $($context.TenantId)" -Level Info
        
        # Get organization info
        try {
            $org = Get-MgOrganization
            Write-Log "  Organization: $($org.DisplayName)" -Level Info
        }
        catch {
            Write-Log "  Could not retrieve organization details" -Level Warning
        }
    }
    catch {
        Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level Error
        exit 1
    }
}

# Connect to Exchange Online
if ($Services -contains 'Exchange') {
    Write-Log "`nConnecting to Exchange Online..." -Level Info
    
    try {
        Connect-ExchangeOnline -ShowBanner:$false
        Write-Log "✓ Connected to Exchange Online" -Level Success
    }
    catch {
        Write-Log "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level Error
    }
}

# Connect to Microsoft Teams
if ($Services -contains 'Teams') {
    Write-Log "`nConnecting to Microsoft Teams..." -Level Info
    
    try {
        Connect-MicrosoftTeams | Out-Null
        Write-Log "✓ Connected to Microsoft Teams" -Level Success
    }
    catch {
        Write-Log "Failed to connect to Microsoft Teams: $($_.Exception.Message)" -Level Error
    }
}

Show-WelcomeBanner
Show-QuickCommands

Write-Log "Session ready! Run Microsoft 365 commands now." -Level Success
Write-Log "Type 'exit' when done to disconnect and close session.`n" -Level Info

#endregion

