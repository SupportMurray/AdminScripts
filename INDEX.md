# Master Index - Admin Scripts Project

**Quick Navigation Guide**  
**Last Updated:** December 2, 2025

---

## 🚀 START HERE

| If You Are... | Read This First |
|---------------|----------------|
| **New User** | `README.md` → `QUICKSTART.md` |
| **Master Agent** | `MASTER_AGENT_CONTEXT.md` → `MASTER_AGENT.md` |
| **New Agent** | `Agents/START_HERE.md` → `Agents/AGENT_CONTEXT.md` |
| **Returning to Project** | This file (INDEX.md) |

---

## 📋 Core Documentation (Root Directory)

### Essential Reading
| File | Purpose | Who Should Read |
|------|---------|-----------------|
| **README.md** | Project overview | Everyone |
| **QUICKSTART.md** | M365 connection quick start | Users |
| **MASTER_AGENT_CONTEXT.md** | Master Agent resume guide | Master Agent ⭐ |

### Master Agent Documents
| File | Purpose |
|------|---------|
| **MASTER_AGENT.md** | Role and responsibilities |
| **SAFETY_CHECKLIST.md** | Review checklist (313 lines) |
| **BRANCH_WORKFLOW.md** | Git merge authority |
| **PROJECT_ORGANIZATION.md** | Maintenance procedures |

### Project Structure
| File | Purpose |
|------|---------|
| **PROJECT_STRUCTURE.md** | Directory organization |
| **PROJECT_STATUS.md** | Current status report |
| **WORKFLOW.md** | Development workflow |
| **VERSION_HISTORY.md** | Version tracking |
| **FINAL_STRUCTURE_REVIEW.md** | Structure verification |
| **AGENT_REFERENCE_SUMMARY.md** | Agent updates summary |

### Setup & Configuration
| File | Purpose |
|------|---------|
| **SETUP_GUIDE.md** | PowerShell setup guide |
| **.env.ps1.example** | Configuration template |
| **.gitignore** | Security protection |

---

## 🤖 Agent Documentation (Agents/)

### Critical for All Agents
| File | Purpose | Priority |
|------|---------|----------|
| **START_HERE.md** | Critical orientation | ⭐⭐⭐ Read First! |
| **QUICK_START_AGENTS.md** | 5-minute quickstart | ⭐⭐ |
| **AGENT_CONTEXT.md** | Complete standards (1,729 lines) | ⭐⭐⭐ Essential! |
| **PROMPT_TEMPLATES.md** | 10 role templates (930+ lines) | ⭐⭐ |
| **README.md** | Directory overview | ⭐ |

---

## 📖 Documentation Directory

### Agent Guides
| File | Purpose |
|------|---------|
| **AGENT_ONBOARDING.md** | Complete onboarding checklist |
| **FILE_ORGANIZATION_RULES.md** | File placement rules ⭐ |
| **AUTHENTICATION_GUIDE.md** | Auth setup and troubleshooting |

### Quick References
| File | Purpose |
|------|---------|
| **GETTING_STARTED.md** | Getting started guide |
| **QUICK_REFERENCE.md** | Quick lookup reference |
| **QUICK_AUDIT_GUIDE.txt** | Quick audit guide |

### Specialized Prompts
| File | Purpose |
|------|---------|
| **SECURITY_REVIEW_PROMPT.md** | Security agent prompts |
| **INTUNE_MDM_PROMPTS.md** | Intune/MDM agent prompts |
| **AUDIT_AGENT_README.md** | Audit agent overview |
| **RUN_AUDIT_INSTRUCTIONS.md** | Audit instructions |

### Subdirectories
- **Examples/** - Script templates and examples
- **Patterns/** - Common code patterns (ready for use)
- **Troubleshooting/** - Troubleshooting guides (ready for use)

---

## 💻 Utility Scripts (Root Directory)

### Setup & Installation
| Script | Purpose |
|--------|---------|
| **Setup-M365Modules.ps1** | Install all M365 modules |

### Authentication
| Script | Purpose |
|--------|---------|
| **Initialize-M365Session.ps1** | Quick auth (recommended) ⭐ |
| **Connect-M365Services.ps1** | Connect to services |
| **Disconnect-M365Services.ps1** | Disconnect all services |
| **Start-M365Session.ps1** | Interactive session |
| **Test-M365Connection.ps1** | Test connectivity |

### Validation
| Script | Purpose |
|--------|---------|
| **Validate-ProjectStructure.ps1** | Validate project organization |

---

## 📂 Scripts Directory (By Role)

### Production Scripts Location
```
Scripts/
├── Audit_Administration/         ✅ Get-M365ComprehensiveAudit.ps1
├── Compliance_Administration/    (Ready for scripts)
├── Exchange_Administration/      (Ready for scripts)
├── Global_Administration/        (Ready for scripts)
├── Intune_Administration/        (Ready for scripts)
├── License_Administration/       (Ready for scripts)
├── Security_Administration/      ✅ Get-M365SecurityReview.ps1
├── SharePoint_Administration/    (Ready for scripts)
├── Teams_Administration/         (Ready for scripts)
└── User_Administration/          (Ready for scripts)
```

---

## 🧪 Tests Directory

### Structure
```
Tests/
├── Test_Data/          - Test input files (CSV, JSON)
└── Test_Results/       - Test outputs and reports (8 files)
```

---

## 📝 Reviews Directory

### Master Agent Workflow
```
Reviews/
├── Approved/           - Approved scripts
├── Needs_Revision/     - Scripts needing revision
└── Rejected/           - Rejected scripts
```

---

## 🎯 Quick Navigation by Task

### I Want to...

**Connect to Microsoft 365**
→ Run `./Initialize-M365Session.ps1`
→ See `QUICKSTART.md`

**Create a New Script**
→ Read `Agents/START_HERE.md`
→ Use template from `Agents/PROMPT_TEMPLATES.md`
→ Follow `Agents/AGENT_CONTEXT.md`

**Review a Script (Master Agent)**
→ Use `SAFETY_CHECKLIST.md`
→ See `MASTER_AGENT.md`
→ Follow `BRANCH_WORKFLOW.md` for merging

**Understand File Organization**
→ Read `Documentation/FILE_ORGANIZATION_RULES.md`
→ See visual examples in `Agents/QUICK_START_AGENTS.md`

**Fix Authentication Issues**
→ Read `Documentation/AUTHENTICATION_GUIDE.md`
→ Run `./Test-M365Connection.ps1`

**Validate Project Structure**
→ Run `./Validate-ProjectStructure.ps1`

**Onboard a New Agent**
→ Direct to `Agents/START_HERE.md`
→ Follow `Documentation/AGENT_ONBOARDING.md`

---

## 📊 Documentation Map

### By Audience

**For End Users:**
- README.md
- QUICKSTART.md
- SETUP_GUIDE.md

**For Master Agent:**
- MASTER_AGENT_CONTEXT.md ⭐
- MASTER_AGENT.md
- SAFETY_CHECKLIST.md
- BRANCH_WORKFLOW.md
- PROJECT_ORGANIZATION.md

**For Specialized Agents:**
- Agents/START_HERE.md ⭐
- Agents/AGENT_CONTEXT.md ⭐
- Agents/PROMPT_TEMPLATES.md
- Documentation/FILE_ORGANIZATION_RULES.md ⭐
- Documentation/AUTHENTICATION_GUIDE.md

**For Everyone:**
- Documentation/QUICK_REFERENCE.md
- WORKFLOW.md
- PROJECT_STRUCTURE.md

---

## 🔍 Find Information About...

### Authentication
- Setup: `SETUP_GUIDE.md`
- Quick start: `QUICKSTART.md`
- Troubleshooting: `Documentation/AUTHENTICATION_GUIDE.md`
- Helper script: `Initialize-M365Session.ps1`

### File Organization
- Rules: `Documentation/FILE_ORGANIZATION_RULES.md`
- Quick ref: `Agents/QUICK_START_AGENTS.md`
- Structure: `PROJECT_STRUCTURE.md`
- Validation: `Validate-ProjectStructure.ps1`

### Safety & Security
- Checklist: `SAFETY_CHECKLIST.md`
- Patterns: `Agents/AGENT_CONTEXT.md`
- Review: `MASTER_AGENT.md`
- Security prompts: `Documentation/SECURITY_REVIEW_PROMPT.md`

### Workflows
- Development: `WORKFLOW.md`
- Git branches: `BRANCH_WORKFLOW.md`
- Organization: `PROJECT_ORGANIZATION.md`
- Review process: `MASTER_AGENT.md`

### Agent Roles
- All templates: `Agents/PROMPT_TEMPLATES.md`
- All context: `Agents/AGENT_CONTEXT.md`
- Security: `Documentation/SECURITY_REVIEW_PROMPT.md`
- Intune/MDM: `Documentation/INTUNE_MDM_PROMPTS.md`
- Audit: `Documentation/AUDIT_AGENT_README.md`

---

## 🛠️ Tools & Scripts

### Setup
- `Setup-M365Modules.ps1` - Install modules
- `Test-M365Connection.ps1` - Test connectivity

### Authentication
- `Initialize-M365Session.ps1` ⭐ Recommended
- `Connect-M365Services.ps1` - Multi-service
- `Disconnect-M365Services.ps1` - Clean disconnect
- `Start-M365Session.ps1` - Interactive

### Validation
- `Validate-ProjectStructure.ps1` - Structure check

### Production Scripts
- `Scripts/Audit_Administration/Get-M365ComprehensiveAudit.ps1`
- `Scripts/Security_Administration/Get-M365SecurityReview.ps1`

---

## 📞 Quick Help

| Problem | Solution |
|---------|----------|
| Need to connect to M365 | `./Initialize-M365Session.ps1` |
| Script in wrong directory | See `Documentation/FILE_ORGANIZATION_RULES.md` |
| Authentication failed | See `Documentation/AUTHENTICATION_GUIDE.md` |
| How do I review a script? | See `SAFETY_CHECKLIST.md` |
| Where does my script go? | See role table in `Agents/AGENT_CONTEXT.md` |
| How do I submit for review? | See `WORKFLOW.md` and `BRANCH_WORKFLOW.md` |

---

## 🎯 Most Important Files

### Top 5 for Master Agent
1. **MASTER_AGENT_CONTEXT.md** - Your resume guide
2. **SAFETY_CHECKLIST.md** - Review every script
3. **BRANCH_WORKFLOW.md** - Merge authority
4. **MASTER_AGENT.md** - Your responsibilities
5. **PROJECT_ORGANIZATION.md** - Maintenance duties

### Top 5 for Agents
1. **Agents/START_HERE.md** - Read this first!
2. **Agents/AGENT_CONTEXT.md** - Complete standards
3. **Documentation/FILE_ORGANIZATION_RULES.md** - Where files go
4. **Agents/PROMPT_TEMPLATES.md** - Your role template
5. **Documentation/AUTHENTICATION_GUIDE.md** - Auth help

### Top 5 for Users
1. **README.md** - Project overview
2. **QUICKSTART.md** - Connect to M365
3. **Agents/PROMPT_TEMPLATES.md** - Request scripts
4. **WORKFLOW.md** - How it all works
5. **SETUP_GUIDE.md** - Setup details

---

## 🎉 Project Status

**Version:** 1.0  
**Status:** ✅ Production Ready  
**Validation:** ✅ 0 Errors, 0 Warnings  
**Documentation:** ✅ Complete (25+ files)  
**Agents:** ✅ 10 Roles Documented  
**Setup:** ✅ PowerShell Connected to M365  

**Ready for enterprise-scale Microsoft 365 automation!** 🚀

---

**Use this index to quickly find what you need!**

