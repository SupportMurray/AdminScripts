# 🚨 START HERE - ALL AGENTS READ THIS FIRST! 🚨

```
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║            CRITICAL: FILE ORGANIZATION RULES                          ║
║                                                                       ║
║  Before creating ANY files, you MUST understand where they go!       ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

## 🎯 The #1 Rule

### Save Scripts in the Correct Directory!

```
✅ YES:  Scripts/User_Administration/Get-Users.ps1
✅ YES:  Scripts/Security_Administration/Get-SecurityReview.ps1
✅ YES:  Scripts/Audit_Administration/Get-Audit.ps1

❌ NO:   Get-Users.ps1                        (root directory)
❌ NO:   Scripts/Get-Users.ps1                (not in role folder)
❌ NO:   Admin_Scripts/Get-Users.ps1          (root directory)
```

---

## 📋 Your Role → Your Directory

| You Are... | Save Scripts In... |
|------------|-------------------|
| **User Administrator** | `Scripts/User_Administration/` |
| **Exchange Administrator** | `Scripts/Exchange_Administration/` |
| **SharePoint Administrator** | `Scripts/SharePoint_Administration/` |
| **Teams Administrator** | `Scripts/Teams_Administration/` |
| **Security Administrator** | `Scripts/Security_Administration/` |
| **License Administrator** | `Scripts/License_Administration/` |
| **Compliance Administrator** | `Scripts/Compliance_Administration/` |
| **Audit Administrator** | `Scripts/Audit_Administration/` |
| **Intune/MDM Administrator** | `Scripts/Intune_Administration/` |
| **Global Administrator** | `Scripts/Global_Administration/` |

---

## 📁 File Organization at a Glance

```
Admin_Scripts/
│
├── Scripts/
│   └── [YourRole_Administration]/    ← 🎯 YOUR SCRIPTS GO HERE
│       └── [Action]-[Object].ps1
│
└── Tests/
    └── Test_Results/                 ← 🎯 YOUR TEST OUTPUTS GO HERE
        └── [ReportName].txt
```

---

## 📖 Required Reading (In Order)

### 1️⃣ QUICK_START_AGENTS.md (5 minutes)
- Quick reference and common mistakes
- **File:** `Agents/QUICK_START_AGENTS.md`

### 2️⃣ AGENT_CONTEXT.md (30 minutes) ⭐ CRITICAL
- Complete standards and patterns
- File organization rules
- Authentication requirements
- **File:** `Agents/AGENT_CONTEXT.md`

### 3️⃣ FILE_ORGANIZATION_RULES.md (10 minutes)
- Detailed file placement rules
- Common mistakes to avoid
- **File:** `Documentation/FILE_ORGANIZATION_RULES.md`

### 4️⃣ AUTHENTICATION_GUIDE.md (10 minutes)
- How to authenticate for testing
- Troubleshooting auth issues
- **File:** `Documentation/AUTHENTICATION_GUIDE.md`

---

## ⚡ Quick Start (5-Second Version)

```powershell
# 1. Authenticate
./Initialize-M365Session.ps1

# 2. Create script in YOUR ROLE directory
#    Example for User Admin:
#    Scripts/User_Administration/Get-InactiveUsers.ps1

# 3. Test it

# 4. Save test results in Tests/Test_Results/

# 5. Disconnect
./Disconnect-M365Services.ps1

# 6. Validate structure
./Validate-ProjectStructure.ps1

# 7. Commit and notify for review
```

---

## 🚫 Most Common Mistakes

### ❌ #1: Script in Root Directory
**This is WRONG:**
```
Admin_Scripts/
└── Get-Users.ps1  ❌ WRONG!
```

**This is CORRECT:**
```
Admin_Scripts/
└── Scripts/
    └── User_Administration/
        └── Get-Users.ps1  ✅ CORRECT!
```

### ❌ #2: Test Results in Root
**This is WRONG:**
```
Admin_Scripts/
└── Audit_Report.txt  ❌ WRONG!
```

**This is CORRECT:**
```
Admin_Scripts/
└── Tests/
    └── Test_Results/
        └── Audit_Report.txt  ✅ CORRECT!
```

---

## ✅ Validation

### How to Check Your Work

```powershell
# Run this before submitting
./Validate-ProjectStructure.ps1

# You should see:
# ✓ Project structure is valid!
```

If you see warnings or errors, your files are in the wrong place!

---

## 📞 Need Help?

| Question | Answer File |
|----------|------------|
| Where do files go? | `Documentation/FILE_ORGANIZATION_RULES.md` |
| How do I authenticate? | `Documentation/AUTHENTICATION_GUIDE.md` |
| What are the coding standards? | `Agents/AGENT_CONTEXT.md` |
| How do I submit for review? | `../WORKFLOW.md` |
| What's the Git workflow? | `../BRANCH_WORKFLOW.md` |

---

```
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║  REMEMBER: Scripts in Scripts/[YourRole_Administration]/             ║
║            Test results in Tests/Test_Results/                       ║
║            NEVER in root directory!                                  ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

**Now go read `AGENT_CONTEXT.md` for complete details!** →

