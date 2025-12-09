# Agents Directory

This directory contains all documentation and resources related to AI agents working on Microsoft 365 automation scripts.

## 🚨 IMPORTANT: Start Here

**ALL AGENTS MUST READ `AGENT_CONTEXT.md` BEFORE CREATING SCRIPTS!**

This document contains critical file organization rules that MUST be followed.

**Quick Rule:** Save scripts in `Scripts/[YourRole_Administration]/` - NEVER in root!

---

## Contents

### AGENT_CONTEXT.md
**⭐ REQUIRED READING - Contains file organization rules!**

Core principles, standards, and context for all specialized agents. This document establishes:
- **File organization rules** (CRITICAL - where to save scripts)
- Safety and security standards
- PowerShell best practices
- Microsoft 365 environment context
- Script structure standards
- Common patterns and examples
- Authentication requirements

**Who should read this:**
- All specialized agents (User Admin, Exchange Admin, etc.)
- Agents creating scripts for the first time
- Agents needing to understand standards

**⚠️ Key Sections:**
- "File Organization - CRITICAL" - WHERE to save files
- "Authentication for Testing" - HOW to test scripts
- "Submission Process" - HOW to submit for review

### PROMPT_TEMPLATES.md
Standardized prompt templates for each Microsoft 365 admin role. Includes:
- User Administrator template
- Exchange Administrator template
- SharePoint Administrator template
- Teams Administrator template
- Security Administrator template
- License Administrator template
- Compliance Administrator template
- Audit Administrator template
- Intune/MDM Administrator template
- UI/Dashboard Administrator template
- Global Administrator template

**Who should use this:**
- Users requesting scripts from specialized agents
- Anyone creating prompts for agent tasks

### UI/Dashboard Administrator (Special Role)

**⚠️ ONGOING MAINTENANCE ROLE:**

The UI/Dashboard Administrator has unique ongoing responsibilities:
1. **Initial Creation:** Build the Material-UI dashboard
2. **Continuous Maintenance:** Update dashboard when new scripts are added
3. **Feature Enhancement:** Add UI support for new script capabilities
4. **Script Discovery:** Maintain automatic script detection

**Prompt Location:** `UI_ADMIN_COMPREHENSIVE_PROMPT.txt` (root directory)

**Ongoing Tasks:**
- Monitor for new scripts added by other agents
- Update UI to include new scripts
- Enhance dashboard based on usage
- Maintain documentation

## Usage

### For Users
1. Open `PROMPT_TEMPLATES.md`
2. Select the appropriate role template
3. Fill in TASK and REQUIREMENTS sections
4. Submit to the specialized agent

### For Specialized Agents

**BEFORE creating scripts:**
1. Read `AGENT_CONTEXT.md` - Contains ALL standards and file organization rules
2. Read `../Documentation/AUTHENTICATION_GUIDE.md` - Authentication setup
3. Understand the directory structure below

**CRITICAL: File Organization**

Always place scripts in the correct directory:

```
Scripts/
├── User_Administration/          ← User admin scripts go here
├── Exchange_Administration/      ← Exchange admin scripts go here
├── SharePoint_Administration/    ← SharePoint admin scripts go here
├── Teams_Administration/         ← Teams admin scripts go here
├── Security_Administration/      ← Security admin scripts go here
├── License_Administration/       ← License admin scripts go here
├── Compliance_Administration/    ← Compliance admin scripts go here
├── Audit_Administration/         ← Audit admin scripts go here
├── Intune_Administration/        ← Intune/MDM admin scripts go here
└── Global_Administration/        ← Global admin scripts go here
```

**Example:**
- If you're the User Administrator agent, save scripts in: `Scripts/User_Administration/`
- If you're the Security Administrator agent, save scripts in: `Scripts/Security_Administration/`

**NEVER save scripts in:**
- ❌ The project root directory
- ❌ The Scripts/ directory directly (must be in a role subfolder)
- ❌ Any other location

**Test outputs go in:** `Tests/Test_Results/`

## Audit-Specific Guidance

Auditing scripts differ significantly from administrative scripts in their purpose and approach:

### Key Differences

**Administrative Scripts:**
- **Purpose**: Make changes to the environment
- **Operations**: Create, update, delete resources
- **Safety**: Require -WhatIf support and confirmations
- **Permissions**: Write permissions required
- **Risk**: High risk of unintended changes

**Audit Scripts:**
- **Purpose**: Observe and report on the environment
- **Operations**: Read-only data collection and analysis
- **Safety**: Focus on privacy and data protection
- **Permissions**: Read-only permissions sufficient
- **Risk**: Low operational risk, but privacy concerns

### Audit Script Characteristics

1. **Read-Only Focus**
   - No modification operations
   - No -WhatIf required (nothing to test)
   - Focus on data collection and analysis

2. **Large Data Volumes**
   - Must handle thousands to millions of records
   - Requires efficient pagination and streaming
   - Memory management is critical
   - Progress indicators are essential

3. **Historical Analysis**
   - Time-based queries (date ranges)
   - Trend analysis over periods
   - Incremental collection for scheduled runs

4. **Reporting Emphasis**
   - Not just data dumps
   - Visual and summary reports
   - Executive summaries with KPIs
   - Actionable recommendations
   - Multiple export formats (CSV, JSON, HTML)

5. **Compliance Requirements**
   - Secure storage and transmission
   - Data retention policies
   - Privacy protection (PII handling)
   - Audit trail of audit activities (meta-auditing)

6. **Performance Optimization**
   - API throttling and retry logic
   - Parallel processing where possible
   - Caching of reference data
   - Filter at API level, not in PowerShell

### Common Audit Use Cases

**Security Auditing:**
- Sign-in analysis (successful, failed, risky)
- MFA adoption and coverage
- Conditional Access effectiveness
- Privileged account activity
- Security alert correlation

**Compliance Auditing:**
- DLP event tracking
- Retention policy compliance
- eDiscovery activity
- Sensitivity label usage
- Data governance posture

**Activity Auditing:**
- File access and sharing
- Mail flow analysis
- Teams usage patterns
- External sharing tracking
- Guest user activity

**Resource Auditing:**
- Storage usage and trends
- Mailbox size analysis
- License utilization
- Service adoption metrics
- Inactive resource identification

**Behavioral Analytics:**
- User activity patterns
- Anomaly detection
- Off-hours access
- Unusual download volumes
- Geographic anomalies

### Audit Data Sources

**Primary Sources:**
- **Unified Audit Log** (Search-UnifiedAuditLog)
  - The primary comprehensive audit source
  - Covers all M365 services
  - 90-day standard retention, 1+ year for E5

- **Sign-In Logs** (Get-MgAuditLogSignIn)
  - Authentication and access analysis
  - Risk detection integration
  - Device and location information

- **Directory Audit Logs** (Get-MgAuditLogDirectoryAudit)
  - Azure AD changes
  - Role assignments
  - Policy modifications

**Service-Specific Sources:**
- Exchange: Message trace, mailbox audit logs
- SharePoint/OneDrive: Site access, file activity
- Teams: Usage reports, meeting data
- Usage Reports: Per-service activity metrics

### Best Practices for Audit Scripts

1. **Data Collection**
   - Use efficient pagination patterns
   - Implement throttling retry logic
   - Filter at API level
   - Support date range parameters
   - Enable incremental collection

2. **Data Processing**
   - Process in batches
   - Aggregate and summarize
   - Calculate meaningful metrics
   - Detect anomalies and patterns

3. **Reporting**
   - Generate executive summaries
   - Include visualizations where helpful
   - Provide actionable recommendations
   - Support multiple export formats
   - Include metadata (collection time, parameters)

4. **Privacy & Compliance**
   - Document PII collection
   - Support data anonymization
   - Respect GDPR requirements
   - Include retention recommendations
   - Log audit script executions

5. **Performance**
   - Show progress indicators
   - Handle large datasets efficiently
   - Cache reference data
   - Consider parallel processing
   - Optimize API calls

### Reference Patterns in AGENT_CONTEXT.md

Key patterns for audit scripts:
- **Unified Audit Log Pattern** - Primary audit data collection
- **Sign-In Audit Pattern** - Security and access analysis
- **Message Trace Pattern** - Email flow auditing
- **Graph Pagination Pattern** - Handle large result sets
- **Graph Throttling Pattern** - Retry logic for rate limits
- **Advanced HTML Report Pattern** - Executive reporting
- **Incremental Collection Pattern** - Scheduled audit runs
- **Privacy Protection Pattern** - PII handling and anonymization
- **Audit Session Pattern** - Meta-auditing (audit the audits)

## Related Documentation

- `../MASTER_AGENT.md` - Master Agent review system
- `../SAFETY_CHECKLIST.md` - Review checklist
- `../PROJECT_STRUCTURE.md` - File organization
- `../WORKFLOW.md` - Complete workflow process

