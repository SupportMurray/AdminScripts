# AI Agent Context Documentation

## Purpose
This document provides essential context for all AI agents working on Microsoft 365 automation scripts. It establishes the foundation, standards, and guidelines that all specialized agents must follow.

## Core Principles

### 1. Safety First
- **Never create destructive operations without safeguards**
- Always include `-WhatIf` support for modification operations
- Require confirmation for critical changes
- Implement proper error handling to prevent partial execution

### 2. Production-Ready Code
- **No mock code or placeholders**
- All scripts must be fully functional
- Complete error handling and logging
- Proper authentication and credential management

### 3. PowerShell Best Practices
- Use official Microsoft Graph PowerShell SDK or Exchange Online Management modules
- Follow PowerShell naming conventions (PascalCase for functions, approved verbs)
- Implement comment-based help for all functions
- Use proper parameter validation

### 4. Security Standards
- Never hardcode credentials or secrets
- Use modern authentication methods
- Implement secure credential handling
- Follow principle of least privilege

## Microsoft 365 Environment Context

### Authentication Methods
1. **Microsoft Graph PowerShell SDK**
   - Uses modern authentication (OAuth 2.0)
   - Supports certificate-based authentication
   - Requires appropriate Azure AD app permissions

2. **Exchange Online Management**
   - Modern authentication via Connect-ExchangeOnline
   - Certificate-based authentication supported
   - Role-based access control

3. **SharePoint Online Management Shell**
   - Modern authentication via Connect-SPOService
   - Supports certificate-based authentication

4. **Teams PowerShell Module**
   - Modern authentication via Connect-MicrosoftTeams
   - Requires appropriate permissions

### Common Modules
- `Microsoft.Graph` - Microsoft Graph PowerShell SDK
- `Microsoft.Graph.Intune` - Intune management (legacy)
- `Microsoft.Graph.DeviceManagement` - Device management
- `Microsoft.Graph.DeviceManagement.Administration` - Intune administration
- `Microsoft.Graph.DeviceManagement.Enrollment` - Device enrollment
- `ExchangeOnlineManagement` - Exchange Online management
- `MicrosoftTeams` - Teams management
- `SharePointPnPPowerShellOnline` or `PnP.PowerShell` - SharePoint management
- `AzureAD` or `Microsoft.Graph.Identity.DirectoryManagement` - Azure AD management

### Permission Requirements
- **Global Administrator**: Full access (use sparingly)
- **Exchange Administrator**: Exchange Online management
- **SharePoint Administrator**: SharePoint and OneDrive management
- **Teams Administrator**: Teams configuration and management
- **User Administrator**: User and group management
- **License Administrator**: License assignment
- **Security Administrator**: Security settings and policies
- **Intune Administrator**: Full Intune and device management access
- **Endpoint Security Manager**: Security policies and compliance
- **Cloud Device Administrator**: Device management and actions
- **Audit Log**: Read audit logs and sign-in logs
- **Reports Reader**: Read usage and activity reports
- **Compliance Administrator**: Compliance and audit data access

## Script Structure Standards

### Required Script Header
```powershell
<#
.SYNOPSIS
    Brief description of what the script does

.DESCRIPTION
    Detailed description of the script's functionality

.PARAMETER ParameterName
    Description of the parameter

.EXAMPLE
    Example of how to use the script

.NOTES
    Author: [Agent Name]
    Date: [Date]
    Version: 1.0
    Requires: [List required modules and permissions]
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$ParameterName
)
```

### Error Handling Pattern
```powershell
try {
    # Main script logic
    if ($PSCmdlet.ShouldProcess($target, "Operation description")) {
        # Perform operation
    }
}
catch {
    Write-Error "Error occurred: $($_.Exception.Message)"
    Write-Error "Stack trace: $($_.ScriptStackTrace)"
    # Cleanup if necessary
    exit 1
}
finally {
    # Cleanup connections, close sessions, etc.
}
```

### Logging Pattern
```powershell
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
```

## Common Patterns

### Connection Management
```powershell
# Connect to services
try {
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"
    Connect-ExchangeOnline -ShowProgress $false
}
catch {
    Write-Error "Failed to connect: $($_.Exception.Message)"
    exit 1
}

# Disconnect at end
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
```

### Microsoft Graph Pagination Pattern
```powershell
# Handle @odata.nextLink for large result sets
function Get-GraphDataAllPages {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Uri,
        
        [int]$MaxResults = 0
    )
    
    $allResults = @()
    $count = 0
    
    try {
        do {
            $response = Invoke-MgGraphRequest -Uri $Uri -Method GET
            
            if ($response.value) {
                $allResults += $response.value
                $count = $allResults.Count
                
                Write-Progress -Activity "Collecting data from Microsoft Graph" `
                    -Status "Retrieved $count records" `
                    -PercentComplete -1
                
                # Check if max results reached
                if ($MaxResults -gt 0 -and $count -ge $MaxResults) {
                    Write-Log "Maximum result limit ($MaxResults) reached" -Level Info
                    break
                }
            }
            
            $Uri = $response.'@odata.nextLink'
            
        } while ($Uri)
        
        Write-Progress -Activity "Collecting data from Microsoft Graph" -Completed
        Write-Log "Collected $count total records from Graph API" -Level Success
        
        return $allResults
    }
    catch {
        Write-Error "Failed to retrieve Graph data: $($_.Exception.Message)"
        throw
    }
}
```

### Graph API Throttling and Retry Pattern
```powershell
# Handle Microsoft Graph throttling (429 errors) with exponential backoff
function Invoke-GraphWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,
        
        [int]$MaxRetries = 5,
        [int]$BaseDelaySeconds = 2
    )
    
    $attempt = 0
    
    do {
        try {
            return & $ScriptBlock
        }
        catch {
            $attempt++
            
            # Check for throttling (429) or service unavailable (503)
            if ($_.Exception.Response.StatusCode -eq 429 -or 
                $_.Exception.Response.StatusCode -eq 503) {
                
                # Try to get Retry-After header
                $retryAfter = $_.Exception.Response.Headers['Retry-After']
                
                if (-not $retryAfter) {
                    # Use exponential backoff if no Retry-After header
                    $retryAfter = $BaseDelaySeconds * [Math]::Pow(2, $attempt - 1)
                }
                
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
                # Non-throttling error, throw immediately
                throw
            }
        }
    } while ($attempt -le $MaxRetries)
}

# Example usage:
# $users = Invoke-GraphWithRetry -ScriptBlock { Get-MgUser -All }
```

### Bulk Operations with Progress
```powershell
$items = Get-MgUser -All
$total = $items.Count
$current = 0

foreach ($item in $items) {
    $current++
    Write-Progress -Activity "Processing items" -Status "Processing $current of $total" -PercentComplete (($current / $total) * 100)
    
    try {
        # Process item
    }
    catch {
        Write-Warning "Failed to process $($item.Id): $($_.Exception.Message)"
    }
}
```

### Audit Data Collection Pattern
```powershell
# Audit scripts should collect data efficiently and export in readable formats
function Export-AuditData {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Data,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [ValidateSet('CSV', 'JSON', 'HTML')]
        [string]$Format = 'CSV'
    )
    
    try {
        switch ($Format) {
            'CSV' {
                $Data | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
            }
            'JSON' {
                $Data | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
            }
            'HTML' {
                # Generate HTML report with formatting
                $html = $Data | ConvertTo-Html -Property * -Title "Audit Report"
                $html | Out-File -FilePath $OutputPath -Encoding UTF8
            }
        }
        Write-Log "Exported $($Data.Count) records to $OutputPath" -Level Success
    }
    catch {
        Write-Error "Failed to export data: $($_.Exception.Message)"
        throw
    }
}

### Advanced HTML Report with Aggregations
```powershell
# Generate professional audit reports with summaries and visualizations
function Export-AuditHTMLReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Data,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [hashtable]$Summaries,
        [array]$TopItems,
        [string]$Description
    )
    
    try {
        $css = @"
<style>
    body { 
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        margin: 0;
        padding: 20px;
        background-color: #f5f5f5;
    }
    .header {
        background: linear-gradient(135deg, #0078d4 0%, #005a9e 100%);
        color: white;
        padding: 30px;
        border-radius: 8px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    h1 { margin: 0; font-size: 28px; }
    .subtitle { opacity: 0.9; margin-top: 10px; font-size: 14px; }
    .summary-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
        margin-bottom: 20px;
    }
    .summary-card {
        background-color: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .summary-label {
        font-size: 12px;
        color: #666;
        text-transform: uppercase;
        margin-bottom: 5px;
    }
    .summary-value {
        font-size: 32px;
        font-weight: bold;
        color: #0078d4;
    }
    .top-items {
        background-color: white;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    table {
        border-collapse: collapse;
        width: 100%;
        background-color: white;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    th {
        background-color: #0078d4;
        color: white;
        padding: 12px;
        text-align: left;
        font-weight: 600;
    }
    td {
        border-bottom: 1px solid #e0e0e0;
        padding: 12px;
    }
    tr:hover {
        background-color: #f5f5f5;
    }
    tr:last-child td {
        border-bottom: none;
    }
    .footer {
        margin-top: 20px;
        padding: 15px;
        background-color: white;
        border-radius: 8px;
        text-align: center;
        font-size: 12px;
        color: #666;
    }
</style>
"@
        
        $html = @"
<html>
<head>
    <meta charset="UTF-8">
    <title>$Title</title>
    $css
</head>
<body>
    <div class="header">
        <h1>$Title</h1>
        $(if ($Description) { "<div class='subtitle'>$Description</div>" })
        <div class='subtitle'>Generated: $(Get-Date -Format 'dddd, MMMM dd, yyyy - HH:mm:ss')</div>
    </div>
"@
        
        # Add summary cards
        if ($Summaries -and $Summaries.Count -gt 0) {
            $html += "<div class='summary-container'>"
            foreach ($key in $Summaries.Keys) {
                $html += @"
                <div class='summary-card'>
                    <div class='summary-label'>$key</div>
                    <div class='summary-value'>$($Summaries[$key])</div>
                </div>
"@
            }
            $html += "</div>"
        }
        
        # Add top items section
        if ($TopItems -and $TopItems.Count -gt 0) {
            $html += "<div class='top-items'>"
            $html += "<h2>Top Items</h2>"
            $html += $TopItems | ConvertTo-Html -Fragment
            $html += "</div>"
        }
        
        # Add main data table
        if ($Data -and $Data.Count -gt 0) {
            $html += "<div style='background-color: white; border-radius: 8px; padding: 20px; margin-bottom: 20px;'>"
            $html += "<h2>Detailed Data ($($Data.Count) records)</h2>"
            $html += $Data | ConvertTo-Html -Fragment
            $html += "</div>"
        }
        
        # Add footer
        $html += @"
    <div class='footer'>
        Microsoft 365 Audit Report | Generated by PowerShell Automation
    </div>
</body>
</html>
"@
        
        $html | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Log "Exported HTML report to $OutputPath" -Level Success
        
        # Try to open in default browser
        if ($PSCmdlet.ShouldProcess($OutputPath, "Open in browser")) {
            Start-Process $OutputPath
        }
    }
    catch {
        Write-Error "Failed to export HTML report: $($_.Exception.Message)"
        throw
    }
}

# Example usage with aggregations:
<#
$auditData = Get-AuditData
$summaries = @{
    "Total Records" = $auditData.Count
    "Unique Users" = ($auditData | Select-Object -Unique UserPrincipalName).Count
    "Date Range" = "$($auditData[0].Date) to $($auditData[-1].Date)"
    "High Risk Events" = ($auditData | Where-Object {$_.RiskLevel -eq 'High'}).Count
}

$topUsers = $auditData | 
    Group-Object UserPrincipalName | 
    Select-Object @{N='User';E={$_.Name}}, @{N='ActivityCount';E={$_.Count}} | 
    Sort-Object ActivityCount -Descending | 
    Select-Object -First 10

Export-AuditHTMLReport -Data $auditData -OutputPath "report.html" `
    -Title "Security Audit Report" `
    -Summaries $summaries `
    -TopItems $topUsers `
    -Description "Comprehensive security audit for the period"
#>
```

### Incremental Audit Collection Pattern
```powershell
# For daily/weekly scheduled audit collections
# Maintains state to avoid re-collecting the same data
function Get-IncrementalAuditData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StateFilePath,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$CollectionScriptBlock,
        
        [int]$DefaultLookbackDays = 1
    )
    
    try {
        # Load last collection timestamp
        if (Test-Path $StateFilePath) {
            $state = Get-Content $StateFilePath -Raw | ConvertFrom-Json
            $lastCollection = [datetime]$state.LastCollectionTime
            Write-Log "Last collection: $lastCollection" -Level Info
        }
        else {
            $lastCollection = (Get-Date).AddDays(-$DefaultLookbackDays)
            Write-Log "No previous state found. Looking back $DefaultLookbackDays days" -Level Info
        }
        
        $currentCollection = Get-Date
        
        # Collect data for incremental period
        Write-Log "Collecting data from $lastCollection to $currentCollection" -Level Info
        $data = & $CollectionScriptBlock -StartDate $lastCollection -EndDate $currentCollection
        
        # Update state file
        $newState = @{
            LastCollectionTime = $currentCollection.ToString('o')
            RecordsCollected = $data.Count
            Status = "Success"
        } | ConvertTo-Json
        
        $newState | Out-File -FilePath $StateFilePath -Encoding UTF8
        Write-Log "State updated. Collected $($data.Count) new records" -Level Success
        
        return $data
    }
    catch {
        Write-Error "Failed incremental collection: $($_.Exception.Message)"
        
        # Update state with error
        @{
            LastCollectionTime = $lastCollection.ToString('o')
            Status = "Failed"
            Error = $_.Exception.Message
        } | ConvertTo-Json | Out-File -FilePath $StateFilePath -Encoding UTF8
        
        throw
    }
}

# Example usage:
<#
$stateFile = "C:\AuditState\SignInAudit.json"
$signInData = Get-IncrementalAuditData -StateFilePath $stateFile -CollectionScriptBlock {
    param($StartDate, $EndDate)
    Get-SignInAuditData -StartDate $StartDate -EndDate $EndDate
}

# Archive to dated file
$archiveFile = "C:\AuditArchive\SignIns_$(Get-Date -Format 'yyyyMMdd').csv"
$signInData | Export-Csv $archiveFile -NoTypeInformation
#>
```

# Handle pagination for large datasets
function Get-AuditDataPaginated {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$GetDataFunction,
        
        [int]$PageSize = 100
    )
    
    $allResults = @()
    $skip = 0
    
    do {
        try {
            $results = & $GetDataFunction -Skip $skip -Top $PageSize
            if ($results) {
                $allResults += $results
                $skip += $PageSize
                Write-Progress -Activity "Collecting audit data" -Status "Collected $($allResults.Count) records"
            }
        }
        catch {
            Write-Warning "Error collecting data at offset $skip : $($_.Exception.Message)"
            break
        }
    } while ($results -and $results.Count -eq $PageSize)
    
    return $allResults
}
```

### Safe Modification Operations
```powershell
function Set-UserProperty {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserId,
        
        [Parameter(Mandatory=$true)]
        [string]$PropertyName,
        
        [Parameter(Mandatory=$true)]
        [object]$Value
    )
    
    if ($PSCmdlet.ShouldProcess($UserId, "Set $PropertyName to $Value")) {
        try {
            Update-MgUser -UserId $UserId -BodyParameter @{ $PropertyName = $Value }
            Write-Log "Successfully updated $PropertyName for user $UserId" -Level Success
        }
        catch {
            Write-Error "Failed to update user: $($_.Exception.Message)"
            throw
        }
    }
}
```

## Testing Requirements

### Before Submission
1. **Syntax Check**: Run `Get-Command` to verify cmdlets exist
2. **Parameter Validation**: Test with `-WhatIf` parameter
3. **Error Scenarios**: Test with invalid inputs
4. **Documentation**: Ensure comment-based help is complete

### Testing Environment
- Use test tenants or isolated test accounts
- Never test on production without explicit approval
- Document required test data and setup

## Documentation Requirements

### Inline Comments
- Explain complex logic
- Document assumptions
- Note any limitations or known issues
- Reference Microsoft documentation where applicable

### Function Documentation
- All functions must have comment-based help
- Include examples for common use cases
- Document all parameters and return values
- Note any side effects or dependencies

## UI/Dashboard Development Considerations

### Dashboard Requirements
- **User-Friendly**: Intuitive interface for non-technical users
- **Professional Design**: Material UI design system
- **Responsive**: Works on desktop and tablet
- **Real-time Feedback**: Show script execution progress
- **Error Handling**: Clear error messages and guidance
- **Accessibility**: Follow WCAG guidelines where possible

### Python Web Application Patterns

```python
# Flask application structure
from flask import Flask, render_template, request, jsonify
import subprocess
import json
import os

app = Flask(__name__)

# PowerShell script executor
def execute_powershell_script(script_path, parameters=None):
    """
    Safely execute PowerShell script and capture output
    """
    try:
        # Validate script path
        if not os.path.exists(script_path):
            return {
                'success': False,
                'error': f'Script not found: {script_path}'
            }
        
        # Build PowerShell command
        cmd = ['pwsh', '-File', script_path]
        
        # Add parameters if provided
        if parameters:
            for key, value in parameters.items():
                cmd.extend([f'-{key}', str(value)])
        
        # Execute script
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=3600  # 1 hour timeout
        )
        
        return {
            'success': result.returncode == 0,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'returncode': result.returncode
        }
    
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'error': 'Script execution timeout (exceeded 1 hour)'
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

# API endpoint for script execution
@app.route('/api/execute-script', methods=['POST'])
def execute_script():
    data = request.json
    script_path = data.get('script_path')
    parameters = data.get('parameters', {})
    
    # Validate input
    if not script_path:
        return jsonify({'error': 'Script path required'}), 400
    
    # Execute script
    result = execute_powershell_script(script_path, parameters)
    
    return jsonify(result)

# Home route
@app.route('/')
def index():
    return render_template('index.html')
```

### Material UI Component Pattern (React)

```javascript
// ScriptRunner.jsx
import React, { useState } from 'react';
import {
  Button,
  Card,
  CardContent,
  CircularProgress,
  Alert,
  TextField
} from '@mui/material';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';

const ScriptRunner = ({ script }) => {
  const [running, setRunning] = useState(false);
  const [output, setOutput] = useState('');
  const [error, setError] = useState(null);

  const executeScript = async () => {
    setRunning(true);
    setError(null);
    
    try {
      const response = await fetch('/api/execute-script', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          script_path: script.path,
          parameters: {}
        })
      });
      
      const result = await response.json();
      
      if (result.success) {
        setOutput(result.stdout);
      } else {
        setError(result.error || result.stderr);
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setRunning(false);
    }
  };

  return (
    <Card>
      <CardContent>
        <h3>{script.name}</h3>
        <p>{script.description}</p>
        
        <Button
          variant="contained"
          color="primary"
          onClick={executeScript}
          disabled={running}
          startIcon={running ? <CircularProgress size={20} /> : <PlayArrowIcon />}
        >
          {running ? 'Running...' : 'Execute Script'}
        </Button>
        
        {error && <Alert severity="error">{error}</Alert>}
        {output && <pre>{output}</pre>}
      </CardContent>
    </Card>
  );
};
```

### Security Patterns for UI

```python
# Input validation
def validate_script_path(script_path):
    """
    Validate script path to prevent directory traversal
    """
    # Normalize path
    normalized = os.path.normpath(script_path)
    
    # Ensure it's within Scripts directory
    scripts_dir = os.path.abspath('./Scripts')
    script_abs = os.path.abspath(normalized)
    
    if not script_abs.startswith(scripts_dir):
        raise ValueError("Invalid script path")
    
    # Ensure it's a .ps1 file
    if not script_abs.endswith('.ps1'):
        raise ValueError("Only PowerShell scripts allowed")
    
    return script_abs

# Parameter sanitization
def sanitize_parameter(value):
    """
    Sanitize parameter values to prevent injection
    """
    # Remove potentially dangerous characters
    dangerous_chars = [';', '|', '&', '$', '`', '<', '>', '(', ')']
    
    sanitized = str(value)
    for char in dangerous_chars:
        sanitized = sanitized.replace(char, '')
    
    return sanitized
```

### Dashboard Layout Pattern

```python
# Script categorization
SCRIPT_CATEGORIES = {
    'User Administration': {
        'icon': 'people',
        'color': 'primary',
        'scripts': [
            {
                'name': 'Get Inactive Users',
                'path': 'Scripts/User_Administration/Get-InactiveUsers.ps1',
                'description': 'Find inactive user accounts',
                'parameters': [
                    {'name': 'DaysInactive', 'type': 'number', 'default': 90}
                ]
            }
        ]
    },
    'Security Administration': {
        'icon': 'security',
        'color': 'error',
        'scripts': [
            {
                'name': 'Security Review',
                'path': 'Scripts/Security_Administration/Get-M365SecurityReview.ps1',
                'description': 'Comprehensive security assessment',
                'parameters': [
                    {'name': 'Format', 'type': 'select', 'options': ['HTML', 'CSV', 'JSON', 'All'], 'default': 'All'}
                ]
            }
        ]
    }
}
```

## Intune/MDM Considerations

### Device Management Best Practices
- **Device Impact**: Device operations affect user productivity - always validate before action
- **Platform Differences**: Each platform (Windows, iOS, Android, macOS) has unique requirements
- **Bulk Operations**: Use batching and progress indicators for large-scale device operations
- **Graceful Degradation**: Handle offline devices and connection failures
- **User Communication**: Provide clear messaging for device actions that affect users
- **Rollback Planning**: Document rollback procedures for configuration changes

### Intune-Specific Patterns

```powershell
# Device compliance check
function Get-DeviceComplianceStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DeviceId
    )
    
    try {
        $device = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $DeviceId
        $complianceState = Get-MgDeviceManagementManagedDeviceComplianceState -ManagedDeviceId $DeviceId
        
        return [PSCustomObject]@{
            DeviceName = $device.DeviceName
            Platform = $device.OperatingSystem
            ComplianceState = $complianceState.State
            LastSyncDateTime = $device.LastSyncDateTime
            IsOnline = ((Get-Date) - $device.LastSyncDateTime).TotalHours -lt 24
        }
    }
    catch {
        Write-Error "Failed to get compliance status: $($_.Exception.Message)"
        return $null
    }
}

# Safe device wipe with validation
function Invoke-SafeDeviceWipe {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DeviceId,
        
        [ValidateSet('Selective', 'Full')]
        [string]$WipeType = 'Selective',
        
        [string]$Reason
    )
    
    try {
        # Get device details
        $device = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $DeviceId
        
        if (-not $device) {
            throw "Device not found: $DeviceId"
        }
        
        # Validate device is enrolled
        if ($device.ManagementState -ne 'Managed') {
            throw "Device is not managed: $($device.DeviceName)"
        }
        
        # Confirm action
        $confirmMessage = "Wipe device: $($device.DeviceName) ($($device.OperatingSystem))"
        if ($WipeType -eq 'Full') {
            $confirmMessage += " - FULL WIPE (all data will be lost)"
        }
        
        if ($PSCmdlet.ShouldProcess($device.DeviceName, $confirmMessage)) {
            # Log action
            Write-Log "Initiating $WipeType wipe for device: $($device.DeviceName)" -Level Warning
            Write-Log "Reason: $Reason" -Level Info
            
            # Perform wipe
            if ($WipeType -eq 'Selective') {
                Invoke-MgDeviceManagementManagedDeviceWipe -ManagedDeviceId $DeviceId -KeepEnrollmentData
            }
            else {
                Invoke-MgDeviceManagementManagedDeviceWipe -ManagedDeviceId $DeviceId
            }
            
            Write-Log "Wipe initiated successfully for: $($device.DeviceName)" -Level Success
            return $true
        }
    }
    catch {
        Write-Error "Failed to wipe device: $($_.Exception.Message)"
        return $false
    }
}

# Bulk device operation with error handling
function Invoke-BulkDeviceSync {
    param(
        [Parameter(Mandatory=$true)]
        [array]$DeviceIds,
        
        [int]$ThrottleLimit = 10
    )
    
    $results = @{
        Success = @()
        Failed = @()
    }
    
    $total = $DeviceIds.Count
    $current = 0
    
    foreach ($deviceId in $DeviceIds) {
        $current++
        Write-Progress -Activity "Syncing devices" -Status "Processing $current of $total" -PercentComplete (($current / $total) * 100)
        
        try {
            Invoke-MgDeviceManagementManagedDeviceSyncDevice -ManagedDeviceId $deviceId
            $results.Success += $deviceId
            Write-Log "Sync initiated for device: $deviceId" -Level Success
        }
        catch {
            $results.Failed += @{
                DeviceId = $deviceId
                Error = $_.Exception.Message
            }
            Write-Log "Failed to sync device $deviceId : $($_.Exception.Message)" -Level Error
        }
        
        # Throttle to avoid API limits
        if ($current % $ThrottleLimit -eq 0) {
            Start-Sleep -Seconds 1
        }
    }
    
    Write-Progress -Activity "Syncing devices" -Completed
    
    return $results
}

# Configuration profile deployment
function Deploy-ConfigurationProfile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProfileId,
        
        [Parameter(Mandatory=$true)]
        [string]$GroupId,
        
        [ValidateSet('Include', 'Exclude')]
        [string]$AssignmentType = 'Include'
    )
    
    try {
        # Get profile details
        $profile = Get-MgDeviceManagementDeviceConfiguration -DeviceConfigurationId $ProfileId
        
        if (-not $profile) {
            throw "Profile not found: $ProfileId"
        }
        
        # Get group details
        $group = Get-MgGroup -GroupId $GroupId
        
        if (-not $group) {
            throw "Group not found: $GroupId"
        }
        
        if ($PSCmdlet.ShouldProcess($group.DisplayName, "Assign profile: $($profile.DisplayName)")) {
            # Create assignment
            $assignment = @{
                target = @{
                    '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                    groupId = $GroupId
                }
            }
            
            New-MgDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $ProfileId -BodyParameter $assignment
            
            Write-Log "Profile '$($profile.DisplayName)' assigned to group '$($group.DisplayName)'" -Level Success
            return $true
        }
    }
    catch {
        Write-Error "Failed to assign profile: $($_.Exception.Message)"
        return $false
    }
}
```

### Device Platform Specifics

**Windows 10/11:**
- Configuration: Use Settings Catalog or Administrative Templates
- Updates: Windows Update for Business policies
- Security: BitLocker, Windows Defender, Firewall
- Apps: Win32 apps, Microsoft Store apps, Office 365

**iOS/iPadOS:**
- Enrollment: Automated Device Enrollment (DEP)
- Management: Supervised vs. user-enrolled devices
- Apps: VPP (Volume Purchase Program) apps
- Security: Passcode policies, restrictions

**Android:**
- Enrollment: Android Enterprise (work profile, fully managed)
- Management: Managed Google Play
- Apps: Managed Google Play apps
- Security: Work profile security policies

**macOS:**
- Enrollment: Automated Device Enrollment
- Management: System extensions, kernel extensions
- Security: FileVault encryption, Gatekeeper
- Apps: PKG installers, Mac App Store

### Intune Permission Scopes

```powershell
# Required Graph API permissions for Intune operations

# Device Management
DeviceManagementConfiguration.ReadWrite.All
DeviceManagementManagedDevices.ReadWrite.All
DeviceManagementServiceConfig.ReadWrite.All

# App Management
DeviceManagementApps.ReadWrite.All

# Enrollment
DeviceManagementServiceConfig.ReadWrite.All

# Compliance
DeviceManagementConfiguration.ReadWrite.All

# Read-only operations
DeviceManagementConfiguration.Read.All
DeviceManagementManagedDevices.Read.All
DeviceManagementApps.Read.All
```

### Common Intune Scenarios

**Scenario 1: Non-Compliant Device Remediation**
- Identify non-compliant devices
- Determine compliance policy violations
- Notify users of required actions
- Provide remediation steps
- Track compliance status

**Scenario 2: App Deployment**
- Create app package
- Upload to Intune
- Configure app settings
- Assign to groups
- Monitor deployment status
- Handle installation failures

**Scenario 3: Device Enrollment Automation**
- Import device identifiers
- Create Autopilot profiles
- Assign to groups
- Monitor enrollment status
- Handle enrollment failures

**Scenario 4: Security Baseline Deployment**
- Select appropriate baseline
- Customize settings if needed
- Assign to device groups
- Monitor compliance
- Generate compliance reports

## Security Review Considerations

### Security Assessment Framework
- **Comprehensive Coverage**: Review all security domains (Identity, Data, Apps, Devices)
- **Risk-Based Approach**: Prioritize findings by risk level (Critical, High, Medium, Low)
- **Zero Trust Principles**: Verify explicitly, use least privilege, assume breach
- **Compliance Mapping**: Map findings to frameworks (CIS, NIST, ISO 27001)
- **Actionable Recommendations**: Provide clear remediation steps
- **Executive Summary**: Include high-level summary for leadership

### Security Review Patterns
```powershell
# Security finding structure
function New-SecurityFinding {
    param(
        [string]$Category,
        [string]$Title,
        [ValidateSet('Critical', 'High', 'Medium', 'Low', 'Info')]
        [string]$Severity,
        [string]$Description,
        [string]$Impact,
        [string]$Remediation,
        [hashtable]$ComplianceMapping
    )
    
    return [PSCustomObject]@{
        Category = $Category
        Title = $Title
        Severity = $Severity
        Description = $Description
        Impact = $Impact
        Remediation = $Remediation
        ComplianceMapping = $ComplianceMapping
        Timestamp = Get-Date
    }
}

# Risk scoring
function Get-RiskScore {
    param([array]$Findings)
    
    $score = @{
        Critical = ($Findings | Where-Object {$_.Severity -eq 'Critical'}).Count * 10
        High = ($Findings | Where-Object {$_.Severity -eq 'High'}).Count * 5
        Medium = ($Findings | Where-Object {$_.Severity -eq 'Medium'}).Count * 2
        Low = ($Findings | Where-Object {$_.Severity -eq 'Low'}).Count * 1
    }
    
    $totalScore = $score.Critical + $score.High + $score.Medium + $score.Low
    
    return [PSCustomObject]@{
        TotalRiskScore = $totalScore
        CriticalCount = $score.Critical / 10
        HighCount = $score.High / 5
        MediumCount = $score.Medium / 2
        LowCount = $score.Low
    }
}

# Generate security report
function Export-SecurityReport {
    param(
        [array]$Findings,
        [string]$OutputPath,
        [ValidateSet('HTML', 'JSON', 'CSV')]
        [string]$Format = 'HTML'
    )
    
    # Sort by severity
    $sortedFindings = $Findings | Sort-Object @{
        Expression = {
            switch ($_.Severity) {
                'Critical' { 0 }
                'High' { 1 }
                'Medium' { 2 }
                'Low' { 3 }
                'Info' { 4 }
            }
        }
    }
    
    switch ($Format) {
        'HTML' {
            # Generate HTML report with styling
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Microsoft 365 Security Review</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .critical { background-color: #ff0000; color: white; }
        .high { background-color: #ff6600; color: white; }
        .medium { background-color: #ffcc00; }
        .low { background-color: #99cc00; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    </style>
</head>
<body>
    <h1>Microsoft 365 Security Review</h1>
    <p>Generated: $(Get-Date)</p>
"@
            $html += $sortedFindings | ConvertTo-Html -Fragment
            $html += "</body></html>"
            $html | Out-File -FilePath $OutputPath -Encoding UTF8
        }
        'JSON' {
            $sortedFindings | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        }
        'CSV' {
            $sortedFindings | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        }
    }
}
```

### Security Check Categories

**Identity Security:**
- Conditional Access policy configuration
- MFA enablement and enforcement
- Legacy authentication blocking
- Password policy strength
- Privileged account protection
- Guest access controls

**Data Security:**
- DLP policy coverage
- Sensitivity labels usage
- Encryption configuration
- Data classification
- External sharing settings

**Application Security:**
- App permissions review
- OAuth consent grants
- Service principal security
- API permission scope

**Compliance:**
- Audit logging enabled
- Retention policy configuration
- Legal hold status
- Compliance score

## Audit-Specific Considerations

### Data Collection
- **Privacy**: Respect user privacy when collecting audit data
- **Compliance**: Ensure audit data collection complies with regulations (GDPR, etc.)
- **Data Retention**: Document how long audit data is retained
- **PII Handling**: Be careful with Personally Identifiable Information (PII)
- **Large Datasets**: Use pagination and batching for large data collections
- **API Throttling**: Implement retry logic and respect throttling limits
- **Performance**: Optimize queries to reduce API calls and improve performance
- **Audit Trail**: Log who ran the audit script, when, and with what parameters
- **Data Archival**: Implement long-term storage strategies for historical audit data

### Privacy and PII Protection Pattern
```powershell
# Protect sensitive data in audit reports
function Protect-AuditDataPrivacy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Data,
        
        [string[]]$PropertiesToRedact = @('Password', 'Secret', 'Key'),
        [string[]]$PropertiesToHash = @(),
        [switch]$AnonymizeEmails
    )
    
    foreach ($record in $Data) {
        # Redact sensitive properties
        foreach ($prop in $PropertiesToRedact) {
            if ($record.PSObject.Properties.Name -contains $prop) {
                $record.$prop = "[REDACTED]"
            }
        }
        
        # Hash properties for pseudonymization
        foreach ($prop in $PropertiesToHash) {
            if ($record.PSObject.Properties.Name -contains $prop -and $record.$prop) {
                $hasher = [System.Security.Cryptography.SHA256]::Create()
                $hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($record.$prop))
                $record.$prop = [Convert]::ToBase64String($hash).Substring(0, 16)
            }
        }
        
        # Anonymize email addresses
        if ($AnonymizeEmails) {
            if ($record.PSObject.Properties.Name -contains 'UserPrincipalName' -and $record.UserPrincipalName) {
                $email = $record.UserPrincipalName
                $domain = $email.Split('@')[1]
                $record.UserPrincipalName = "user_$(Get-Random -Minimum 1000 -Maximum 9999)@$domain"
            }
        }
    }
    
    return $Data
}

# Example: Anonymize data for sharing with external auditors
# $anonymizedData = Protect-AuditDataPrivacy -Data $auditData -AnonymizeEmails -PropertiesToHash @('UserId')
```

### Audit Script Logging (Meta-Auditing)
```powershell
# Audit scripts should themselves be auditable
function Start-AuditSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
        
        [string]$LogPath = "C:\AuditLogs\Sessions"
    )
    
    $sessionId = [guid]::NewGuid().ToString()
    
    if (-not (Test-Path $LogPath)) {
        New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
    }
    
    $session = @{
        SessionId = $sessionId
        ScriptName = $ScriptName
        StartTime = (Get-Date).ToString('o')
        ExecutedBy = $env:USERNAME
        ComputerName = $env:COMPUTERNAME
        Parameters = $PSBoundParameters
        Status = "Running"
    }
    
    $sessionFile = Join-Path $LogPath "$sessionId.json"
    $session | ConvertTo-Json | Out-File -FilePath $sessionFile -Encoding UTF8
    
    Write-Log "Audit session started: $sessionId" -Level Info
    
    return @{
        SessionId = $sessionId
        SessionFile = $sessionFile
        StartTime = $session.StartTime
    }
}

function Complete-AuditSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Session,
        
        [int]$RecordsCollected,
        [string]$OutputPath,
        [string]$Status = "Completed"
    )
    
    try {
        $sessionData = Get-Content $Session.SessionFile -Raw | ConvertFrom-Json
        $sessionData.Status = $Status
        $sessionData.EndTime = (Get-Date).ToString('o')
        $sessionData.Duration = ([datetime]$sessionData.EndTime - [datetime]$sessionData.StartTime).ToString()
        $sessionData.RecordsCollected = $RecordsCollected
        $sessionData.OutputPath = $OutputPath
        
        $sessionData | ConvertTo-Json | Out-File -FilePath $Session.SessionFile -Encoding UTF8
        
        Write-Log "Audit session completed: $($Session.SessionId)" -Level Success
    }
    catch {
        Write-Error "Failed to complete audit session: $($_.Exception.Message)"
    }
}

# Example usage:
<#
$session = Start-AuditSession -ScriptName "Get-SecurityAudit.ps1"
try {
    $data = Get-AuditData
    $outputPath = Export-AuditData -Data $data -OutputPath "audit.csv"
    Complete-AuditSession -Session $session -RecordsCollected $data.Count -OutputPath $outputPath
}
catch {
    Complete-AuditSession -Session $session -RecordsCollected 0 -Status "Failed"
}
#>
```

### Reporting
- **Export Formats**: Support multiple export formats (CSV, JSON, HTML)
- **Aggregation**: Provide summary statistics and aggregations
- **Visualization**: Consider including charts or visualizations in reports
- **Actionable Insights**: Include recommendations and insights in reports
- **Date Ranges**: Support flexible date range filtering
- **Filtering**: Allow filtering by various criteria (user, service, date, etc.)

### Audit Data Sources
- **Unified Audit Log**: Primary audit source for M365 (Search-UnifiedAuditLog)
- **Microsoft Graph API**: User activity, sign-in logs, usage reports
- **Exchange Online**: Mailbox statistics, mail flow, message tracking
- **SharePoint/OneDrive**: Storage usage, file activity, sharing statistics
- **Teams**: Usage statistics, meeting data, channel activity
- **Azure AD**: Directory changes, group membership, license assignments
- **Security & Compliance**: Audit logs, DLP events, eDiscovery data

### Unified Audit Log Pattern
```powershell
# Essential for compliance and security auditing
# Unified Audit Log is the primary audit source for M365
function Get-UnifiedAuditData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [datetime]$StartDate,
        
        [Parameter(Mandatory=$true)]
        [datetime]$EndDate,
        
        [string[]]$RecordTypes,
        [string[]]$Operations,
        [string]$UserIds
    )
    
    $allResults = @()
    $sessionId = [guid]::NewGuid().ToString()
    $recordCount = 0
    
    Write-Log "Starting Unified Audit Log search from $StartDate to $EndDate" -Level Info
    
    do {
        try {
            $searchParams = @{
                StartDate = $StartDate
                EndDate = $EndDate
                SessionId = $sessionId
                SessionCommand = 'ReturnLargeSet'
                ResultSize = 5000
            }
            
            if ($RecordTypes) { $searchParams['RecordType'] = $RecordTypes }
            if ($Operations) { $searchParams['Operations'] = $Operations }
            if ($UserIds) { $searchParams['UserIds'] = $UserIds }
            
            $results = Search-UnifiedAuditLog @searchParams
            
            if ($results) {
                $allResults += $results
                $recordCount = $results.Count
                Write-Progress -Activity "Collecting audit logs" `
                    -Status "Retrieved $($allResults.Count) records" `
                    -PercentComplete -1
            }
        }
        catch {
            Write-Warning "Error collecting audit data: $($_.Exception.Message)"
            break
        }
    } while ($recordCount -eq 5000)
    
    Write-Progress -Activity "Collecting audit logs" -Completed
    Write-Log "Collected $($allResults.Count) total audit records" -Level Success
    
    return $allResults
}

# Common Record Types for filtering:
# - ExchangeAdmin, ExchangeItem, SharePoint, SharePointFileOperation
# - AzureActiveDirectory, AzureActiveDirectoryAccountLogon
# - OneDrive, MicrosoftTeams, Yammer, ThreatIntelligence
# - DLP, ComplianceDLPSharePoint, ComplianceDLPExchange

# Note: Standard retention is 90 days; E5 tenants may have 1+ year
```

### Sign-In Audit Pattern
```powershell
# Using Microsoft Graph for comprehensive sign-in analysis
# Essential for security auditing and identity protection
function Get-SignInAuditData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [datetime]$StartDate,
        
        [datetime]$EndDate = (Get-Date),
        
        [ValidateSet('Interactive', 'NonInteractive', 'All')]
        [string]$SignInType = 'All',
        
        [string]$UserPrincipalName
    )
    
    $filterParts = @()
    $filterParts += "createdDateTime ge $($StartDate.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
    
    if ($EndDate) {
        $filterParts += "createdDateTime le $($EndDate.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
    }
    
    if ($UserPrincipalName) {
        $filterParts += "userPrincipalName eq '$UserPrincipalName'"
    }
    
    $filter = $filterParts -join ' and '
    
    try {
        Write-Log "Collecting sign-in logs with filter: $filter" -Level Info
        
        if ($SignInType -eq 'Interactive' -or $SignInType -eq 'All') {
            $signIns = Get-MgAuditLogSignIn -Filter $filter -All
            
            # Extract key security indicators
            $processed = $signIns | Select-Object `
                UserPrincipalName,
                UserId,
                CreatedDateTime,
                AppDisplayName,
                AppId,
                IpAddress,
                @{N='City';E={$_.Location.City}},
                @{N='State';E={$_.Location.State}},
                @{N='Country';E={$_.Location.CountryOrRegion}},
                @{N='RiskLevel';E={$_.RiskLevelDuringSignIn}},
                @{N='RiskState';E={$_.RiskState}},
                @{N='RiskDetail';E={$_.RiskDetail}},
                @{N='ConditionalAccessStatus';E={$_.ConditionalAccessStatus}},
                @{N='MFARequired';E={$_.MfaDetail.AuthMethod}},
                @{N='DeviceOS';E={$_.DeviceDetail.OperatingSystem}},
                @{N='DeviceBrowser';E={$_.DeviceDetail.Browser}},
                @{N='IsCompliant';E={$_.DeviceDetail.IsCompliant}},
                @{N='IsManaged';E={$_.DeviceDetail.IsManaged}},
                @{N='Status';E={$_.Status.ErrorCode}},
                @{N='FailureReason';E={$_.Status.FailureReason}}
            
            Write-Log "Collected $($processed.Count) sign-in records" -Level Success
            return $processed
        }
    }
    catch {
        Write-Error "Failed to collect sign-in data: $($_.Exception.Message)"
        throw
    }
}
```

### Message Trace Audit Pattern
```powershell
# Essential for mail flow auditing and security investigations
function Get-MessageTraceAuditData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [datetime]$StartDate,
        
        [Parameter(Mandatory=$true)]
        [datetime]$EndDate,
        
        [string]$SenderAddress,
        [string]$RecipientAddress
    )
    
    $allMessages = @()
    
    try {
        # Note: Get-MessageTrace only goes back 10 days
        $daysDiff = ($EndDate - $StartDate).Days
        
        if ($daysDiff -le 10) {
            Write-Log "Using Get-MessageTrace for recent data" -Level Info
            
            $searchParams = @{
                StartDate = $StartDate
                EndDate = $EndDate
                PageSize = 5000
            }
            
            if ($SenderAddress) { $searchParams['SenderAddress'] = $SenderAddress }
            if ($RecipientAddress) { $searchParams['RecipientAddress'] = $RecipientAddress }
            
            $page = 1
            do {
                $searchParams['Page'] = $page
                $messages = Get-MessageTrace @searchParams
                
                if ($messages) {
                    $allMessages += $messages
                    $page++
                    Write-Progress -Activity "Collecting message trace data" `
                        -Status "Retrieved $($allMessages.Count) messages (Page $page)"
                }
            } while ($messages.Count -eq 5000)
        }
        else {
            Write-Log "Historical search required (>10 days). Use Start-HistoricalSearch" -Level Warning
            # For historical data beyond 10 days, use historical search
            # This requires creating a search job and retrieving results later
        }
        
        Write-Progress -Activity "Collecting message trace data" -Completed
        Write-Log "Collected $($allMessages.Count) message trace records" -Level Success
        
        return $allMessages
    }
    catch {
        Write-Error "Failed to collect message trace data: $($_.Exception.Message)"
        throw
    }
}
```

## Common Pitfalls to Avoid

### General Pitfalls
1. **Hardcoded Values**: Never hardcode tenant IDs, user IDs, or other environment-specific values
2. **Missing Error Handling**: Always handle errors gracefully
3. **Orphaned Connections**: Always disconnect from services
4. **Infinite Loops**: Ensure proper loop termination conditions
5. **Memory Issues**: Process large datasets in batches
6. **Permission Assumptions**: Always check and document required permissions
7. **No Validation**: Validate inputs before processing
8. **Silent Failures**: Log errors and failures appropriately

### Audit-Specific Pitfalls
9. **API Throttling**: Not implementing retry logic for throttled requests
10. **Large Dataset Memory**: Loading entire datasets into memory instead of streaming
11. **No Data Aggregation**: Exporting raw data without summaries or insights
12. **Privacy Violations**: Collecting or exposing sensitive PII without proper safeguards
13. **Missing Pagination**: Not handling large result sets with pagination
14. **Ignoring Date Ranges**: Collecting all historical data instead of relevant time periods
15. **No Deduplication**: Not checking for duplicate records in incremental collections
16. **Static Queries**: Hard-coding filters instead of using parameters
17. **Missing Context**: Not including metadata (collection time, script version, parameters)
18. **Poor Performance**: Making individual API calls instead of batching
19. **No Progress Indicators**: Long-running scripts without user feedback
20. **Incomplete Exports**: Not handling special characters or nested objects in CSV exports

## Authentication for Testing

### Before Testing Any Script

**IMPORTANT**: Always authenticate before testing scripts to avoid authentication errors.

#### Quick Authentication
```powershell
# Run initialization script (handles all authentication)
./Initialize-M365Session.ps1

# Or for all services
./Initialize-M365Session.ps1 -Services All
```

#### What This Does
- Connects to Microsoft Graph with comprehensive permissions
- Verifies connection is working
- Provides feedback on connection status
- Handles existing sessions gracefully

#### After Testing
```powershell
# Always disconnect when done
./Disconnect-M365Services.ps1
```

### Including Authentication Checks in Scripts

**Always include connection verification:**

```powershell
<#
.SYNOPSIS
    Your script

.NOTES
    Prerequisites: Run ./Initialize-M365Session.ps1 before executing
    Required Scopes: User.ReadWrite.All, Group.ReadWrite.All
    Required Role: User Administrator
#>

[CmdletBinding()]
param()

# Check connection
try {
    $context = Get-MgContext -ErrorAction Stop
    if (-not $context -or -not $context.Account) {
        throw "Not connected"
    }
}
catch {
    Write-Error "Not connected to Microsoft Graph. Run: ./Initialize-M365Session.ps1"
    exit 1
}

# Your script logic here
```

### Required Permissions by Role

**User Administrator:**
```powershell
# Initialize with default scopes (includes User.ReadWrite.All)
./Initialize-M365Session.ps1
```

**Exchange Administrator:**
```powershell
# Initialize Exchange
./Initialize-M365Session.ps1 -Services Exchange
```

**Security Administrator:**
```powershell
# Includes security-specific scopes
./Initialize-M365Session.ps1
```

**Audit Administrator:**
```powershell
# Includes audit and reporting scopes
./Initialize-M365Session.ps1
```

### Troubleshooting Authentication

**Issue: "Authentication needed" error**
```powershell
# Solution: Run initialization
./Initialize-M365Session.ps1
```

**Issue: "Insufficient privileges" error**
```powershell
# Solution: Verify your account has admin role
# Check in Azure Portal: Azure AD > Roles and administrators
```

**Issue: Session expired during testing**
```powershell
# Solution: Reconnect (sessions expire after 1 hour)
./Initialize-M365Session.ps1
```

See `Documentation/AUTHENTICATION_GUIDE.md` for complete authentication guide.

## File Organization - CRITICAL

### Where to Place Scripts

**IMPORTANT**: All scripts MUST be placed in the correct role-specific directory:

| Your Role | Script Location |
|-----------|----------------|
| User Administrator | `Scripts/User_Administration/` |
| Exchange Administrator | `Scripts/Exchange_Administration/` |
| SharePoint Administrator | `Scripts/SharePoint_Administration/` |
| Teams Administrator | `Scripts/Teams_Administration/` |
| Security Administrator | `Scripts/Security_Administration/` |
| License Administrator | `Scripts/License_Administration/` |
| Compliance Administrator | `Scripts/Compliance_Administration/` |
| Audit Administrator | `Scripts/Audit_Administration/` |
| Intune/MDM Administrator | `Scripts/Intune_Administration/` |
| Global Administrator | `Scripts/Global_Administration/` |

**Example:**
```
✅ CORRECT: Scripts/User_Administration/Get-InactiveUsers.ps1
❌ WRONG:   Get-InactiveUsers.ps1 (in root)
❌ WRONG:   Scripts/Get-InactiveUsers.ps1 (not in role folder)
```

### Script Naming Convention

**Format:** `[Action]-[Object]-[OptionalDescription].ps1`

**Examples:**
- ✅ `Get-InactiveUsers.ps1`
- ✅ `Set-BulkUserLicenses.ps1`
- ✅ `Export-ComplianceReport.ps1`
- ✅ `Get-M365SecurityReview.ps1`
- ❌ `users_script.ps1` (wrong format)
- ❌ `Script1.ps1` (not descriptive)

### Test Results and Output Files

**Place test results in:** `Tests/Test_Results/`

**Example:**
```
✅ CORRECT: Tests/Test_Results/Audit_Report_20251202.txt
❌ WRONG:   Audit_Report_20251202.txt (in root)
```

### Documentation Files

**If creating documentation, place in:** `Documentation/`

**Example:**
```
✅ CORRECT: Documentation/User-Management-Guide.md
❌ WRONG:   User-Management-Guide.md (in root)
```

## Submission Process

1. **Create Branch**: 
   - Create feature branch: `agent/[role]/[script-name]`
   - Example: `agent/user-admin/inactive-users`

2. **Create Script**: 
   - Follow all standards and patterns
   - **Place in correct directory**: `Scripts/[YourRole]/`
   - Use proper naming convention

3. **Self-Review**: 
   - Check against this context document
   - Verify file is in correct location
   - Validate naming convention

4. **Test with Authentication**: 
   - Run `./Initialize-M365Session.ps1`
   - Test script thoroughly
   - Run `./Disconnect-M365Services.ps1`
   - Move test results to `Tests/Test_Results/`

5. **Commit and Push**:
   ```bash
   git add Scripts/[YourRole]/[ScriptName].ps1
   git commit -m "feat: Add [script description]"
   git push origin agent/[role]/[script-name]
   ```

6. **Submit for Review**: 
   - Notify user that script is ready
   - Provide branch name
   - Script will be reviewed by Master Agent

7. **Address Feedback**: 
   - Make necessary revisions in same branch
   - Commit changes
   - Notify when ready for re-review

8. **Final Approval**: 
   - Master Agent merges to main
   - Script is ready for production testing

## Resources

### Official Documentation
- Microsoft Graph PowerShell SDK: https://learn.microsoft.com/en-us/powershell/microsoftgraph/
- Exchange Online PowerShell: https://learn.microsoft.com/en-us/powershell/exchange/
- Teams PowerShell: https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-overview

### Best Practices
- PowerShell Scripting Best Practices: https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines
- Secure Application Model: https://learn.microsoft.com/en-us/powershell/partner-center/multi-factor-auth

## Agent Responsibilities

Each specialized agent must:
1. Follow all standards in this document
2. Create production-ready scripts (no placeholders)
3. Include comprehensive error handling
4. Document all functions and parameters
5. Test scripts in safe environments
6. Submit for Master Agent review
7. Address feedback promptly

