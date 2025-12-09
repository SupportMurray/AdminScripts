# Root Directory Enforcement - Keep It Clean!

**Policy:** STRICT  
**Maximum Files in Root:** 6  
**Enforced By:** Master Agent + Validation Script  
**Updated:** December 2, 2025

---

## 🚨 STRICT RULES (NO EXCEPTIONS)

### ✅ ONLY These 6 Files Allowed in Root:

1. **README.md** - Main overview
2. **INDEX.md** - Navigation
3. **MASTER_AGENT.md** - Master Agent role
4. **MASTER_AGENT_CONTEXT.md** - Master Agent resume
5. **SAFETY_CHECKLIST.md** - Review checklist
6. **Validate-ProjectStructure.ps1** - Validation script

**Plus hidden files:**
- .gitignore
- .gitattributes  
- .env.ps1.example

**TOTAL: 6 visible files + 5 directories**

---

## ❌ NEVER Allow in Root

| File Type | Move To |
|-----------|---------|
| Agent prompts | `Documentation/Agent_Prompts/` |
| Workflow docs | `Documentation/Workflows/` |
| Setup guides | `Documentation/Setup_Guides/` |
| Status/review docs | `Documentation/Project_Status/` |
| PowerShell utilities | `Scripts/Utilities/` |
| Any .txt files | Appropriate Documentation/ subdirectory |
| Test results | `Tests/Test_Results/` |
| Temporary files | DELETE immediately |

---

## 🔒 Automatic Enforcement

### Validation Script (Enhanced)

`./Validate-ProjectStructure.ps1` now:
- ✅ Checks for ONLY allowed files in root
- ✅ Flags ANY unauthorized file with location suggestion
- ✅ Counts total files (max 6)
- ✅ Provides helpful error messages

**Run weekly:**
```powershell
./Validate-ProjectStructure.ps1
```

Expected output:
```
✓ Project structure is valid!
Errors: 0
```

If errors found, validation tells you where to move files.

---

## 📋 Master Agent Enforcement Duties

### Daily (Quick Scan)
```bash
# Count files in root
ls -1 | wc -l
# Should output: 12 (6 files + 6 directories)
```

### Weekly (Validation)
```powershell
./Validate-ProjectStructure.ps1
```

### When Files Appear in Root

**Immediately move to correct location:**

```bash
# Identify file type and move
# Prompts → Documentation/Agent_Prompts/
mv *PROMPT* *_TO_AGENTS* Documentation/Agent_Prompts/

# Workflows → Documentation/Workflows/  
mv *WORKFLOW* *STRUCTURE* *ORGANIZATION* Documentation/Workflows/

# Status → Documentation/Project_Status/
mv *STATUS* *COMPLETE* *SUMMARY* *REVIEW* Documentation/Project_Status/

# Scripts → Scripts/Utilities/
mv *.ps1 Scripts/Utilities/  # (except Validate-ProjectStructure.ps1)
```

### When Reviewing Agent Scripts

**Check file organization:**
- [ ] Script in correct `Scripts/[Role]/` directory
- [ ] Test results in `Tests/Test_Results/`
- [ ] NO files in root directory
- [ ] Validation passes

**Reject if files in wrong location!**

---

## 🎯 Prevention Strategy

### 1. Clear Documentation
- ✅ ROOT_DIRECTORY_POLICY.md (this file)
- ✅ FILE_ORGANIZATION_RULES.md (for agents)
- ✅ Agents educated via AGENT_CONTEXT.md

### 2. Automated Validation
- ✅ Validation script enforces rules
- ✅ Runs on demand
- ✅ Clear error messages

### 3. Master Agent Vigilance
- ✅ Weekly validation
- ✅ Immediate cleanup
- ✅ Reject misorganized submissions

### 4. Agent Education
- ✅ All agents know file rules
- ✅ Prompts include organization reminders
- ✅ Documentation comprehensive

---

## 📊 Current Root Status

**Files in Root:**
```bash
$ ls -1
Agents                          # Directory
Documentation                   # Directory  
INDEX.md                       # ✅ Allowed
MASTER_AGENT.md               # ✅ Allowed
MASTER_AGENT_CONTEXT.md       # ✅ Allowed
README.md                      # ✅ Allowed
Reviews                        # Directory
SAFETY_CHECKLIST.md           # ✅ Allowed
Scripts                        # Directory
Tests                          # Directory
Validate-ProjectStructure.ps1  # ✅ Allowed

Total: 6 files + 6 directories = 12 items ✅
```

**Status:** ✅ **CLEAN - At Policy Limit**

---

## 🔄 Cleanup Procedure (If Root Gets Messy)

### Quick Cleanup Script

```bash
#!/bin/bash
# Save as: cleanup-root.sh

cd /Users/eduardogarcia/Admin_Scripts

# Move agent prompts
mv *PROMPT* *_TO_AGENTS* Documentation/Agent_Prompts/ 2>/dev/null

# Move workflows
mv *WORKFLOW* *STRUCTURE* *ORGANIZATION* Documentation/Workflows/ 2>/dev/null

# Move setup guides
mv *SETUP* *QUICKSTART* Documentation/Setup_Guides/ 2>/dev/null

# Move status docs
mv *STATUS* *COMPLETE* *SUMMARY* *REVIEW* *HISTORY* Documentation/Project_Status/ 2>/dev/null

# Move utility scripts (except Validate-ProjectStructure.ps1)
find . -maxdepth 1 -name "*.ps1" ! -name "Validate-ProjectStructure.ps1" -exec mv {} Scripts/Utilities/ \;

# Move any .txt files
mv *.txt Documentation/ 2>/dev/null

echo "Cleanup complete. Run validation:"
pwsh -Command "./Validate-ProjectStructure.ps1"
```

---

## ✅ Success Criteria

Root directory is clean when:
- [ ] Only 6 files present (excluding hidden files)
- [ ] Only 6 directories present
- [ ] Validation passes: `./Validate-ProjectStructure.ps1`
- [ ] No .txt files in root
- [ ] No PowerShell scripts except Validate-ProjectStructure.ps1
- [ ] All documentation in subdirectories

---

## 🎓 Summary

**Root directory policy:**
- **Maximum 6 files** - README, INDEX, MASTER_AGENT, MASTER_AGENT_CONTEXT, SAFETY_CHECKLIST, Validate-ProjectStructure.ps1
- **Everything else** → Organized in subdirectories
- **Enforced by** - Validation script + Master Agent
- **Result** - Clean, professional, easy to navigate

**Current status:** ✅ **CLEAN AND ENFORCED**

---

**This policy prevents root directory mess and maintains professional organization!**

