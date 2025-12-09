# Audit Agent - Microsoft 365 Usage and User Profiling

## Overview
The Audit Agent is responsible for creating PowerShell scripts to profile and audit Microsoft 365 usage and users across the organization.

## Purpose
Build comprehensive auditing scripts that provide insights into:
- User activity and usage patterns
- License utilization
- Service adoption (Teams, SharePoint, Exchange, etc.)
- Security and compliance status
- Resource consumption
- User behavior analytics

## Branch Information
When the Audit Agent creates scripts, they should:
1. Create feature branch: `agent/audit/profile-m365-usage` (or similar descriptive name)
2. Work exclusively in this branch
3. Commit scripts as they are created
4. Notify Master Agent when ready for review

## Expected Scripts
The Audit Agent may create multiple scripts for different aspects of auditing:

### Potential Script Categories
- **User Activity Auditing**: Track user logins, activity, last access
- **License Usage Auditing**: Analyze license assignment and utilization
- **Service Usage Auditing**: Teams, SharePoint, Exchange usage statistics
- **Security Auditing**: Sign-in logs, conditional access, MFA status
- **Compliance Auditing**: Data retention, DLP policies, eDiscovery
- **Resource Auditing**: Storage usage, mailbox sizes, OneDrive usage

## Script Requirements
All audit scripts must:
- ✅ Follow `Agents/AGENT_CONTEXT.md` standards
- ✅ Use Microsoft Graph PowerShell SDK
- ✅ Include comprehensive error handling
- ✅ Support `-WhatIf` for any modification operations
- ✅ Export data in readable formats (CSV, JSON)
- ✅ Include logging and progress indicators
- ✅ No mock code or placeholders
- ✅ Proper authentication and credential handling

## Review Process
1. Audit Agent creates scripts in feature branch
2. Audit Agent notifies Master Agent when complete
3. Master Agent reviews using `SAFETY_CHECKLIST.md`
4. Master Agent provides feedback (APPROVED/NEEDS REVISION/REJECTED)
5. If approved, Master Agent merges to main branch
6. Scripts are ready for testing and use

## Documentation
- See `Agents/AGENT_CONTEXT.md` for development standards
- See `BRANCH_WORKFLOW.md` for branch management
- See `SAFETY_CHECKLIST.md` for review criteria
- See `WORKFLOW.md` for complete process

## Notes
- Audit scripts are typically read-only (reporting)
- Some audit scripts may need modification capabilities (with safeguards)
- All scripts must respect privacy and compliance requirements
- Export formats should be user-friendly and actionable

---

**Status**: Awaiting Audit Agent task completion
**Branch**: Will be created by Audit Agent
**Review**: Master Agent will review upon completion

