# Safety and Review Checklist

## Purpose
This checklist is used by the Master Agent to ensure all PowerShell scripts are safe, secure, and ready for testing. Every script must pass all applicable checks before approval.

## Pre-Review Checks

### File Structure
- [ ] Script file has proper naming convention (descriptive, no spaces)
- [ ] Script is in appropriate directory structure
- [ ] No temporary or backup files included
- [ ] Script header includes purpose, author, and date

### Basic Syntax
- [ ] PowerShell syntax is valid (no syntax errors)
- [ ] All cmdlets and functions are properly referenced
- [ ] No undefined variables or functions
- [ ] Proper use of PowerShell operators and syntax

### Code Completeness
- [ ] **NO MOCK CODE OR PLACEHOLDERS**
- [ ] All functions are fully implemented
- [ ] No TODO comments or incomplete sections
- [ ] All required logic is present
- [ ] Script is executable end-to-end

---

## Safety Checks

### Destructive Operations

#### User Operations
- [ ] User deletion requires confirmation or `-Confirm` parameter
- [ ] User deletion supports `-WhatIf`
- [ ] User property changes are logged
- [ ] Bulk user operations have progress indicators
- [ ] User operations validate user existence first

#### Group Operations
- [ ] Group deletion requires confirmation
- [ ] Group deletion supports `-WhatIf`
- [ ] Group membership changes are logged
- [ ] Group property changes are reversible where possible

#### Mailbox Operations
- [ ] Mailbox deletion requires confirmation
- [ ] Mailbox deletion supports `-WhatIf`
- [ ] Mailbox operations validate mailbox existence
- [ ] Mailbox data operations have safeguards

#### Site/SharePoint Operations
- [ ] Site deletion requires confirmation
- [ ] Site deletion supports `-WhatIf`
- [ ] Site permission changes are logged
- [ ] Site operations validate site existence

#### Teams Operations
- [ ] Team deletion requires confirmation
- [ ] Team deletion supports `-WhatIf`
- [ ] Team operations validate team existence
- [ ] Team membership changes are logged

#### License Operations
- [ ] License removal requires confirmation
- [ ] License removal supports `-WhatIf`
- [ ] License availability is checked before assignment
- [ ] License conflicts are handled appropriately

#### Policy Operations
- [ ] Policy deletion requires confirmation
- [ ] Policy deletion supports `-WhatIf`
- [ ] Policy changes are logged with before/after values
- [ ] Policy changes document impact

### Safeguards
- [ ] All modification operations support `-WhatIf`
- [ ] Critical operations require `-Confirm` or explicit confirmation
- [ ] Error handling prevents partial execution
- [ ] Rollback mechanisms where applicable
- [ ] No operations that could cause data loss without safeguards

### Error Handling
- [ ] Try-catch blocks for all critical operations
- [ ] Proper error messages with context
- [ ] Errors don't expose sensitive information
- [ ] Errors are logged appropriately
- [ ] Script doesn't continue after critical errors
- [ ] Cleanup operations in finally blocks

---

## Security Checks

### Authentication
- [ ] No hardcoded credentials
- [ ] No plaintext passwords in code
- [ ] Uses modern authentication (OAuth 2.0, certificate-based)
- [ ] Proper credential handling (SecureString, credential objects)
- [ ] No credentials in logs or output
- [ ] Uses appropriate authentication scopes (principle of least privilege)

### Secrets Management
- [ ] No API keys hardcoded
- [ ] No connection strings with credentials
- [ ] Secrets stored securely (Key Vault, environment variables, etc.)
- [ ] No secrets in version control
- [ ] Proper use of SecureString for sensitive data

### Permissions
- [ ] Required permissions are documented
- [ ] Script uses minimum required permissions
- [ ] Permission requirements are clear in documentation
- [ ] No assumption of elevated permissions

### Data Handling
- [ ] No sensitive data in logs
- [ ] No sensitive data in console output
- [ ] Proper handling of PII (Personally Identifiable Information)
- [ ] Secure transmission of data
- [ ] Proper data sanitization in logs

---

## Code Quality Checks

### PowerShell Best Practices
- [ ] Uses approved PowerShell verbs for functions
- [ ] Proper function naming (PascalCase)
- [ ] Proper parameter naming and validation
- [ ] Comment-based help for all functions
- [ ] Proper use of cmdlet binding attributes
- [ ] Appropriate use of pipeline input
- [ ] Proper variable scoping

### Error Handling
- [ ] Comprehensive try-catch-finally blocks
- [ ] Proper error object handling
- [ ] Meaningful error messages
- [ ] Error logging
- [ ] Graceful failure handling

### Logging
- [ ] Logging function implemented
- [ ] Appropriate log levels (Info, Warning, Error, Success)
- [ ] Timestamps in logs
- [ ] Log file location is appropriate
- [ ] Log rotation or size limits considered
- [ ] No sensitive data in logs

### Performance
- [ ] Efficient querying (filtering at source)
- [ ] Proper use of batching for bulk operations
- [ ] Progress indicators for long operations
- [ ] Connection management (connect/disconnect properly)
- [ ] Memory-efficient processing of large datasets
- [ ] Throttling considerations for API calls

### Documentation
- [ ] Comment-based help for all functions
- [ ] Inline comments for complex logic
- [ ] Examples in help documentation
- [ ] Parameter documentation complete
- [ ] Return value documentation
- [ ] Usage examples provided

---

## Testing Readiness Checks

### Dependencies
- [ ] All required modules are documented
- [ ] Module versions specified if critical
- [ ] Installation instructions provided
- [ ] Module availability checked in script

### Prerequisites
- [ ] Required permissions documented
- [ ] Required roles documented
- [ ] Required licenses documented
- [ ] Environment requirements documented
- [ ] Pre-requisite configurations documented

### Testing Instructions
- [ ] Testing steps are clear
- [ ] Test data requirements specified
- [ ] Expected results documented
- [ ] Edge cases considered
- [ ] Rollback procedures documented if needed

### Validation
- [ ] Input validation implemented
- [ ] Parameter validation attributes used
- [ ] Data type validation
- [ ] Range validation where applicable
- [ ] Format validation (email, UPN, etc.)

---

## Operational Checks

### Connection Management
- [ ] Proper connection establishment
- [ ] Connection error handling
- [ ] Proper disconnection in finally blocks
- [ ] Multiple service connections handled correctly
- [ ] Connection state validation

### Resource Cleanup
- [ ] Temporary files cleaned up
- [ ] Connections closed properly
- [ ] Memory resources released
- [ ] No resource leaks

### Output and Reporting
- [ ] Clear output formatting
- [ ] Progress indicators for long operations
- [ ] Summary information provided
- [ ] Results are actionable
- [ ] Output is appropriate for automation

---

## Compliance and Best Practices

### Microsoft 365 Best Practices
- [ ] Follows Microsoft recommended practices
- [ ] Uses official Microsoft modules
- [ ] Respects throttling limits
- [ ] Proper use of Graph API vs. legacy APIs
- [ ] Modern authentication methods

### Scripting Best Practices
- [ ] No deprecated cmdlets or methods
- [ ] Proper use of PowerShell 7+ features where applicable
- [ ] Cross-platform considerations if applicable
- [ ] Proper module management

---

## Review Decision Matrix

### APPROVED
✅ All safety checks pass
✅ All security checks pass
✅ Code quality meets standards
✅ No mock code or placeholders
✅ Proper error handling and logging
✅ Testing instructions are clear
✅ Dependencies are documented

### NEEDS REVISION
⚠️ Minor safety or security concerns
⚠️ Code quality issues that don't prevent testing
⚠️ Missing documentation or examples
⚠️ Performance optimizations needed
⚠️ Error handling improvements needed

### REJECTED
❌ Critical safety issues (data loss risk)
❌ Critical security vulnerabilities
❌ Mock code or placeholders present
❌ Missing critical error handling
❌ No safeguards for destructive operations
❌ Hardcoded credentials or secrets

---

## Review Notes Template

```
## Script Review: [Script Name]

**Date:** [Date]
**Reviewer:** Master Agent
**Status:** [APPROVED/NEEDS REVISION/REJECTED]

### Summary
[Brief summary of the script and review outcome]

### Safety Assessment
- [List safety findings]

### Security Assessment
- [List security findings]

### Code Quality Assessment
- [List code quality findings]

### Testing Readiness
- [List testing readiness findings]

### Recommendations
- [List recommendations for improvement]

### Approval Conditions
- [If NEEDS REVISION, list what must be fixed]

### Next Steps
- [What happens next]
```

---

## Continuous Improvement

- Track common issues across reviews
- Update checklist based on new findings
- Share patterns with specialized agents
- Maintain knowledge base of approved patterns
- Document rejected patterns and why

