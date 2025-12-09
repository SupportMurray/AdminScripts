# Agent Onboarding Checklist

## Welcome, Specialized Agent!

Before creating any scripts, please complete this onboarding checklist to ensure you understand the project structure and standards.

---

## ✅ Step 1: Read Core Documentation (15-20 minutes)

**Required Reading (in order):**

1. **`README.md`** (5 min)
   - [ ] Understand project overview
   - [ ] Review admin roles
   - [ ] Understand workflow

2. **`Agents/AGENT_CONTEXT.md`** (10 min) - **MOST IMPORTANT**
   - [ ] Read core principles (Safety, Production-Ready, Security)
   - [ ] Review script structure standards
   - [ ] Study code patterns (error handling, logging, connection management)
   - [ ] **Read "File Organization - CRITICAL" section**
   - [ ] Review authentication requirements
   - [ ] Understand submission process

3. **`Documentation/FILE_ORGANIZATION_RULES.md`** (5 min) - **CRITICAL**
   - [ ] Understand directory structure
   - [ ] Know where to place scripts
   - [ ] Know where test results go
   - [ ] Review common mistakes to avoid

---

## ✅ Step 2: Understand Your Role (5 minutes)

**Find your role in `Agents/PROMPT_TEMPLATES.md`:**

- [ ] User Administrator
- [ ] Exchange Administrator
- [ ] SharePoint Administrator
- [ ] Teams Administrator
- [ ] Security Administrator
- [ ] License Administrator
- [ ] Compliance Administrator
- [ ] Audit Administrator
- [ ] Intune/MDM Administrator
- [ ] Global Administrator

**Review your template section to understand:**
- [ ] Common tasks for your role
- [ ] Required modules and permissions
- [ ] Expected output format

---

## ✅ Step 3: Set Up Authentication (5 minutes)

**Before testing any scripts:**

1. Run initialization:
   ```powershell
   ./Initialize-M365Session.ps1
   ```

2. Read authentication guide:
   - [ ] Read `Documentation/AUTHENTICATION_GUIDE.md`
   - [ ] Understand how to authenticate
   - [ ] Know how to disconnect

---

## ✅ Step 4: Understand File Organization (CRITICAL)

### Where Your Scripts Go

| Your Role | Script Directory |
|-----------|------------------|
| User Administrator | `Scripts/User_Administration/` |
| Exchange Administrator | `Scripts/Exchange_Administration/` |
| SharePoint Administrator | `Scripts/SharePoint_Administration/` |
| Teams Administrator | `Scripts/Teams_Administration/` |
| Security Administrator | `Scripts/Security_Administration/` |
| License Administrator | `Scripts/License_Administration/` |
| Compliance Administrator | `Scripts/Compliance_Administration/` |
| Audit Administrator | `Scripts/Audit_Administration/` |
| Intune/MDM Administrator | `Scripts/Intune_Administration/` |
| Global Administrator | `Scripts/Global_Administration/` |

### Where Test Results Go

**ALL test outputs go in:** `Tests/Test_Results/`

### Quick Check

- [ ] I know where to save my scripts
- [ ] I know where to save test results
- [ ] I will NOT save files in the root directory
- [ ] I will use proper naming convention

---

## ✅ Step 5: Review Safety Standards (10 minutes)

**Read `SAFETY_CHECKLIST.md` to understand:**

- [ ] Pre-review checks
- [ ] Safety requirements (WhatIf, confirmations)
- [ ] Security requirements (no hardcoded credentials)
- [ ] Code quality standards
- [ ] Testing readiness

**Key Safety Rules:**
- ✅ All modification operations support `-WhatIf`
- ✅ No hardcoded credentials or secrets
- ✅ Comprehensive error handling (try-catch-finally)
- ✅ Proper logging
- ✅ No mock code or placeholders

---

## ✅ Step 6: Understand Workflow (5 minutes)

**Read `WORKFLOW.md` and `BRANCH_WORKFLOW.md` to understand:**

1. **Branch Creation**
   - [ ] Create feature branch: `agent/[role]/[script-name]`
   - [ ] Work in this branch only
   - [ ] Never commit to main

2. **Script Development**
   - [ ] Create script in correct directory
   - [ ] Follow naming convention
   - [ ] Include full documentation

3. **Testing**
   - [ ] Authenticate first: `./Initialize-M365Session.ps1`
   - [ ] Test with `-WhatIf`
   - [ ] Save results to `Tests/Test_Results/`
   - [ ] Disconnect: `./Disconnect-M365Services.ps1`

4. **Submission**
   - [ ] Commit to your branch
   - [ ] Push to remote
   - [ ] Notify user for Master Agent review

5. **Review Process**
   - [ ] Master Agent reviews your branch
   - [ ] Address feedback if needed
   - [ ] Master Agent merges to main when approved

---

## ✅ Step 7: Review Script Template (5 minutes)

**Examine the template:**

- [ ] Open `Documentation/Examples/SCRIPT_TEMPLATE.ps1`
- [ ] Review header format
- [ ] Study error handling pattern
- [ ] Understand logging implementation
- [ ] Note connection management

---

## 🎓 Knowledge Check

Before creating your first script, verify you understand:

### File Organization
- [ ] I know where scripts for my role go
- [ ] I know where test results go
- [ ] I understand naming conventions
- [ ] I will NOT save files in root directory

### Code Standards
- [ ] I understand PowerShell best practices
- [ ] I know how to implement error handling
- [ ] I understand `-WhatIf` support requirement
- [ ] I know security requirements (no hardcoded credentials)

### Workflow
- [ ] I understand branch workflow
- [ ] I know how to authenticate for testing
- [ ] I know the review process
- [ ] I know how to submit for review

### Safety
- [ ] I understand safety requirements
- [ ] I know review criteria
- [ ] I understand security standards
- [ ] I know testing requirements

---

## 📚 Quick Reference

### Essential Commands

```powershell
# Before testing
./Initialize-M365Session.ps1

# Validate structure
./Validate-ProjectStructure.ps1

# After testing
./Disconnect-M365Services.ps1
```

### Essential Files

| File | Purpose |
|------|---------|
| `Agents/AGENT_CONTEXT.md` | Complete standards and patterns |
| `Documentation/FILE_ORGANIZATION_RULES.md` | Where files go |
| `Documentation/AUTHENTICATION_GUIDE.md` | Authentication help |
| `SAFETY_CHECKLIST.md` | Review criteria |
| `WORKFLOW.md` | Complete process |
| `BRANCH_WORKFLOW.md` | Git workflow |

---

## ✅ Final Checklist

Before creating your first script:

- [ ] I have read all required documentation
- [ ] I understand file organization rules
- [ ] I know where to save my scripts
- [ ] I know how to authenticate
- [ ] I understand safety requirements
- [ ] I understand the review process
- [ ] I know my role and responsibilities

---

## 🚀 Ready to Start!

Once you've completed this checklist, you're ready to:

1. Review the prompt template for your role in `Agents/PROMPT_TEMPLATES.md`
2. Wait for task assignment from the user
3. Create your feature branch
4. Develop your script in the correct directory
5. Test with proper authentication
6. Submit for Master Agent review

---

## ❓ Questions?

If you have questions:

- **File Organization**: See `Documentation/FILE_ORGANIZATION_RULES.md`
- **Standards**: See `Agents/AGENT_CONTEXT.md`
- **Authentication**: See `Documentation/AUTHENTICATION_GUIDE.md`
- **Workflow**: See `WORKFLOW.md`
- **Safety**: See `SAFETY_CHECKLIST.md`

---

**Welcome to the team! Follow the structure, and you'll create excellent scripts!** 🎉

