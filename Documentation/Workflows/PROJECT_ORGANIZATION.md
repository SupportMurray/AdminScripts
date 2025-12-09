# Project Organization and Maintenance Guide

## Overview
This document provides guidelines for maintaining a clean and organized project structure. The Master Agent is responsible for ensuring all directories and files are properly organized according to the established structure.

## Directory Structure Standards

### Root Directory
The root directory should **ONLY** contain:
- Core documentation files (README.md, MASTER_AGENT.md, etc.)
- Agent-related directory (Agents/)
- Configuration files (if any)
- `.gitignore` and other version control files
- Validation scripts (Validate-ProjectStructure.ps1, etc.)

**NOT allowed in root:**
- ❌ PowerShell scripts (.ps1 files) - except validation/test scripts
- ❌ Test data files
- ❌ Temporary files
- ❌ Backup files
- ❌ Review files (unless in Reviews/ directory)
- ❌ Agent context files (must be in Agents/ directory)

### Scripts Directory
**Location**: `Scripts/[Role]/`

**Organization Rules:**
- Each admin role has its own subdirectory
- Scripts must be in the correct role directory
- No scripts directly in `Scripts/` root
- Script naming: `[Action]-[Object]-[OptionalDescription].ps1`

**Allowed Files:**
- ✅ PowerShell scripts (.ps1)
- ✅ Script-specific README.md (optional)
- ✅ Script-specific configuration templates (optional)

**NOT Allowed:**
- ❌ Test data files (use `Tests/Test_Data/`)
- ❌ Review documents (use `Reviews/`)
- ❌ Temporary or backup files

### Reviews Directory
**Location**: `Reviews/[Status]/`

**Organization Rules:**
- Approved scripts → `Reviews/Approved/`
- Scripts needing revision → `Reviews/Needs_Revision/`
- Rejected scripts → `Reviews/Rejected/`

**File Organization:**
- Option 1: Move entire script file to review directory
- Option 2: Create review document in review directory, keep script in Scripts/
- Option 3: Use subdirectories by date or script name

**Recommended Structure:**
```
Reviews/
├── Approved/
│   ├── 2024-01/
│   │   └── Script-Name.ps1
│   └── 2024-02/
├── Needs_Revision/
│   └── [Script-Name]-Review.md
└── Rejected/
    └── [Script-Name]-Review.md
```

### Agents Directory
**Location**: `Agents/`

**Organization Rules:**
- Contains all agent-related documentation
- Agent context and standards
- Prompt templates for all roles
- Agent-specific guides and documentation

**Files:**
- `AGENT_CONTEXT.md` - Core principles and standards
- `PROMPT_TEMPLATES.md` - Role-based prompt templates
- Other agent-related documentation

### Documentation Directory
**Location**: `Documentation/`

**Subdirectories:**
- `Examples/` - Example scripts and templates
- `Patterns/` - Common code patterns and snippets
- `Troubleshooting/` - Troubleshooting guides

**Organization Rules:**
- Examples should be clearly named and documented
- Patterns should be categorized by purpose
- Troubleshooting guides should be indexed
- Note: Agent documentation is in Agents/, not here

### Tests Directory
**Location**: `Tests/`

**Subdirectories:**
- `Test_Data/` - Test data files (CSV, JSON, etc.)
- `Test_Results/` - Test execution results and logs

**Organization Rules:**
- Test data must be sanitized (no real PII)
- Test results should be organized by date or script
- Old test results should be archived or cleaned up

## File Naming Standards

### Scripts
- Format: `[Action]-[Object]-[OptionalDescription].ps1`
- Examples:
  - ✅ `Get-UserLicenseStatus.ps1`
  - ✅ `Set-BulkUserProperties.ps1`
  - ❌ `user_script.ps1` (wrong format)
  - ❌ `script1.ps1` (not descriptive)

### Documentation
- Format: `[Topic]-[Description].md`
- Examples:
  - ✅ `User-License-Assignment-Guide.md`
  - ✅ `Exchange-Mailbox-Patterns.md`
  - ❌ `doc1.md` (not descriptive)

### Review Documents
- Format: `[ScriptName]-Review.md` or `[ScriptName]-[Date]-Review.md`
- Examples:
  - ✅ `Get-UserLicenseStatus-Review.md`
  - ✅ `Set-BulkUserProperties-2024-01-15-Review.md`

### Test Data
- Format: `Test_[ScriptName]_[Purpose].[ext]`
- Examples:
  - ✅ `Test_Get-UserLicenseStatus_SampleUsers.csv`
  - ✅ `Test_Set-BulkUserProperties_InputData.json`

## Maintenance Procedures

### Daily Maintenance
**Tasks:**
- Quick scan for obviously misplaced files
- Check for temporary files in wrong locations
- Verify new scripts are in correct directories

**Actions:**
- Move misplaced files to correct location
- Delete temporary files
- Update documentation if structure changes

### Weekly Maintenance
**Tasks:**
- Comprehensive directory scan
- Check file naming compliance
- Verify directory structure integrity
- Review recent additions for organization

**Checklist:**
- [ ] All scripts in correct role directories
- [ ] No files in root (except allowed documentation)
- [ ] Review directories organized
- [ ] Test data properly organized
- [ ] No duplicate files
- [ ] No temporary or backup files

### Monthly Maintenance
**Tasks:**
- Deep audit of entire project structure
- Archive old test results
- Clean up old review documents
- Update documentation index
- Check for orphaned files

**Actions:**
- Archive test results older than 3 months
- Move old reviews to archive if needed
- Update directory structure documentation
- Remove unused files
- Consolidate duplicate content

### Quarterly Maintenance
**Tasks:**
- Major structure review
- Evaluate directory organization effectiveness
- Update organization standards if needed
- Comprehensive cleanup
- Documentation refresh

## Cleanup Procedures

### Identifying Files to Clean

#### Temporary Files
Look for:
- Files with `.tmp`, `.bak`, `.old` extensions
- Files with `~` prefix or suffix
- Files with `_backup`, `_old`, `_temp` in name
- Files in wrong directories

#### Orphaned Files
Look for:
- Scripts without corresponding documentation
- Documentation without corresponding scripts
- Test data without corresponding scripts
- Review documents for deleted scripts

#### Duplicate Files
Look for:
- Files with same name in different locations
- Files with similar names (check content)
- Multiple versions of same script

### Cleanup Actions

#### Move Files
```powershell
# Example: Move script to correct directory
Move-Item -Path "Scripts/Get-UserLicenseStatus.ps1" `
          -Destination "Scripts/User_Administration/Get-UserLicenseStatus.ps1"
```

#### Archive Files
```powershell
# Example: Archive old test results
$archiveDate = Get-Date -Format "yyyy-MM"
New-Item -ItemType Directory -Path "Tests/Test_Results/Archive/$archiveDate" -Force
Move-Item -Path "Tests/Test_Results/*.log" `
          -Destination "Tests/Test_Results/Archive/$archiveDate/"
```

#### Delete Files
Only delete:
- Confirmed temporary files
- Confirmed duplicates (after verification)
- Files explicitly marked for deletion

**Never delete without verification:**
- Scripts (even if old)
- Documentation
- Review documents
- Test data (unless confirmed obsolete)

## Organization Validation

### Automated Checks
Create a validation script to check:
1. All scripts in correct directories
2. No files in root (except allowed)
3. File naming compliance
4. Directory structure integrity
5. No temporary files
6. No orphaned files

### Manual Audit Checklist

#### Root Directory
- [ ] Only documentation files present
- [ ] No .ps1 files
- [ ] No test data
- [ ] No temporary files
- [ ] Structure matches PROJECT_STRUCTURE.md

#### Scripts Directory
- [ ] All role subdirectories exist
- [ ] All scripts in correct role directories
- [ ] No scripts in Scripts/ root
- [ ] All scripts follow naming convention
- [ ] No duplicate scripts

#### Reviews Directory
- [ ] Three subdirectories exist (Approved, Needs_Revision, Rejected)
- [ ] Review documents properly organized
- [ ] No scripts directly in Reviews/ root
- [ ] Old reviews archived if needed

#### Documentation Directory
- [ ] Examples in Examples/ subdirectory
- [ ] Patterns in Patterns/ subdirectory
- [ ] Troubleshooting in Troubleshooting/ subdirectory
- [ ] All documentation properly named

#### Tests Directory
- [ ] Test data in Test_Data/ subdirectory
- [ ] Test results in Test_Results/ subdirectory
- [ ] Test data is sanitized (no PII)
- [ ] Old test results archived

## Common Issues and Solutions

### Issue: Script in Wrong Directory
**Solution:**
1. Identify correct directory based on role
2. Move script to correct location
3. Update any references to script location
4. Document the move if significant

### Issue: Files in Root Directory
**Solution:**
1. Identify file type and purpose
2. Determine correct location
3. Move to appropriate directory
4. Update documentation if needed

### Issue: Duplicate Files
**Solution:**
1. Compare file contents
2. Identify which is current/correct
3. Archive or delete older version
4. Update references if needed

### Issue: Orphaned Files
**Solution:**
1. Determine file purpose
2. If still needed, move to correct location
3. If obsolete, archive or delete
4. Update documentation

### Issue: Temporary Files
**Solution:**
1. Verify file is temporary
2. Check if still needed
3. Delete if confirmed temporary
4. Document cleanup action

## Maintenance Scripts

### Directory Structure Validation
Create a script to validate structure:
```powershell
# Validate-DirectoryStructure.ps1
# Checks that directory structure matches standards
```

### File Organization Check
Create a script to check file placement:
```powershell
# Test-FileOrganization.ps1
# Verifies files are in correct directories
```

### Cleanup Script
Create a script for automated cleanup:
```powershell
# Remove-TemporaryFiles.ps1
# Removes temporary and backup files
```

## Reporting

### Organization Status Report
Generate regular reports on:
- Directory structure compliance
- File placement accuracy
- Cleanup actions taken
- Issues found and resolved

### Maintenance Log
Maintain a log of:
- Maintenance activities performed
- Files moved or organized
- Issues identified and resolved
- Structure changes made

## Best Practices

### Proactive Organization
- Organize files immediately when created
- Verify placement during review process
- Clean up as you go, not just during maintenance

### Documentation
- Document any structure changes
- Update PROJECT_STRUCTURE.md if structure evolves
- Keep organization guidelines current

### Automation
- Use scripts for validation and cleanup
- Automate routine maintenance tasks
- Schedule regular audits

### Communication
- Notify team of structure changes
- Document cleanup actions
- Share organization improvements

## Integration with Review Process

### During Script Review
- Verify script is in correct directory
- Check file naming compliance
- Note any organization issues in review

### After Script Approval
- Move to Reviews/Approved/ if using that workflow
- Ensure proper organization maintained
- Update any indexes or documentation

### Continuous Monitoring
- Monitor new file additions
- Verify organization compliance
- Address issues immediately

## Emergency Cleanup

If project structure becomes disorganized:

1. **Assess Situation**: Identify scope of disorganization
2. **Create Backup**: Backup current state
3. **Plan Reorganization**: Determine correct structure
4. **Execute Cleanup**: Systematically organize files
5. **Validate**: Verify organization is correct
6. **Document**: Record what was done and why

---

**Remember**: A well-organized project is easier to maintain, navigate, and use. Regular maintenance prevents major cleanup efforts.

