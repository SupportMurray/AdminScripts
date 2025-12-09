# Project Structure and Guidelines

## Directory Structure

```
Admin_Scripts/
├── README.md                          # Main project documentation
├── MASTER_AGENT.md                    # Master Agent review system
├── BRANCH_WORKFLOW.md                 # Git branch workflow and merge process
├── SAFETY_CHECKLIST.md                # Safety and review checklist
├── PROJECT_STRUCTURE.md               # This file
├── PROJECT_ORGANIZATION.md            # Organization and maintenance guide
├── WORKFLOW.md                        # Workflow documentation
├── Agents/                            # Agent-related documentation
│   ├── AGENT_CONTEXT.md               # Context for all AI agents
│   └── PROMPT_TEMPLATES.md            # Prompt templates for each role
├── Documentation/                     # Additional documentation
│   ├── GETTING_STARTED.md             # Getting started guide
│   ├── QUICK_REFERENCE.md             # Quick reference guide
│   ├── Examples/                      # Example scripts
│   ├── Patterns/                      # Common patterns and snippets
│   └── Troubleshooting/               # Troubleshooting guides
│
├── Scripts/                           # All PowerShell scripts
│   ├── User_Administration/           # User admin scripts
│   ├── Exchange_Administration/       # Exchange admin scripts
│   ├── SharePoint_Administration/     # SharePoint admin scripts
│   ├── Teams_Administration/          # Teams admin scripts
│   ├── Security_Administration/       # Security admin scripts
│   ├── License_Administration/        # License admin scripts
│   ├── Compliance_Administration/     # Compliance admin scripts
│   ├── Audit_Administration/          # Audit admin scripts
│   ├── Intune_Administration/         # Intune/MDM admin scripts
│   ├── UI_Administration/             # Dashboard and UI applications
│   └── Global_Administration/         # Global admin scripts
│
├── Reviews/                           # Master Agent reviews
│   ├── Approved/                      # Approved scripts
│   ├── Needs_Revision/                # Scripts needing revision
│   └── Rejected/                      # Rejected scripts
│
├── Documentation/                     # Additional documentation
│   ├── Examples/                      # Example scripts
│   ├── Patterns/                      # Common patterns and snippets
│   └── Troubleshooting/               # Troubleshooting guides
│
└── Tests/                             # Test scripts and data
    ├── Test_Data/                     # Test data files
    └── Test_Results/                  # Test results and logs
```

## Script Naming Conventions

### Format
`[Action]-[Object]-[OptionalDescription].ps1`

### Examples
- `Get-UserLicenseStatus.ps1`
- `Set-BulkUserProperties.ps1`
- `New-DistributionGroupWithMembers.ps1`
- `Remove-InactiveMailboxes.ps1`
- `Export-TeamMembershipReport.ps1`

### Guidelines
- Use approved PowerShell verbs (Get, Set, New, Remove, Export, Import, etc.)
- Be descriptive but concise
- Use PascalCase
- Include object type in name
- Add description if script has specific purpose

## Script Organization

### Script Header Template
Every script must start with this header:

```powershell
<#
.SYNOPSIS
    Brief one-line description

.DESCRIPTION
    Detailed description of what the script does, including:
    - Purpose and use cases
    - What it modifies or retrieves
    - Any important considerations

.PARAMETER ParameterName
    Description of the parameter, including:
    - Data type
    - Required or optional
    - Example values
    - Any constraints

.EXAMPLE
    .\Script-Name.ps1 -ParameterName "Value"
    Description of what this example does

.EXAMPLE
    .\Script-Name.ps1 -ParameterName "Value" -WhatIf
    Description of dry-run example

.NOTES
    Author: [Agent Name]
    Date: [YYYY-MM-DD]
    Version: 1.0
    Requires:
        - Module: Microsoft.Graph
        - Permissions: User.ReadWrite.All
        - Role: User Administrator
    Changelog:
        - 1.0: Initial version

.LINK
    https://learn.microsoft.com/powershell/microsoftgraph/
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$true)]
    [string]$ParameterName
)
```

## Module Organization

### Function-Based Scripts
For scripts with multiple functions:

```powershell
#region Functions
function Get-UserData {
    <#
    .SYNOPSIS
        Retrieves user data
    #>
    param(...)
    # Function implementation
}

function Set-UserData {
    <#
    .SYNOPSIS
        Sets user data
    #>
    param(...)
    # Function implementation
}
#endregion

#region Main Script
# Main script logic here
#endregion
```

### Script-Based Scripts
For single-purpose scripts:

```powershell
#region Parameters
[CmdletBinding(SupportsShouldProcess)]
param(...)
#endregion

#region Initialization
# Connection setup, validation, etc.
#endregion

#region Main Logic
# Primary script functionality
#endregion

#region Cleanup
# Disconnect, cleanup, etc.
#endregion
```

## File Organization Standards

### Script Files
- **Location**: Appropriate subdirectory in `Scripts/`
- **Extension**: `.ps1`
- **Encoding**: UTF-8 with BOM (for Windows compatibility)
- **Line Endings**: CRLF (Windows) or LF (cross-platform)

### Documentation Files
- **Location**: Same directory as script or `Documentation/`
- **Extension**: `.md` for Markdown, `.txt` for plain text
- **Naming**: Match script name with `.md` extension

### Configuration Files
- **Location**: Same directory as script or `Config/`
- **Extension**: `.json`, `.csv`, `.xml` as appropriate
- **Naming**: Descriptive, match script purpose

### Test Files
- **Location**: `Tests/Test_Data/`
- **Naming**: `Test_[ScriptName]_[Purpose].csv` or similar

## Version Control Guidelines

### Git Workflow
**All agents must use feature branches. See `BRANCH_WORKFLOW.md` for complete details.**

1. **Create branch**: `agent/[role]/[script-name]`
2. **Develop script**: Follow all standards
3. **Self-review**: Check against checklist
4. **Push branch**: Commit and push to remote
5. **Submit for review**: Master Agent reviews branch
6. **Address feedback**: Make revisions in same branch
7. **Merge**: Master Agent merges to main after approval

### Commit Messages
Format: `[Type]: [Description]`

Types:
- `feat`: New script or feature
- `fix`: Bug fix
- `docs`: Documentation update
- `refactor`: Code refactoring
- `test`: Test additions or updates

Examples:
- `feat: Add bulk user license assignment script`
- `fix: Correct error handling in mailbox script`
- `docs: Update User Administrator prompt template`

### What to Commit
- ✅ Script files (.ps1)
- ✅ Documentation files (.md)
- ✅ Configuration templates
- ✅ Test data (sanitized, no real data)

### What NOT to Commit
- ❌ Credentials or secrets
- ❌ Real user data or PII
- ❌ Personal information
- ❌ API keys or connection strings
- ❌ Test results with sensitive data

## Documentation Requirements

### Script Documentation
Every script must have:
1. **Comment-based help** (in script header)
2. **Inline comments** for complex logic
3. **Usage examples** in help
4. **Parameter documentation**

### Additional Documentation
For complex scripts, also provide:
1. **README.md** in script directory
2. **Architecture diagram** (if complex)
3. **Flow chart** (if multi-step process)
4. **Troubleshooting guide** (if applicable)

## Testing Structure

### Test Scripts
- Create test scripts for complex functionality
- Test scripts should use `-WhatIf` extensively
- Test with sample data, not production data
- Document test scenarios

### Test Data
- Use sanitized test data
- No real user information
- Document test data structure
- Include edge cases

### Test Results
- Document test results
- Include success and failure cases
- Note any issues found
- Update script based on findings

## Review Process Integration

### Pre-Submission Checklist
Before submitting for Master Agent review:
- [ ] Script follows naming conventions
- [ ] Script has proper header
- [ ] All functions documented
- [ ] Error handling implemented
- [ ] Logging implemented
- [ ] `-WhatIf` support added
- [ ] Self-reviewed against SAFETY_CHECKLIST.md

### Submission Process
1. Place script in appropriate `Scripts/[Role]/` directory
2. Create review request (document or issue)
3. Master Agent reviews using SAFETY_CHECKLIST.md
4. Address feedback
5. Resubmit if needed
6. Move to `Reviews/Approved/` when approved

### Post-Approval
1. Script is ready for testing
2. Test in appropriate environment
3. Document test results
4. Update script if issues found
5. Mark as production-ready when validated

## Best Practices

### Code Organization
- Group related functions together
- Use regions for organization
- Keep functions focused and single-purpose
- Avoid deep nesting (max 3-4 levels)

### Error Handling
- Use try-catch-finally consistently
- Log all errors with context
- Don't swallow errors silently
- Provide actionable error messages

### Performance
- Filter at source, not in memory
- Use batching for bulk operations
- Implement progress indicators
- Consider throttling limits

### Security
- Never hardcode credentials
- Use secure credential handling
- Validate all inputs
- Follow principle of least privilege

### Maintainability
- Write clear, self-documenting code
- Use meaningful variable names
- Keep functions small and focused
- Document complex logic
- Update documentation with code changes

## Integration with Master Agent

### Review Request Format
When requesting review, include:
1. Script path and name
2. Purpose and use case
3. Any special considerations
4. Testing environment requirements
5. Expected impact

### Review Response
Master Agent will provide:
1. Review status (APPROVED/NEEDS REVISION/REJECTED)
2. Safety assessment
3. Security assessment
4. Code quality feedback
5. Recommendations
6. Testing notes

## Maintenance Guidelines

### Regular Updates
- Review scripts quarterly for deprecated cmdlets
- Update module versions as needed
- Refresh documentation
- Update examples

### Deprecation
- Mark deprecated scripts clearly
- Provide migration path
- Archive old versions
- Update documentation

### Knowledge Sharing
- Document common patterns
- Share approved patterns
- Maintain troubleshooting guides
- Update best practices

