# How to Run the M365 Comprehensive Audit

## Prerequisites

1. **Install Required PowerShell Modules** (if not already installed):
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

2. **Required Permissions:**
   - User.Read.All
   - Directory.Read.All
   - AuditLog.Read.All
   - Reports.Read.All
   - Organization.Read.All
   - Group.Read.All
   - Application.Read.All

## Steps to Run Full Audit

### Option 1: Interactive Authentication (Recommended for First Run)

```powershell
# Navigate to the script directory
cd /Users/eduardogarcia/Admin_Scripts

# Run the audit script (it will prompt for authentication)
pwsh ./Get-M365ComprehensiveAudit.ps1
```

The script will:
1. Prompt you to sign in to Microsoft 365
2. Request consent for required permissions
3. Collect comprehensive audit data
4. Generate a detailed report

### Option 2: Pre-Authenticate Then Run

```powershell
# Connect to Microsoft Graph first
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All","AuditLog.Read.All","Reports.Read.All","Organization.Read.All","Group.Read.All","Application.Read.All"

# Run the audit
cd /Users/eduardogarcia/Admin_Scripts
pwsh ./Get-M365ComprehensiveAudit.ps1
```

### Option 3: Include Sign-In Analysis (Requires Azure AD Premium)

```powershell
cd /Users/eduardogarcia/Admin_Scripts
pwsh ./Get-M365ComprehensiveAudit.ps1 -IncludeSignInLogs -DaysBack 30
```

### Option 4: Custom Output Location

```powershell
cd /Users/eduardogarcia/Admin_Scripts
pwsh ./Get-M365ComprehensiveAudit.ps1 -OutputPath "/Users/eduardogarcia/Reports"
```

## What the Audit Collects

### 1. Tenant Information
- Organization name and details
- Verified domains
- Tenant ID and configuration

### 2. User Analysis
- Total, enabled, disabled users
- Licensed vs unlicensed users
- Guest user statistics
- Inactive users (no sign-in 90+ days)
- New users created recently

### 3. License Usage
- All license SKUs and utilization
- Available vs assigned licenses
- License optimization recommendations

### 4. Security Posture
- MFA registration status and adoption rate
- Conditional Access policy inventory
- Privileged role assignments
- Security recommendations

### 5. Groups
- Microsoft 365 Groups
- Security Groups
- Distribution Groups
- Recent group creation activity

### 6. Applications
- Registered applications
- Service principals
- Expiring credentials alert

### 7. Sign-In Analysis (Optional)
- Successful vs failed sign-ins
- Risky sign-in detection
- Top users and applications
- Geographic sign-in distribution

### 8. Exchange Online (If connected)
- Mailbox statistics
- Transport rules
- Mail flow configuration

## Report Output

The script generates a text file with:
- **Timestamp**: When the audit was run
- **Comprehensive Data**: All collected metrics and statistics
- **Recommendations**: Actionable items based on findings
- **Executive Summary**: Quick overview of environment health

## Troubleshooting

### "Authentication needed" Errors
- **Cause**: Not connected to Microsoft Graph
- **Solution**: Run with interactive authentication or pre-authenticate

### "Insufficient permissions" Errors
- **Cause**: Your account lacks required permissions
- **Solution**: Use a Global Administrator or Global Reader account

### Sign-In Logs Not Available
- **Cause**: Requires Azure AD Premium P1/P2 licenses
- **Solution**: Run without `-IncludeSignInLogs` flag

### Module Not Found
- **Cause**: Microsoft.Graph module not installed
- **Solution**: Run `Install-Module Microsoft.Graph -Scope CurrentUser`

## Security Notes

- The script is **read-only** and makes no changes to your environment
- Audit logs are stored locally on your machine
- Consider protecting the report files as they contain sensitive information
- Review the generated report before sharing externally

## Scheduling Regular Audits

To run audits automatically (e.g., weekly):

### macOS/Linux (cron):
```bash
# Edit crontab
crontab -e

# Add line for weekly Monday 9 AM audit:
0 9 * * 1 /usr/local/bin/pwsh /Users/eduardogarcia/Admin_Scripts/Get-M365ComprehensiveAudit.ps1
```

### For Certificate-Based Authentication (Unattended)
See Microsoft documentation for setting up app-based authentication for scheduled audits.

## Support

For issues or questions:
1. Review error messages in the generated report
2. Check Microsoft Graph permissions in Azure AD
3. Verify PowerShell module versions are up to date
4. Consult the audit patterns in `/Agents/AGENT_CONTEXT.md`

