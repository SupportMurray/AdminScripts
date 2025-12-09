<#
.SYNOPSIS
    Disconnects from Microsoft 365 services

.DESCRIPTION
    Helper script to disconnect from all Microsoft 365 services.

.EXAMPLE
    .\Disconnect-M365Services.ps1
    Disconnects from all Microsoft 365 services

.NOTES
    Author: Master Agent
    Date: 2024-01-01
    Version: 1.0
#>

[CmdletBinding()]
param()

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

Write-Log "=== Disconnecting from Microsoft 365 Services ===" -Level Info

# Disconnect from Microsoft Graph
try {
    Disconnect-MgGraph -ErrorAction Stop
    Write-Log "✓ Disconnected from Microsoft Graph" -Level Success
}
catch {
    Write-Log "Microsoft Graph: Not connected or already disconnected" -Level Info
}

# Disconnect from Exchange Online
try {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction Stop
    Write-Log "✓ Disconnected from Exchange Online" -Level Success
}
catch {
    Write-Log "Exchange Online: Not connected or already disconnected" -Level Info
}

# Disconnect from Microsoft Teams
try {
    Disconnect-MicrosoftTeams -ErrorAction Stop
    Write-Log "✓ Disconnected from Microsoft Teams" -Level Success
}
catch {
    Write-Log "Microsoft Teams: Not connected or already disconnected" -Level Info
}

# Disconnect from SharePoint Online
try {
    Disconnect-PnPOnline -ErrorAction Stop
    Write-Log "✓ Disconnected from SharePoint Online" -Level Success
}
catch {
    Write-Log "SharePoint Online: Not connected or already disconnected" -Level Info
}

Write-Log "`n=== Disconnection Complete ===" -Level Success

