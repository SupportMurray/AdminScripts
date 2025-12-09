# 🚀 Start Here - Project Navigation

**Welcome to the Microsoft 365 Admin Scripts Framework**

This is your main entry point to navigate the project.

---

## 📋 Quick Links by Role

| I Am... | Start Here |
|---------|------------|
| **End User** | `README.md` → `QUICKSTART.md` |
| **Master Agent** (Resume) | `MASTER_AGENT_CONTEXT.md` |
| **New Agent** | `Agents/START_HERE.md` |
| **Returning Agent** | `Agents/QUICK_START_AGENTS.md` |

---

## 📖 Essential Documents

### Core Documentation (Root)
- **README.md** - Project overview and quick start
- **MASTER_AGENT.md** - Master Agent role and responsibilities
- **MASTER_AGENT_CONTEXT.md** - Master Agent resume guide
- **SAFETY_CHECKLIST.md** - Review checklist for all scripts
- **INDEX.md** - Complete file navigation

### Agent Resources (Agents/)
- **Agents/START_HERE.md** - Critical orientation for agents
- **Agents/AGENT_CONTEXT.md** - Complete standards (1,966 lines)
- **Agents/PROMPT_TEMPLATES.md** - 11 role templates

### Quick References (Documentation/)
- **Documentation/QUICK_REFERENCE.md** - Quick lookup guide
- **Documentation/FILE_ORGANIZATION_RULES.md** - File placement rules
- **Documentation/AUTHENTICATION_GUIDE.md** - Auth setup

---

## 🎯 What Do You Want to Do?

### Connect to Microsoft 365
```powershell
./Initialize-M365Session.ps1
```

### Run a Script
```powershell
# See available scripts
ls Scripts/*/

# Example: Run security review
./Scripts/Security_Administration/Get-M365SecurityReview.ps1
```

### Get an Agent Prompt
```
Documentation/Agent_Prompts/COPY_THIS_TO_AGENTS.txt  (General)
Documentation/Agent_Prompts/UI_ADMIN_COMPREHENSIVE_PROMPT.txt  (UI Admin)
```

### Validate Structure
```powershell
./Validate-ProjectStructure.ps1
```

---

**For complete navigation, see:** `INDEX.md`

