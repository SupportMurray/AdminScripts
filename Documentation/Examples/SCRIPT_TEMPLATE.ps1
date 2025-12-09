<#
.SYNOPSIS
    Template script for Microsoft 365 automation

.DESCRIPTION
    This is a template script demonstrating the structure and patterns
    required for all Microsoft 365 automation scripts. Use this as a
    starting point for new scripts.

.PARAMETER InputFile
    Path to input file (CSV, JSON, etc.)

.PARAMETER WhatIf
    Shows what would happen if the script runs without making changes

.EXAMPLE
    .\Script-Template.ps1 -InputFile "users.csv"
    Runs the script with the specified input file

.EXAMPLE
    .\Script-Template.ps1 -InputFile "users.csv" -WhatIf
    Shows what would happen without making changes

.NOTES
    Author: [Agent Name]
    Date: [YYYY-MM-DD]
    Version: 1.0
    Requires:
        - Module: Microsoft.Graph
        - Permissions: User.ReadWrite.All
        - Role: User Administrator
    Changelog:
        - 1.0: Initial version

.LINK
    https://learn.microsoft.com/powershell/microsoftgraph/
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if (Test-Path $_) {
            $true
        } else {
            throw "Input file not found: $_"
        }
    })]
    [string]$InputFile
)

#region Initialization

# Set error action preference
$ErrorActionPreference = 'Stop'

# Logging function
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

#endregion

#region Main Script

try {
    Write-Log "Starting script execution" -Level Info
    
    # Connect to Microsoft Graph
    Write-Log "Connecting to Microsoft Graph" -Level Info
    $requiredScopes = @("User.ReadWrite.All")
    Connect-MgGraph -Scopes $requiredScopes -ErrorAction Stop
    Write-Log "Successfully connected to Microsoft Graph" -Level Success
    
    # Validate input file
    Write-Log "Validating input file: $InputFile" -Level Info
    $inputData = Import-Csv -Path $InputFile -ErrorAction Stop
    Write-Log "Successfully imported $($inputData.Count) records" -Level Success
    
    # Process each record
    $total = $inputData.Count
    $current = 0
    $successCount = 0
    $errorCount = 0
    
    foreach ($record in $inputData) {
        $current++
        Write-Progress -Activity "Processing records" -Status "Processing $current of $total" -PercentComplete (($current / $total) * 100)
        
        try {
            # Validate record
            if (-not $record.UserPrincipalName) {
                Write-Log "Skipping record $current: Missing UserPrincipalName" -Level Warning
                $errorCount++
                continue
            }
            
            # Check if user exists
            $user = Get-MgUser -UserId $record.UserPrincipalName -ErrorAction SilentlyContinue
            
            if (-not $user) {
                Write-Log "User not found: $($record.UserPrincipalName)" -Level Warning
                $errorCount++
                continue
            }
            
            # Perform operation with WhatIf support
            if ($PSCmdlet.ShouldProcess($record.UserPrincipalName, "Perform operation")) {
                # Example operation - replace with actual logic
                # Update-MgUser -UserId $record.UserPrincipalName -BodyParameter @{ ... }
                
                Write-Log "Successfully processed: $($record.UserPrincipalName)" -Level Success
                $successCount++
            }
        }
        catch {
            Write-Log "Error processing record $current ($($record.UserPrincipalName)): $($_.Exception.Message)" -Level Error
            $errorCount++
            # Continue processing other records
        }
    }
    
    Write-Progress -Activity "Processing records" -Completed
    
    # Summary
    Write-Log "Script execution completed" -Level Info
    Write-Log "Total records: $total" -Level Info
    Write-Log "Successful: $successCount" -Level Success
    Write-Log "Errors: $errorCount" -Level Warning
    
    if ($errorCount -gt 0) {
        Write-Log "Some records failed to process. Review errors above." -Level Warning
    }
}
catch {
    Write-Log "Critical error: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}
finally {
    # Cleanup connections
    Write-Log "Disconnecting from Microsoft Graph" -Level Info
    Disconnect-MgGraph -ErrorAction SilentlyContinue
    Write-Log "Script execution finished" -Level Info
}

#endregion

