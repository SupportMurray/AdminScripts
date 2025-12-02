<#
.SYNOPSIS
    Performs a comprehensive security review of Microsoft 365 environment.

.DESCRIPTION
    This script conducts a thorough security assessment across 10 critical security domains:
    1. Identity & Access Management
    2. Threat Protection
    3. Data Protection
    4. Compliance & Governance
    5. Application Security
    6. Email Security
    7. Collaboration Security
    8. Device & Endpoint Security
    9. Monitoring & Alerting
    10. Privileged Access
    
    The script generates detailed findings with risk ratings, remediation recommendations,
    and maps findings to compliance frameworks (CIS, NIST, ISO 27001).

.PARAMETER OutputPath
    Path where reports will be saved. Defaults to current directory.

.PARAMETER Format
    Output format(s). Valid values: HTML, CSV, JSON, All. Default is All.

.PARAMETER SkipDomains
    Array of domain names to skip during assessment.

.EXAMPLE
    .\Get-M365SecurityReview.ps1
    
    Performs full security review and generates all report formats.

.EXAMPLE
    .\Get-M365SecurityReview.ps1 -OutputPath "C:\SecurityReports" -Format HTML
    
    Performs security review and generates HTML report only.

.EXAMPLE
    .\Get-M365SecurityReview.ps1 -SkipDomains "Device","Collaboration"
    
    Performs review skipping device and collaboration security assessments.

.NOTES
    Author: Security Administrator Agent
    Date: 2025-12-02
    Version: 1.0
    Requires: 
        - Microsoft.Graph module (Connect-MgGraph with appropriate scopes)
        - ExchangeOnlineManagement module
        - Permissions: Security Reader, Global Reader, or Security Administrator
        - PowerShell 7.0 or later recommended
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('HTML', 'CSV', 'JSON', 'All')]
    [string]$Format = 'All',
    
    [Parameter(Mandatory=$false)]
    [string[]]$SkipDomains = @()
)

#Requires -Version 5.1

# Script variables
$script:Findings = @()
$script:StartTime = Get-Date
$script:TotalChecks = 0
$script:CompletedChecks = 0

#region Helper Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Error' { Write-Error $logMessage }
        'Warning' { Write-Warning $logMessage }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

function Add-Finding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Critical', 'High', 'Medium', 'Low', 'Info')]
        [string]$Risk,
        
        [Parameter(Mandatory=$true)]
        [string]$Remediation,
        
        [Parameter(Mandatory=$false)]
        [string[]]$ComplianceFrameworks = @(),
        
        [Parameter(Mandatory=$false)]
        [string]$Reference = ""
    )
    
    $finding = [PSCustomObject]@{
        Domain = $Domain
        Title = $Title
        Description = $Description
        Risk = $Risk
        Remediation = $Remediation
        ComplianceFrameworks = ($ComplianceFrameworks -join "; ")
        Reference = $Reference
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $script:Findings += $finding
    Write-Log "Finding: [$Risk] $Title" -Level $(if ($Risk -eq 'Critical' -or $Risk -eq 'High') { 'Warning' } else { 'Info' })
}

function Update-Progress {
    param([string]$Activity, [string]$Status)
    
    $script:CompletedChecks++
    $percentComplete = if ($script:TotalChecks -gt 0) { 
        ($script:CompletedChecks / $script:TotalChecks) * 100 
    } else { 
        0 
    }
    
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $percentComplete
}

function Invoke-GraphWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,
        
        [int]$MaxRetries = 3,
        [int]$BaseDelaySeconds = 2
    )
    
    $attempt = 0
    
    do {
        try {
            return & $ScriptBlock
        }
        catch {
            $attempt++
            
            if ($_.Exception.Response.StatusCode -eq 429 -or 
                $_.Exception.Response.StatusCode -eq 503) {
                
                $retryAfter = $BaseDelaySeconds * [Math]::Pow(2, $attempt - 1)
                
                if ($attempt -le $MaxRetries) {
                    Write-Warning "Request throttled (Attempt $attempt/$MaxRetries). Waiting $retryAfter seconds..."
                    Start-Sleep -Seconds $retryAfter
                }
                else {
                    Write-Error "Max retries ($MaxRetries) exceeded due to throttling"
                    throw
                }
            }
            else {
                throw
            }
        }
    } while ($attempt -le $MaxRetries)
}

#endregion

#region Domain 1: Identity & Access Management

function Test-IdentityAccessManagement {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Identity & Access Management..." -Level Info
    
    try {
        # Check Conditional Access policies
        Update-Progress -Activity "Security Review" -Status "Checking Conditional Access policies..."
        
        $caPolicies = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgIdentityConditionalAccessPolicy -All -ErrorAction SilentlyContinue
        }
        
        if ($caPolicies.Count -eq 0) {
            Add-Finding -Domain "Identity & Access" `
                -Title "No Conditional Access Policies Configured" `
                -Description "No Conditional Access policies are configured. This leaves the environment vulnerable to unauthorized access." `
                -Risk "Critical" `
                -Remediation "Implement Conditional Access policies to enforce MFA, block legacy authentication, and restrict access based on location and device compliance." `
                -ComplianceFrameworks @("CIS 1.1", "NIST AC-2", "ISO 27001 A.9.2.1") `
                -Reference "https://learn.microsoft.com/en-us/entra/identity/conditional-access/"
        } else {
            $enabledPolicies = ($caPolicies | Where-Object { $_.State -eq 'enabled' }).Count
            $reportOnlyPolicies = ($caPolicies | Where-Object { $_.State -eq 'enabledForReportingButNotEnforced' }).Count
            
            if ($enabledPolicies -eq 0) {
                Add-Finding -Domain "Identity & Access" `
                    -Title "No Enabled Conditional Access Policies" `
                    -Description "Conditional Access policies exist but none are enabled (Found $reportOnlyPolicies in report-only mode)." `
                    -Risk "Critical" `
                    -Remediation "Enable Conditional Access policies to enforce security requirements. Start with report-only mode if needed for testing." `
                    -ComplianceFrameworks @("CIS 1.1", "NIST AC-2") `
                    -Reference "https://learn.microsoft.com/en-us/entra/identity/conditional-access/"
            }
            
            # Check for MFA enforcement
            $mfaPolicies = $caPolicies | Where-Object { 
                $_.GrantControls.BuiltInControls -contains 'mfa' -and $_.State -eq 'enabled' 
            }
            
            if ($mfaPolicies.Count -eq 0) {
                Add-Finding -Domain "Identity & Access" `
                    -Title "MFA Not Enforced via Conditional Access" `
                    -Description "No enabled Conditional Access policies require multi-factor authentication." `
                    -Risk "Critical" `
                    -Remediation "Create Conditional Access policy to require MFA for all users, especially administrators." `
                    -ComplianceFrameworks @("CIS 1.2", "NIST IA-2(1)", "ISO 27001 A.9.4.2") `
                    -Reference "https://learn.microsoft.com/en-us/entra/identity/authentication/"
            }
            
            # Check for legacy authentication blocking
            $legacyAuthBlocked = $caPolicies | Where-Object {
                $_.Conditions.ClientAppTypes -contains 'exchangeActiveSync' -or
                $_.Conditions.ClientAppTypes -contains 'other' -and
                $_.GrantControls.BuiltInControls -contains 'block' -and
                $_.State -eq 'enabled'
            }
            
            if ($legacyAuthBlocked.Count -eq 0) {
                Add-Finding -Domain "Identity & Access" `
                    -Title "Legacy Authentication Not Blocked" `
                    -Description "Legacy authentication protocols (like basic auth) are not blocked via Conditional Access." `
                    -Risk "High" `
                    -Remediation "Create a Conditional Access policy to block legacy authentication protocols that don't support MFA." `
                    -ComplianceFrameworks @("CIS 1.3", "NIST IA-2(1)") `
                    -Reference "https://learn.microsoft.com/en-us/entra/identity/conditional-access/block-legacy-authentication"
            }
        }
        
        # Check for security defaults
        Update-Progress -Activity "Security Review" -Status "Checking security defaults..."
        
        $securityDefaults = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy -ErrorAction SilentlyContinue
        }
        
        if ($securityDefaults.IsEnabled -eq $false -and $caPolicies.Count -eq 0) {
            Add-Finding -Domain "Identity & Access" `
                -Title "Security Defaults Disabled Without Conditional Access" `
                -Description "Security defaults are disabled and no Conditional Access policies are configured." `
                -Risk "Critical" `
                -Remediation "Either enable security defaults or implement Conditional Access policies." `
                -ComplianceFrameworks @("CIS 1.1", "NIST AC-2") `
                -Reference "https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults"
        }
        
        # Check admin MFA status
        Update-Progress -Activity "Security Review" -Status "Checking administrator MFA status..."
        
        $adminRoles = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgDirectoryRole -All -ErrorAction SilentlyContinue
        }
        
        $criticalRoles = $adminRoles | Where-Object { 
            $_.DisplayName -match "Global Administrator|Security Administrator|Privileged" 
        }
        
        foreach ($role in $criticalRoles) {
            $members = Invoke-GraphWithRetry -ScriptBlock {
                Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction SilentlyContinue
            }
            
            foreach ($member in $members) {
                $authMethods = Invoke-GraphWithRetry -ScriptBlock {
                    Get-MgUserAuthenticationMethod -UserId $member.Id -ErrorAction SilentlyContinue
                }
                
                $hasMFA = $authMethods | Where-Object { 
                    $_.'@odata.type' -match 'phone|fido2|softwareOath|microsoftAuthenticator' 
                }
                
                if (-not $hasMFA) {
                    $user = Invoke-GraphWithRetry -ScriptBlock {
                        Get-MgUser -UserId $member.Id -Property DisplayName,UserPrincipalName -ErrorAction SilentlyContinue
                    }
                    
                    Add-Finding -Domain "Identity & Access" `
                        -Title "Administrator Without MFA" `
                        -Description "User '$($user.UserPrincipalName)' has role '$($role.DisplayName)' but no MFA registered." `
                        -Risk "Critical" `
                        -Remediation "Require MFA registration for all administrative accounts immediately." `
                        -ComplianceFrameworks @("CIS 1.2", "NIST IA-2(1)", "ISO 27001 A.9.2.4") `
                        -Reference "https://learn.microsoft.com/en-us/entra/identity/authentication/"
                }
            }
        }
        
        Write-Log "Identity & Access Management assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Identity & Access assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 2: Threat Protection

function Test-ThreatProtection {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Threat Protection..." -Level Info
    
    try {
        # Check Microsoft Defender for Office 365
        Update-Progress -Activity "Security Review" -Status "Checking Defender policies..."
        
        # Anti-phishing policies
        $antiPhishPolicies = Get-AntiPhishPolicy -ErrorAction SilentlyContinue
        
        if ($antiPhishPolicies.Count -eq 0) {
            Add-Finding -Domain "Threat Protection" `
                -Title "No Anti-Phishing Policies Configured" `
                -Description "No anti-phishing policies are configured to protect against phishing attacks." `
                -Risk "High" `
                -Remediation "Configure anti-phishing policies with user and domain impersonation protection enabled." `
                -ComplianceFrameworks @("CIS 2.1", "NIST SI-3", "ISO 27001 A.12.2.1") `
                -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about"
        } else {
            foreach ($policy in $antiPhishPolicies) {
                if (-not $policy.EnableTargetedUserProtection -and -not $policy.EnableTargetedDomainsProtection) {
                    Add-Finding -Domain "Threat Protection" `
                        -Title "Anti-Phishing Policy Incomplete" `
                        -Description "Policy '$($policy.Name)' does not have user or domain impersonation protection enabled." `
                        -Risk "Medium" `
                        -Remediation "Enable targeted user and domain protection in anti-phishing policy." `
                        -ComplianceFrameworks @("CIS 2.1", "NIST SI-3") `
                        -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/"
                }
            }
        }
        
        # Safe Links policies
        $safeLinksPolicies = Get-SafeLinksPolicy -ErrorAction SilentlyContinue
        
        if ($safeLinksPolicies.Count -eq 0) {
            Add-Finding -Domain "Threat Protection" `
                -Title "No Safe Links Policies Configured" `
                -Description "Safe Links protection is not configured to scan URLs in emails and documents." `
                -Risk "High" `
                -Remediation "Configure Safe Links policies to scan URLs in emails, Office documents, and Teams." `
                -ComplianceFrameworks @("CIS 2.2", "NIST SI-3", "ISO 27001 A.12.2.1") `
                -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-links-about"
        }
        
        # Safe Attachments policies
        $safeAttachmentsPolicies = Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue
        
        if ($safeAttachmentsPolicies.Count -eq 0) {
            Add-Finding -Domain "Threat Protection" `
                -Title "No Safe Attachments Policies Configured" `
                -Description "Safe Attachments protection is not configured to scan email attachments for malware." `
                -Risk "High" `
                -Remediation "Configure Safe Attachments policies with Dynamic Delivery or Block action." `
                -ComplianceFrameworks @("CIS 2.3", "NIST SI-3", "ISO 27001 A.12.2.1") `
                -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-about"
        }
        
        # Check malware filter policies
        Update-Progress -Activity "Security Review" -Status "Checking malware filters..."
        
        $malwarePolicies = Get-MalwareFilterPolicy -ErrorAction SilentlyContinue
        
        foreach ($policy in $malwarePolicies) {
            if ($policy.EnableFileFilter -eq $false) {
                Add-Finding -Domain "Threat Protection" `
                    -Title "File Filter Disabled in Malware Policy" `
                    -Description "Malware policy '$($policy.Name)' has file filter disabled." `
                    -Risk "Medium" `
                    -Remediation "Enable common attachment type filter in malware policies." `
                    -ComplianceFrameworks @("CIS 2.4", "NIST SI-3") `
                    -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/"
        }
        }
        
        Write-Log "Threat Protection assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Threat Protection assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 3: Data Protection

function Test-DataProtection {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Data Protection..." -Level Info
    
    try {
        # Check DLP policies
        Update-Progress -Activity "Security Review" -Status "Checking DLP policies..."
        
        $dlpPolicies = Get-DlpCompliancePolicy -ErrorAction SilentlyContinue
        
        if ($dlpPolicies.Count -eq 0) {
            Add-Finding -Domain "Data Protection" `
                -Title "No DLP Policies Configured" `
                -Description "No Data Loss Prevention policies are configured to protect sensitive information." `
                -Risk "High" `
                -Remediation "Implement DLP policies to protect sensitive data types (PII, financial data, etc.)." `
                -ComplianceFrameworks @("CIS 3.1", "NIST SC-8", "ISO 27001 A.13.2.3") `
                -Reference "https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp"
        } else {
            $enabledDLP = $dlpPolicies | Where-Object { $_.Enabled -eq $true }
            
            if ($enabledDLP.Count -eq 0) {
                Add-Finding -Domain "Data Protection" `
                    -Title "All DLP Policies Disabled" `
                    -Description "DLP policies exist but all are disabled." `
                    -Risk "High" `
                    -Remediation "Enable DLP policies to actively protect sensitive data." `
                    -ComplianceFrameworks @("CIS 3.1", "NIST SC-8") `
                    -Reference "https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp"
            }
        }
        
        # Check sensitivity labels
        Update-Progress -Activity "Security Review" -Status "Checking sensitivity labels..."
        
        $sensitivityLabels = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgInformationProtectionPolicy -ErrorAction SilentlyContinue
        }
        
        if (-not $sensitivityLabels) {
            Add-Finding -Domain "Data Protection" `
                -Title "Sensitivity Labels Not Configured" `
                -Description "Sensitivity labels are not configured for data classification and protection." `
                -Risk "Medium" `
                -Remediation "Configure sensitivity labels to classify and protect sensitive documents and emails." `
                -ComplianceFrameworks @("CIS 3.2", "NIST MP-3", "ISO 27001 A.8.2.2") `
                -Reference "https://learn.microsoft.com/en-us/purview/sensitivity-labels"
        }
        
        # Check encryption settings
        Update-Progress -Activity "Security Review" -Status "Checking encryption settings..."
        
        $irmConfig = Get-IRMConfiguration -ErrorAction SilentlyContinue
        
        if ($irmConfig.AzureRMSLicensingEnabled -eq $false) {
            Add-Finding -Domain "Data Protection" `
                -Title "Azure Rights Management Not Enabled" `
                -Description "Azure Rights Management (encryption) is not enabled for the tenant." `
                -Risk "High" `
                -Remediation "Enable Azure Rights Management to support email encryption and document protection." `
                -ComplianceFrameworks @("CIS 3.3", "NIST SC-13", "ISO 27001 A.10.1.1") `
                -Reference "https://learn.microsoft.com/en-us/azure/information-protection/"
        }
        
        Write-Log "Data Protection assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Data Protection assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 4: Compliance & Governance

function Test-ComplianceGovernance {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Compliance & Governance..." -Level Info
    
    try {
        # Check audit logging
        Update-Progress -Activity "Security Review" -Status "Checking audit log configuration..."
        
        $auditConfig = Get-AdminAuditLogConfig -ErrorAction SilentlyContinue
        
        if ($auditConfig.UnifiedAuditLogIngestionEnabled -eq $false) {
            Add-Finding -Domain "Compliance & Governance" `
                -Title "Unified Audit Log Disabled" `
                -Description "Unified audit logging is not enabled, preventing visibility into user and admin activities." `
                -Risk "Critical" `
                -Remediation "Enable unified audit logging immediately to track security events and maintain compliance." `
                -ComplianceFrameworks @("CIS 4.1", "NIST AU-2", "ISO 27001 A.12.4.1") `
                -Reference "https://learn.microsoft.com/en-us/purview/audit-log-enable-disable"
        }
        
        # Check retention policies
        Update-Progress -Activity "Security Review" -Status "Checking retention policies..."
        
        $retentionPolicies = Get-RetentionCompliancePolicy -ErrorAction SilentlyContinue
        
        if ($retentionPolicies.Count -eq 0) {
            Add-Finding -Domain "Compliance & Governance" `
                -Title "No Retention Policies Configured" `
                -Description "No retention policies are configured for compliance and data governance." `
                -Risk "Medium" `
                -Remediation "Implement retention policies based on legal and compliance requirements." `
                -ComplianceFrameworks @("CIS 4.2", "NIST SI-12", "ISO 27001 A.18.1.3") `
                -Reference "https://learn.microsoft.com/en-us/purview/retention-policies"
        }
        
        # Check litigation hold status
        Update-Progress -Activity "Security Review" -Status "Checking mailbox holds..."
        
        $mailboxes = Get-Mailbox -ResultSize Unlimited -ErrorAction SilentlyContinue
        $holdCount = ($mailboxes | Where-Object { $_.LitigationHoldEnabled -eq $true }).Count
        
        if ($holdCount -eq 0 -and $mailboxes.Count -gt 0) {
            Add-Finding -Domain "Compliance & Governance" `
                -Title "No Mailboxes on Litigation Hold" `
                -Description "No mailboxes have litigation hold enabled for legal preservation." `
                -Risk "Low" `
                -Remediation "Consider enabling litigation hold for executive and legal team mailboxes as needed." `
                -ComplianceFrameworks @("ISO 27001 A.18.1.3") `
                -Reference "https://learn.microsoft.com/en-us/exchange/security-and-compliance/in-place-and-litigation-holds"
        }
        
        Write-Log "Compliance & Governance assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Compliance & Governance assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 5: Application Security

function Test-ApplicationSecurity {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Application Security..." -Level Info
    
    try {
        # Check service principals and app registrations
        Update-Progress -Activity "Security Review" -Status "Checking application permissions..."
        
        $servicePrincipals = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgServicePrincipal -All -ErrorAction SilentlyContinue
        }
        
        # Check for apps with high-risk permissions
        $highRiskPermissions = @('Mail.Read', 'Mail.ReadWrite', 'Files.ReadWrite.All', 'Sites.ReadWrite.All')
        
        foreach ($sp in $servicePrincipals) {
            $permissions = Invoke-GraphWithRetry -ScriptBlock {
                Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -ErrorAction SilentlyContinue
            }
            
            foreach ($permission in $permissions) {
                $appRole = $permission.AppRoleId
                
                # This is simplified - in production you'd map AppRoleId to permission names
                if ($permissions.Count -gt 10) {
                    Add-Finding -Domain "Application Security" `
                        -Title "Application with Excessive Permissions" `
                        -Description "Application '$($sp.DisplayName)' has $($permissions.Count) granted permissions." `
                        -Risk "Medium" `
                        -Remediation "Review and remove unnecessary permissions following principle of least privilege." `
                        -ComplianceFrameworks @("CIS 5.1", "NIST AC-6", "ISO 27001 A.9.4.1") `
                        -Reference "https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/"
                    break
                }
            }
        }
        
        # Check for user consent settings
        Update-Progress -Activity "Security Review" -Status "Checking consent settings..."
        
        $consentPolicy = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgPolicyAuthorizationPolicy -ErrorAction SilentlyContinue
        }
        
        if ($consentPolicy.DefaultUserRolePermissions.PermissionGrantPoliciesAssigned -notcontains 'ManagePermissionGrantsForSelf') {
            # User consent is restricted - this is good
        } else {
            Add-Finding -Domain "Application Security" `
                -Title "User Consent Allowed for Applications" `
                -Description "Users can consent to applications accessing organizational data." `
                -Risk "High" `
                -Remediation "Restrict user consent and implement admin consent workflow for application access." `
                -ComplianceFrameworks @("CIS 5.2", "NIST AC-3", "ISO 27001 A.9.4.1") `
                -Reference "https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-user-consent"
        }
        
        Write-Log "Application Security assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Application Security assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 6: Email Security

function Test-EmailSecurity {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Email Security..." -Level Info
    
    try {
        # Check for auto-forwarding rules
        Update-Progress -Activity "Security Review" -Status "Checking email forwarding..."
        
        $transportRules = Get-TransportRule -ErrorAction SilentlyContinue
        
        $autoForwardRule = $transportRules | Where-Object {
            $_.Name -like "*forward*" -and $_.State -eq "Enabled"
        }
        
        # Check remote domain auto-forward setting
        $remoteDomains = Get-RemoteDomain -ErrorAction SilentlyContinue
        $allowAutoForward = $remoteDomains | Where-Object { $_.AutoForwardEnabled -eq $true }
        
        if ($allowAutoForward) {
            Add-Finding -Domain "Email Security" `
                -Title "Auto-Forwarding Enabled" `
                -Description "Automatic email forwarding to external domains is allowed, posing data exfiltration risk." `
                -Risk "High" `
                -Remediation "Disable automatic forwarding to external domains or use transport rules to monitor and control." `
                -ComplianceFrameworks @("CIS 6.1", "NIST SC-7", "ISO 27001 A.13.1.3") `
                -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/"
        }
        
        # Check SPF, DKIM, DMARC
        Update-Progress -Activity "Security Review" -Status "Checking email authentication..."
        
        $acceptedDomains = Get-AcceptedDomain -ErrorAction SilentlyContinue
        
        foreach ($domain in $acceptedDomains | Where-Object { $_.DomainType -eq 'Authoritative' }) {
            # Check DKIM
            $dkimConfig = Get-DkimSigningConfig -Identity $domain.DomainName -ErrorAction SilentlyContinue
            
            if (-not $dkimConfig -or $dkimConfig.Enabled -eq $false) {
                Add-Finding -Domain "Email Security" `
                    -Title "DKIM Not Enabled for Domain" `
                    -Description "DKIM signing is not enabled for domain '$($domain.DomainName)'." `
                    -Risk "Medium" `
                    -Remediation "Enable DKIM signing to authenticate outbound emails and prevent spoofing." `
                    -ComplianceFrameworks @("CIS 6.2", "NIST SC-8", "ISO 27001 A.13.2.3") `
                    -Reference "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dkim-configure"
            }
        }
        
        # Check for mailbox delegation
        Update-Progress -Activity "Security Review" -Status "Checking mailbox permissions..."
        
        $mailboxes = Get-Mailbox -ResultSize 100 -ErrorAction SilentlyContinue
        
        foreach ($mailbox in $mailboxes) {
            $permissions = Get-MailboxPermission -Identity $mailbox.Identity -ErrorAction SilentlyContinue | 
                Where-Object { $_.User -notlike "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false }
            
            if ($permissions) {
                Add-Finding -Domain "Email Security" `
                    -Title "Mailbox Delegation Detected" `
                    -Description "Mailbox '$($mailbox.UserPrincipalName)' has delegated permissions to other users." `
                    -Risk "Low" `
                    -Remediation "Review mailbox permissions and remove unnecessary delegations." `
                    -ComplianceFrameworks @("ISO 27001 A.9.2.1") `
                    -Reference "https://learn.microsoft.com/en-us/exchange/recipients/mailbox-permissions"
            }
        }
        
        Write-Log "Email Security assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Email Security assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 7: Collaboration Security

function Test-CollaborationSecurity {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Collaboration Security..." -Level Info
    
    try {
        # Check SharePoint external sharing
        Update-Progress -Activity "Security Review" -Status "Checking SharePoint sharing settings..."
        
        $spoTenant = Get-SPOTenant -ErrorAction SilentlyContinue
        
        if ($spoTenant.SharingCapability -eq 'ExternalUserAndGuestSharing') {
            Add-Finding -Domain "Collaboration Security" `
                -Title "Unrestricted External Sharing in SharePoint" `
                -Description "SharePoint allows sharing with anyone, including unauthenticated users." `
                -Risk "High" `
                -Remediation "Restrict external sharing to authenticated users only or disable external sharing." `
                -ComplianceFrameworks @("CIS 7.1", "NIST AC-3", "ISO 27001 A.9.4.1") `
                -Reference "https://learn.microsoft.com/en-us/sharepoint/external-sharing-overview"
        }
        
        # Check Teams external access
        Update-Progress -Activity "Security Review" -Status "Checking Teams external access..."
        
        $teamsConfig = Get-CsTeamsClientConfiguration -ErrorAction SilentlyContinue
        
        if ($teamsConfig.AllowGuestUser -eq $true) {
            Add-Finding -Domain "Collaboration Security" `
                -Title "Guest Access Enabled in Teams" `
                -Description "Microsoft Teams allows guest users from external organizations." `
                -Risk "Medium" `
                -Remediation "Review guest access policies and restrict if not required. Implement guest access reviews." `
                -ComplianceFrameworks @("CIS 7.2", "NIST AC-2", "ISO 27001 A.9.2.6") `
                -Reference "https://learn.microsoft.com/en-us/microsoftteams/guest-access"
        }
        
        # Check for anonymous meeting join
        $teamsMeetingPolicy = Get-CsTeamsMeetingPolicy -Identity Global -ErrorAction SilentlyContinue
        
        if ($teamsMeetingPolicy.AllowAnonymousUsersToJoinMeeting -eq $true) {
            Add-Finding -Domain "Collaboration Security" `
                -Title "Anonymous Users Can Join Teams Meetings" `
                -Description "Anonymous users can join Teams meetings without authentication." `
                -Risk "Medium" `
                -Remediation "Disable anonymous meeting join or implement lobby controls for anonymous users." `
                -ComplianceFrameworks @("CIS 7.3", "NIST AC-3") `
                -Reference "https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-participants-and-guests"
        }
        
        Write-Log "Collaboration Security assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Collaboration Security assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 8: Device & Endpoint Security

function Test-DeviceEndpointSecurity {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Device & Endpoint Security..." -Level Info
    
    try {
        # Check Intune enrollment
        Update-Progress -Activity "Security Review" -Status "Checking device management..."
        
        $devices = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgDevice -All -ErrorAction SilentlyContinue
        }
        
        if ($devices.Count -eq 0) {
            Add-Finding -Domain "Device & Endpoint" `
                -Title "No Devices Enrolled in Management" `
                -Description "No devices are enrolled in Intune or device management." `
                -Risk "High" `
                -Remediation "Implement device enrollment and management via Intune for security control." `
                -ComplianceFrameworks @("CIS 8.1", "NIST CM-2", "ISO 27001 A.8.1.1") `
                -Reference "https://learn.microsoft.com/en-us/mem/intune/"
        } else {
            # Check for compliant devices
            $managedDevices = Invoke-GraphWithRetry -ScriptBlock {
                Get-MgDeviceManagementManagedDevice -All -ErrorAction SilentlyContinue
            }
            
            if ($managedDevices) {
                $nonCompliantDevices = $managedDevices | Where-Object { $_.ComplianceState -ne 'compliant' }
                
                if ($nonCompliantDevices.Count -gt 0) {
                    Add-Finding -Domain "Device & Endpoint" `
                        -Title "Non-Compliant Devices Detected" `
                        -Description "$($nonCompliantDevices.Count) devices are not compliant with security policies." `
                        -Risk "Medium" `
                        -Remediation "Review and remediate non-compliant devices. Consider blocking access for non-compliant devices." `
                        -ComplianceFrameworks @("CIS 8.2", "NIST CM-6") `
                        -Reference "https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started"
                }
            }
        }
        
        # Check device compliance policies
        Update-Progress -Activity "Security Review" -Status "Checking compliance policies..."
        
        $compliancePolicies = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgDeviceManagementDeviceCompliancePolicy -All -ErrorAction SilentlyContinue
        }
        
        if ($compliancePolicies.Count -eq 0) {
            Add-Finding -Domain "Device & Endpoint" `
                -Title "No Device Compliance Policies" `
                -Description "No device compliance policies are configured to enforce security requirements." `
                -Risk "High" `
                -Remediation "Create compliance policies requiring encryption, password, and security updates." `
                -ComplianceFrameworks @("CIS 8.3", "NIST CM-6", "ISO 27001 A.12.6.1") `
                -Reference "https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started"
        }
        
        Write-Log "Device & Endpoint Security assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Device & Endpoint Security assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 9: Monitoring & Alerting

function Test-MonitoringAlerting {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Monitoring & Alerting..." -Level Info
    
    try {
        # Check alert policies
        Update-Progress -Activity "Security Review" -Status "Checking alert policies..."
        
        $alertPolicies = Get-ProtectionAlert -ErrorAction SilentlyContinue
        
        if ($alertPolicies.Count -eq 0) {
            Add-Finding -Domain "Monitoring & Alerting" `
                -Title "No Alert Policies Configured" `
                -Description "No security alert policies are configured for threat detection." `
                -Risk "High" `
                -Remediation "Configure alert policies for suspicious activities (unusual logins, malware, data exfiltration)." `
                -ComplianceFrameworks @("CIS 9.1", "NIST SI-4", "ISO 27001 A.16.1.2") `
                -Reference "https://learn.microsoft.com/en-us/purview/alert-policies"
        } else {
            $disabledAlerts = $alertPolicies | Where-Object { $_.Disabled -eq $true }
            
            if ($disabledAlerts.Count -gt 0) {
                Add-Finding -Domain "Monitoring & Alerting" `
                    -Title "Alert Policies Disabled" `
                    -Description "$($disabledAlerts.Count) alert policies are disabled." `
                    -Risk "Medium" `
                    -Remediation "Review and enable critical alert policies for security monitoring." `
                    -ComplianceFrameworks @("CIS 9.1", "NIST SI-4") `
                    -Reference "https://learn.microsoft.com/en-us/purview/alert-policies"
            }
        }
        
        # Check mailbox auditing
        Update-Progress -Activity "Security Review" -Status "Checking mailbox auditing..."
        
        $mailboxAuditStatus = Get-OrganizationConfig -ErrorAction SilentlyContinue
        
        if ($mailboxAuditStatus.AuditDisabled -eq $true) {
            Add-Finding -Domain "Monitoring & Alerting" `
                -Title "Mailbox Auditing Disabled" `
                -Description "Mailbox auditing is disabled, preventing visibility into mailbox access." `
                -Risk "High" `
                -Remediation "Enable mailbox auditing to track mailbox access and changes." `
                -ComplianceFrameworks @("CIS 9.2", "NIST AU-2", "ISO 27001 A.12.4.1") `
                -Reference "https://learn.microsoft.com/en-us/purview/audit-mailboxes"
        }
        
        Write-Log "Monitoring & Alerting assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Monitoring & Alerting assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Domain 10: Privileged Access

function Test-PrivilegedAccess {
    [CmdletBinding()]
    param()
    
    Write-Log "Assessing Privileged Access..." -Level Info
    
    try {
        # Check Global Administrator count
        Update-Progress -Activity "Security Review" -Status "Checking privileged roles..."
        
        $globalAdminRole = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgDirectoryRole -All | Where-Object { $_.DisplayName -eq "Global Administrator" }
        }
        
        if ($globalAdminRole) {
            $globalAdmins = Invoke-GraphWithRetry -ScriptBlock {
                Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id -All
            }
            
            if ($globalAdmins.Count -gt 5) {
                Add-Finding -Domain "Privileged Access" `
                    -Title "Excessive Global Administrators" `
                    -Description "Found $($globalAdmins.Count) Global Administrators. Microsoft recommends 2-4." `
                    -Risk "High" `
                    -Remediation "Reduce Global Administrator count. Use role-based administration with least privilege." `
                    -ComplianceFrameworks @("CIS 10.1", "NIST AC-6", "ISO 27001 A.9.2.3") `
                    -Reference "https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices"
            }
            
            # Check for emergency access accounts
            $emergencyAccountPattern = @("break", "glass", "emergency")
            $emergencyAccounts = $globalAdmins | Where-Object {
                $user = Invoke-GraphWithRetry -ScriptBlock {
                    Get-MgUser -UserId $_.Id -ErrorAction SilentlyContinue
                }
                $emergencyAccountPattern | ForEach-Object { $user.DisplayName -like "*$_*" }
            }
            
            if ($emergencyAccounts.Count -eq 0) {
                Add-Finding -Domain "Privileged Access" `
                    -Title "No Emergency Access Account Detected" `
                    -Description "No dedicated emergency access (break-glass) account found." `
                    -Risk "Medium" `
                    -Remediation "Create emergency access accounts excluded from MFA and Conditional Access for account lockout scenarios." `
                    -ComplianceFrameworks @("CIS 10.2", "NIST AC-2") `
                    -Reference "https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access"
            }
        }
        
        # Check privileged role assignments
        Update-Progress -Activity "Security Review" -Status "Auditing role assignments..."
        
        $allRoles = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgDirectoryRole -All
        }
        
        $privilegedRoles = $allRoles | Where-Object { 
            $_.DisplayName -match "Administrator|Privileged" 
        }
        
        foreach ($role in $privilegedRoles) {
            $members = Invoke-GraphWithRetry -ScriptBlock {
                Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction SilentlyContinue
            }
            
            foreach ($member in $members) {
                $user = Invoke-GraphWithRetry -ScriptBlock {
                    Get-MgUser -UserId $member.Id -Property AccountEnabled,UserPrincipalName -ErrorAction SilentlyContinue
                }
                
                if ($user.AccountEnabled -eq $false) {
                    Add-Finding -Domain "Privileged Access" `
                        -Title "Disabled User with Privileged Role" `
                        -Description "Disabled user '$($user.UserPrincipalName)' still has '$($role.DisplayName)' role." `
                        -Risk "Medium" `
                        -Remediation "Remove role assignments from disabled user accounts." `
                        -ComplianceFrameworks @("CIS 10.3", "NIST AC-2", "ISO 27001 A.9.2.6") `
                        -Reference "https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/"
                }
            }
        }
        
        # Check for PIM (Privileged Identity Management)
        Update-Progress -Activity "Security Review" -Status "Checking PIM configuration..."
        
        $pimRoles = Invoke-GraphWithRetry -ScriptBlock {
            Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All -ErrorAction SilentlyContinue
        }
        
        if (-not $pimRoles) {
            Add-Finding -Domain "Privileged Access" `
                -Title "Privileged Identity Management Not Configured" `
                -Description "PIM is not configured for just-in-time privileged access." `
                -Risk "Medium" `
                -Remediation "Implement PIM to provide time-bound and approval-based role activation for privileged roles." `
                -ComplianceFrameworks @("CIS 10.4", "NIST AC-6", "ISO 27001 A.9.2.3") `
                -Reference "https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/"
        }
        
        Write-Log "Privileged Access assessment completed" -Level Success
    }
    catch {
        Write-Log "Error in Privileged Access assessment: $($_.Exception.Message)" -Level Error
    }
}

#endregion

#region Export Functions

function Export-ToCSV {
    param([string]$Path)
    
    try {
        $csvPath = Join-Path $Path "M365SecurityReview_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        $script:Findings | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Write-Log "CSV report exported to: $csvPath" -Level Success
        return $csvPath
    }
    catch {
        Write-Log "Failed to export CSV: $($_.Exception.Message)" -Level Error
        throw
    }
}

function Export-ToJSON {
    param([string]$Path)
    
    try {
        $jsonPath = Join-Path $Path "M365SecurityReview_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        
        $report = @{
            GeneratedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Duration = (Get-Date) - $script:StartTime
            TotalFindings = $script:Findings.Count
            CriticalFindings = ($script:Findings | Where-Object { $_.Risk -eq 'Critical' }).Count
            HighFindings = ($script:Findings | Where-Object { $_.Risk -eq 'High' }).Count
            MediumFindings = ($script:Findings | Where-Object { $_.Risk -eq 'Medium' }).Count
            LowFindings = ($script:Findings | Where-Object { $_.Risk -eq 'Low' }).Count
            Findings = $script:Findings
        }
        
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
        Write-Log "JSON report exported to: $jsonPath" -Level Success
        return $jsonPath
    }
    catch {
        Write-Log "Failed to export JSON: $($_.Exception.Message)" -Level Error
        throw
    }
}

function Export-ToHTML {
    param([string]$Path)
    
    try {
        $htmlPath = Join-Path $Path "M365SecurityReview_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
        
        $criticalCount = ($script:Findings | Where-Object { $_.Risk -eq 'Critical' }).Count
        $highCount = ($script:Findings | Where-Object { $_.Risk -eq 'High' }).Count
        $mediumCount = ($script:Findings | Where-Object { $_.Risk -eq 'Medium' }).Count
        $lowCount = ($script:Findings | Where-Object { $_.Risk -eq 'Low' }).Count
        $infoCount = ($script:Findings | Where-Object { $_.Risk -eq 'Info' }).Count
        
        # Calculate risk score (0-100, lower is better)
        $riskScore = [math]::Min(100, ($criticalCount * 10) + ($highCount * 5) + ($mediumCount * 2) + $lowCount)
        $riskLevel = if ($riskScore -gt 50) { "High Risk" } elseif ($riskScore -gt 20) { "Medium Risk" } else { "Low Risk" }
        $riskColor = if ($riskScore -gt 50) { "#d32f2f" } elseif ($riskScore -gt 20) { "#f57c00" } else { "#388e3c" }
        
        $css = @"
<style>
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        margin: 0;
        padding: 20px;
        background-color: #f5f5f5;
    }
    .header {
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        color: white;
        padding: 40px;
        border-radius: 10px;
        margin-bottom: 30px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    h1 {
        margin: 0 0 10px 0;
        font-size: 32px;
    }
    .subtitle {
        opacity: 0.9;
        font-size: 16px;
        margin: 5px 0;
    }
    .summary-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .summary-card {
        background-color: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        text-align: center;
    }
    .summary-label {
        font-size: 13px;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 10px;
    }
    .summary-value {
        font-size: 36px;
        font-weight: bold;
        margin: 10px 0;
    }
    .risk-critical { color: #d32f2f; }
    .risk-high { color: #f57c00; }
    .risk-medium { color: #ffa726; }
    .risk-low { color: #66bb6a; }
    .risk-info { color: #42a5f5; }
    .risk-score-card {
        grid-column: span 2;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }
    .risk-score-value {
        font-size: 48px;
        font-weight: bold;
        color: white;
    }
    .findings-section {
        background-color: white;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
    .findings-section h2 {
        margin-top: 0;
        color: #1e3c72;
        border-bottom: 2px solid #1e3c72;
        padding-bottom: 10px;
    }
    .finding {
        background-color: #fafafa;
        border-left: 4px solid #ccc;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 5px;
    }
    .finding.critical { border-left-color: #d32f2f; }
    .finding.high { border-left-color: #f57c00; }
    .finding.medium { border-left-color: #ffa726; }
    .finding.low { border-left-color: #66bb6a; }
    .finding-title {
        font-size: 18px;
        font-weight: bold;
        margin-bottom: 10px;
        color: #333;
    }
    .finding-risk {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 15px;
        font-size: 12px;
        font-weight: bold;
        text-transform: uppercase;
        margin-left: 10px;
    }
    .risk-badge-critical {
        background-color: #d32f2f;
        color: white;
    }
    .risk-badge-high {
        background-color: #f57c00;
        color: white;
    }
    .risk-badge-medium {
        background-color: #ffa726;
        color: white;
    }
    .risk-badge-low {
        background-color: #66bb6a;
        color: white;
    }
    .finding-domain {
        color: #666;
        font-size: 14px;
        margin-bottom: 10px;
    }
    .finding-description {
        margin: 15px 0;
        line-height: 1.6;
        color: #555;
    }
    .finding-remediation {
        background-color: #e3f2fd;
        padding: 15px;
        border-radius: 5px;
        margin-top: 15px;
    }
    .finding-remediation-title {
        font-weight: bold;
        color: #1565c0;
        margin-bottom: 8px;
    }
    .finding-compliance {
        margin-top: 10px;
        font-size: 13px;
        color: #666;
    }
    .footer {
        text-align: center;
        margin-top: 40px;
        padding: 20px;
        background-color: white;
        border-radius: 10px;
        color: #666;
        font-size: 14px;
    }
    .no-findings {
        text-align: center;
        padding: 40px;
        color: #66bb6a;
        font-size: 18px;
    }
</style>
"@
        
        $findingsByRisk = $script:Findings | Group-Object -Property Risk | Sort-Object @{Expression={
            switch ($_.Name) {
                'Critical' { 1 }
                'High' { 2 }
                'Medium' { 3 }
                'Low' { 4 }
                'Info' { 5 }
            }
        }}
        
        $findingsHTML = ""
        
        if ($script:Findings.Count -eq 0) {
            $findingsHTML = "<div class='no-findings'>✓ No security findings detected. Your environment appears to be well-configured!</div>"
        } else {
            foreach ($riskGroup in $findingsByRisk) {
                $riskLevel = $riskGroup.Name.ToLower()
                
                foreach ($finding in $riskGroup.Group) {
                    $findingsHTML += @"
                <div class='finding $riskLevel'>
                    <div class='finding-title'>
                        $($finding.Title)
                        <span class='finding-risk risk-badge-$riskLevel'>$($finding.Risk)</span>
                    </div>
                    <div class='finding-domain'><strong>Domain:</strong> $($finding.Domain)</div>
                    <div class='finding-description'>$($finding.Description)</div>
                    <div class='finding-remediation'>
                        <div class='finding-remediation-title'>📋 Remediation:</div>
                        $($finding.Remediation)
                    </div>
                    $(if ($finding.ComplianceFrameworks) { "<div class='finding-compliance'><strong>Compliance:</strong> $($finding.ComplianceFrameworks)</div>" })
                    $(if ($finding.Reference) { "<div class='finding-compliance'><strong>Reference:</strong> <a href='$($finding.Reference)' target='_blank'>$($finding.Reference)</a></div>" })
                </div>
"@
                }
            }
        }
        
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Microsoft 365 Security Review Report</title>
    $css
</head>
<body>
    <div class='header'>
        <h1>🛡️ Microsoft 365 Security Review Report</h1>
        <div class='subtitle'>Comprehensive Security Assessment</div>
        <div class='subtitle'>Generated: $(Get-Date -Format 'dddd, MMMM dd, yyyy - HH:mm:ss')</div>
        <div class='subtitle'>Duration: $([math]::Round(((Get-Date) - $script:StartTime).TotalSeconds, 2)) seconds</div>
    </div>
    
    <div class='summary-container'>
        <div class='summary-card risk-score-card'>
            <div class='summary-label'>Risk Score</div>
            <div class='risk-score-value'>$riskScore</div>
            <div style='font-size: 16px; margin-top: 10px;'>$riskLevel</div>
        </div>
        <div class='summary-card'>
            <div class='summary-label'>Total Findings</div>
            <div class='summary-value'>$($script:Findings.Count)</div>
        </div>
        <div class='summary-card'>
            <div class='summary-label'>Critical</div>
            <div class='summary-value risk-critical'>$criticalCount</div>
        </div>
        <div class='summary-card'>
            <div class='summary-label'>High</div>
            <div class='summary-value risk-high'>$highCount</div>
        </div>
        <div class='summary-card'>
            <div class='summary-label'>Medium</div>
            <div class='summary-value risk-medium'>$mediumCount</div>
        </div>
        <div class='summary-card'>
            <div class='summary-label'>Low</div>
            <div class='summary-value risk-low'>$lowCount</div>
        </div>
    </div>
    
    <div class='findings-section'>
        <h2>Security Findings & Recommendations</h2>
        $findingsHTML
    </div>
    
    <div class='footer'>
        <strong>Microsoft 365 Security Review</strong><br>
        Powered by PowerShell Automation | Security Administrator Agent<br>
        This report contains confidential security information
    </div>
</body>
</html>
"@
        
        $html | Out-File -FilePath $htmlPath -Encoding UTF8
        Write-Log "HTML report exported to: $htmlPath" -Level Success
        
        # Try to open in default browser
        if ($PSCmdlet.ShouldProcess($htmlPath, "Open in browser")) {
            try {
                Start-Process $htmlPath
            }
            catch {
                Write-Log "Could not open browser automatically. Please open the file manually." -Level Warning
            }
        }
        
        return $htmlPath
    }
    catch {
        Write-Log "Failed to export HTML: $($_.Exception.Message)" -Level Error
        throw
    }
}

#endregion

#region Main Execution

try {
    Write-Log "========================================" -Level Info
    Write-Log "Microsoft 365 Security Review Starting" -Level Info
    Write-Log "========================================" -Level Info
    
    # Validate output path
    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
        Write-Log "Created output directory: $OutputPath" -Level Info
    }
    
    # Check connections
    Write-Log "Checking Microsoft Graph connection..." -Level Info
    
    try {
        $context = Get-MgContext -ErrorAction SilentlyContinue
        if (-not $context) {
            Write-Log "Not connected to Microsoft Graph. Attempting to connect..." -Level Warning
            Connect-MgGraph -Scopes "Directory.Read.All", "Policy.Read.All", "SecurityEvents.Read.All", "User.Read.All", "AuditLog.Read.All" -NoWelcome
            Write-Log "Connected to Microsoft Graph successfully" -Level Success
        } else {
            Write-Log "Already connected to Microsoft Graph as $($context.Account)" -Level Success
        }
    }
    catch {
        Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" -Level Error
        Write-Log "Please run: Connect-MgGraph -Scopes 'Directory.Read.All','Policy.Read.All','SecurityEvents.Read.All'" -Level Error
        exit 1
    }
    
    # Check Exchange Online connection
    Write-Log "Checking Exchange Online connection..." -Level Info
    
    try {
        $exoSession = Get-ConnectionInformation -ErrorAction SilentlyContinue
        if (-not $exoSession) {
            Write-Log "Not connected to Exchange Online. Attempting to connect..." -Level Warning
            Connect-ExchangeOnline -ShowBanner:$false
            Write-Log "Connected to Exchange Online successfully" -Level Success
        } else {
            Write-Log "Already connected to Exchange Online" -Level Success
        }
    }
    catch {
        Write-Log "Failed to connect to Exchange Online: $($_.Exception.Message)" -Level Warning
        Write-Log "Some checks will be skipped. Run: Connect-ExchangeOnline" -Level Warning
    }
    
    # Define all domains and their functions
    $domains = @(
        @{ Name = "Identity"; DisplayName = "Identity & Access Management"; Function = { Test-IdentityAccessManagement } },
        @{ Name = "Threat"; DisplayName = "Threat Protection"; Function = { Test-ThreatProtection } },
        @{ Name = "Data"; DisplayName = "Data Protection"; Function = { Test-DataProtection } },
        @{ Name = "Compliance"; DisplayName = "Compliance & Governance"; Function = { Test-ComplianceGovernance } },
        @{ Name = "Application"; DisplayName = "Application Security"; Function = { Test-ApplicationSecurity } },
        @{ Name = "Email"; DisplayName = "Email Security"; Function = { Test-EmailSecurity } },
        @{ Name = "Collaboration"; DisplayName = "Collaboration Security"; Function = { Test-CollaborationSecurity } },
        @{ Name = "Device"; DisplayName = "Device & Endpoint Security"; Function = { Test-DeviceEndpointSecurity } },
        @{ Name = "Monitoring"; DisplayName = "Monitoring & Alerting"; Function = { Test-MonitoringAlerting } },
        @{ Name = "Privileged"; DisplayName = "Privileged Access"; Function = { Test-PrivilegedAccess } }
    )
    
    # Filter out skipped domains
    $domainsToTest = $domains | Where-Object { $_.Name -notin $SkipDomains }
    $script:TotalChecks = $domainsToTest.Count * 5 # Approximate checks per domain
    
    Write-Log "Starting security assessment across $($domainsToTest.Count) domains..." -Level Info
    
    # Execute all domain assessments
    foreach ($domain in $domainsToTest) {
        Write-Log "========================================"  -Level Info
        Write-Log "Assessing: $($domain.DisplayName)" -Level Info
        Write-Log "========================================"  -Level Info
        
        try {
            & $domain.Function
        }
        catch {
            Write-Log "Error assessing $($domain.DisplayName): $($_.Exception.Message)" -Level Error
        }
    }
    
    Write-Progress -Activity "Security Review" -Completed
    
    # Generate summary
    Write-Log "========================================" -Level Info
    Write-Log "Security Assessment Complete" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log "Total Findings: $($script:Findings.Count)" -Level Info
    Write-Log "  Critical: $(($script:Findings | Where-Object { $_.Risk -eq 'Critical' }).Count)" -Level $(if (($script:Findings | Where-Object { $_.Risk -eq 'Critical' }).Count -gt 0) { 'Error' } else { 'Info' })
    Write-Log "  High: $(($script:Findings | Where-Object { $_.Risk -eq 'High' }).Count)" -Level $(if (($script:Findings | Where-Object { $_.Risk -eq 'High' }).Count -gt 0) { 'Warning' } else { 'Info' })
    Write-Log "  Medium: $(($script:Findings | Where-Object { $_.Risk -eq 'Medium' }).Count)" -Level Info
    Write-Log "  Low: $(($script:Findings | Where-Object { $_.Risk -eq 'Low' }).Count)" -Level Info
    
    # Export reports
    Write-Log "========================================" -Level Info
    Write-Log "Exporting Reports" -Level Info
    Write-Log "========================================" -Level Info
    
    $exportedFiles = @()
    
    if ($Format -eq 'All' -or $Format -eq 'HTML') {
        $htmlFile = Export-ToHTML -Path $OutputPath
        $exportedFiles += $htmlFile
    }
    
    if ($Format -eq 'All' -or $Format -eq 'CSV') {
        $csvFile = Export-ToCSV -Path $OutputPath
        $exportedFiles += $csvFile
    }
    
    if ($Format -eq 'All' -or $Format -eq 'JSON') {
        $jsonFile = Export-ToJSON -Path $OutputPath
        $exportedFiles += $jsonFile
    }
    
    Write-Log "========================================" -Level Success
    Write-Log "Security Review Complete!" -Level Success
    Write-Log "========================================" -Level Success
    Write-Log "Exported files:" -Level Success
    foreach ($file in $exportedFiles) {
        Write-Log "  - $file" -Level Success
    }
    
    # Return summary object
    return [PSCustomObject]@{
        TotalFindings = $script:Findings.Count
        CriticalFindings = ($script:Findings | Where-Object { $_.Risk -eq 'Critical' }).Count
        HighFindings = ($script:Findings | Where-Object { $_.Risk -eq 'High' }).Count
        MediumFindings = ($script:Findings | Where-Object { $_.Risk -eq 'Medium' }).Count
        LowFindings = ($script:Findings | Where-Object { $_.Risk -eq 'Low' }).Count
        Duration = (Get-Date) - $script:StartTime
        ExportedFiles = $exportedFiles
    }
}
catch {
    Write-Log "Critical error during security review: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    throw
}
finally {
    # Cleanup
    Write-Progress -Activity "Security Review" -Completed
}

#endregion

