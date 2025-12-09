# 🚀 Quick Start for Specialized Agents

## ⚡ Critical Information (READ THIS FIRST!)

### Where Do My Scripts Go?

```
╔═══════════════════════════════════════════════════════════════════╗
║  CRITICAL: Save scripts in the CORRECT directory!                ║
╚═══════════════════════════════════════════════════════════════════╝

Scripts/User_Administration/         ← User admin scripts HERE
Scripts/Exchange_Administration/     ← Exchange admin scripts HERE
Scripts/SharePoint_Administration/   ← SharePoint admin scripts HERE
Scripts/Teams_Administration/        ← Teams admin scripts HERE
Scripts/Security_Administration/     ← Security admin scripts HERE
Scripts/License_Administration/      ← License admin scripts HERE
Scripts/Compliance_Administration/   ← Compliance admin scripts HERE
Scripts/Audit_Administration/        ← Audit admin scripts HERE
Scripts/Intune_Administration/       ← Intune/MDM admin scripts HERE
Scripts/Global_Administration/       ← Global admin scripts HERE

Tests/Test_Results/                  ← ALL test outputs HERE

❌ NEVER save scripts in root directory!
❌ NEVER save scripts directly in Scripts/ (must be in role subfolder)
```

---

## 📋 Your 5-Minute Checklist

### Before Creating Any Script

- [ ] **Read** `AGENT_CONTEXT.md` - Contains ALL standards and rules
- [ ] **Read** `../Documentation/FILE_ORGANIZATION_RULES.md` - File placement rules
- [ ] **Identify** your role and correct directory
- [ ] **Create** feature branch: `agent/[role]/[script-name]`
- [ ] **Authenticate** for testing: `./Initialize-M365Session.ps1`

### While Creating Script

- [ ] **Save** script in `Scripts/[YourRole_Administration]/`
- [ ] **Name** script: `[Action]-[Object]-[Description].ps1`
- [ ] **Include** comment-based help
- [ ] **Add** error handling (try-catch-finally)
- [ ] **Support** `-WhatIf` for modifications
- [ ] **Add** logging
- [ ] **No** mock code or placeholders
- [ ] **No** hardcoded credentials

### After Creating Script

- [ ] **Test** with authentication
- [ ] **Save** test results to `Tests/Test_Results/`
- [ ] **Validate** with `./Validate-ProjectStructure.ps1`
- [ ] **Commit** to your branch
- [ ] **Disconnect** when done: `./Disconnect-M365Services.ps1`
- [ ] **Notify** user for Master Agent review

---

## 🎯 Script Naming Examples

### Good Examples ✅
```
Get-InactiveUsers.ps1
Set-BulkUserLicenses.ps1
Export-ComplianceReport.ps1
New-DistributionGroup.ps1
Remove-StaleDevices.ps1
Get-M365SecurityReview.ps1
Invoke-SecurityAudit.ps1
```

### Bad Examples ❌
```
users.ps1                    (not descriptive)
get_users.ps1                (wrong format - use hyphens)
Script1.ps1                  (not descriptive)
my-script.ps1                (wrong case - use PascalCase)
```

---

## 🔐 Authentication Quick Reference

### Before Testing
```powershell
# Connect to Microsoft 365
./Initialize-M365Session.ps1

# Or connect to all services
./Initialize-M365Session.ps1 -Services All
```

### After Testing
```powershell
# Disconnect from all services
./Disconnect-M365Services.ps1
```

### Verify Connection
```powershell
# Check Microsoft Graph connection
Get-MgContext

# Test with simple query
Get-MgUser -Top 1
```

---

## 📁 File Organization Quick Reference

| File Type | Location | Example |
|-----------|----------|---------|
| **Your Scripts** | `Scripts/[YourRole]/` | `Scripts/User_Administration/Get-Users.ps1` |
| **Test Results** | `Tests/Test_Results/` | `Tests/Test_Results/UserReport.txt` |
| **Documentation** | `Documentation/` | `Documentation/UserGuide.md` |

---

## ✅ Self-Review Checklist

Before submitting for Master Agent review:

### File Organization
- [ ] Script is in correct `Scripts/[Role]/` directory
- [ ] Test results are in `Tests/Test_Results/`
- [ ] No files in root directory
- [ ] Naming convention followed

### Code Quality
- [ ] No mock code or placeholders
- [ ] Complete error handling (try-catch-finally)
- [ ] Logging implemented
- [ ] Comment-based help included
- [ ] `-WhatIf` support for modifications

### Security
- [ ] No hardcoded credentials
- [ ] Secure authentication used
- [ ] No secrets in code or logs
- [ ] Proper permission requirements documented

### Testing
- [ ] Tested with authentication
- [ ] Tested with `-WhatIf`
- [ ] Error scenarios tested
- [ ] Test results saved properly

---

## 🚫 Common Mistakes - AVOID THESE!

### ❌ Mistake #1: Script in Root
```
Wrong: /Admin_Scripts/Get-Users.ps1
Right: /Admin_Scripts/Scripts/User_Administration/Get-Users.ps1
```

### ❌ Mistake #2: Test Results in Root
```
Wrong: /Admin_Scripts/Report.txt
Right: /Admin_Scripts/Tests/Test_Results/Report.txt
```

### ❌ Mistake #3: Wrong Role Directory
```
Wrong: Scripts/Security_Administration/Get-UserLicenses.ps1
Right: Scripts/License_Administration/Get-UserLicenses.ps1
```

### ❌ Mistake #4: No Authentication
```
Wrong: Run script without connecting
Right: ./Initialize-M365Session.ps1 THEN run script
```

### ❌ Mistake #5: Hardcoded Credentials
```
Wrong: $password = "MyPassword123"
Right: Use Connect-MgGraph for authentication
```

---

## 📖 Essential Reading Order

1. **This file** (QUICK_START_AGENTS.md) - You are here! ✓
2. **AGENT_CONTEXT.md** - Complete standards (30 min)
3. **FILE_ORGANIZATION_RULES.md** - File placement (10 min)
4. **AUTHENTICATION_GUIDE.md** - Auth setup (10 min)
5. **SAFETY_CHECKLIST.md** - Review criteria (15 min)

**Total Time: ~1 hour to be fully onboarded**

---

## 🎯 Quick Start Workflow

```
1. Read docs (you are here!)
2. Create branch: agent/[role]/[script-name]
3. Authenticate: ./Initialize-M365Session.ps1
4. Create script in: Scripts/[YourRole_Administration]/
5. Test thoroughly
6. Save results in: Tests/Test_Results/
7. Validate: ./Validate-ProjectStructure.ps1
8. Disconnect: ./Disconnect-M365Services.ps1
9. Commit and push
10. Notify user for review
```

---

## ✅ You're Ready When...

- ✅ You've read `AGENT_CONTEXT.md`
- ✅ You know where to save your scripts
- ✅ You know how to authenticate
- ✅ You understand safety requirements
- ✅ You know the submission process

---

## 🆘 Need Help?

| Question | Check This File |
|----------|----------------|
| Where do files go? | `../Documentation/FILE_ORGANIZATION_RULES.md` |
| How do I authenticate? | `../Documentation/AUTHENTICATION_GUIDE.md` |
| What are the standards? | `AGENT_CONTEXT.md` |
| How does review work? | `../WORKFLOW.md` |
| What makes a good script? | `../SAFETY_CHECKLIST.md` |

---

**Remember: When in doubt, check AGENT_CONTEXT.md or ask the Master Agent!**

