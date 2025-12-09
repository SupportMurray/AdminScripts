# Root Directory Policy - STRICT ENFORCEMENT

**Created:** December 2, 2025  
**Enforced By:** Master Agent  
**Status:** ✅ **MANDATORY**

---

## 🚨 ROOT DIRECTORY RULES (STRICT)

### ✅ ALLOWED in Root Directory

**ONLY these 5 files are allowed:**

1. **README.md** - Main project overview
2. **INDEX.md** - Navigation guide
3. **MASTER_AGENT.md** - Master Agent role
4. **MASTER_AGENT_CONTEXT.md** - Master Agent resume guide
5. **SAFETY_CHECKLIST.md** - Review checklist

**ONLY this 1 script is allowed:**

6. **Validate-ProjectStructure.ps1** - Structure validation

**TOTAL MAXIMUM: 6 FILES IN ROOT**

---

## ❌ NOT ALLOWED in Root Directory

### Never Allow:
- ❌ Agent prompts → Move to `Documentation/Agent_Prompts/`
- ❌ Status documents → Move to `Documentation/Project_Status/`
- ❌ Workflow docs → Move to `Documentation/Workflows/`
- ❌ Setup guides → Move to `Documentation/Setup_Guides/`
- ❌ PowerShell scripts → Move to `Scripts/Utilities/`
- ❌ Test results → Move to `Tests/Test_Results/`
- ❌ Review documents → Move to `Reviews/[Status]/`
- ❌ Agent documentation → Move to `Agents/`
- ❌ Temporary files → Delete immediately
- ❌ Backup files → Delete immediately

---

## 📁 Where Files Should Go

| File Type | Correct Location |
|-----------|------------------|
| **Agent Prompts** | `Documentation/Agent_Prompts/` |
| **Workflow Docs** | `Documentation/Workflows/` |
| **Setup Guides** | `Documentation/Setup_Guides/` |
| **Status Reports** | `Documentation/Project_Status/` |
| **User Guides** | `Documentation/` |
| **Utility Scripts** | `Scripts/Utilities/` |
| **Production Scripts** | `Scripts/[Role_Administration]/` |
| **Test Results** | `Tests/Test_Results/` |
| **Reviews** | `Reviews/[Approved/Needs_Revision/Rejected]/` |

---

## 🔒 Enforcement Mechanism

### Master Agent Must:

1. **Weekly Check**
   ```powershell
   ./Validate-ProjectStructure.ps1
   ```

2. **Immediate Action on New Files in Root**
   - Identify file type
   - Move to appropriate directory
   - Update references if needed
   - Document the move

3. **Reject Scripts with Files in Wrong Location**
   - During review, check file placement
   - Require agents to move files to correct locations
   - Do not approve until files are properly organized

---

## 📋 Root Directory Checklist

Run this monthly to keep root clean:

- [ ] Count files in root: `ls -1 | wc -l` (should be ≤ 6 items + directories)
- [ ] Check for .md files: Only 5 allowed
- [ ] Check for .ps1 files: Only 1 allowed (Validate-ProjectStructure.ps1)
- [ ] Check for .txt files: None allowed (move to Documentation/)
- [ ] Check for temp files: Delete immediately
- [ ] Run validation: `./Validate-ProjectStructure.ps1`

---

## 🎯 Cleanup Procedure (When Root Gets Messy)

### Step 1: Identify File Types
```bash
ls -1 *.md | grep -v "README\|INDEX\|MASTER_AGENT\|SAFETY_CHECKLIST"
ls -1 *.ps1 | grep -v "Validate-ProjectStructure"
ls -1 *.txt
```

### Step 2: Move Files

**Agent Prompts:**
```bash
mv *PROMPT* *_TO_AGENTS* Documentation/Agent_Prompts/
```

**Workflow Docs:**
```bash
mv *WORKFLOW* *STRUCTURE* *ORGANIZATION* Documentation/Workflows/
```

**Setup Guides:**
```bash
mv *SETUP* *QUICKSTART* Documentation/Setup_Guides/
```

**Status Docs:**
```bash
mv *STATUS* *COMPLETE* *REVIEW* *SUMMARY* Documentation/Project_Status/
```

**Utility Scripts:**
```bash
mv *-M365*.ps1 Setup-*.ps1 Test-*.ps1 Connect-*.ps1 Disconnect-*.ps1 Initialize-*.ps1 Start-*.ps1 Scripts/Utilities/
```

### Step 3: Validate
```powershell
./Validate-ProjectStructure.ps1
```

---

## 🛡️ Prevention Rules

### For Master Agent:

1. **Before Approving Any Script**
   - Check all files are in correct locations
   - Reject if files in root (except allowed 6)

2. **Weekly Maintenance**
   - Run validation script
   - Move any misplaced files
   - Update this policy if needed

3. **When Creating New Files**
   - Create in appropriate subdirectory
   - Never create in root unless absolutely essential
   - Prefer adding to existing files over creating new ones

### For Agents:

**Agents are already educated via:**
- Agents/AGENT_CONTEXT.md - File organization rules
- Documentation/FILE_ORGANIZATION_RULES.md - Detailed rules
- All prompt templates include file organization reminders

---

## 📊 Current Root Status

**Files in Root:** 6 (maximum allowed)

1. ✅ README.md
2. ✅ INDEX.md
3. ✅ MASTER_AGENT.md
4. ✅ MASTER_AGENT_CONTEXT.md
5. ✅ SAFETY_CHECKLIST.md
6. ✅ Validate-ProjectStructure.ps1

**Directories in Root:** 5
- Agents/
- Documentation/
- Scripts/
- Reviews/
- Tests/

**Status:** ✅ **CLEAN - At Maximum Allowed**

---

## 🔄 Ongoing Maintenance

### Daily (Quick Check)
```bash
# Count files in root
ls -1 | wc -l
# Should be: 11 total (6 files + 5 directories)
```

### Weekly (Validation)
```powershell
./Validate-ProjectStructure.ps1
```

### Monthly (Deep Clean)
```bash
# Check for any rogue files
find . -maxdepth 1 -type f -name "*.md" | grep -v "README\|INDEX\|MASTER_AGENT\|SAFETY_CHECKLIST"
find . -maxdepth 1 -type f -name "*.ps1" | grep -v "Validate-ProjectStructure"
find . -maxdepth 1 -type f -name "*.txt"
```

---

## 🎓 Training

This policy is referenced in:
- ✅ MASTER_AGENT_CONTEXT.md - Master Agent responsibilities
- ✅ PROJECT_ORGANIZATION.md - Organization guide
- ✅ Agents/AGENT_CONTEXT.md - Agent file organization rules

---

**REMEMBER: A clean root directory = An organized project!**

**Maximum files in root: 6 (5 .md + 1 .ps1)**

