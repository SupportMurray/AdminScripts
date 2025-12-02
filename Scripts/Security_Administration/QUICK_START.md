# Quick Start Guide - Get-M365SecurityReview.ps1

## 🚀 5-Minute Setup

### Step 1: Install Required Modules (First Time Only)

```powershell
# Run as Administrator
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force
Install-Module -Name MicrosoftTeams -Scope CurrentUser -Force
```

### Step 2: Connect to M365

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.Read.All","Policy.Read.All","SecurityEvents.Read.All","User.Read.All","AuditLog.Read.All"

# Connect to Exchange Online
Connect-ExchangeOnline

# Connect to SharePoint (replace with your tenant URL)
Connect-SPOService -Url "https://yourtenant-admin.sharepoint.com"

# Connect to Teams
Connect-MicrosoftTeams
```

### Step 3: Run the Security Review

```powershell
# Navigate to script location
cd "C:\Path\To\Scripts\Security_Administration"

# Run the assessment
.\Get-M365SecurityReview.ps1
```

**That's it!** The script will:
- ✅ Assess all 10 security domains
- ✅ Generate HTML, CSV, and JSON reports
- ✅ Open the HTML report in your browser
- ✅ Save reports to the current directory

---

## 📊 What Gets Assessed?

| Domain | Key Checks |
|--------|-----------|
| **1. Identity & Access** | Conditional Access, MFA, Legacy Auth |
| **2. Threat Protection** | Defender, Anti-Phishing, Safe Links |
| **3. Data Protection** | DLP, Sensitivity Labels, Encryption |
| **4. Compliance** | Audit Logs, Retention Policies |
| **5. Application Security** | App Permissions, OAuth Grants |
| **6. Email Security** | Forwarding, SPF/DKIM/DMARC |
| **7. Collaboration** | SharePoint/Teams Sharing |
| **8. Device & Endpoint** | Intune, Compliance Policies |
| **9. Monitoring & Alerting** | Security Alerts, Auditing |
| **10. Privileged Access** | Admin Accounts, PIM, Roles |

---

## 🎯 Common Use Cases

### Use Case 1: Quick Security Check
```powershell
.\Get-M365SecurityReview.ps1
```

### Use Case 2: Executive Report Only
```powershell
.\Get-M365SecurityReview.ps1 -Format HTML -OutputPath "C:\Reports"
```

### Use Case 3: Focus on Identity Security
```powershell
.\Get-M365SecurityReview.ps1 -SkipDomains "Device","Collaboration","Email"
```

### Use Case 4: Data Analysis
```powershell
.\Get-M365SecurityReview.ps1 -Format CSV
# Import into Excel for analysis
```

---

## 📈 Understanding Your Results

### Risk Score (0-100, lower is better)

```
🟢 0-20:   Low Risk     - Good security posture
🟡 21-50:  Medium Risk  - Needs attention
🔴 51+:    High Risk    - Immediate action required
```

### Finding Priorities

```
🔴 Critical  → Fix immediately (within 24 hours)
🟠 High      → Fix within 1 week
🟡 Medium    → Fix within 30 days
🟢 Low       → Address in quarterly review
```

---

## 🔧 Quick Troubleshooting

### Problem: "Module not found"
```powershell
Solution: Install the required module
Install-Module -Name Microsoft.Graph -Force
```

### Problem: "Access denied"
```powershell
Solution: You need Security Reader or Global Reader role
Ask your Global Administrator to grant permissions
```

### Problem: "Not connected to Exchange"
```powershell
Solution: Connect manually first
Connect-ExchangeOnline
```

### Problem: "Script takes too long"
```powershell
Solution: Skip non-critical domains
.\Get-M365SecurityReview.ps1 -SkipDomains "Device","Monitoring"
```

---

## 📁 Output Files Explained

### 1. HTML Report (For Management)
- **Purpose:** Executive summary with visual dashboard
- **Best For:** Sharing with non-technical stakeholders
- **Features:** Color-coded findings, risk score, remediation steps

### 2. CSV Report (For Analysis)
- **Purpose:** Detailed data in tabular format
- **Best For:** Tracking remediation, Excel analysis
- **Features:** All findings with full details, easy to filter

### 3. JSON Report (For Automation)
- **Purpose:** Machine-readable format
- **Best For:** API integration, automated workflows
- **Features:** Structured data with metadata

---

## ⚡ Pro Tips

1. **Run Regularly:** Schedule weekly or monthly assessments
2. **Track Progress:** Compare reports over time to see improvements
3. **Prioritize:** Always fix Critical findings first
4. **Document:** Note why certain findings are accepted risks
5. **Share:** Use HTML report for leadership presentations

---

## 🔗 Need More Help?

- **Detailed Documentation:** See README.md in this directory
- **Usage Examples:** See EXAMPLES.md for advanced scenarios
- **Microsoft Docs:** Check the Reference links in each finding
- **Support:** Contact your security team

---

## ⚠️ Important Notes

- ✅ **Read-Only:** This script doesn't modify your environment
- 🔒 **Secure Storage:** Reports contain sensitive information
- 📅 **Regular Reviews:** Run monthly for best results
- 🎯 **Action Required:** Review findings and implement fixes

---

## 🎉 You're Ready!

Run your first security assessment:

```powershell
.\Get-M365SecurityReview.ps1
```

The HTML report will open automatically in your browser. Review the findings and start improving your security posture!

---

**Questions?** Review the detailed README.md or consult the EXAMPLES.md file for more advanced usage scenarios.

