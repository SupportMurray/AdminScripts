# Quick Start - Connect to Microsoft 365

## ✅ Setup Complete!

All Microsoft 365 PowerShell modules are installed and ready to use:
- ✅ **Microsoft Graph** (v2.32.0) - User, Group, Directory, Reports, Audit
- ✅ **Exchange Online Management** (v3.8.0) - Mailboxes, Mail flow, Compliance
- ✅ **Microsoft Teams** (v7.5.0) - Teams, Channels, Policies
- ✅ **SharePoint PnP** (v3.1.0) - SharePoint, OneDrive, Sites

## Connect to Microsoft 365

### Option 1: Quick Connect (Interactive)

#### Connect to Microsoft Graph
```powershell
pwsh
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.Read.All", "AuditLog.Read.All", "Reports.Read.All"
```

This will:
1. Open your browser
2. Ask you to sign in with your Microsoft 365 admin account
3. Request consent for permissions
4. Establish connection

#### Verify Connection
```powershell
Get-MgContext
```

You should see:
- Your account
- Tenant ID
- Granted scopes

#### Test the Connection
```powershell
# Get all users
Get-MgUser -All | Select-Object DisplayName, UserPrincipalName

# Get your organization details
Get-MgOrganization
```

#### Disconnect When Done
```powershell
Disconnect-MgGraph
exit
```

### Option 2: Use Helper Scripts

#### Connect to All Services
```powershell
pwsh
./Connect-M365Services.ps1 -Services All -Interactive
```

This connects to:
- Microsoft Graph
- Exchange Online
- Microsoft Teams
- SharePoint Online

#### Disconnect from All Services
```powershell
./Disconnect-M365Services.ps1
exit
```

## Common Tasks

### Get User Information
```powershell
pwsh
Connect-MgGraph -Scopes "User.Read.All"

# Get all users
Get-MgUser -All | Select-Object DisplayName, UserPrincipalName, JobTitle

# Get specific user
Get-MgUser -UserId "user@yourdomain.com"

# Get user count
(Get-MgUser -All).Count

Disconnect-MgGraph
exit
```

### Get License Information
```powershell
pwsh
Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All"

# Get all licenses in tenant
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits

# Get user's licenses
Get-MgUserLicenseDetail -UserId "user@yourdomain.com"

Disconnect-MgGraph
exit
```

### Get Sign-In Logs (Audit)
```powershell
pwsh
Connect-MgGraph -Scopes "AuditLog.Read.All"

# Get recent sign-ins
Get-MgAuditLogSignIn -Top 10 | Select-Object UserPrincipalName, CreatedDateTime, Status

Disconnect-MgGraph
exit
```

## Next Steps

### 1. Review Documentation
- **SETUP_GUIDE.md** - Complete setup and authentication guide
- **Agents/AGENT_CONTEXT.md** - Development standards
- **SAFETY_CHECKLIST.md** - Safety and security requirements

### 2. Configure Certificate-Based Auth (Optional)
For automation and scheduled scripts:
- Create app registration in Azure AD
- Generate certificate
- Configure permissions
- See SETUP_GUIDE.md for details

### 3. Start Building Scripts
- Review example scripts in `Documentation/Examples/`
- Use agent prompts in `Agents/PROMPT_TEMPLATES.md`
- Follow standards in `Agents/AGENT_CONTEXT.md`

## Troubleshooting

### Issue: "Connect-MgGraph: Authentication needed"
**Solution**: Run `Connect-MgGraph -Scopes "User.Read.All"` and sign in

### Issue: "Insufficient privileges"
**Solution**: Sign in with an admin account that has the required permissions

### Issue: "Browser doesn't open"
**Solution**: Copy the URL from the terminal and paste into browser manually

### Issue: "Module not found"
**Solution**: Run `./Setup-M365Modules.ps1` again to reinstall modules

## Important Security Notes

⚠️ **Never commit credentials to git**
- `.env.ps1` is in `.gitignore`
- Don't save passwords in scripts
- Use certificate-based auth for automation

⚠️ **Always disconnect when done**
- Run `Disconnect-MgGraph` after your session
- Prevents unauthorized access

⚠️ **Use appropriate permissions**
- Only request the scopes you need
- Follow principle of least privilege

## Ready to Start!

You're all set up! Try connecting:

```powershell
pwsh
Connect-MgGraph -Scopes "User.Read.All"
Get-MgUser -Top 5 | Select-Object DisplayName, UserPrincipalName
Disconnect-MgGraph
exit
```

For more examples, see:
- **SETUP_GUIDE.md** - Detailed setup guide
- **Documentation/Examples/** - Example scripts
- **Agents/PROMPT_TEMPLATES.md** - Agent prompts for automation

