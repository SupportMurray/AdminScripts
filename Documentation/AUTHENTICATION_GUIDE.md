# Authentication Guide for Agents

## Overview
This guide helps agents authenticate to Microsoft 365 services for script testing. All agents should follow these procedures to avoid authentication issues.

## Quick Start for Agents

### Before Testing Any Script

Always run the initialization script first:

```powershell
# Connect to Microsoft Graph (default, most common)
./Initialize-M365Session.ps1

# Connect to all services
./Initialize-M365Session.ps1 -Services All

# Connect with silent mode (minimal output)
./Initialize-M365Session.ps1 -Silent
```

### After Testing Scripts

Always disconnect when done:

```powershell
./Disconnect-M365Services.ps1
```

## Authentication Methods

### Method 1: Interactive Authentication (Recommended for Testing)

**Pros:**
- Easy to use
- Works for all services
- No setup required

**Process:**
1. Run initialization script
2. Browser opens for authentication
3. Sign in with admin credentials
4. Grant consent if prompted
5. Connection established

**Example:**
```powershell
# Initialize session
./Initialize-M365Session.ps1 -Services Graph

# Test your script
./Scripts/User_Administration/Get-UserReport.ps1

# Disconnect
./Disconnect-M365Services.ps1
```

### Method 2: Certificate-Based Authentication (For Automation)

**Pros:**
- No interactive login needed
- Suitable for scheduled scripts
- More secure for automation

**Setup Required:**
1. Create app registration in Azure AD
2. Generate certificate
3. Configure .env.ps1
4. Upload certificate to app

**See:** `SETUP_GUIDE.md` for detailed instructions

## Common Scopes and Permissions

### Default Scopes (Included in Initialize-M365Session.ps1)

The initialization script requests comprehensive permissions:

```powershell
# User and Group Management
User.ReadWrite.All
Group.ReadWrite.All

# Directory and Identity
Directory.Read.All
Directory.ReadWrite.All

# Audit and Reports
AuditLog.Read.All
Reports.Read.All

# Organization
Organization.Read.All

# Security
SecurityEvents.Read.All
IdentityRiskEvent.Read.All

# Policy
Policy.Read.All
Policy.ReadWrite.ConditionalAccess

# Application
Application.Read.All

# Device
Device.Read.All

# Sites (SharePoint)
Sites.Read.All
```

### Role-Specific Scopes

**User Administration:**
```powershell
User.ReadWrite.All
Group.ReadWrite.All
Directory.Read.All
```

**Exchange Administration:**
```powershell
# Uses Exchange Online PowerShell (no Graph scopes needed)
# Requires: Exchange Administrator role
```

**Security Administration:**
```powershell
SecurityEvents.Read.All
IdentityRiskEvent.Read.All
Policy.Read.All
AuditLog.Read.All
Directory.Read.All
```

**Audit Administration:**
```powershell
AuditLog.Read.All
Reports.Read.All
Directory.Read.All
User.Read.All
```

### Custom Scopes

If you need specific scopes for testing:

```powershell
# Connect with custom scopes
./Initialize-M365Session.ps1 -Scopes "User.Read.All","Group.Read.All"
```

## Troubleshooting Authentication Issues

### Issue: "Authentication needed. Please call Connect-MgGraph"

**Solution:**
```powershell
# Run initialization script
./Initialize-M365Session.ps1
```

### Issue: "Insufficient privileges to complete the operation"

**Causes:**
1. Missing required scopes
2. Account lacks admin permissions
3. Consent not granted

**Solution:**
```powershell
# 1. Reconnect with required scopes
Disconnect-MgGraph
./Initialize-M365Session.ps1 -Services Graph

# 2. Verify account has admin role
Get-MgContext | Select-Object Account

# 3. In Azure Portal:
#    - Go to Azure AD > Enterprise Applications
#    - Find "Microsoft Graph PowerShell"
#    - Grant admin consent for permissions
```

### Issue: "The term 'Get-MgUser' is not recognized"

**Causes:**
1. Module not imported
2. Session not established

**Solution:**
```powershell
# Import module manually
Import-Module Microsoft.Graph.Users

# Or reconnect
./Initialize-M365Session.ps1
```

### Issue: "Connection timeout or browser doesn't open"

**Solution:**
```powershell
# 1. Copy the URL from terminal
# 2. Paste in browser manually
# 3. Complete authentication
# 4. Return to terminal

# Alternative: Use device code flow
Connect-MgGraph -Scopes "User.Read.All" -UseDeviceAuthentication
```

### Issue: "Session expired during testing"

**Solution:**
```powershell
# Microsoft Graph tokens expire after 1 hour
# Reconnect:
./Initialize-M365Session.ps1

# For long testing sessions, consider:
# - Certificate-based auth (doesn't expire)
# - Refresh connection periodically
```

## Best Practices for Agents

### 1. Always Initialize Before Testing

```powershell
# At start of testing session
./Initialize-M365Session.ps1 -Services Graph

# Run your tests
./Scripts/Your_Script.ps1

# At end of session
./Disconnect-M365Services.ps1
```

### 2. Check Connection Status

```powershell
# Verify Microsoft Graph connection
Get-MgContext

# Verify Exchange Online connection
Get-OrganizationConfig

# Verify Teams connection
Get-CsTenant
```

### 3. Handle Authentication in Scripts

Include connection checks in your scripts:

```powershell
<#
.SYNOPSIS
    Your script description
    
.NOTES
    Prerequisites: Run ./Initialize-M365Session.ps1 before executing
#>

# Check if connected
try {
    $context = Get-MgContext
    if (-not $context) {
        Write-Error "Not connected to Microsoft Graph. Run ./Initialize-M365Session.ps1"
        exit 1
    }
}
catch {
    Write-Error "Not connected to Microsoft Graph. Run ./Initialize-M365Session.ps1"
    exit 1
}

# Your script logic here
```

### 4. Document Required Permissions

In your script header:

```powershell
<#
.NOTES
    Author: [Agent Name]
    Date: [Date]
    Version: 1.0
    Prerequisites:
        - Run ./Initialize-M365Session.ps1 before executing
        - Required Scopes: User.ReadWrite.All, Group.ReadWrite.All
        - Required Role: User Administrator
#>
```

### 5. Test Connection Before Operations

```powershell
# Test connection with simple query
try {
    $testUser = Get-MgUser -Top 1 -ErrorAction Stop
    Write-Host "✓ Connection verified" -ForegroundColor Green
}
catch {
    Write-Error "Connection test failed. Verify authentication."
    exit 1
}
```

## Testing Checklist

Before submitting a script for review:

- [ ] Run `./Initialize-M365Session.ps1` to authenticate
- [ ] Test script with `-WhatIf` parameter (if applicable)
- [ ] Verify script handles missing authentication gracefully
- [ ] Test with limited permissions to verify error handling
- [ ] Document required permissions in script header
- [ ] Include prerequisites in documentation
- [ ] Test disconnection and cleanup
- [ ] Run `./Disconnect-M365Services.ps1` when done

## Multi-Service Scripts

For scripts requiring multiple services:

```powershell
# Initialize all services
./Initialize-M365Session.ps1 -Services All

# Or initialize specific services
./Initialize-M365Session.ps1 -Services Graph,Exchange

# Your script can now use cmdlets from all connected services
Get-MgUser -Top 5
Get-Mailbox -ResultSize 5

# Disconnect all when done
./Disconnect-M365Services.ps1
```

## Environment Configuration (Optional)

For frequent testing, configure `.env.ps1`:

```powershell
# Copy example file
cp .env.ps1.example .env.ps1

# Edit .env.ps1 with your details
$Global:M365Config = @{
    TenantId = "your-tenant-id"
    TenantDomain = "yourtenant.onmicrosoft.com"
    AdminUpn = "admin@yourtenant.com"
    SharePointAdminUrl = "https://yourtenant-admin.sharepoint.com"
}
```

Then load in scripts:

```powershell
# Load configuration
if (Test-Path "./.env.ps1") {
    . ./.env.ps1
}
```

## Security Reminders

⚠️ **Important Security Notes:**

1. **Never commit credentials** to git
   - `.env.ps1` is in `.gitignore`
   - Don't save passwords in scripts
   - Use secure authentication methods

2. **Always disconnect** when done testing
   - Prevents unauthorized access
   - Clears cached credentials
   - Closes sessions properly

3. **Use least privilege**
   - Only request scopes you need
   - Test with minimal permissions first
   - Document all required permissions

4. **Protect tokens**
   - Tokens grant access to your tenant
   - Don't share terminal output with tokens
   - Clear session history after sensitive operations

## Additional Resources

- **Setup Guide:** `SETUP_GUIDE.md` - Complete authentication setup
- **Quick Start:** `QUICKSTART.md` - Quick connection examples
- **Agent Context:** `Agents/AGENT_CONTEXT.md` - Development standards
- **Workflow:** `WORKFLOW.md` - Complete development workflow

## Support

If you encounter authentication issues:

1. Review this guide
2. Check `SETUP_GUIDE.md` for detailed setup
3. Verify module installation with `./Setup-M365Modules.ps1`
4. Test connection with `./Test-M365Connection.ps1 -Interactive`
5. Check Azure AD role assignments and permissions

