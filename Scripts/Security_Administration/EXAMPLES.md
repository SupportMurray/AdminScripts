# Get-M365SecurityReview.ps1 - Usage Examples

This document provides detailed examples and scenarios for using the comprehensive M365 security review script.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Advanced Scenarios](#advanced-scenarios)
3. [Scheduled Automation](#scheduled-automation)
4. [Integration Examples](#integration-examples)
5. [Sample Output](#sample-output)

---

## Basic Usage

### Scenario 1: First-Time Security Assessment

**Objective:** Run a complete security review of your M365 environment.

```powershell
# Step 1: Connect to required services
Connect-MgGraph -Scopes "Directory.Read.All","Policy.Read.All","SecurityEvents.Read.All","User.Read.All","AuditLog.Read.All"
Connect-ExchangeOnline
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"
Connect-MicrosoftTeams

# Step 2: Run the security review
.\Get-M365SecurityReview.ps1

# Output:
# - Assesses all 10 security domains
# - Generates reports in current directory
# - Opens HTML report in browser
```

**Expected Files:**
```
M365SecurityReview_20251202_143022.html
M365SecurityReview_20251202_143022.csv
M365SecurityReview_20251202_143022.json
```

---

### Scenario 2: Generate Executive Report Only

**Objective:** Create a visual HTML report for management review.

```powershell
# Run with HTML output only to a specific location
.\Get-M365SecurityReview.ps1 `
    -OutputPath "C:\SecurityReports\Executive" `
    -Format HTML

# Result: Clean, professional HTML report for non-technical stakeholders
```

**Use Case:** Monthly security briefing for leadership team.

---

### Scenario 3: Focus on Critical Domains

**Objective:** Assess only identity and access-related security.

```powershell
# Skip non-critical domains for focused assessment
.\Get-M365SecurityReview.ps1 `
    -SkipDomains "Collaboration","Device","Email" `
    -OutputPath "C:\Reports\IdentityFocus"

# Assessed Domains:
# ✓ Identity & Access Management
# ✓ Threat Protection
# ✓ Data Protection
# ✓ Compliance & Governance
# ✓ Application Security
# ✓ Monitoring & Alerting
# ✓ Privileged Access
```

---

## Advanced Scenarios

### Scenario 4: Multi-Tenant Assessment

**Objective:** Assess security across multiple M365 tenants.

```powershell
# Define tenant list
$tenants = @(
    @{ Name = "Contoso-Prod"; AdminUrl = "https://contoso-admin.sharepoint.com" },
    @{ Name = "Contoso-Dev"; AdminUrl = "https://contosodev-admin.sharepoint.com" },
    @{ Name = "Contoso-Test"; AdminUrl = "https://contosotest-admin.sharepoint.com" }
)

# Assess each tenant
foreach ($tenant in $tenants) {
    Write-Host "Assessing tenant: $($tenant.Name)" -ForegroundColor Cyan
    
    # Connect to tenant
    Disconnect-MgGraph -ErrorAction SilentlyContinue
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    
    Connect-MgGraph -Scopes "Directory.Read.All","Policy.Read.All","SecurityEvents.Read.All"
    Connect-ExchangeOnline
    Connect-SPOService -Url $tenant.AdminUrl
    
    # Run assessment
    .\Get-M365SecurityReview.ps1 `
        -OutputPath "C:\SecurityReports\$($tenant.Name)" `
        -Format All
    
    Write-Host "Completed assessment for $($tenant.Name)" -ForegroundColor Green
}

Write-Host "All tenant assessments complete!" -ForegroundColor Green
```

---

### Scenario 5: Comparison Report (Before/After Remediation)

**Objective:** Track security improvements after implementing fixes.

```powershell
# Week 1: Baseline assessment
$baseline = .\Get-M365SecurityReview.ps1 `
    -OutputPath "C:\SecurityReports\Baseline" `
    -Format All

Write-Host "Baseline Assessment Complete:"
Write-Host "  Total Findings: $($baseline.TotalFindings)"
Write-Host "  Critical: $($baseline.CriticalFindings)"
Write-Host "  High: $($baseline.HighFindings)"

# [Implement remediation steps here]

# Week 4: Post-remediation assessment
$postRemediation = .\Get-M365SecurityReview.ps1 `
    -OutputPath "C:\SecurityReports\PostRemediation" `
    -Format All

Write-Host "`nPost-Remediation Assessment:"
Write-Host "  Total Findings: $($postRemediation.TotalFindings)"
Write-Host "  Critical: $($postRemediation.CriticalFindings)"
Write-Host "  High: $($postRemediation.HighFindings)"

# Calculate improvement
$improvement = @{
    TotalReduced = $baseline.TotalFindings - $postRemediation.TotalFindings
    CriticalReduced = $baseline.CriticalFindings - $postRemediation.CriticalFindings
    HighReduced = $baseline.HighFindings - $postRemediation.HighFindings
}

Write-Host "`nImprovements:"
Write-Host "  Total findings reduced: $($improvement.TotalReduced)"
Write-Host "  Critical findings resolved: $($improvement.CriticalReduced)"
Write-Host "  High findings resolved: $($improvement.HighReduced)"
```

---

### Scenario 6: Conditional Execution Based on Findings

**Objective:** Trigger alerts or workflows based on security findings.

```powershell
# Run assessment and capture results
$results = .\Get-M365SecurityReview.ps1 -OutputPath "C:\SecurityReports" -Format JSON

# Check for critical findings
if ($results.CriticalFindings -gt 0) {
    Write-Host "ALERT: $($results.CriticalFindings) critical security findings detected!" -ForegroundColor Red
    
    # Send alert email
    $emailParams = @{
        To = "security-team@contoso.com"
        Subject = "URGENT: Critical M365 Security Findings"
        Body = @"
Critical security issues detected in M365 environment:

Critical Findings: $($results.CriticalFindings)
High Findings: $($results.HighFindings)
Total Findings: $($results.TotalFindings)

Please review the attached report immediately.

Report Location: $($results.ExportedFiles -join "`n")
"@
        Attachments = $results.ExportedFiles | Where-Object { $_ -like "*.html" }
    }
    
    # Send-MailMessage @emailParams
    Write-Host "Alert email would be sent to security team" -ForegroundColor Yellow
}
else {
    Write-Host "No critical findings. Security posture is good!" -ForegroundColor Green
}
```

---

## Scheduled Automation

### Scenario 7: Weekly Automated Assessment

**Objective:** Schedule weekly security reviews with automatic reporting.

**PowerShell Script: Run-WeeklySecurityReview.ps1**

```powershell
<#
.SYNOPSIS
    Automated weekly M365 security assessment
#>

param(
    [string]$ReportPath = "C:\SecurityReports\Weekly",
    [string]$EmailTo = "security-team@contoso.com"
)

try {
    # Create weekly folder
    $weekFolder = Join-Path $ReportPath "Week_$(Get-Date -Format 'yyyy-MM-dd')"
    New-Item -Path $weekFolder -ItemType Directory -Force | Out-Null
    
    # Connect to services (use certificate-based auth for automation)
    Connect-MgGraph -ClientId "YOUR_APP_ID" -TenantId "YOUR_TENANT_ID" -CertificateThumbprint "YOUR_CERT_THUMBPRINT"
    Connect-ExchangeOnline -CertificateThumbprint "YOUR_CERT_THUMBPRINT" -AppId "YOUR_APP_ID" -Organization "contoso.onmicrosoft.com"
    
    # Run assessment
    $results = & "C:\Scripts\Get-M365SecurityReview.ps1" -OutputPath $weekFolder -Format All
    
    # Generate summary
    $summary = @"
Weekly M365 Security Review - $(Get-Date -Format 'MMMM dd, yyyy')

Assessment Results:
-------------------
Total Findings: $($results.TotalFindings)
Critical: $($results.CriticalFindings)
High: $($results.HighFindings)
Medium: $($results.MediumFindings)
Low: $($results.LowFindings)

Duration: $($results.Duration.TotalMinutes) minutes

Reports: $($results.ExportedFiles -join "`n")

Please review the HTML report for detailed findings and remediation steps.
"@
    
    # Log results
    $summary | Out-File -FilePath (Join-Path $weekFolder "Summary.txt")
    
    # Email results (configure as needed)
    # Send-MailMessage -To $EmailTo -Subject "Weekly M365 Security Review" -Body $summary -Attachments $results.ExportedFiles
    
    Write-Host "Weekly security review completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Weekly security review failed: $_"
    # Send failure notification
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
```

**Task Scheduler Configuration:**

```powershell
# Create scheduled task for weekly execution
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Run-WeeklySecurityReview.ps1"

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 6:00AM

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 2) -RestartCount 3

Register-ScheduledTask -TaskName "M365-Weekly-Security-Review" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Weekly automated M365 security assessment"
```

---

## Integration Examples

### Scenario 8: Integration with Azure DevOps/ServiceNow

**Objective:** Create work items for each security finding.

```powershell
# Run assessment and get JSON results
$results = .\Get-M365SecurityReview.ps1 -OutputPath "C:\Reports" -Format JSON

# Load JSON findings
$jsonFile = $results.ExportedFiles | Where-Object { $_ -like "*.json" }
$reportData = Get-Content $jsonFile -Raw | ConvertFrom-Json

# Create work items for critical and high findings
foreach ($finding in $reportData.Findings | Where-Object { $_.Risk -in @('Critical', 'High') }) {
    
    # Azure DevOps work item
    $workItem = @{
        Title = "[$($finding.Risk)] $($finding.Title)"
        Description = @"
Domain: $($finding.Domain)

Description:
$($finding.Description)

Remediation Steps:
$($finding.Remediation)

Compliance Frameworks: $($finding.ComplianceFrameworks)
Reference: $($finding.Reference)

Detected: $($finding.Timestamp)
"@
        Priority = if ($finding.Risk -eq 'Critical') { 1 } else { 2 }
        Tags = @($finding.Domain, $finding.Risk, "M365Security")
    }
    
    # Call Azure DevOps API or ServiceNow API
    Write-Host "Would create work item: $($workItem.Title)" -ForegroundColor Cyan
    
    # Example: New-AzDevOpsWorkItem @workItem
    # Example: New-ServiceNowIncident @workItem
}
```

---

### Scenario 9: Dashboard Integration (Power BI)

**Objective:** Import findings into Power BI for trend analysis.

```powershell
# Run monthly assessments
$months = 1..3 # Last 3 months

foreach ($monthOffset in $months) {
    $assessmentDate = (Get-Date).AddMonths(-$monthOffset)
    
    # Simulate monthly assessment
    $results = .\Get-M365SecurityReview.ps1 `
        -OutputPath "C:\Reports\PowerBI\Source" `
        -Format CSV
    
    # Load CSV
    $csvFile = $results.ExportedFiles | Where-Object { $_ -like "*.csv" }
    $findings = Import-Csv $csvFile
    
    # Add metadata
    $findings | ForEach-Object {
        $_ | Add-Member -NotePropertyName "AssessmentDate" -NotePropertyValue $assessmentDate.ToString("yyyy-MM-dd")
        $_ | Add-Member -NotePropertyName "Month" -NotePropertyValue $assessmentDate.ToString("yyyy-MM")
    }
    
    # Export for Power BI
    $findings | Export-Csv "C:\Reports\PowerBI\Combined_Findings.csv" -Append -NoTypeInformation
}

Write-Host "Data prepared for Power BI import" -ForegroundColor Green
Write-Host "Import file: C:\Reports\PowerBI\Combined_Findings.csv"
```

**Power BI Measures:**
```DAX
Total Findings = COUNT(Findings[Title])
Critical Count = CALCULATE(COUNT(Findings[Title]), Findings[Risk] = "Critical")
Security Score = 100 - ([Critical Count] * 10 + [High Count] * 5 + [Medium Count] * 2)
Month over Month Trend = [Total Findings] - CALCULATE([Total Findings], PREVIOUSMONTH(Findings[AssessmentDate]))
```

---

## Sample Output

### Console Output

```
========================================
Microsoft 365 Security Review Starting
========================================
[2025-12-02 14:30:15] [Info] Created output directory: C:\SecurityReports
[2025-12-02 14:30:16] [Success] Already connected to Microsoft Graph as admin@contoso.com
[2025-12-02 14:30:17] [Success] Already connected to Exchange Online
[2025-12-02 14:30:18] [Info] Starting security assessment across 10 domains...
========================================
[2025-12-02 14:30:18] [Info] Assessing: Identity & Access Management
========================================
[2025-12-02 14:30:20] [Warning] Finding: [Critical] No Conditional Access Policies Configured
[2025-12-02 14:30:22] [Warning] Finding: [Critical] MFA Not Enforced via Conditional Access
[2025-12-02 14:30:24] [Success] Identity & Access Management assessment completed
========================================
[2025-12-02 14:30:24] [Info] Assessing: Threat Protection
========================================
[2025-12-02 14:30:27] [Warning] Finding: [High] No Anti-Phishing Policies Configured
[2025-12-02 14:30:29] [Success] Threat Protection assessment completed
...
========================================
Security Assessment Complete
========================================
[2025-12-02 14:35:42] [Info] Total Findings: 23
[2025-12-02 14:35:42] [Error]   Critical: 4
[2025-12-02 14:35:42] [Warning]   High: 8
[2025-12-02 14:35:42] [Info]   Medium: 7
[2025-12-02 14:35:42] [Info]   Low: 4
========================================
Exporting Reports
========================================
[2025-12-02 14:35:43] [Success] HTML report exported to: C:\SecurityReports\M365SecurityReview_20251202_143022.html
[2025-12-02 14:35:43] [Success] CSV report exported to: C:\SecurityReports\M365SecurityReview_20251202_143022.csv
[2025-12-02 14:35:44] [Success] JSON report exported to: C:\SecurityReports\M365SecurityReview_20251202_143022.json
========================================
Security Review Complete!
========================================
```

### Sample JSON Output Structure

```json
{
  "GeneratedDate": "2025-12-02 14:35:42",
  "Duration": "00:05:24",
  "TotalFindings": 23,
  "CriticalFindings": 4,
  "HighFindings": 8,
  "MediumFindings": 7,
  "LowFindings": 4,
  "Findings": [
    {
      "Domain": "Identity & Access",
      "Title": "No Conditional Access Policies Configured",
      "Description": "No Conditional Access policies are configured. This leaves the environment vulnerable to unauthorized access.",
      "Risk": "Critical",
      "Remediation": "Implement Conditional Access policies to enforce MFA, block legacy authentication, and restrict access based on location and device compliance.",
      "ComplianceFrameworks": "CIS 1.1; NIST AC-2; ISO 27001 A.9.2.1",
      "Reference": "https://learn.microsoft.com/en-us/entra/identity/conditional-access/",
      "Timestamp": "2025-12-02 14:30:20"
    }
  ]
}
```

---

## Troubleshooting Common Issues

### Issue: "Access Denied" Errors

**Solution:**
```powershell
# Verify you have required roles
Get-MgContext | Select-Object -ExpandProperty Scopes

# Reconnect with all required scopes
Disconnect-MgGraph
Connect-MgGraph -Scopes "Directory.Read.All","Policy.Read.All","SecurityEvents.Read.All","User.Read.All","AuditLog.Read.All"
```

### Issue: Script Runs Too Long

**Solution:**
```powershell
# Run with specific domains only
.\Get-M365SecurityReview.ps1 `
    -SkipDomains "Device","Monitoring" `
    -OutputPath "C:\Reports"
```

### Issue: Certificate-Based Authentication for Automation

**Setup:**
```powershell
# Create self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject "CN=M365SecurityReview" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256

# Export certificate
Export-Certificate -Cert $cert -FilePath "C:\Certs\M365SecurityReview.cer"

# Use in script
Connect-MgGraph `
    -ClientId "YOUR_APP_ID" `
    -TenantId "YOUR_TENANT_ID" `
    -CertificateThumbprint $cert.Thumbprint
```

---

## Best Practices

1. **Regular Cadence:** Run assessments weekly or monthly
2. **Track Progress:** Compare results over time
3. **Prioritize:** Address Critical/High findings first
4. **Document:** Keep notes on why certain findings are accepted risks
5. **Automate:** Use scheduled tasks for consistency
6. **Share:** Distribute HTML reports to stakeholders
7. **Integrate:** Connect findings to your ticketing system
8. **Validate:** Re-run after implementing fixes

---

**For more information, see the README.md file in this directory.**

