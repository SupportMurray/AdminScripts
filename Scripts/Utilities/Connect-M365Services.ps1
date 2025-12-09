<#
.SYNOPSIS
    Connects to Microsoft 365 services

.DESCRIPTION
    Helper script to connect to one or more Microsoft 365 services using
    interactive or certificate-based authentication.

.PARAMETER Services
    Services to connect to: Graph, Exchange, Teams, SharePoint, All

.PARAMETER Interactive
    Use interactive authentication (prompts for credentials)

.PARAMETER LoadConfig
    Load configuration from .env.ps1 file

.EXAMPLE
    .\Connect-M365Services.ps1 -Services Graph -Interactive
    Connects to Microsoft Graph with interactive authentication

.EXAMPLE
    .\Connect-M365Services.ps1 -Services All -LoadConfig
    Connects to all services using configuration from .env.ps1

.NOTES
    Author: Master Agent
    Date: 2024-01-01
    Version: 1.0
#>

[CmdletBinding()]
param(
    [ValidateSet('Graph', 'Exchange', 'Teams', 'SharePoint', 'All')]
    [string[]]$Services = @('Graph'),
    
    [switch]$Interactive,
    [switch]$LoadConfig
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

#endregion

#region Main Script

Write-Log "=== Connecting to Microsoft 365 Services ===" -Level Info

# Load configuration if requested
if ($LoadConfig) {
    $configPath = Join-Path $PSScriptRoot ".env.ps1"
    if (Test-Path $configPath) {
        Write-Log "Loading configuration from .env.ps1" -Level Info
        . $configPath
    }
    else {
        Write-Log ".env.ps1 not found. Copy .env.ps1.example and configure." -Level Warning
        $LoadConfig = $false
    }
}

# Expand 'All' to all services
if ($Services -contains 'All') {
    $Services = @('Graph', 'Exchange', 'Teams', 'SharePoint')
}

# Connect to Microsoft Graph
if ($Services -contains 'Graph') {
    Write-Log "`nConnecting to Microsoft Graph..." -Level Info
    
    try {
        if ($Interactive) {
            Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.Read.All", "AuditLog.Read.All", "Reports.Read.All" -NoWelcome
        }
        elseif ($LoadConfig -and $Global:M365Config) {
            Connect-MgGraph -ClientId $Global:M365Config.AppId `
                -TenantId $Global:M365Config.TenantId `
                -CertificateThumbprint $Global:M365Config.CertThumbprint -NoWelcome
        }
        else {
            Write-Log "No authentication method specified. Use -Interactive or -LoadConfig" -Level Error
            exit 1
        }
        
        $context = Get-MgContext
        Write-Log "✓ Connected to Microsoft Graph" -Level Success
        Write-Log "  Tenant: $($context.TenantId)" -Level Info
        Write-Log "  Account: $($context.Account)" -Level Info
    }
    catch {
        Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level Error
    }
}

# Connect to Exchange Online
if ($Services -contains 'Exchange') {
    Write-Log "`nConnecting to Exchange Online..." -Level Info
    
    try {
        if ($Interactive) {
            Connect-ExchangeOnline -ShowBanner:$false
        }
        elseif ($LoadConfig -and $Global:M365Config) {
            Connect-ExchangeOnline -CertificateThumbprint $Global:M365Config.CertThumbprint `
                -AppId $Global:M365Config.AppId `
                -Organization $Global:M365Config.ExchangeOrganization `
                -ShowBanner:$false
        }
        else {
            Write-Log "No authentication method specified. Use -Interactive or -LoadConfig" -Level Error
        }
        
        $orgConfig = Get-OrganizationConfig
        Write-Log "✓ Connected to Exchange Online" -Level Success
        Write-Log "  Organization: $($orgConfig.Name)" -Level Info
    }
    catch {
        Write-Log "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level Error
    }
}

# Connect to Microsoft Teams
if ($Services -contains 'Teams') {
    Write-Log "`nConnecting to Microsoft Teams..." -Level Info
    
    try {
        if ($Interactive) {
            Connect-MicrosoftTeams | Out-Null
        }
        elseif ($LoadConfig -and $Global:M365Config) {
            Connect-MicrosoftTeams -TenantId $Global:M365Config.TenantId `
                -CertificateThumbprint $Global:M365Config.CertThumbprint `
                -ApplicationId $Global:M365Config.AppId | Out-Null
        }
        else {
            Write-Log "No authentication method specified. Use -Interactive or -LoadConfig" -Level Error
        }
        
        $tenant = Get-CsTenant
        Write-Log "✓ Connected to Microsoft Teams" -Level Success
        Write-Log "  Tenant ID: $($tenant.TenantId)" -Level Info
    }
    catch {
        Write-Log "Failed to connect to Microsoft Teams: $($_.Exception.Message)" -Level Error
    }
}

# Connect to SharePoint Online
if ($Services -contains 'SharePoint') {
    Write-Log "`nConnecting to SharePoint Online..." -Level Info
    
    try {
        if ($LoadConfig -and $Global:M365Config -and $Global:M365Config.SharePointAdminUrl) {
            $url = $Global:M365Config.SharePointAdminUrl
        }
        else {
            Write-Log "SharePoint Admin URL required. Add to .env.ps1 or specify manually." -Level Warning
            Write-Host "Enter SharePoint Admin URL (e.g., https://yourtenant-admin.sharepoint.com): " -NoNewline
            $url = Read-Host
        }
        
        if ($Interactive) {
            Connect-PnPOnline -Url $url -Interactive
        }
        elseif ($LoadConfig -and $Global:M365Config) {
            Connect-PnPOnline -Url $url `
                -ClientId $Global:M365Config.AppId `
                -Tenant $Global:M365Config.TenantDomain `
                -Thumbprint $Global:M365Config.CertThumbprint
        }
        else {
            Write-Log "No authentication method specified. Use -Interactive or -LoadConfig" -Level Error
        }
        
        $connection = Get-PnPConnection
        Write-Log "✓ Connected to SharePoint Online" -Level Success
        Write-Log "  URL: $($connection.Url)" -Level Info
    }
    catch {
        Write-Log "Failed to connect to SharePoint Online: $($_.Exception.Message)" -Level Error
    }
}

Write-Log "`n=== Connection Complete ===" -Level Success
Write-Log "Use Disconnect-M365Services.ps1 to disconnect all services" -Level Info

#endregion

