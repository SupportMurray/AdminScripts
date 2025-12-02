# Security Administration Scripts

This directory contains PowerShell scripts for Microsoft 365 security administration and assessment.

## Scripts

### Get-M365SecurityReview.ps1

Performs a comprehensive security review of your Microsoft 365 environment across 10 critical security domains.

#### Overview

This production-ready script conducts a thorough security assessment and generates detailed reports with:
- **Risk ratings** (Critical, High, Medium, Low)
- **Remediation recommendations** for each finding
- **Compliance framework mapping** (CIS, NIST, ISO 27001)
- **Multiple export formats** (HTML, CSV, JSON)
- **Executive summary** with risk scoring

#### 10 Security Domains Assessed

1. **Identity & Access Management**
   - Conditional Access policies
   - MFA enforcement
   - Legacy authentication blocking
   - Security defaults
   - Administrator MFA status

2. **Threat Protection**
   - Microsoft Defender for Office 365
   - Anti-phishing policies
   - Safe Links and Safe Attachments
   - Malware filter policies

3. **Data Protection**
   - Data Loss Prevention (DLP) policies
   - Sensitivity labels
   - Azure Rights Management
   - Encryption settings

4. **Compliance & Governance**
   - Unified audit logging
   - Retention policies
   - Litigation hold
   - Compliance policies

5. **Application Security**
   - Service principal permissions
   - OAuth grants
   - User consent settings
   - Application permissions audit

6. **Email Security**
   - Email forwarding rules
   - SPF, DKIM, DMARC configuration
   - Transport rules
   - Mailbox delegation

7. **Collaboration Security**
   - SharePoint external sharing
   - Teams guest access
   - Anonymous meeting join
   - External sharing policies

8. **Device & Endpoint Security**
   - Intune enrollment
   - Device compliance policies
   - Non-compliant devices
   - Mobile device management

9. **Monitoring & Alerting**
   - Security alert policies
   - Mailbox auditing
   - Threat detection
   - Activity monitoring

10. **Privileged Access**
    - Global Administrator count
    - Emergency access accounts
    - Privileged role assignments
    - Privileged Identity Management (PIM)

#### Prerequisites

**Required Modules:**
```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
Install-Module -Name MicrosoftTeams -Scope CurrentUser
```

**Required Permissions:**
- Security Reader or Security Administrator role
- Global Reader role (recommended)
- Or specific permissions:
  - Directory.Read.All
  - Policy.Read.All
  - SecurityEvents.Read.All
  - User.Read.All
  - AuditLog.Read.All

#### Usage Examples

**Example 1: Full Security Review (All Domains)**
```powershell
.\Get-M365SecurityReview.ps1
```
This will:
- Assess all 10 security domains
- Generate HTML, CSV, and JSON reports
- Save reports to the current directory
- Open the HTML report in your browser

**Example 2: Specify Output Location**
```powershell
.\Get-M365SecurityReview.ps1 -OutputPath "C:\SecurityReports"
```

**Example 3: Generate Only HTML Report**
```powershell
.\Get-M365SecurityReview.ps1 -Format HTML
```

**Example 4: Skip Specific Domains**
```powershell
.\Get-M365SecurityReview.ps1 -SkipDomains "Device","Collaboration"
```
Useful when you don't have permissions for certain areas or want to focus on specific domains.

**Example 5: With -WhatIf (Preview)**
```powershell
.\Get-M365SecurityReview.ps1 -WhatIf
```
Shows what the script would do without actually running it.

#### Connection Requirements

The script will automatically connect to required services if not already connected:

```powershell
# Manual connection (if needed)
Connect-MgGraph -Scopes "Directory.Read.All","Policy.Read.All","SecurityEvents.Read.All","User.Read.All","AuditLog.Read.All"
Connect-ExchangeOnline
Connect-SPOService -Url "https://yourtenant-admin.sharepoint.com"
Connect-MicrosoftTeams
```

#### Output Files

The script generates three types of reports:

1. **HTML Report** (Executive Friendly)
   - Visual risk scoring dashboard
   - Color-coded findings by severity
   - Detailed remediation steps
   - Clickable references
   - Professional formatting

2. **CSV Report** (Data Analysis)
   - All findings in tabular format
   - Easy to filter and sort
   - Compatible with Excel
   - Suitable for tracking remediation

3. **JSON Report** (Programmatic)
   - Machine-readable format
   - Complete metadata
   - API integration ready
   - Automation workflows

#### Understanding Risk Scores

**Risk Score Calculation:**
- Critical finding: +10 points
- High finding: +5 points
- Medium finding: +2 points
- Low finding: +1 point

**Risk Levels:**
- **0-20**: Low Risk (Good security posture)
- **21-50**: Medium Risk (Needs attention)
- **51+**: High Risk (Immediate action required)

#### Compliance Framework Mapping

Findings are mapped to industry standards:
- **CIS Microsoft 365 Foundations Benchmark**
- **NIST Cybersecurity Framework**
- **ISO 27001:2013**

This helps organizations meet compliance requirements and industry best practices.

#### Troubleshooting

**Issue: Permission Denied**
```
Solution: Ensure you have Security Reader or Global Reader role
```

**Issue: Module Not Found**
```powershell
Solution: Install required modules
Install-Module -Name Microsoft.Graph -Force
Install-Module -Name ExchangeOnlineManagement -Force
```

**Issue: Connection Timeout**
```
Solution: Connect manually before running the script
Connect-MgGraph -Scopes "Directory.Read.All","Policy.Read.All"
Connect-ExchangeOnline
```

**Issue: Some Checks Skipped**
```
Solution: This is normal if certain features aren't enabled or licenses aren't available.
The script will log warnings for skipped checks.
```

#### Performance Considerations

- **Execution Time**: 5-15 minutes depending on tenant size
- **API Calls**: Uses throttling retry logic to handle rate limits
- **Memory**: Processes data in batches for large tenants
- **Network**: Requires stable internet connection

#### Best Practices

1. **Schedule Regular Reviews**
   - Run weekly or monthly
   - Track improvements over time
   - Export to consistent location

2. **Prioritize Findings**
   - Address Critical findings immediately
   - Plan High findings within 30 days
   - Schedule Medium/Low findings quarterly

3. **Document Remediation**
   - Track which findings were fixed
   - Note exceptions or accepted risks
   - Maintain security posture history

4. **Share Reports**
   - HTML report for executives and management
   - CSV report for security teams
   - JSON report for automation/tracking

5. **Combine with Other Assessments**
   - Microsoft Secure Score
   - Azure Security Center
   - Compliance Manager
   - Regular penetration testing

#### Security Considerations

- Script is **read-only** - no modifications made to environment
- All findings are logged locally
- Reports may contain sensitive information - store securely
- Review findings before sharing with external parties
- Delete old reports after remediation tracking

#### Version History

- **v1.0** (2025-12-02): Initial release
  - 10 security domains
  - 3 export formats
  - Compliance framework mapping
  - Risk scoring system

#### Support and Feedback

For issues, questions, or suggestions:
1. Review the troubleshooting section above
2. Check the AGENT_CONTEXT.md for standards
3. Consult Microsoft documentation links in findings
4. Contact your security team for environment-specific questions

#### Related Scripts

- **Get-ConditionalAccessReport.ps1** - Detailed CA policy analysis
- **Get-MFAStatus.ps1** - User MFA registration status
- **Get-PrivilegedAccessAudit.ps1** - Admin account audit

---

**⚠️ Important Notes:**
- This script performs READ-ONLY operations
- No changes are made to your environment
- Reports contain sensitive security information
- Store reports securely and limit access
- Review findings with security team before remediation

**📚 Additional Resources:**
- [Microsoft 365 Security Documentation](https://learn.microsoft.com/en-us/microsoft-365/security/)
- [Microsoft Secure Score](https://learn.microsoft.com/en-us/microsoft-365/security/defender/microsoft-secure-score)
- [CIS Microsoft 365 Benchmark](https://www.cisecurity.org/benchmark/microsoft_365)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

