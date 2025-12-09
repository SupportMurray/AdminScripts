# Agent Reference Summary - Updated Structure

**Last Updated:** December 2, 2025  
**Status:** ✅ All files organized, validated, and documented

---

## 🎯 Critical Updates for All Agents

### ✅ File Organization Now Enforced

All agents MUST follow these rules:

1. **Scripts Location:**
   - ✅ Save in: `Scripts/[YourRole_Administration]/`
   - ❌ NEVER in root directory
   - ❌ NEVER directly in Scripts/ folder

2. **Test Results Location:**
   - ✅ Save in: `Tests/Test_Results/`
   - ❌ NEVER in root directory

3. **Naming Convention:**
   - ✅ Format: `[Action]-[Object]-[Description].ps1`
   - ✅ Examples: `Get-InactiveUsers.ps1`, `Set-BulkLicenses.ps1`

---

## 📚 Updated Agent Documentation

### New/Updated Files for Agents

1. **`Agents/AGENT_CONTEXT.md`** ⭐ UPDATED
   - Added "File Organization - CRITICAL" section
   - Added authentication for testing section
   - Updated submission process
   - Now 1,640+ lines of comprehensive guidance

2. **`Agents/PROMPT_TEMPLATES.md`** ⭐ UPDATED
   - Added critical file organization notice at top
   - Updated general template with file organization rules
   - All 10 role templates include file organization context
   - Now includes Intune/MDM Administrator template

3. **`Agents/README.md`** ⭐ UPDATED
   - Added visual directory structure
   - Highlighted file organization importance
   - Clear warnings about file placement

4. **`Agents/QUICK_START_AGENTS.md`** ⭐ NEW
   - Fast onboarding guide
   - Visual file organization reference
   - Common mistakes to avoid
   - Quick workflow reference

5. **`Documentation/FILE_ORGANIZATION_RULES.md`** ⭐ NEW
   - Complete file organization rules
   - Examples of correct/incorrect placement
   - Role-specific directory mapping
   - Common mistakes with solutions

6. **`Documentation/AGENT_ONBOARDING.md`** ⭐ NEW
   - Complete onboarding checklist
   - Step-by-step learning path
   - Knowledge verification
   - Essential commands reference

7. **`Documentation/AUTHENTICATION_GUIDE.md`** ⭐ NEW
   - Complete authentication guide
   - Troubleshooting authentication issues
   - Best practices for testing
   - Connection verification steps

---

## 🗺️ Agent Directory Map

### Which Directory for My Role?

| If You Are... | Your Scripts Go In... |
|---------------|----------------------|
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

---

## ✅ Validation Tools

### Check Your Work

```powershell
# Validate project structure
./Validate-ProjectStructure.ps1

# Expected output:
# ✓ Project structure is valid!
```

**What it checks:**
- ✅ All directories exist
- ✅ No scripts in root
- ✅ No files in wrong locations
- ✅ Naming conventions followed
- ✅ No temporary files

---

## 🔄 Complete Workflow

### 1. Setup (One Time)
```powershell
# Read all agent documentation
# - Agents/AGENT_CONTEXT.md
# - Documentation/FILE_ORGANIZATION_RULES.md
# - Documentation/AUTHENTICATION_GUIDE.md
```

### 2. Start Task
```bash
# Create feature branch
git checkout -b agent/[role]/[script-name]
```

### 3. Authenticate
```powershell
# Connect to M365
./Initialize-M365Session.ps1
```

### 4. Create Script
```powershell
# Create in correct directory
# Scripts/[YourRole_Administration]/[ScriptName].ps1
```

### 5. Test Script
```powershell
# Test with -WhatIf (if applicable)
./Scripts/[YourRole]/[ScriptName].ps1 -WhatIf

# Test actual execution
./Scripts/[YourRole]/[ScriptName].ps1 -OutputPath "Tests/Test_Results/test.txt"
```

### 6. Validate Structure
```powershell
# Verify files are in correct locations
./Validate-ProjectStructure.ps1
```

### 7. Disconnect
```powershell
# Clean up connections
./Disconnect-M365Services.ps1
```

### 8. Submit for Review
```bash
# Commit your work
git add Scripts/[YourRole]/[ScriptName].ps1
git commit -m "feat: Add [description]"
git push origin agent/[role]/[script-name]

# Notify user: "Script ready in branch agent/[role]/[script-name]"
```

---

## 📊 Project Structure Overview

```
Admin_Scripts/
│
├── Agents/                          ← Agent documentation (READ FIRST!)
│   ├── AGENT_CONTEXT.md             ← ⭐ Complete standards
│   ├── PROMPT_TEMPLATES.md          ← ⭐ Your role template
│   ├── QUICK_START_AGENTS.md        ← ⭐ Quick reference
│   └── README.md
│
├── Scripts/                         ← YOUR SCRIPTS GO HERE
│   ├── User_Administration/
│   ├── Exchange_Administration/
│   ├── SharePoint_Administration/
│   ├── Teams_Administration/
│   ├── Security_Administration/
│   ├── License_Administration/
│   ├── Compliance_Administration/
│   ├── Audit_Administration/
│   ├── Intune_Administration/
│   └── Global_Administration/
│
├── Tests/
│   ├── Test_Data/                   ← Test input files
│   └── Test_Results/                ← YOUR TEST OUTPUTS GO HERE
│
├── Documentation/                   ← Guides and references
│   ├── FILE_ORGANIZATION_RULES.md   ← ⭐ File placement rules
│   ├── AUTHENTICATION_GUIDE.md      ← ⭐ Auth guide
│   ├── AGENT_ONBOARDING.md          ← ⭐ Onboarding checklist
│   └── ... (more guides)
│
└── [Utility Scripts and Core Docs]
```

---

## ⚠️ Master Agent Will Check

When you submit for review, Master Agent will verify:

✅ Script is in correct directory  
✅ Naming convention followed  
✅ No mock code or placeholders  
✅ Error handling present  
✅ `-WhatIf` support included  
✅ No hardcoded credentials  
✅ Documentation complete  
✅ Test results properly saved  

**If files are in wrong locations, script will be rejected!**

---

## 🚀 Ready to Create Scripts!

### Your Checklist:
- [ ] I've read `AGENT_CONTEXT.md`
- [ ] I've read `FILE_ORGANIZATION_RULES.md`
- [ ] I know where my scripts go
- [ ] I know how to authenticate
- [ ] I understand the workflow
- [ ] I'm ready to create production-quality scripts!

---

**Quick Links:**
- **Standards**: `AGENT_CONTEXT.md`
- **File Rules**: `../Documentation/FILE_ORGANIZATION_RULES.md`
- **Authentication**: `../Documentation/AUTHENTICATION_GUIDE.md`
- **Templates**: `PROMPT_TEMPLATES.md`
- **Quick Start**: `QUICK_START_AGENTS.md` (this file)

**Good luck, and create amazing scripts!** 🎉

