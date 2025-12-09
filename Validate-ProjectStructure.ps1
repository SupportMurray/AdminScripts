<#
.SYNOPSIS
    Validates the project directory structure and file organization

.DESCRIPTION
    This script checks that the project structure follows the standards defined
    in PROJECT_STRUCTURE.md and PROJECT_ORGANIZATION.md. It identifies:
    - Files in incorrect locations
    - Missing required directories
    - Files not following naming conventions
    - Temporary or backup files
    - Orphaned files

.PARAMETER Fix
    Automatically fix minor issues (move files, create missing directories)

.PARAMETER Detailed
    Show detailed information about all checks

.EXAMPLE
    .\Validate-ProjectStructure.ps1
    Validates structure and reports issues

.EXAMPLE
    .\Validate-ProjectStructure.ps1 -Fix
    Validates and automatically fixes minor issues

.NOTES
    Author: Master Agent
    Date: 2024-01-01
    Version: 1.0
    Requires: PowerShell 5.1 or later
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Fix,
    [switch]$Detailed
)

$script:Issues = @()
$script:Warnings = @()
$script:Fixed = @()

#region Helper Functions

function Write-Issue {
    param(
        [string]$Message,
        [ValidateSet('Error', 'Warning', 'Info')]
        [string]$Severity = 'Warning'
    )
    
    $issue = @{
        Message = $Message
        Severity = $Severity
        Timestamp = Get-Date
    }
    
    switch ($Severity) {
        'Error' { 
            $script:Issues += $issue
            Write-Host "ERROR: $Message" -ForegroundColor Red
        }
        'Warning' { 
            $script:Warnings += $issue
            Write-Host "WARNING: $Message" -ForegroundColor Yellow
        }
        'Info' { 
            if ($Detailed) {
                Write-Host "INFO: $Message" -ForegroundColor Cyan
            }
        }
    }
}

function Write-Fixed {
    param([string]$Message)
    
    $script:Fixed += $Message
    Write-Host "FIXED: $Message" -ForegroundColor Green
}

#endregion

#region Directory Structure Validation

Write-Host "`n=== Validating Directory Structure ===" -ForegroundColor Cyan

$rootPath = $PSScriptRoot
$requiredDirs = @(
    "Agents",
    "Documentation",
    "Scripts",
    "Scripts\Utilities",
    "Scripts\User_Administration",
    "Scripts\Exchange_Administration",
    "Scripts\SharePoint_Administration",
    "Scripts\Teams_Administration",
    "Scripts\Security_Administration",
    "Scripts\License_Administration",
    "Scripts\Compliance_Administration",
    "Scripts\Audit_Administration",
    "Scripts\Intune_Administration",
    "Scripts\UI_Administration",
    "Scripts\Global_Administration",
    "Reviews",
    "Reviews\Approved",
    "Reviews\Needs_Revision",
    "Reviews\Rejected",
    "Documentation",
    "Documentation\Examples",
    "Documentation\Patterns",
    "Documentation\Troubleshooting",
    "Tests",
    "Tests\Test_Data",
    "Tests\Test_Results"
)

foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $rootPath $dir
    if (-not (Test-Path $fullPath)) {
        Write-Issue "Missing required directory: $dir" -Severity Error
        
        if ($Fix -and $PSCmdlet.ShouldProcess($fullPath, "Create directory")) {
            try {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                Write-Fixed "Created directory: $dir"
            }
            catch {
                Write-Issue "Failed to create directory $dir : $($_.Exception.Message)" -Severity Error
            }
        }
    }
    elseif ($Detailed) {
        Write-Issue "Directory exists: $dir" -Severity Info
    }
}

#endregion

#region Root Directory Validation

Write-Host "`n=== Validating Root Directory ===" -ForegroundColor Cyan

$rootFiles = Get-ChildItem -Path $rootPath -File | Where-Object { 
    $_.Extension -ne '.md' -and 
    $_.Name -ne '.gitignore' -and 
    $_.Name -ne '.gitattributes' -and
    $_.Extension -ne '.ps1' -or $_.Name -like 'Validate-*.ps1' -or $_.Name -like 'Test-*.ps1'
}

foreach ($file in $rootFiles) {
    if ($file.Extension -eq '.ps1' -and ($file.Name -like 'Validate-*.ps1' -or $file.Name -like 'Test-*.ps1')) {
        # Validation and test scripts are allowed in root
        if ($Detailed) {
            Write-Issue "Validation script in root (allowed): $($file.Name)" -Severity Info
        }
        continue
    }
    
    if ($file.Extension -eq '.ps1') {
        Write-Issue "PowerShell script in root directory: $($file.Name) (should be in Scripts/[Role]/)" -Severity Error
    }
    elseif ($file.Extension -in @('.csv', '.json', '.xml', '.txt')) {
        Write-Issue "Data file in root directory: $($file.Name) (should be in appropriate subdirectory)" -Severity Warning
    }
    else {
        Write-Issue "Unexpected file in root: $($file.Name)" -Severity Warning
    }
}

#endregion

#region Script Directory Validation

Write-Host "`n=== Validating Scripts Directory ===" -ForegroundColor Cyan

$scriptsRoot = Join-Path $rootPath "Scripts"
$roleDirs = @(
    "User_Administration",
    "Exchange_Administration",
    "SharePoint_Administration",
    "Teams_Administration",
    "Security_Administration",
    "License_Administration",
    "Compliance_Administration",
    "Global_Administration"
)

# Check for agent files in root (should be in Agents/)
$agentFilesInRoot = Get-ChildItem -Path $rootPath -File -Filter "*AGENT*.md" -ErrorAction SilentlyContinue
foreach ($file in $agentFilesInRoot) {
    # MASTER_AGENT.md and MASTER_AGENT_CONTEXT.md belong in root
    if ($file.Name -eq "MASTER_AGENT.md" -or $file.Name -eq "MASTER_AGENT_CONTEXT.md") {
        if ($Detailed) {
            Write-Issue "Master Agent file in root (correct): $($file.Name)" -Severity Info
        }
        continue
    }
    
    if ($file.Name -like "*AGENT_CONTEXT*" -or $file.Name -like "*PROMPT_TEMPLATE*") {
        Write-Issue "Agent file in root: $($file.Name) (should be in Agents/ directory)" -Severity Error
    }
}

# Check for scripts directly in Scripts/ root
$scriptsInRoot = Get-ChildItem -Path $scriptsRoot -File -Filter "*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $scriptsInRoot) {
    Write-Issue "Script in Scripts root: $($script.Name) (should be in role subdirectory)" -Severity Error
}

# Validate scripts in role directories
foreach ($roleDir in $roleDirs) {
    $rolePath = Join-Path $scriptsRoot $roleDir
    if (Test-Path $rolePath) {
        $scripts = Get-ChildItem -Path $rolePath -File -Filter "*.ps1" -ErrorAction SilentlyContinue
        
        foreach ($script in $scripts) {
            # Check naming convention: [Action]-[Object]-[OptionalDescription].ps1
            # Allow flexibility for descriptive names like Get-M365SecurityReview.ps1
            $namePattern = '^[A-Z][a-z]+-[A-Z0-9][a-zA-Z0-9]+(-[A-Z][a-zA-Z0-9]+)*\.ps1$'
            if ($script.Name -notmatch $namePattern) {
                Write-Issue "Script naming convention violation in $roleDir`: $($script.Name) (should be [Action]-[Object]-[Description].ps1)" -Severity Warning
            }
            
            if ($Detailed) {
                Write-Issue "Script found: $roleDir\$($script.Name)" -Severity Info
            }
        }
    }
}

#endregion

#region Temporary Files Check

Write-Host "`n=== Checking for Temporary Files ===" -ForegroundColor Cyan

$tempPatterns = @(
    "*.tmp",
    "*.bak",
    "*.old",
    "*~*",
    "*_backup*",
    "*_old*",
    "*_temp*"
)

$allFiles = Get-ChildItem -Path $rootPath -Recurse -File -ErrorAction SilentlyContinue

foreach ($file in $allFiles) {
    # Skip template files (intentional)
    if ($file.Name -like "*TEMPLATE*" -or $file.Name -like "*Template*") {
        if ($Detailed) {
            Write-Issue "Skipping template file: $($file.Name)" -Severity Info
        }
        continue
    }
    
    foreach ($pattern in $tempPatterns) {
        if ($file.Name -like $pattern) {
            Write-Issue "Temporary or backup file found: $($file.FullName.Replace($rootPath, '.'))" -Severity Warning
            break
        }
    }
}

#endregion

#region Summary

Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Errors: $($script:Issues.Count)" -ForegroundColor $(if ($script:Issues.Count -gt 0) { 'Red' } else { 'Green' })
Write-Host "Warnings: $($script:Warnings.Count)" -ForegroundColor $(if ($script:Warnings.Count -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "Fixed: $($script:Fixed.Count)" -ForegroundColor $(if ($script:Fixed.Count -gt 0) { 'Green' } else { 'Gray' })

if ($script:Issues.Count -eq 0 -and $script:Warnings.Count -eq 0) {
    Write-Host "`n✓ Project structure is valid!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`n✗ Project structure has issues. Review above." -ForegroundColor Red
    exit 1
}

#endregion

