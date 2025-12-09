# File Organization Rules for All Agents

**Last Updated:** December 2, 2025  
**Status:** ✅ Current and Enforced

---

## 🚨 CRITICAL RULES - READ FIRST

### Rule #1: Scripts Must Be in Role Directories

**ALL scripts MUST be placed in their correct role-specific directory.**

```
✅ CORRECT:
Scripts/User_Administration/Get-InactiveUsers.ps1
Scripts/Security_Administration/Get-SecurityReview.ps1
Scripts/Audit_Administration/Get-M365Audit.ps1

❌ WRONG:
Get-InactiveUsers.ps1                    (in root - NEVER do this)
Scripts/Get-InactiveUsers.ps1            (not in role folder)
Documentation/Get-InactiveUsers.ps1      (wrong directory)
```

### Rule #2: Test Results Go in Tests Directory

**ALL test output files MUST be placed in `Tests/Test_Results/`**

```
✅ CORRECT:
Tests/Test_Results/Audit_Report_20251202.txt
Tests/Test_Results/Security_Scan_Results.csv

❌ WRONG:
Audit_Report_20251202.txt                (in root)
Scripts/Audit_Administration/report.txt  (not in Tests)
```

### Rule #3: Documentation Goes in Documentation Directory

**ALL documentation files MUST be placed in `Documentation/` or subdirectories**

```
✅ CORRECT:
Documentation/User-Management-Guide.md
Documentation/Examples/Sample-Script.ps1
Documentation/Troubleshooting/Common-Issues.md

❌ WRONG:
User-Management-Guide.md                 (in root)
Scripts/User_Administration/Guide.md     (not in Documentation)
```

---

## 📁 Complete Directory Structure

### Root Directory (Keep Clean!)

**Only these files should be in root:**
- Core documentation (.md files)
- Utility scripts (Setup, Test, Connect, Disconnect, Initialize, Validate)
- NO script output files
- NO test results
- NO agent scripts

### Scripts Directory Structure

```
Scripts/
├── User_Administration/           # User management scripts
│   ├── Get-InactiveUsers.ps1
│   ├── Set-BulkUserLicenses.ps1
│   └── Export-UserReport.ps1
│
├── Exchange_Administration/       # Exchange/mailbox scripts
│   ├── Get-MailboxReport.ps1
│   └── Set-MailboxPermissions.ps1
│
├── SharePoint_Administration/     # SharePoint/OneDrive scripts
│   ├── Get-SiteInventory.ps1
│   └── Set-SharingPolicies.ps1
│
├── Teams_Administration/          # Teams scripts
│   ├── Get-TeamsUsage.ps1
│   └── New-TeamFromTemplate.ps1
│
├── Security_Administration/       # Security scripts
│   ├── Get-SecurityReview.ps1
│   └── Get-ConditionalAccessAudit.ps1
│
├── License_Administration/        # License management scripts
│   ├── Get-LicenseUsage.ps1
│   └── Set-BulkLicenseAssignment.ps1
│
├── Compliance_Administration/     # Compliance scripts
│   ├── Get-RetentionPolicies.ps1
│   └── Export-AuditLogs.ps1
│
├── Audit_Administration/          # Audit scripts
│   ├── Get-M365ComprehensiveAudit.ps1
│   └── Get-SecurityPosture.ps1
│
├── Intune_Administration/         # Intune/MDM scripts
│   ├── Get-DeviceInventory.ps1
│   └── Get-ComplianceReport.ps1
│
└── Global_Administration/         # Global admin scripts
    ├── Get-TenantConfig.ps1
    └── Export-TenantSettings.ps1
```

### Tests Directory Structure

```
Tests/
├── Test_Data/                     # Test input files (CSV, JSON, etc.)
│   ├── sample-users.csv
│   └── test-devices.json
│
└── Test_Results/                  # ALL test outputs go here
    ├── M365_Audit_Report_20251202_120104.txt
    ├── Security_Scan_20251202.csv
    └── Device_Inventory_20251202.json
```

### Documentation Directory Structure

```
Documentation/
├── AUTHENTICATION_GUIDE.md        # Authentication guide
├── GETTING_STARTED.md             # Getting started
├── QUICK_REFERENCE.md             # Quick reference
├── SECURITY_REVIEW_PROMPT.md      # Security prompts
├── INTUNE_MDM_PROMPTS.md          # Intune prompts
├── FILE_ORGANIZATION_RULES.md     # This file
│
├── Examples/                      # Example scripts and templates
│   └── SCRIPT_TEMPLATE.ps1
│
├── Patterns/                      # Code patterns (for future use)
│
└── Troubleshooting/               # Troubleshooting guides (for future use)
```

### Reviews Directory Structure

```
Reviews/
├── Approved/                      # Approved scripts (moved by Master Agent)
├── Needs_Revision/                # Scripts needing revision
└── Rejected/                      # Rejected scripts
```

---

## 🎯 Quick Reference by Agent Role

### User Administrator
- **Scripts:** `Scripts/User_Administration/`
- **Example:** `Scripts/User_Administration/Get-InactiveUsers.ps1`

### Exchange Administrator
- **Scripts:** `Scripts/Exchange_Administration/`
- **Example:** `Scripts/Exchange_Administration/Get-MailboxStats.ps1`

### SharePoint Administrator
- **Scripts:** `Scripts/SharePoint_Administration/`
- **Example:** `Scripts/SharePoint_Administration/Get-SiteUsage.ps1`

### Teams Administrator
- **Scripts:** `Scripts/Teams_Administration/`
- **Example:** `Scripts/Teams_Administration/Get-TeamsReport.ps1`

### Security Administrator
- **Scripts:** `Scripts/Security_Administration/`
- **Example:** `Scripts/Security_Administration/Get-SecurityReview.ps1`

### License Administrator
- **Scripts:** `Scripts/License_Administration/`
- **Example:** `Scripts/License_Administration/Get-LicenseReport.ps1`

### Compliance Administrator
- **Scripts:** `Scripts/Compliance_Administration/`
- **Example:** `Scripts/Compliance_Administration/Get-ComplianceAudit.ps1`

### Audit Administrator
- **Scripts:** `Scripts/Audit_Administration/`
- **Example:** `Scripts/Audit_Administration/Get-M365Audit.ps1`

### Intune/MDM Administrator
- **Scripts:** `Scripts/Intune_Administration/`
- **Example:** `Scripts/Intune_Administration/Get-DeviceCompliance.ps1`

### Global Administrator
- **Scripts:** `Scripts/Global_Administration/`
- **Example:** `Scripts/Global_Administration/Get-TenantReport.ps1`

---

## ✅ Checklist Before Creating Files

Before creating any file, ask yourself:

**For Scripts:**
- [ ] Am I placing this in `Scripts/[MyRole]/`?
- [ ] Is the filename following naming convention? (`[Action]-[Object]-[Description].ps1`)
- [ ] Am I working in a feature branch? (`agent/[role]/[script-name]`)

**For Test Results:**
- [ ] Am I placing output in `Tests/Test_Results/`?
- [ ] Is the filename descriptive with date?

**For Documentation:**
- [ ] Am I placing this in `Documentation/` or subdirectory?
- [ ] Is this file necessary or should it be in existing docs?

---

## 🚫 Common Mistakes to Avoid

### Mistake #1: Script in Root Directory
```
❌ WRONG:
/Users/eduardogarcia/Admin_Scripts/Get-UserReport.ps1

✅ CORRECT:
/Users/eduardogarcia/Admin_Scripts/Scripts/User_Administration/Get-UserReport.ps1
```

### Mistake #2: Test Results in Root
```
❌ WRONG:
/Users/eduardogarcia/Admin_Scripts/M365_Audit_Report.txt

✅ CORRECT:
/Users/eduardogarcia/Admin_Scripts/Tests/Test_Results/M365_Audit_Report.txt
```

### Mistake #3: Script in Wrong Role Directory
```
❌ WRONG:
Scripts/Security_Administration/Get-UserLicenses.ps1
(User license script in Security directory)

✅ CORRECT:
Scripts/License_Administration/Get-UserLicenses.ps1
(User license script in License directory)
```

### Mistake #4: Multiple Scripts in Root
```
❌ WRONG:
Get-Users.ps1
Set-Licenses.ps1
Audit-Security.ps1
(All in root directory)

✅ CORRECT:
Scripts/User_Administration/Get-Users.ps1
Scripts/License_Administration/Set-Licenses.ps1
Scripts/Security_Administration/Audit-Security.ps1
```

---

## 📝 Script Naming Convention

**Format:** `[Action]-[Object]-[OptionalDescription].ps1`

**Approved Actions (PowerShell Verbs):**
- `Get` - Retrieve information
- `Set` - Modify configuration
- `New` - Create new resource
- `Remove` - Delete resource
- `Export` - Export data
- `Import` - Import data
- `Test` - Test condition
- `Invoke` - Perform action
- `Start` - Start process
- `Stop` - Stop process

**Examples:**
- ✅ `Get-InactiveUsers.ps1`
- ✅ `Set-BulkUserLicenses.ps1`
- ✅ `New-DistributionGroup.ps1`
- ✅ `Remove-StaleDevices.ps1`
- ✅ `Export-SecurityReport.ps1`
- ✅ `Import-UsersFromCSV.ps1`
- ✅ `Test-ComplianceStatus.ps1`
- ✅ `Invoke-SecurityAudit.ps1`

**Bad Examples:**
- ❌ `users_script.ps1` (wrong format)
- ❌ `Script1.ps1` (not descriptive)
- ❌ `my-user-script.ps1` (wrong case)
- ❌ `GetUsers.ps1` (no hyphen)

---

## 🔍 How to Verify Your Organization

Run the validation script:

```powershell
./Validate-ProjectStructure.ps1
```

This will check:
- ✅ All required directories exist
- ✅ No scripts in root directory
- ✅ No agent files misplaced
- ✅ No temporary files
- ✅ Naming conventions followed

**Expected Output:**
```
✓ Project structure is valid!
```

---

## 📚 Related Documents

- **`AGENT_CONTEXT.md`** - Complete agent standards (includes file organization)
- **`PROJECT_STRUCTURE.md`** - Detailed structure documentation
- **`PROJECT_ORGANIZATION.md`** - Maintenance and organization guide
- **`WORKFLOW.md`** - Complete development workflow
- **`BRANCH_WORKFLOW.md`** - Git branching workflow

---

## ❓ Questions?

**Q: Where do I put my audit script?**  
A: `Scripts/Audit_Administration/`

**Q: Where do I put test output files?**  
A: `Tests/Test_Results/`

**Q: Can I create a folder for my scripts?**  
A: No, use the existing role-specific directories

**Q: What if my script fits multiple roles?**  
A: Choose the primary role. If truly cross-role, use `Global_Administration/`

**Q: Where do temporary files go?**  
A: Temporary files should be cleaned up. If needed for debugging, use `Tests/Test_Results/`

---

## ✅ Summary

1. **Scripts** → `Scripts/[YourRole]/[ScriptName].ps1`
2. **Test Results** → `Tests/Test_Results/[ReportName].txt`
3. **Documentation** → `Documentation/[DocName].md`
4. **Root** → Keep clean (only core docs and utilities)
5. **Validate** → Run `./Validate-ProjectStructure.ps1`

**When in doubt, check `AGENT_CONTEXT.md` or ask Master Agent!**

