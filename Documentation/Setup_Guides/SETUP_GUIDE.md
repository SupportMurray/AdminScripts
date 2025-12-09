# Microsoft 365 PowerShell Setup Guide

## Overview
This guide will help you install and configure all necessary PowerShell modules to connect to Microsoft 365 services.

## Prerequisites

### PowerShell Version
- **Minimum**: PowerShell 5.1 (Windows)
- **Recommended**: PowerShell 7.x (cross-platform)
- Check version: `$PSVersionTable.PSVersion`

### Operating System
- **Windows**: PowerShell 5.1+ (built-in) or PowerShell 7+
- **macOS**: PowerShell 7+ (install via Homebrew)
- **Linux**: PowerShell 7+ (install via package manager)

### Administrator Permissions
- Install on Windows: Run PowerShell as Administrator
- Install on macOS/Linux: Use sudo if needed

## Installation Steps

### Step 1: Install PowerShell 7 (Recommended)

#### macOS (using Homebrew)
```bash
brew install --cask powershell
```

#### Windows
```powershell
# Using winget
winget install Microsoft.PowerShell

# Or download from: https://github.com/PowerShell/PowerShell/releases
```

#### Linux (Ubuntu/Debian)
```bash
# Install prerequisites
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common

# Download and install
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

### Step 2: Install Required Modules

Run the `Setup-M365Modules.ps1` script to install all required modules:

```powershell
./Setup-M365Modules.ps1
```

Or install manually:

#### Microsoft Graph PowerShell SDK
```powershell
# Install the main Microsoft Graph module
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Install specific sub-modules as needed
Install-Module Microsoft.Graph.Users -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Groups -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Reports -Scope CurrentUser -Force
```

#### Exchange Online Management
```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
```

#### Microsoft Teams
```powershell
Install-Module MicrosoftTeams -Scope CurrentUser -Force
```

#### SharePoint Online (PnP)
```powershell
Install-Module PnP.PowerShell -Scope CurrentUser -Force
```

#### Azure AD (Legacy - Optional)
```powershell
Install-Module AzureAD -Scope CurrentUser -Force
```

### Step 3: Verify Installation

Run the verification script:

```powershell
./Verify-M365Modules.ps1
```

Or verify manually:

```powershell
# Check installed modules
Get-Module -ListAvailable Microsoft.Graph*
Get-Module -ListAvailable ExchangeOnlineManagement
Get-Module -ListAvailable MicrosoftTeams
Get-Module -ListAvailable PnP.PowerShell
```

## Connecting to Microsoft 365

### Interactive Authentication (Recommended for Testing)

#### Connect to Microsoft Graph
```powershell
# Connect with specific scopes
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.Read.All"

# Verify connection
Get-MgContext
```

#### Connect to Exchange Online
```powershell
Connect-ExchangeOnline -UserPrincipalName admin@yourtenant.com -ShowProgress $true

# Verify connection
Get-OrganizationConfig | Select-Object Name, Identity
```

#### Connect to Microsoft Teams
```powershell
Connect-MicrosoftTeams

# Verify connection
Get-CsTeamsClientConfiguration
```

#### Connect to SharePoint Online
```powershell
# Replace with your tenant admin URL
Connect-PnPOnline -Url "https://yourtenant-admin.sharepoint.com" -Interactive

# Verify connection
Get-PnPConnection
```

### Certificate-Based Authentication (Recommended for Automation)

#### Create App Registration
1. Go to Azure Portal (portal.azure.com)
2. Navigate to Azure Active Directory > App registrations
3. Click "New registration"
4. Name: "M365-PowerShell-Automation"
5. Supported account types: Single tenant
6. Click "Register"

#### Configure API Permissions
Add the following API permissions based on your needs:

**Microsoft Graph:**
- User.ReadWrite.All
- Group.ReadWrite.All
- Directory.Read.All
- AuditLog.Read.All
- Reports.Read.All

**Exchange:**
- Exchange.ManageAsApp

Click "Grant admin consent"

#### Create Certificate
```powershell
# Run the certificate creation script
./Create-M365Certificate.ps1 -CertificateName "M365-PowerShell-Cert"

# Or create manually:
$cert = New-SelfSignedCertificate -Subject "CN=M365-PowerShell-Cert" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(2)

# Export certificate (upload to Azure AD)
Export-Certificate -Cert $cert -FilePath "M365-PowerShell-Cert.cer"
```

#### Upload Certificate to App Registration
1. Go to your App registration
2. Navigate to "Certificates & secrets"
3. Click "Upload certificate"
4. Upload the .cer file

#### Connect Using Certificate
```powershell
# Get certificate thumbprint
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like "*M365-PowerShell-Cert*"}
$thumbprint = $cert.Thumbprint

# Connect to Microsoft Graph
Connect-MgGraph -ClientId "YOUR-APP-ID" `
    -TenantId "YOUR-TENANT-ID" `
    -CertificateThumbprint $thumbprint

# Connect to Exchange Online
Connect-ExchangeOnline -CertificateThumbprint $thumbprint `
    -AppId "YOUR-APP-ID" `
    -Organization "yourtenant.onmicrosoft.com"
```

## Environment Configuration

### Option 1: Environment Variables
```powershell
# Set environment variables (Windows)
$env:M365_TENANT_ID = "your-tenant-id"
$env:M365_APP_ID = "your-app-id"
$env:M365_CERT_THUMBPRINT = "your-cert-thumbprint"

# Set environment variables (macOS/Linux)
export M365_TENANT_ID="your-tenant-id"
export M365_APP_ID="your-app-id"
export M365_CERT_THUMBPRINT="your-cert-thumbprint"
```

### Option 2: Configuration File
Create a `.env.ps1` file (DO NOT commit to git):

```powershell
# .env.ps1 - LOCAL CONFIGURATION ONLY
$Global:M365Config = @{
    TenantId = "your-tenant-id"
    AppId = "your-app-id"
    CertThumbprint = "your-cert-thumbprint"
    TenantDomain = "yourtenant.onmicrosoft.com"
    AdminUpn = "admin@yourtenant.com"
}
```

Load configuration:
```powershell
. ./.env.ps1
```

## Testing Your Connection

Use the provided connection test script:

```powershell
./Test-M365Connection.ps1
```

This will test connections to:
- Microsoft Graph
- Exchange Online
- Microsoft Teams
- SharePoint Online

## Troubleshooting

### Issue: "Execution of scripts is disabled"
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set execution policy (Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: "Module not found"
```powershell
# Check module paths
$env:PSModulePath -split ';'

# Import module manually
Import-Module ModuleName -Force
```

### Issue: "Authentication failed"
- Verify credentials
- Check MFA status
- Ensure proper permissions granted
- Check certificate validity and thumbprint

### Issue: "Insufficient privileges"
- Verify Azure AD role assignments
- Check API permissions in app registration
- Ensure admin consent granted

## Security Best Practices

1. **Never commit credentials or certificates to git**
   - Add `.env.ps1` to `.gitignore`
   - Add certificate files to `.gitignore`

2. **Use certificate-based auth for automation**
   - Store certificates in secure key vault
   - Rotate certificates regularly

3. **Apply principle of least privilege**
   - Only grant required permissions
   - Use scoped permissions

4. **Enable audit logging**
   - Monitor admin activities
   - Review sign-in logs

## Next Steps

1. Run `./Setup-M365Modules.ps1` to install modules
2. Run `./Test-M365Connection.ps1` to verify connectivity
3. Review `Documentation/GETTING_STARTED.md` for script development
4. Review `Agents/AGENT_CONTEXT.md` for development standards

## Resources

- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/)
- [Exchange Online PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/)
- [Teams PowerShell](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-overview)
- [SharePoint PnP PowerShell](https://pnp.github.io/powershell/)

