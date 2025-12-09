<#
.SYNOPSIS
    Installs all required Microsoft 365 PowerShell modules

.DESCRIPTION
    This script installs all PowerShell modules needed for Microsoft 365 administration
    including Microsoft Graph, Exchange Online, Teams, and SharePoint management.

.PARAMETER Scope
    Installation scope: CurrentUser or AllUsers (requires admin)

.PARAMETER Force
    Force reinstallation even if modules already exist

.EXAMPLE
    .\Setup-M365Modules.ps1
    Installs all modules for current user

.EXAMPLE
    .\Setup-M365Modules.ps1 -Force
    Reinstalls all modules even if they exist

.NOTES
    Author: Master Agent
    Date: 2024-01-01
    Version: 1.0
    Requires: PowerShell 5.1 or higher
#>

[CmdletBinding()]
param(
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser',
    
    [switch]$Force
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

function Install-M365Module {
    param(
        [string]$ModuleName,
        [string]$Description,
        [string]$MinVersion = $null
    )
    
    Write-Log "Checking $Description ($ModuleName)..." -Level Info
    
    try {
        $installedModule = Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
        
        if ($installedModule -and -not $Force) {
            Write-Log "  $ModuleName is already installed (Version: $($installedModule.Version))" -Level Success
            return $true
        }
        
        if ($Force -and $installedModule) {
            Write-Log "  Force reinstall requested, removing existing version..." -Level Warning
            Uninstall-Module -Name $ModuleName -AllVersions -Force -ErrorAction SilentlyContinue
        }
        
        Write-Log "  Installing $ModuleName..." -Level Info
        
        $installParams = @{
            Name = $ModuleName
            Scope = $Scope
            Force = $true
            AllowClobber = $true
        }
        
        if ($MinVersion) {
            $installParams['MinimumVersion'] = $MinVersion
        }
        
        Install-Module @installParams
        
        Write-Log "  Successfully installed $ModuleName" -Level Success
        return $true
    }
    catch {
        Write-Log "  Failed to install $ModuleName : $($_.Exception.Message)" -Level Error
        return $false
    }
}

#endregion

#region Main Script

Write-Log "`n=== Microsoft 365 PowerShell Module Setup ===" -Level Info
Write-Log "Installation Scope: $Scope" -Level Info
Write-Log "Force Reinstall: $Force`n" -Level Info

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-Log "PowerShell Version: $psVersion" -Level Info

if ($psVersion.Major -lt 5) {
    Write-Log "ERROR: PowerShell 5.1 or higher is required" -Level Error
    exit 1
}

# Set TLS 1.2 for PowerShell Gallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check if PowerShell Gallery is trusted
$galleryInfo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($galleryInfo.InstallationPolicy -ne 'Trusted') {
    Write-Log "Setting PSGallery as trusted repository..." -Level Info
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# Define modules to install
$modules = @(
    @{
        Name = 'Microsoft.Graph'
        Description = 'Microsoft Graph PowerShell SDK'
        Required = $true
    },
    @{
        Name = 'ExchangeOnlineManagement'
        Description = 'Exchange Online Management'
        Required = $true
    },
    @{
        Name = 'MicrosoftTeams'
        Description = 'Microsoft Teams Management'
        Required = $true
    },
    @{
        Name = 'PnP.PowerShell'
        Description = 'SharePoint PnP PowerShell'
        Required = $true
    },
    @{
        Name = 'AzureAD'
        Description = 'Azure AD Management (Legacy)'
        Required = $false
    }
)

$results = @{
    Success = @()
    Failed = @()
}

Write-Log "`n=== Installing Modules ===" -Level Info

foreach ($module in $modules) {
    $success = Install-M365Module -ModuleName $module.Name -Description $module.Description
    
    if ($success) {
        $results.Success += $module.Name
    }
    else {
        $results.Failed += $module.Name
        
        if ($module.Required) {
            Write-Log "CRITICAL: Required module $($module.Name) failed to install" -Level Error
        }
    }
    
    Write-Host ""
}

# Summary
Write-Log "`n=== Installation Summary ===" -Level Info
Write-Log "Successfully installed: $($results.Success.Count) modules" -Level Success
foreach ($moduleName in $results.Success) {
    Write-Log "  ✓ $moduleName" -Level Success
}

if ($results.Failed.Count -gt 0) {
    Write-Log "`nFailed to install: $($results.Failed.Count) modules" -Level Error
    foreach ($moduleName in $results.Failed) {
        Write-Log "  ✗ $moduleName" -Level Error
    }
}

Write-Log "`n=== Next Steps ===" -Level Info
Write-Log "1. Run ./Test-M365Connection.ps1 to verify connectivity" -Level Info
Write-Log "2. Review SETUP_GUIDE.md for authentication setup" -Level Info
Write-Log "3. Configure certificate-based auth for automation (optional)" -Level Info

# Exit code
if ($results.Failed.Count -gt 0) {
    exit 1
}
else {
    exit 0
}

#endregion

