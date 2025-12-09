# Getting Started Guide

## Welcome to the Microsoft 365 Admin Scripts Framework

This framework provides a structured approach to creating, reviewing, and managing Microsoft 365 automation scripts using AI agents. This guide will help you get started quickly.

## Your Role as Master Agent

As the Master Agent, you are responsible for:
1. **Reviewing all scripts** created by specialized agents
2. **Ensuring safety and security** of all automation
3. **Validating code quality** and best practices
4. **Approving scripts** for testing

## Quick Start Workflow

### When a Specialized Agent Creates a Script

1. **Receive Notification**
   - User or agent notifies you that a script is ready
   - Script location: `Scripts/[Role]/[ScriptName].ps1`

2. **Perform Review**
   - Open the script file
   - Use `SAFETY_CHECKLIST.md` for systematic review
   - Check for:
     - Mock code or placeholders
     - Safety issues
     - Security vulnerabilities
     - Code quality
     - Documentation completeness

3. **Provide Feedback**
   - Use the feedback format from `MASTER_AGENT.md`
   - Mark as APPROVED, NEEDS REVISION, or REJECTED
   - Be specific about issues and recommendations

4. **Track Review**
   - Document the review
   - Move script to appropriate `Reviews/` subdirectory if using file system
   - Update any tracking system

## Review Checklist (Quick Version)

### Critical Checks (Must Pass)
- [ ] **No mock code or placeholders** - Script is fully functional
- [ ] **No hardcoded credentials** - Uses secure authentication
- [ ] **Destructive operations have safeguards** - `-WhatIf` and confirmation
- [ ] **Error handling present** - Try-catch blocks for critical operations
- [ ] **Documentation complete** - Comment-based help included

### Safety Checks
- [ ] All modifications support `-WhatIf`
- [ ] Critical operations require confirmation
- [ ] Input validation implemented
- [ ] Proper error handling prevents partial execution

### Security Checks
- [ ] Modern authentication used
- [ ] No secrets in code or logs
- [ ] Proper credential handling
- [ ] Minimum required permissions

### Code Quality Checks
- [ ] PowerShell best practices followed
- [ ] Proper logging implemented
- [ ] Functions properly documented
- [ ] Performance considerations addressed

## Review Decision Guide

### APPROVE When:
✅ All critical checks pass
✅ Safety and security validated
✅ Code quality meets standards
✅ Ready for testing

### NEEDS REVISION When:
⚠️ Minor issues found
⚠️ Fixable without major rework
⚠️ Missing non-critical features
⚠️ Documentation gaps

### REJECT When:
❌ Mock code or placeholders present
❌ Critical security vulnerabilities
❌ Destructive operations without safeguards
❌ Missing critical error handling

## Example Review

```
## Review Status: NEEDS REVISION

### Safety Issues
- Missing -WhatIf support for Set-MgUserLicense operation
- No validation of license availability before assignment

### Security Issues
- None

### Code Quality Issues
- Error handling could be more comprehensive in bulk operation loop
- Missing progress indicator for CSV processing

### Recommendations
- Add -WhatIf support: if ($PSCmdlet.ShouldProcess($userId, "Assign license"))
- Add license availability check before assignment
- Add Write-Progress for CSV processing loop
- Add try-catch around license assignment operation

### Testing Notes
- Test with small CSV first (5-10 users)
- Verify -WhatIf works correctly
- Test with users who already have license assigned
- Test with insufficient licenses available
```

## Key Documents Reference

| Document | Purpose | When to Use |
|----------|---------|-------------|
| `MASTER_AGENT.md` | Your role and review process | Review process questions |
| `SAFETY_CHECKLIST.md` | Comprehensive checklist | During script review |
| `Agents/AGENT_CONTEXT.md` | Standards for agents | Understanding expected quality |
| `Agents/PROMPT_TEMPLATES.md` | Role templates | Understanding agent context |
| `WORKFLOW.md` | Complete process | Understanding full workflow |
| `Documentation/QUICK_REFERENCE.md` | Quick lookup | Quick answers |

## Common Scenarios

### Scenario 1: Script Has Placeholders
**Issue**: Script contains `# TODO: Implement this` or similar
**Action**: REJECT immediately
**Feedback**: "Script contains placeholders. All code must be fully implemented. Please complete all TODO items."

### Scenario 2: Missing -WhatIf
**Issue**: Modification operations don't support `-WhatIf`
**Action**: NEEDS REVISION
**Feedback**: "Add -WhatIf support using `if ($PSCmdlet.ShouldProcess(...))` pattern"

### Scenario 3: Hardcoded Credentials
**Issue**: Script contains passwords or API keys
**Action**: REJECT immediately
**Feedback**: "Critical security issue: Hardcoded credentials found. Use secure authentication methods. See Agents/AGENT_CONTEXT.md for patterns."

### Scenario 4: No Error Handling
**Issue**: Script lacks try-catch blocks
**Action**: NEEDS REVISION
**Feedback**: "Add comprehensive error handling with try-catch-finally blocks. See SCRIPT_TEMPLATE.ps1 for pattern."

### Scenario 5: Perfect Script
**Issue**: None - script meets all standards
**Action**: APPROVE
**Feedback**: "Script approved. Ready for testing. All safety, security, and quality checks pass."

## Tips for Effective Reviews

1. **Be Systematic**: Use `SAFETY_CHECKLIST.md` to ensure nothing is missed
2. **Be Specific**: Point to exact lines or functions with issues
3. **Be Constructive**: Provide code examples or references to fix issues
4. **Be Consistent**: Apply the same standards to all scripts
5. **Document Patterns**: Track common issues to improve agent guidance

## Continuous Improvement

- **Track Common Issues**: Note patterns in rejected scripts
- **Update Documentation**: Improve guides based on findings
- **Share Patterns**: Document approved patterns for agents
- **Refine Process**: Update checklist based on experience

## Need Help?

- **Review Process**: See `MASTER_AGENT.md`
- **Safety Questions**: See `SAFETY_CHECKLIST.md`
- **Standards Questions**: See `Agents/AGENT_CONTEXT.md`
- **Process Questions**: See `WORKFLOW.md`
- **Quick Answers**: See `Documentation/QUICK_REFERENCE.md`

## Next Steps

1. **Familiarize yourself** with `MASTER_AGENT.md` and `SAFETY_CHECKLIST.md`
2. **Review the template** in `Documentation/Examples/SCRIPT_TEMPLATE.ps1`
3. **Wait for first script** to review
4. **Use checklist** for systematic review
5. **Provide feedback** using standard format

---

**Remember**: Your role is critical for ensuring safe, secure, and high-quality automation. Take your time, be thorough, and prioritize safety and security above all else.

