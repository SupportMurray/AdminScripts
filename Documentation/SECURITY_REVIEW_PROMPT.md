# Security Agent Prompt - Full Microsoft 365 Security Review

## Complete Prompt for Security Agent

Copy and paste this entire prompt to the Security Agent:

---

```
You are a Microsoft 365 Security Administrator and PowerShell automation expert specializing in comprehensive security assessments.

CONTEXT:
- Review Agents/AGENT_CONTEXT.md for standards and best practices
- All scripts must be production-ready with no mock code or placeholders
- Scripts will be reviewed by the Master Agent before testing
- Use Microsoft Graph PowerShell SDK and Security modules
- Follow PowerShell best practices and security standards
- Create scripts in branch: agent/security-admin/full-security-review
- Security operations require EXTRA caution and validation

TASK:
Create a comprehensive PowerShell script to perform a full security review of our Microsoft 365 environment. The script should assess all critical security domains and generate a detailed security report with findings, risk ratings, and remediation recommendations.

REQUIREMENTS:

1. IDENTITY & ACCESS MANAGEMENT REVIEW
   - Audit Conditional Access policies (coverage, gaps, misconfigurations)
   - MFA enforcement status for all users (enabled, enforced, excluded)
   - Legacy authentication usage and blocking
   - Password policies and authentication methods
   - Privileged accounts and admin roles audit
   - Guest user access and external collaboration settings
   - Identity Protection policies and risk detection
   - Sign-in risk policies and user risk policies
   - Self-service password reset configuration
   - Account lockout and password expiration settings

2. THREAT PROTECTION ASSESSMENT
   - Microsoft Defender for Office 365 configuration
   - Anti-phishing policies (impersonation, domain protection)
   - Anti-malware and safe attachments configuration
   - Safe links policies and URL rewriting
   - ATP (Advanced Threat Protection) policies coverage
   - Threat analytics and security alerts
   - Email authentication (SPF, DKIM, DMARC) status
   - Quarantine policies and admin notifications

3. DATA PROTECTION REVIEW
   - Data Loss Prevention (DLP) policies audit
   - Information Protection labels and policies
   - Sensitivity labels usage and coverage
   - Encryption settings (BitLocker, RMS, OME)
   - Data classification status
   - External sharing settings (SharePoint, OneDrive, Teams)
   - Rights Management configuration
   - Insider risk management policies

4. COMPLIANCE & GOVERNANCE
   - Audit logging enablement (mailbox, admin, unified)
   - Retention policies coverage (Exchange, SharePoint, Teams)
   - eDiscovery cases and holds
   - Communication compliance policies
   - Compliance score and recommendations
   - Alert policies and notifications
   - Litigation hold status
   - Content searches and exports

5. APPLICATION SECURITY
   - Azure AD app registrations review
   - OAuth consent grants audit (user and admin)
   - Service principals and managed identities
   - API permissions scope review
   - Application access policies
   - Risky applications detection
   - Unused applications cleanup
   - Third-party app integrations

6. EMAIL SECURITY
   - Exchange Online Protection (EOP) configuration
   - Transport rules security review
   - Mailbox delegation and permissions
   - Forwarding rules audit (auto-forward detection)
   - Shared mailbox security
   - Mail flow rules and connectors
   - Inbox rules audit (suspicious rules)
   - External email warnings

7. COLLABORATION SECURITY
   - Teams external access settings
   - Teams guest access policies
   - SharePoint external sharing
   - OneDrive sharing settings
   - Files and folder permissions
   - Anonymous sharing links
   - Expiration policies for shared links

8. DEVICE & ENDPOINT SECURITY
   - Device compliance policies
   - Intune configuration profiles
   - Conditional Access for devices
   - Mobile device management (MDM)
   - Mobile application management (MAM)
   - Device enrollment restrictions

9. MONITORING & ALERTING
   - Security alerts configuration
   - Alert policies and rules
   - Admin activity monitoring
   - Sign-in logs analysis
   - Risky sign-ins detection
   - Anomaly detection alerts
   - Security incidents tracking

10. PRIVILEGED ACCESS REVIEW
    - Global Administrators count and activity
    - Emergency access accounts
    - Role assignments audit
    - Privileged Identity Management (PIM)
    - Just-in-time access
    - Admin consent workflow
    - Break-glass accounts

TECHNICAL REQUIREMENTS:
- Use Microsoft.Graph.Security module
- Use Microsoft.Graph.Identity.SignIns module
- Use ExchangeOnlineManagement module
- Required permissions: Security.Read.All, AuditLog.Read.All, Policy.Read.All
- Support -WhatIf for any modification operations (if included)
- Include comprehensive error handling
- Handle API throttling and pagination
- Process large datasets efficiently
- Include progress indicators for long operations

OUTPUT REQUIREMENTS:
- Generate comprehensive security findings
- Rate each finding: Critical, High, Medium, Low, Info
- Provide detailed remediation steps
- Include security best practice references
- Map findings to compliance frameworks:
  * CIS Microsoft 365 Foundations Benchmark
  * NIST Cybersecurity Framework
  * ISO 27001 controls
  * Microsoft Secure Score
- Generate executive summary with:
  * Overall security posture rating
  * Critical findings count
  * High-priority recommendations
  * Compliance status
  * Risk score calculation
- Export results in multiple formats:
  * HTML report with styling and charts
  * CSV for detailed analysis
  * JSON for automation
  * Executive summary PDF (if possible)

SCRIPT STRUCTURE:
1. Parameters section with output options
2. Authentication and connection handling
3. Security check functions (one per domain)
4. Risk scoring and prioritization
5. Report generation functions
6. Executive summary generation
7. Proper cleanup and disconnection

DELIVERABLES:
- Main security review script: Get-M365SecurityReview.ps1
- Place in: Scripts/Security_Administration/
- Include comment-based help
- Add usage examples
- Document required permissions
- Include test mode (limit scope for testing)

After creating the script, commit to branch agent/security-admin/full-security-review and notify the user for Master Agent review.
```

---

## What the Security Agent Will Create

The Security Agent will create a comprehensive PowerShell script that:

1. **Connects to Microsoft 365** with appropriate permissions
2. **Performs 10+ security assessments** across all critical domains
3. **Generates detailed findings** with risk ratings
4. **Provides remediation guidance** for each issue
5. **Creates multiple report formats** (HTML, CSV, JSON)
6. **Includes compliance mapping** (CIS, NIST, ISO 27001)
7. **Calculates risk scores** and security posture
8. **Produces executive summary** for leadership

## Expected Output Script

The script will be named: `Get-M365SecurityReview.ps1`

Location: `Scripts/Security_Administration/Get-M365SecurityReview.ps1`

## How to Use After Creation

Once the Security Agent creates the script and it's reviewed:

```powershell
# Connect to Microsoft 365
Connect-MgGraph -Scopes "Security.Read.All", "AuditLog.Read.All", "Policy.Read.All"

# Run full security review
./Scripts/Security_Administration/Get-M365SecurityReview.ps1 -OutputPath "./SecurityReview_$(Get-Date -Format 'yyyyMMdd').html"

# Run with detailed logging
./Scripts/Security_Administration/Get-M365SecurityReview.ps1 -OutputPath "./review.html" -Verbose

# Run quick scan (test mode)
./Scripts/Security_Administration/Get-M365SecurityReview.ps1 -QuickScan -OutputPath "./quick-review.html"
```

## Review Checklist for Master Agent

When the script is ready for review, check for:
- ✅ No mock code or placeholders
- ✅ Comprehensive security checks across all domains
- ✅ Proper error handling and logging
- ✅ Risk scoring and prioritization
- ✅ Actionable remediation recommendations
- ✅ Multiple export formats
- ✅ Executive summary generation
- ✅ Compliance framework mapping
- ✅ API throttling handling
- ✅ Progress indicators for long operations

## Additional Security Prompts

If you want the Security Agent to create specific focused scripts:

### Quick Prompts for Specific Security Reviews

**1. Conditional Access Review:**
```
Create a script to audit all Conditional Access policies, identify gaps in coverage, detect misconfigurations, and recommend improvements based on Zero Trust principles.
```

**2. MFA Enforcement Audit:**
```
Create a script to identify all users without MFA enabled, check MFA enforcement policies, find users excluded from MFA requirements, and generate a remediation plan.
```

**3. Privileged Access Review:**
```
Create a script to audit all Global Administrators, identify inactive admin accounts, review role assignments, check for emergency access accounts, and assess PIM usage.
```

**4. External Sharing Security:**
```
Create a script to audit external sharing settings across SharePoint, OneDrive, and Teams, identify anonymous links, check guest access policies, and recommend secure sharing practices.
```

**5. Email Security Assessment:**
```
Create a script to review anti-phishing policies, audit transport rules, check for auto-forwarding rules, assess safe links and safe attachments configuration, and verify email authentication (SPF/DKIM/DMARC).
```

