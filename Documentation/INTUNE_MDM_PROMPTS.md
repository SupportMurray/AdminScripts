# Intune/MDM Administrator Prompts

## Overview
This document contains ready-to-use prompts for the Intune/MDM Administrator agent to create device management and endpoint security scripts.

## Main Comprehensive Prompt

### Full Intune Environment Review

```
You are a Microsoft Intune and Mobile Device Management (MDM) expert and PowerShell automation specialist.

CONTEXT:
- Review Agents/AGENT_CONTEXT.md for standards and best practices
- All scripts must be production-ready with no mock code or placeholders
- Create scripts in branch: agent/intune-admin/comprehensive-review
- Use Microsoft Graph PowerShell SDK for Intune management
- Follow PowerShell best practices and security standards

TASK:
Create a comprehensive PowerShell script to audit and report on the complete Intune/MDM environment including device inventory, compliance status, configuration profiles, applications, and security policies across all platforms (Windows, iOS, Android, macOS).

REQUIREMENTS:

1. DEVICE INVENTORY & STATUS
   - All enrolled devices (Windows, iOS, Android, macOS)
   - Device details: name, platform, OS version, manufacturer, model
   - Enrollment date and last sync time
   - Device ownership (corporate/personal)
   - Management state (managed, unmanaged, retired)
   - Hardware inventory (serial number, storage, memory)
   - User assignment and primary user

2. COMPLIANCE REPORTING
   - All compliance policies and their assignments
   - Device compliance status (compliant, non-compliant, in grace period)
   - Compliance policy violations by device
   - Non-compliant devices by policy
   - Conditional Access blocking status
   - Grace period expiration tracking
   - Compliance trends and statistics

3. CONFIGURATION PROFILES
   - All configuration profiles by platform
   - Profile assignments (groups, users, devices)
   - Profile deployment status and errors
   - Settings catalog policies
   - Administrative templates (Windows)
   - Custom profiles (OMA-URI)
   - Profile conflicts detection

4. APPLICATION MANAGEMENT
   - All managed applications
   - App assignments (required, available, uninstall)
   - App installation status by device
   - Failed app installations and errors
   - App protection policies (MAM)
   - App configuration policies
   - VPP app licensing (iOS/macOS)
   - Managed Google Play apps (Android)

5. SECURITY & ENDPOINT PROTECTION
   - Windows Defender policies
   - Disk encryption status (BitLocker, FileVault)
   - Firewall policies and status
   - Antivirus policies and health
   - Attack surface reduction rules
   - Security baselines deployment
   - Device health attestation

6. UPDATE MANAGEMENT
   - Windows Update rings and policies
   - Feature update policies
   - Update compliance status
   - Pending updates by device
   - Failed update installations
   - iOS/Android update policies

7. AUTOPILOT & PROVISIONING
   - Autopilot registered devices
   - Deployment profiles and assignments
   - Enrollment Status Page configuration
   - Autopilot deployment status
   - Failed Autopilot deployments

8. CONDITIONAL ACCESS INTEGRATION
   - Device-based Conditional Access policies
   - Devices blocked by Conditional Access
   - Compliance-based access policies
   - Device filters used in policies

TECHNICAL REQUIREMENTS:
- Use Microsoft.Graph.DeviceManagement modules
- Required permissions: DeviceManagementManagedDevices.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All
- Handle API pagination and throttling
- Process large device inventories efficiently
- Include progress indicators
- Support filtering by platform, compliance status, or date range

OUTPUT REQUIREMENTS:
- Generate comprehensive inventory report
- Create compliance dashboard with statistics
- Identify security gaps and risks
- Provide remediation recommendations
- Export in multiple formats: HTML (with charts), CSV, JSON
- Include executive summary with key metrics
- Show trends and statistics
- Highlight critical issues requiring attention

DELIVERABLES:
- Script name: Get-IntuneEnvironmentReport.ps1
- Location: Scripts/Intune_Administration/
- Include full documentation and usage examples
- Support quick scan mode for testing

After creating, commit to branch agent/intune-admin/comprehensive-review
```

---

## Focused Intune/MDM Prompts

### 1. Device Compliance Audit

```
Create a PowerShell script to audit device compliance across all platforms. Report on:
- All compliance policies and their requirements
- Non-compliant devices with specific violations
- Grace period status and expiration
- Devices blocked by Conditional Access
- Compliance trends over time
- Remediation recommendations per device

Include risk ratings and export detailed compliance report in HTML and CSV formats.
```

### 2. Application Deployment Report

```
Create a PowerShell script to audit all Intune-managed applications including:
- App inventory (Win32, Store, VPP, managed Google Play)
- App assignments (required, available, uninstall)
- Installation status per device and user
- Failed installations with error codes
- App protection policies (MAM)
- Unused or redundant apps
- License utilization (VPP)

Generate deployment success rate metrics and identify problematic apps.
```

### 3. Windows Autopilot Management

```
Create a PowerShell script to manage Windows Autopilot including:
- Import devices from CSV (hardware hashes)
- Assign devices to deployment profiles
- Monitor enrollment status
- Track deployment success/failures
- Generate Autopilot readiness report
- Remove devices from Autopilot
- Support bulk operations with error handling

Include validation and progress indicators for large imports.
```

### 4. Non-Compliant Device Remediation

```
Create a PowerShell script to identify and remediate non-compliant devices:
- Find all non-compliant devices
- Determine specific policy violations
- Generate user notification emails with remediation steps
- Sync devices to refresh compliance state
- Track remediation progress
- Report on devices exceeding grace period
- Support automated device actions (sync, notify)

Provide per-device remediation guidance and timeline for resolution.
```

### 5. Configuration Profile Deployment

```
Create a PowerShell script to:
- Deploy configuration profiles to device groups
- Verify profile assignments
- Monitor deployment status
- Detect and report profile conflicts
- Rollback profiles if needed
- Generate deployment report with success rates
- Support multiple platforms (Windows, iOS, Android, macOS)

Include -WhatIf support and comprehensive logging.
```

### 6. Device Security Baseline Assessment

```
Create a PowerShell script to:
- Audit security baseline deployment (Windows, iOS, Android, macOS)
- Check BitLocker/FileVault encryption status
- Verify Windows Defender configuration
- Assess firewall policies
- Check for missing security updates
- Identify devices not meeting security standards
- Generate security posture report with risk ratings

Map findings to security frameworks (CIS, NIST) and provide remediation steps.
```

### 7. Device Wipe and Retirement Automation

```
Create a PowerShell script for safe device management:
- Bulk device wipe (selective or full) with confirmation
- Device retirement automation
- Validate device state before action
- Support filtering by: last sync date, compliance status, user
- Log all actions with reason codes
- Generate pre-action report for review
- Support -WhatIf for safety testing
- Track action status and failures

Include multiple safety checks and mandatory confirmation for destructive operations.
```

### 8. Intune Policy Backup and Export

```
Create a PowerShell script to:
- Export all Intune policies (compliance, configuration, Conditional Access)
- Backup app assignments and settings
- Export Autopilot profiles
- Document policy assignments
- Generate human-readable policy documentation
- Support selective backup (by policy type or platform)
- Export in JSON format for re-import
- Create backup inventory manifest

Enable disaster recovery and policy documentation.
```

### 9. Device Enrollment Report

```
Create a PowerShell script to track device enrollment:
- New enrollments by day/week/month
- Enrollment methods (Autopilot, manual, bulk)
- Enrollment failures and error analysis
- Platform distribution (Windows, iOS, Android, macOS)
- Corporate vs. personal device ratio
- Enrollment trends and forecasting
- User enrollment statistics

Generate enrollment health dashboard with charts and metrics.
```

### 10. App Protection Policy (MAM) Audit

```
Create a PowerShell script to audit Mobile Application Management:
- All app protection policies (iOS, Android)
- Policy assignments and coverage
- Targeted apps and services
- Policy settings and restrictions
- User coverage gaps
- Device without app protection
- MAM compliance status
- Generate MAM security assessment

Identify data protection gaps and provide recommendations.
```

### 11. Windows Update Compliance Report

```
Create a PowerShell script to audit Windows Update status:
- All update rings and policies
- Device update compliance
- Pending updates by device
- Failed update installations
- Feature update readiness
- Quality update status
- Update deployment rings
- Devices outside update windows

Generate update health dashboard and identify devices at risk.
```

### 12. Device Inventory Export

```
Create a PowerShell script for comprehensive device inventory:
- All managed devices with full details
- Hardware specifications
- Installed applications per device
- User assignments
- Compliance and security status
- Network information
- Last sync and activity
- Support filtering and sorting
- Export to Excel-compatible CSV

Include pivot-ready format for analysis and reporting.
```

---

## Quick Start Examples

### Basic Device Inventory
```powershell
# After script is created and approved:
./Scripts/Intune_Administration/Get-IntuneDeviceInventory.ps1 -Platform Windows -OutputPath "./inventory.csv"
```

### Compliance Check
```powershell
./Scripts/Intune_Administration/Get-ComplianceReport.ps1 -IncludeNonCompliantOnly -OutputPath "./non-compliant.html"
```

### Autopilot Import
```powershell
./Scripts/Intune_Administration/Import-AutopilotDevices.ps1 -CsvPath "./devices.csv" -ProfileName "Corporate-Profile" -WhatIf
```

---

## Testing Requirements

Before submitting Intune scripts for review:

1. **Authenticate First**
   ```powershell
   ./Initialize-M365Session.ps1
   ```

2. **Test with -WhatIf** (if applicable)
   ```powershell
   ./Script-Name.ps1 -WhatIf
   ```

3. **Test with small dataset** first
   ```powershell
   ./Script-Name.ps1 -Top 10
   ```

4. **Verify permissions**
   - DeviceManagementManagedDevices.ReadWrite.All
   - DeviceManagementConfiguration.ReadWrite.All
   - DeviceManagementApps.ReadWrite.All

5. **Test across platforms** (if applicable)
   - Windows devices
   - iOS devices
   - Android devices
   - macOS devices

---

## Important Considerations

⚠️ **Device Impact**: Device operations directly affect users:
- Always use -WhatIf before bulk operations
- Validate device state before actions
- Consider device availability (online/offline)
- Communicate with users before disruptive actions

⚠️ **Platform Differences**: Each platform has unique capabilities:
- Windows: Full MDM, Autopilot, Win32 apps
- iOS: Supervised devices, VPP, DEP
- Android: Work profile vs. fully managed
- macOS: System extensions, FileVault

⚠️ **API Throttling**: Intune APIs have rate limits:
- Implement retry logic
- Use batching for bulk operations
- Add throttle delays (1-2 seconds per batch)
- Monitor for 429 (Too Many Requests) errors

---

## Resources

- **Microsoft Graph Device Management API**: https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview
- **Intune PowerShell Samples**: https://github.com/microsoftgraph/powershell-intune-samples
- **Device Management Best Practices**: https://learn.microsoft.com/en-us/mem/intune/fundamentals/

---

Use these prompts with the Intune/MDM Administrator agent to create comprehensive device management scripts!

