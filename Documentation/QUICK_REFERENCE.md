# Quick Reference Guide

## For Users Requesting Scripts

### Step 1: Create Prompt
1. Open `Agents/PROMPT_TEMPLATES.md`
2. Copy template for your admin role
3. Fill in TASK and REQUIREMENTS
4. Submit to specialized agent

### Step 2: Request Review
```
Master Agent, please review:
Script: Scripts/[Role]/[ScriptName].ps1
Purpose: [Brief description]
```

### Step 3: Test Approved Script
- Run with `-WhatIf` first
- Test in safe environment
- Verify results

---

## For Specialized Agents

### Before Creating Script
- ✅ Read `Agents/AGENT_CONTEXT.md`
- ✅ Review `PROJECT_STRUCTURE.md`
- ✅ Understand `SAFETY_CHECKLIST.md`

### Script Requirements
- ✅ No mock code or placeholders
- ✅ Complete error handling
- ✅ `-WhatIf` support
- ✅ Comment-based help
- ✅ Proper logging
- ✅ Security best practices

### Self-Review Checklist
- [ ] Follows all standards
- [ ] No placeholders
- [ ] Error handling complete
- [ ] Documentation complete
- [ ] Ready for review

---

## For Master Agent

### Review Process
1. Read script thoroughly
2. Use `SAFETY_CHECKLIST.md`
3. Check for:
   - Mock code/placeholders
   - Safety issues
   - Security vulnerabilities
   - Code quality
4. Provide feedback

### Project Organization
1. Run `Validate-ProjectStructure.ps1`
2. Check for misplaced files
3. Verify directory structure
4. Clean up temporary files
5. Organize as needed

### Review Status
- **APPROVED**: Ready for testing
- **NEEDS REVISION**: Fix issues and resubmit
- **REJECTED**: Critical issues, start over

### Feedback Format
```
## Review Status: [STATUS]

### Safety Issues
- [List issues]

### Security Issues
- [List issues]

### Code Quality Issues
- [List issues]

### Recommendations
- [Suggestions]
```

---

## Common Admin Roles

| Role | Module | Common Tasks |
|------|--------|--------------|
| User Admin | Microsoft.Graph | Users, licenses, groups |
| Exchange Admin | ExchangeOnlineManagement | Mailboxes, DLs, mail flow |
| SharePoint Admin | PnP.PowerShell | Sites, permissions, OneDrive |
| Teams Admin | MicrosoftTeams | Teams, channels, policies |
| Security Admin | Microsoft.Graph | CA policies, MFA, threats |
| License Admin | Microsoft.Graph | License assignment, reporting |
| Compliance Admin | ExchangeOnlineManagement | Retention, DLP, eDiscovery |
| Global Admin | Multiple | Tenant-wide operations |

---

## Safety Checklist Quick Reference

### Must Have
- ✅ `-WhatIf` for modifications
- ✅ Error handling (try-catch)
- ✅ Logging
- ✅ Input validation
- ✅ No hardcoded credentials

### Must Not Have
- ❌ Mock code or placeholders
- ❌ Destructive ops without safeguards
- ❌ Hardcoded secrets
- ❌ Silent failures
- ❌ Missing documentation

---

## Organization Checklist

### Directory Structure
- [ ] All scripts in correct role directories
- [ ] No files in root (except documentation)
- [ ] Review directories organized
- [ ] Test data properly organized
- [ ] No temporary files
- [ ] No duplicate files

### File Naming
- [ ] Scripts: `[Action]-[Object]-[Description].ps1`
- [ ] Documentation: `[Topic]-[Description].md`
- [ ] Test data: `Test_[ScriptName]_[Purpose].[ext]`

### Maintenance
- [ ] Run `Validate-ProjectStructure.ps1` weekly
- [ ] Clean up temporary files
- [ ] Archive old test results
- [ ] Organize review documents

---

## Script Header Template

```powershell
<#
.SYNOPSIS
    Brief description

.DESCRIPTION
    Detailed description

.PARAMETER ParamName
    Parameter description

.EXAMPLE
    .\Script-Name.ps1 -ParamName "Value"

.NOTES
    Author: [Agent Name]
    Date: [YYYY-MM-DD]
    Version: 1.0
    Requires: [Modules and permissions]
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$ParamName
)
```

---

## Error Handling Pattern

```powershell
try {
    if ($PSCmdlet.ShouldProcess($target, "Operation")) {
        # Perform operation
    }
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}
finally {
    # Cleanup
}
```

---

## Connection Pattern

```powershell
try {
    Connect-MgGraph -Scopes "User.ReadWrite.All"
    # Script logic
}
catch {
    Write-Error "Connection failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}
```

---

## File Locations

| Item | Location |
|------|----------|
| Scripts | `Scripts/[Role]/` |
| Reviews | `Reviews/[Status]/` |
| Documentation | `Documentation/` |
| Tests | `Tests/` |

---

## Key Documents

1. **README.md** - Overview and quick start
2. **MASTER_AGENT.md** - Review system
3. **Agents/AGENT_CONTEXT.md** - Standards and patterns
4. **Agents/PROMPT_TEMPLATES.md** - Role templates
5. **SAFETY_CHECKLIST.md** - Review checklist
6. **PROJECT_STRUCTURE.md** - Organization
7. **PROJECT_ORGANIZATION.md** - Maintenance
8. **WORKFLOW.md** - Complete process

---

## Emergency Contacts

- **Review Questions**: Check `MASTER_AGENT.md`
- **Development Questions**: Check `Agents/AGENT_CONTEXT.md`
- **Process Questions**: Check `WORKFLOW.md`
- **Safety Questions**: Check `SAFETY_CHECKLIST.md`
- **Organization Questions**: Check `PROJECT_ORGANIZATION.md`

---

## Common Issues

### Issue: Script has placeholders
**Solution**: Reject and request complete implementation

### Issue: Missing -WhatIf
**Solution**: Request revision to add -WhatIf support

### Issue: Hardcoded credentials
**Solution**: Reject and require secure authentication

### Issue: No error handling
**Solution**: Request revision to add try-catch blocks

### Issue: Missing documentation
**Solution**: Request revision to add comment-based help

### Issue: File in wrong directory
**Solution**: Move to correct location per PROJECT_ORGANIZATION.md

### Issue: Temporary files
**Solution**: Delete or archive per maintenance schedule

---

**Remember**: Safety and security first. All scripts must be reviewed before testing. Keep project organized and clean.
