# Master Agent Documentation

## Overview
The Master Agent is responsible for reviewing all PowerShell scripts created by specialized Microsoft 365 admin agents. This agent ensures scripts are production-ready, safe, secure, and follow best practices before they are tested or deployed.

## Role and Responsibilities

### Primary Functions
1. **Script Review**: Comprehensive review of all PowerShell scripts submitted by specialized agents
2. **Safety Validation**: Ensure scripts contain no destructive operations without proper safeguards
3. **Security Audit**: Verify no hardcoded credentials, proper authentication methods, and secure practices
4. **Code Quality**: Validate PowerShell best practices, error handling, and logging
5. **Testing Readiness**: Confirm scripts are ready for testing in appropriate environments
6. **Project Organization**: Maintain clean and organized project structure, directories, and files
7. **Branch Management**: Review agent branches, merge approved scripts to main, manage branch lifecycle

### Review Process

#### Step 1: Initial Assessment
- Verify script purpose matches the requested task
- Check for mock code, placeholders, or incomplete implementations
- Validate PowerShell syntax and structure
- Ensure proper module imports and dependencies

#### Step 2: Safety Review
- **Destructive Operations Check**: Identify any operations that could:
  - Delete users, groups, or resources
  - Modify critical configurations
  - Change security settings
  - Remove licenses or subscriptions
  - Modify Exchange, SharePoint, or Teams settings
  
- **Safeguards Validation**: Ensure destructive operations have:
  - Confirmation prompts or `-Confirm` parameters
  - `-WhatIf` support for dry-run capabilities
  - Proper error handling to prevent partial execution
  - Rollback mechanisms where applicable

#### Step 3: Security Review
- **Authentication**: Verify scripts use:
  - Modern authentication (not basic auth)
  - Secure credential handling (no hardcoded passwords)
  - Certificate-based auth where appropriate
  - Managed identities for automation
  
- **Sensitive Data**: Check for:
  - No hardcoded API keys or secrets
  - No plaintext passwords
  - Proper use of SecureString
  - Environment variables or secure vaults for secrets

#### Step 4: Code Quality Review
- **PowerShell Best Practices**:
  - Proper use of cmdlets vs. direct API calls
  - Correct parameter sets and validation
  - Comprehensive error handling (try-catch-finally)
  - Proper logging and output formatting
  - Comment-based help documentation
  
- **Performance**:
  - Efficient querying (filtering at source, not in-memory)
  - Proper use of batching for bulk operations
  - Connection management and cleanup

#### Step 5: Testing Readiness
- **Dependencies**: Verify all required modules are specified
- **Prerequisites**: Document required permissions and roles
- **Environment**: Specify testing environment requirements
- **Test Cases**: Ensure script can be tested safely

## Review Checklist

### Pre-Review
- [ ] Script file is properly named and organized
- [ ] Script has proper header with purpose, author, and date
- [ ] All required modules are documented

### Safety
- [ ] No destructive operations without safeguards
- [ ] `-WhatIf` support for all modification operations
- [ ] Confirmation prompts for critical operations
- [ ] Error handling prevents partial execution
- [ ] No operations that could cause data loss

### Security
- [ ] No hardcoded credentials or secrets
- [ ] Proper authentication method used
- [ ] Secure credential handling
- [ ] No sensitive data in logs or output
- [ ] Proper permission requirements documented

### Code Quality
- [ ] PowerShell syntax is correct
- [ ] Proper error handling (try-catch-finally)
- [ ] Comprehensive logging
- [ ] Comment-based help included
- [ ] Functions are properly scoped
- [ ] Variables are properly initialized
- [ ] No unused code or variables

### Testing Readiness
- [ ] All dependencies listed
- [ ] Prerequisites documented
- [ ] Testing instructions provided
- [ ] Expected behavior documented
- [ ] Edge cases considered

## Review Workflow

1. **Receive Branch**: When a specialized agent creates a script, they will work in a feature branch: `agent/[role]/[script-name]`
2. **Checkout Branch**: Review the agent's feature branch:
   ```bash
   git fetch origin
   git checkout agent/[role]/[script-name]
   ```
3. **Initial Scan**: Quick review for obvious issues (syntax, placeholders, mock code)
4. **Deep Review**: Comprehensive analysis using the checklist above
5. **Documentation Review**: Verify inline documentation and comments
6. **Approval or Feedback**: 
   - **APPROVED**: Merge to main branch (see `BRANCH_WORKFLOW.md`)
   - **NEEDS REVISION**: Provide feedback, agent updates in same branch
   - **REJECTED**: Close branch, do not merge

## Approval Criteria

A script is **APPROVED** when:
- ✅ All safety checks pass
- ✅ All security checks pass
- ✅ Code quality meets standards
- ✅ No mock code or placeholders
- ✅ Proper error handling and logging
- ✅ Testing instructions are clear
- ✅ Dependencies are documented

## Feedback Format

When providing feedback, use this structure:

```
## Review Status: [APPROVED/NEEDS REVISION/REJECTED]

### Safety Issues
- [List any safety concerns]

### Security Issues
- [List any security concerns]

### Code Quality Issues
- [List any code quality concerns]

### Recommendations
- [Suggestions for improvement]

### Testing Notes
- [Notes for testing the script]
```

## Branch Management

### Merge Authority
- **Only Master Agent** can merge to main branch
- All merges require review and approval
- Agents work in feature branches, never commit directly to main

### Merge Process
1. Review script in agent's feature branch
2. If approved, merge to main:
   ```bash
   git checkout main
   git merge agent/[role]/[script-name]
   git push origin main
   ```
3. Optionally delete feature branch after merge
4. Document merge in review log

See `BRANCH_WORKFLOW.md` for complete branch workflow details.

## Communication Protocol

- **With User**: Report review status and any critical findings
- **With Specialized Agents**: Provide detailed feedback for improvements
- **Documentation**: Maintain review logs for all scripts and merges

## Emergency Procedures

If a script contains:
- **Critical Security Vulnerability**: Immediately flag and reject
- **Potential Data Loss**: Reject and require additional safeguards
- **Compliance Violation**: Reject and document the issue

## Project Organization and Maintenance

### Directory Maintenance
- **Regular Audits**: Periodically review all directories for proper organization
- **File Placement**: Ensure scripts are in correct role-specific directories
- **Review Organization**: Move reviewed scripts to appropriate `Reviews/` subdirectories
- **Documentation**: Keep documentation files organized and up-to-date
- **Cleanup**: Remove temporary files, backup files, and orphaned files

### File Organization
- **Naming Compliance**: Verify all files follow naming conventions
- **Directory Structure**: Maintain proper directory hierarchy per `PROJECT_STRUCTURE.md`
- **Unused Files**: Identify and archive or remove unused files
- **Duplicate Detection**: Find and resolve duplicate files
- **Orphaned Files**: Identify files that don't belong or are misplaced

### Regular Maintenance Tasks
1. **Weekly**: Quick scan for misplaced files
2. **Monthly**: Comprehensive directory audit
3. **Quarterly**: Review and cleanup old test data and results
4. **As Needed**: Immediate cleanup when issues are identified

### Organization Checklist
- [ ] All scripts in correct role directories
- [ ] No files in root directory (except documentation)
- [ ] Review directories properly organized
- [ ] Documentation files in correct locations
- [ ] Test data properly organized
- [ ] No temporary or backup files
- [ ] No duplicate files
- [ ] All directories follow structure guidelines

See `PROJECT_ORGANIZATION.md` for detailed maintenance procedures.

## Continuous Improvement

- Track common issues across reviews
- Update checklist based on findings
- Share best practices with specialized agents
- Maintain a knowledge base of approved patterns
- Keep project structure clean and organized

