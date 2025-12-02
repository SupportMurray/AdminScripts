# MFA/2FA User Report Guide

## Overview

The MFA reporting capabilities provide detailed analysis of Multi-Factor Authentication status across your Microsoft 365 tenant. You can generate MFA reports in two ways:

1. **Integrated with Security Review** - Include MFA report with full security assessment
2. **Standalone MFA Report** - Generate only MFA user status report

---

## 📊 What's Included in MFA Reports

### User Information
- **Display Name** and **User Principal Name**
- **Account Status** (Enabled/Disabled)
- **MFA Status** (Enabled/Disabled)
- **MFA Method Count**
- **Detailed Authentication Methods**:
  - Microsoft Authenticator App
  - Phone Authentication (SMS/Call)
  - Email
  - FIDO2 Security Keys
  - Software OATH Tokens
  - Windows Hello for Business
- **Admin Status**
- **Last Sign-In Date**
- **Risk Level** (Critical, High, Medium, Low)

### Statistics Dashboard
- **MFA Adoption Percentage**
- **Total Users Analyzed**
- **Users with MFA Enabled**
- **Users with MFA Disabled**
- **Administrators Without MFA** (Critical!)
- **Users with Authenticator App**
- **Users with FIDO2 Keys**
- **Users with SMS Only** (Less Secure)
- **Users with Windows Hello**
- **Risk Distribution** (Critical/High/Medium/Low)

### Report Formats
- **HTML** - Interactive dashboard with filtering and statistics
- **CSV** - Detailed data for Excel analysis
- **JSON** - Machine-readable with full statistics

---

## Method 1: Integrated with Security Review

### Usage

```powershell
# Run full security review WITH MFA report
.\Get-M365SecurityReview.ps1 -IncludeMFAReport

# With custom output path
.\Get-M365SecurityReview.ps1 -IncludeMFAReport -OutputPath "C:\Reports"

# Skip some domains but include MFA report
.\Get-M365SecurityReview.ps1 -IncludeMFAReport -SkipDomains "Device","Collaboration"
```

### What You Get

When you add `-IncludeMFAReport` to the security review:

1. **All security domain assessments** (10 domains)
2. **Security findings reports** (HTML, CSV, JSON)
3. **Additional MFA user reports** (HTML, CSV, JSON)

Total of **6 files** generated:
```
M365SecurityReview_YYYYMMDD_HHMMSS.html
M365SecurityReview_YYYYMMDD_HHMMSS.csv
M365SecurityReview_YYYYMMDD_HHMMSS.json
MFA_User_Report_YYYYMMDD_HHMMSS.html
MFA_User_Report_YYYYMMDD_HHMMSS.csv
MFA_User_Report_YYYYMMDD_HHMMSS.json
```

---

## Method 2: Standalone MFA Report

### Quick Start

```powershell
# Run standalone MFA report
.\Get-MFAUserReport.ps1

# That's it! Reports will be generated and HTML opens automatically
```

### Advanced Usage

**Generate HTML Only**
```powershell
.\Get-MFAUserReport.ps1 -ExportFormat HTML
```

**Custom Output Location**
```powershell
.\Get-MFAUserReport.ps1 -OutputPath "C:\MFAReports"
```

**Administrators Only**
```powershell
.\Get-MFAUserReport.ps1 -AdminsOnly
```

**Exclude Disabled Accounts**
```powershell
.\Get-MFAUserReport.ps1 -IncludeDisabledUsers:$false
```

**Combined Options**
```powershell
.\Get-MFAUserReport.ps1 `
    -OutputPath "C:\Reports\MFA" `
    -ExportFormat All `
    -AdminsOnly `
    -IncludeDisabledUsers:$false
```

---

## 🔐 Prerequisites

### Required PowerShell Module
```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser
```

### Required Permissions
```powershell
Connect-MgGraph -Scopes "User.Read.All","UserAuthenticationMethod.Read.All","Directory.Read.All"
```

### Roles Needed
- **Security Reader** (recommended)
- **Global Reader** (alternative)
- Or appropriate Azure AD role with user read permissions

---

## 📊 Understanding the HTML Report

### Dashboard Features

**MFA Adoption Gauge**
- Large percentage display showing overall MFA adoption
- Green = Good (>80%), Yellow = Needs Work (50-80%), Red = Critical (<50%)

**Statistics Cards**
- **Total Users** - All users analyzed
- **MFA Enabled/Disabled** - Current status
- **Admins Without MFA** - Critical security risk!
- **Critical Risk Count** - Users requiring immediate attention
- **Method Distribution** - Shows most secure vs. less secure methods

**Interactive User Table**
- **Filter Buttons**:
  - All Users
  - MFA Disabled
  - Admins Without MFA (Critical!)
  - Critical Risk
  - High Risk
- **Sortable Columns**
- **Color-Coded Badges** for quick visual assessment

**Method Distribution Section**
- Shows which authentication methods are in use
- Highlights recommended vs. less secure methods
- Provides counts for each method type

**Recommendations Section**
- **Immediate Actions** - Critical items to fix now
- **High Priority** - Important improvements needed
- **Security Upgrades** - Move from SMS to stronger methods
- **Best Practices** - Long-term security enhancements

---

## 🎯 Risk Level Explained

### Critical Risk 🔴
**Who:** Administrators without MFA  
**Why:** Admin accounts have elevated privileges - compromise would be catastrophic  
**Action:** Enable MFA immediately (within 24 hours)

### High Risk 🟠
**Who:** Enabled users without MFA  
**Why:** Active accounts vulnerable to credential theft  
**Action:** Enable MFA within 1 week

### Medium Risk 🟡
**Who:** 
- Disabled users without MFA
- Users with SMS-only MFA
**Why:** Lower immediate risk but still vulnerable  
**Action:** Enable MFA or upgrade to stronger methods within 30 days

### Low Risk 🟢
**Who:** Users with MFA enabled using strong methods  
**Why:** Protected by multiple factors  
**Action:** Maintain current security posture

---

## 📈 Common Scenarios

### Scenario 1: Compliance Audit Preparation

**Goal:** Generate comprehensive MFA status for compliance audit

```powershell
# Generate detailed reports for all users
.\Get-MFAUserReport.ps1 -OutputPath "C:\Audit\MFA"

# Result: Three formats ready for auditors
# - HTML for management review
# - CSV for detailed analysis
# - JSON for automated compliance systems
```

---

### Scenario 2: Admin Account Security Check

**Goal:** Verify all administrators have MFA enabled

```powershell
# Focus on administrator accounts only
.\Get-MFAUserReport.ps1 -AdminsOnly -OutputPath "C:\Reports\AdminMFA"

# Review the "Admins Without MFA" statistic
# If count > 0, take immediate action!
```

---

### Scenario 3: MFA Adoption Tracking

**Goal:** Track MFA rollout progress over time

```powershell
# Week 1 - Baseline
.\Get-MFAUserReport.ps1 -OutputPath "C:\MFATracking\Week1"

# Week 2 - After first push
.\Get-MFAUserReport.ps1 -OutputPath "C:\MFATracking\Week2"

# Week 3 - After enforcement
.\Get-MFAUserReport.ps1 -OutputPath "C:\MFATracking\Week3"

# Compare CSV files to track improvement
# Monitor MFA percentage increase
```

---

### Scenario 4: Security Upgrade Campaign

**Goal:** Identify users with weak MFA methods (SMS only)

```powershell
# Generate full report
.\Get-MFAUserReport.ps1 -ExportFormat CSV

# Open CSV in Excel
# Filter where:
#   - MFAStatus = Enabled
#   - HasSMS = True
#   - HasMicrosoftAuthenticator = False
#   - HasFIDO2 = False

# These users need to upgrade from SMS to authenticator app or FIDO2
```

---

### Scenario 5: Executive Report

**Goal:** Present MFA status to leadership

```powershell
# Generate HTML report only
.\Get-MFAUserReport.ps1 -ExportFormat HTML -OutputPath "C:\Reports\Executive"

# Present the HTML dashboard showing:
# - MFA adoption percentage (goal: >95%)
# - Admins without MFA (goal: 0)
# - Critical risk count (goal: 0)
# - Method distribution (emphasize authenticator app adoption)
```

---

## 🔍 Interpreting the Results

### Good Security Posture ✅

Indicators of strong MFA implementation:
- **MFA Adoption: >90%**
- **Admins Without MFA: 0**
- **Critical Risk Users: 0**
- **High Risk Users: <5%**
- **Authenticator App Usage: >70%**
- **FIDO2 Usage: Growing**
- **SMS Only Users: <10%**

### Needs Improvement ⚠️

Warning signs requiring attention:
- **MFA Adoption: 50-90%**
- **Admins Without MFA: >0** ⚠️ CRITICAL
- **Critical Risk: >0**
- **High Risk: >10%**
- **SMS Only: >30%**
- **Authenticator App Usage: <50%**

### Critical Issues 🚨

Immediate action required:
- **MFA Adoption: <50%**
- **Admins Without MFA: >1** 🚨 FIX NOW
- **Critical Risk: >5%**
- **High Risk: >25%**
- **Any admin without MFA is unacceptable**

---

## 🛠️ Troubleshooting

### Issue: "Permission Denied"

**Solution:**
```powershell
# Reconnect with required scopes
Disconnect-MgGraph
Connect-MgGraph -Scopes "User.Read.All","UserAuthenticationMethod.Read.All","Directory.Read.All"
```

### Issue: "Module not found"

**Solution:**
```powershell
Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Authentication
```

### Issue: Script runs slow

**Explanation:** Normal for large tenants. The script analyzes each user's authentication methods.

**Expected Time:**
- Small tenant (100 users): 1-2 minutes
- Medium tenant (1,000 users): 10-15 minutes
- Large tenant (10,000+ users): 30-60 minutes

**Optimization:**
```powershell
# Focus on specific groups if needed
.\Get-MFAUserReport.ps1 -AdminsOnly  # Much faster

# Or exclude disabled accounts
.\Get-MFAUserReport.ps1 -IncludeDisabledUsers:$false
```

### Issue: Some users show "Never" for Last Sign-In

**Explanation:** Users who have never signed in or sign-in logging not enabled.

**Not a problem:** This is expected for:
- Newly created accounts
- Service accounts
- Shared mailboxes

---

## 📋 Best Practices

### 1. Regular Reporting Schedule

```powershell
# Weekly admin check
.\Get-MFAUserReport.ps1 -AdminsOnly -OutputPath "C:\Reports\Weekly"

# Monthly full report
.\Get-MFAUserReport.ps1 -OutputPath "C:\Reports\Monthly"
```

### 2. Track Metrics Over Time

Keep historical reports to track:
- **MFA Adoption Rate** (trend upward)
- **Admins Without MFA** (maintain at 0)
- **Critical Risk Count** (trend downward)
- **Method Upgrades** (more authenticator app, less SMS)

### 3. Prioritize Actions

**Order of priority:**
1. 🔴 Enable MFA for ALL administrators (Critical)
2. 🔴 Enable MFA for active users without it (High)
3. 🟡 Upgrade SMS-only users to authenticator app (Medium)
4. 🟢 Deploy FIDO2 for privileged accounts (Best practice)

### 4. Use Reports for Communication

- **HTML** → Management and executives
- **CSV** → IT teams for remediation work
- **JSON** → Automation and compliance systems

### 5. Combine with Conditional Access

After reviewing MFA status:
1. Implement Conditional Access to enforce MFA
2. Block legacy authentication
3. Require MFA for all cloud apps
4. Use report to monitor compliance

---

## 📊 Sample Use Cases by Role

### Security Administrator
```powershell
# Daily: Quick admin check
.\Get-MFAUserReport.ps1 -AdminsOnly -ExportFormat HTML

# Weekly: Full tenant review
.\Get-MFAUserReport.ps1 -ExportFormat All
```

### Compliance Officer
```powershell
# Monthly compliance report
.\Get-MFAUserReport.ps1 -OutputPath "C:\Compliance\$(Get-Date -Format 'yyyy-MM')"

# Provides evidence of MFA enforcement for audits
```

### IT Manager
```powershell
# Track MFA rollout progress
.\Get-MFAUserReport.ps1 -OutputPath "C:\MFAProject\Week_$(Get-Date -Format 'yyyy-MM-dd')"

# Use MFA percentage as KPI
```

### Help Desk
```powershell
# Generate list of users needing MFA setup
.\Get-MFAUserReport.ps1 -ExportFormat CSV -IncludeDisabledUsers:$false

# Filter CSV for MFAStatus = Disabled and AccountEnabled = True
# Reach out to users for MFA enrollment
```

---

## 🎓 Pro Tips

1. **Bookmark the HTML Report** - Easy to share with stakeholders

2. **Use CSV for Bulk Operations** - Filter and create distribution lists for communication

3. **Schedule Regular Reports** - Use Task Scheduler for automated weekly reports

4. **Monitor the Critical Count** - Keep it at zero!

5. **Celebrate Progress** - Share MFA adoption percentage improvements with the team

6. **Export Before Changes** - Generate baseline before implementing new policies

7. **Compare Methods** - Track migration from SMS to authenticator app

8. **Focus on Admins First** - Zero tolerance for admins without MFA

---

## 🔗 Related Resources

- **Main Security Review:** `Get-M365SecurityReview.ps1`
- **Quick Start Guide:** `QUICK_START.md`
- **Examples:** `EXAMPLES.md`
- **Microsoft MFA Documentation:** https://learn.microsoft.com/en-us/entra/identity/authentication/

---

## ✅ Quick Reference

### Standalone MFA Report
```powershell
.\Get-MFAUserReport.ps1
```

### MFA Report with Security Review
```powershell
.\Get-M365SecurityReview.ps1 -IncludeMFAReport
```

### Admins Only
```powershell
.\Get-MFAUserReport.ps1 -AdminsOnly
```

### Custom Path
```powershell
.\Get-MFAUserReport.ps1 -OutputPath "C:\Reports"
```

---

**Remember:** MFA is your first line of defense against credential theft. Keep that adoption rate high! 🔐

