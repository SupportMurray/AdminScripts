# Workflow Documentation

## Overview
This document describes the complete workflow for creating, reviewing, and deploying Microsoft 365 automation scripts using AI agents.

## Workflow Diagram

```
User Request
    ↓
Select Role & Create Prompt
    ↓
Specialized Agent Creates Script
    ↓
Master Agent Review
    ↓
[APPROVED] → Testing → Production
    ↓
[NEEDS REVISION] → Agent Revises → Review Again
    ↓
[REJECTED] → Document Issues → Start Over
```

## Detailed Workflow Steps

### Step 1: User Identifies Task
**Actor**: User (Microsoft 365 Administrator)

**Actions**:
1. Identify the automation task needed
2. Determine which admin role is required
3. Gather requirements and constraints
4. Identify any special considerations

**Output**: Task description with requirements

---

### Step 2: Create Prompt for Specialized Agent
**Actor**: User

**Actions**:
1. Open `Agents/PROMPT_TEMPLATES.md`
2. Select appropriate role template (User Admin, Exchange Admin, etc.)
3. Fill in the TASK section with specific requirements
4. Customize REQUIREMENTS section
5. Add any additional context or constraints

**Template Location**: `Agents/PROMPT_TEMPLATES.md`

**Example**:
```
You are a Microsoft 365 User Administrator and PowerShell automation expert.

CONTEXT:
- Review Agents/AGENT_CONTEXT.md for standards and best practices
- All scripts must be production-ready with no mock code or placeholders
- Scripts will be reviewed by the Master Agent before testing
- Use Microsoft Graph PowerShell SDK for user management operations
- Follow PowerShell best practices and security standards

TASK:
Create a script to bulk assign Microsoft 365 E5 licenses to users from a CSV file.
The CSV contains UserPrincipalName column. Validate license availability and skip
users who already have the license.

REQUIREMENTS:
- Read from CSV file with UserPrincipalName column
- Validate each user exists
- Check license availability
- Skip users with existing license
- Support -WhatIf
- Log all operations
- Show progress

OUTPUT:
- Create a PowerShell script that [describes expected functionality]
- Include comprehensive error handling
- Add comment-based help documentation
- Support -WhatIf for modification operations
- Include logging functionality
- Validate all inputs before processing

After creating the script, it will be reviewed by the Master Agent for safety and quality.
```

---

### Step 3: Specialized Agent Creates Branch and Script
**Actor**: Specialized AI Agent (User Admin, Exchange Admin, etc.)

**Actions**:
1. **Create Feature Branch**:
   - Create branch: `agent/[role]/[script-name]`
   - Work in this branch (never commit directly to main)
2. Review `Agents/AGENT_CONTEXT.md` for standards
3. Review `PROJECT_STRUCTURE.md` for organization
4. Create PowerShell script following all standards:
   - No mock code or placeholders
   - Complete error handling
   - Proper logging
   - `-WhatIf` support
   - Comment-based help
   - Security best practices
4. Self-review against `SAFETY_CHECKLIST.md`
5. Place script in appropriate directory: `Scripts/[Role]/`
6. Commit and push branch:
   ```bash
   git add Scripts/[Role]/[ScriptName].ps1
   git commit -m "feat: Add [script description]"
   git push origin agent/[role]/[script-name]
   ```
7. Notify user that script is ready for review

**Standards to Follow**:
- `Agents/AGENT_CONTEXT.md` - Core principles and patterns
- `PROJECT_STRUCTURE.md` - File organization and naming
- `SAFETY_CHECKLIST.md` - Safety and quality standards

**Output**: Complete PowerShell script ready for review

---

### Step 4: Request Master Agent Review
**Actor**: User

**Actions**:
1. Notify Master Agent that a script is ready for review
2. Provide branch name: `agent/[role]/[script-name]`
3. Provide script location and name
4. Provide any context or special considerations
5. Wait for review results

**Communication Format**:
```
Master Agent, please review the following script:

Script: Scripts/User_Administration/Set-BulkUserLicenses.ps1
Purpose: Bulk assign E5 licenses from CSV
Special Considerations: None
Testing Environment: Test tenant available
```

---

### Step 5: Master Agent Review
**Actor**: Master Agent

**Actions**:
1. **Checkout Agent's Branch**:
   ```bash
   git fetch origin
   git checkout agent/[role]/[script-name]
   ```
2. Read the script thoroughly
3. Review against `SAFETY_CHECKLIST.md`:
   - Pre-Review Checks
   - Safety Checks
   - Security Checks
   - Code Quality Checks
   - Testing Readiness Checks
3. Check for:
   - Mock code or placeholders
   - Destructive operations without safeguards
   - Security vulnerabilities
   - Code quality issues
   - Missing documentation
4. Create review report using template from `SAFETY_CHECKLIST.md`
5. Provide one of three outcomes:
   - **APPROVED**: Ready for testing
   - **NEEDS REVISION**: Fix issues and resubmit
   - **REJECTED**: Critical issues, start over

**Review Tools**:
- `SAFETY_CHECKLIST.md` - Comprehensive checklist
- `MASTER_AGENT.md` - Review guidelines
- `Agents/AGENT_CONTEXT.md` - Standards reference

**Output**: Review report with status and feedback

---

### Step 6A: Script APPROVED
**Actor**: Master Agent → User

**Actions**:
1. Master Agent marks script as APPROVED
2. **Merge to Main Branch**:
   ```bash
   git checkout main
   git merge agent/[role]/[script-name]
   git push origin main
   ```
3. Optionally delete feature branch after merge
4. Documents merge in review log
5. Provides review report to user
6. User proceeds to testing

**Next Steps**: Go to Step 7 (Testing)

---

### Step 6B: Script NEEDS REVISION
**Actor**: Master Agent → Specialized Agent → User

**Actions**:
1. Master Agent provides detailed feedback:
   - Specific issues found
   - Code quality concerns
   - Security or safety issues
   - Recommendations for fixes
2. User forwards feedback to Specialized Agent
3. Specialized Agent addresses all feedback in the same branch:
   ```bash
   git checkout agent/[role]/[script-name]
   # Make changes
   git add Scripts/[Role]/[ScriptName].ps1
   git commit -m "fix: Address review feedback"
   git push origin agent/[role]/[script-name]
   ```
4. Specialized Agent notifies user changes are complete
5. User requests review again (back to Step 5)

**Feedback Format** (from `MASTER_AGENT.md`):
```
## Review Status: NEEDS REVISION

### Safety Issues
- Missing -WhatIf support for license assignment operation
- No validation of license availability before assignment

### Security Issues
- None

### Code Quality Issues
- Error handling could be more comprehensive
- Missing progress indicator for bulk operations

### Recommendations
- Add -WhatIf support to Set-MgUserLicense cmdlet call
- Add license availability check before assignment
- Add Write-Progress for CSV processing loop

### Testing Notes
- Test with small CSV first (5-10 users)
- Verify -WhatIf works correctly
- Test with users who already have license
```

---

### Step 6C: Script REJECTED
**Actor**: Master Agent → User

**Actions**:
1. Master Agent provides detailed rejection reasons
2. Documents critical issues
3. **Close Branch** (optional):
   ```bash
   git branch -D agent/[role]/[script-name]
   git push origin --delete agent/[role]/[script-name]
   ```
4. User reviews rejection reasons
5. User decides:
   - Fix issues and create new branch (back to Step 3)
   - Revise requirements and start over (back to Step 2)
   - Abandon task

**Rejection Reasons** (examples):
- Critical security vulnerability (hardcoded credentials)
- Potential data loss without safeguards
- Mock code or placeholders present
- Missing critical error handling

---

### Step 7: Testing
**Actor**: User

**Actions**:
1. Review testing requirements from script documentation
2. Set up test environment:
   - Test tenant or isolated test accounts
   - Required permissions
   - Test data
3. Run script with `-WhatIf` first
4. Verify `-WhatIf` output is correct
5. Run script on small test set
6. Verify results
7. Test error scenarios
8. Document test results

**Testing Checklist**:
- [ ] `-WhatIf` works correctly
- [ ] Script runs without errors on test data
- [ ] Results match expectations
- [ ] Error handling works for invalid inputs
- [ ] Logging captures all operations
- [ ] No unintended side effects

**Output**: Test results and validation

---

### Step 8: Production Deployment (Optional)
**Actor**: User

**Actions**:
1. Review test results
2. If tests pass, plan production deployment:
   - Schedule appropriate time
   - Notify stakeholders if needed
   - Prepare rollback plan
3. Run script in production with `-WhatIf` first
4. Review `-WhatIf` output
5. Execute script in production
6. Monitor results
7. Verify success
8. Document execution

**Production Considerations**:
- Run during maintenance window if large impact
- Have rollback plan ready
- Monitor for issues
- Document execution results

---

## Workflow Variations

### Quick Review (Minor Changes)
For small fixes or updates to approved scripts:
1. Specialized Agent makes changes
2. User requests quick review from Master Agent
3. Master Agent reviews changes only
4. Approve or request additional fixes

### Emergency Scripts
For urgent production issues:
1. Follow same workflow but expedite
2. Master Agent prioritizes review
3. Extra caution for safety checks
4. May require additional approval

### Complex Multi-Role Scripts
For scripts requiring multiple admin roles:
1. Identify all required roles
2. May need multiple specialized agents
3. Master Agent reviews integration points
4. Extra validation for cross-service operations

## Communication Protocols

### User → Specialized Agent
- Use prompt templates from `Agents/PROMPT_TEMPLATES.md`
- Be specific about requirements
- Include constraints and limitations

### Specialized Agent → User
- Notify when script is ready
- Highlight any assumptions made
- Note any limitations

### User → Master Agent
- Request review with script location
- Provide context and considerations
- Reference any special requirements

### Master Agent → User
- Provide review report
- Use standard format from `MASTER_AGENT.md`
- Be specific about issues and recommendations

## Quality Gates

### Gate 1: Specialized Agent Self-Review
- Script follows all standards
- No mock code or placeholders
- Basic safety checks pass

### Gate 2: Master Agent Review
- Comprehensive safety review
- Security validation
- Code quality assessment
- Testing readiness check

### Gate 3: Testing Validation
- Script works in test environment
- Results match expectations
- Error handling validated

### Gate 4: Production Readiness (if applicable)
- Test results validated
- Production plan in place
- Rollback plan ready

## Documentation Updates

### After Script Approval
- Update script documentation if needed
- Add to examples if useful pattern
- Update troubleshooting if issues found

### After Testing
- Document test results
- Update script if issues found
- Add to knowledge base

### After Production Use
- Document production results
- Update best practices
- Share lessons learned

## Continuous Improvement

### Review Process
- Track common issues
- Update checklists based on findings
- Refine review criteria

### Agent Improvement
- Share approved patterns
- Document rejected patterns
- Update context documentation

### Workflow Optimization
- Identify bottlenecks
- Streamline processes
- Update documentation

