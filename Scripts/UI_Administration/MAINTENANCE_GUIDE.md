# Dashboard Maintenance Guide

This guide explains how the dashboard discovers new scripts and what manual maintenance might be needed.

## Automatic Script Discovery

The dashboard **automatically discovers new PowerShell scripts** added by other agents!

### How It Works

1. **On Startup**: Dashboard scans `../../Scripts/` directory
2. **On Refresh**: Users can click "Refresh" to rescan
3. **Categorization**: Scripts are categorized by their directory
4. **Metadata Parsing**: PowerShell help is parsed for parameters

### What Gets Discovered Automatically

- ✅ Script name and filename
- ✅ Category (based on directory)
- ✅ File size and modification date
- ✅ Synopsis and description (from `.SYNOPSIS` and `.DESCRIPTION`)
- ✅ Parameters (from `param` block and `.PARAMETER` tags)
- ✅ Examples (from `.EXAMPLE` tags)
- ✅ Author and version (from `.NOTES`)

### When Scripts Are Added

When an agent adds a new script like `Get-NewFeature.ps1` to `Scripts/Security_Administration/`:

1. **Automatic Detection** ✅
   - Dashboard detects it on next page load or refresh
   - No code changes needed

2. **Automatic Categorization** ✅
   - Placed in "Security Administration" category
   - Icon assigned automatically

3. **Automatic Parameters** ✅
   - Parameters parsed from PowerShell
   - Form fields generated automatically

4. **Ready to Execute** ✅
   - Script appears in UI immediately
   - Users can run it right away

## No Manual Updates Needed!

For **standard scripts** (PowerShell files with proper comment-based help), you don't need to do anything!

## Manual Updates Only Needed For

### 1. New Script Categories

If a completely new category is added (beyond the 10 existing ones):

**File:** `utils/script_scanner.py`

```python
CATEGORIES = {
    # ... existing categories ...
    'NewCategory_Administration': {
        'key': 'NewCategory',
        'label': 'New Category Administration',
        'icon': 'new_icon_name',
        'description': 'New category description'
    }
}
```

**File:** `frontend/src/App.js`

```javascript
const categoryIcons = {
  // ... existing icons ...
  'NewCategory': <NewIcon />
};
```

### 2. Special Parameter Types

If a script uses custom parameter types not supported by Material-UI:

**File:** `frontend/src/App.js` (in parameter rendering logic)

Add custom form field for the new parameter type.

### 3. Custom Output Formats

If scripts generate reports in new formats (beyond HTML, CSV, JSON, TXT):

**File:** May need to add viewer for new format

## Testing New Script Integration

After an agent adds a new script:

1. **Refresh Dashboard**
   - Click "Refresh" button or reload page

2. **Check Script Appears**
   - Navigate to appropriate category
   - Find the script card
   - Verify name and description display

3. **Test Parameter Form**
   - Click "Run Script"
   - Check all parameters appear
   - Verify types (text, dropdown, etc.)

4. **Test Execution**
   - Fill in parameters
   - Click "Execute"
   - Verify output displays correctly
   - Check execution history logs it

## Dashboard Configuration

### Scan Interval

To change how often scripts are rescanned:

**File:** `config.json`

```json
{
  "scanning": {
    "auto_refresh_interval": 300  // seconds
  }
}
```

### Script Directory

To change where scripts are located:

**File:** `config.json`

```json
{
  "paths": {
    "scripts_directory": "../../Scripts"
  }
}
```

## Monitoring Script Additions

### Check Dashboard Logs

Flask backend logs show script discoveries:

```
INFO - ScriptScanner initialized: /path/to/Scripts
INFO - Found 24 scripts
```

### View in UI

Dashboard Statistics show:
- Total scripts count
- Scripts by category

## Common Scenarios

### Scenario 1: Security Agent Adds Get-ConditionalAccessAudit.ps1

**What Happens:**
1. File saved to `Scripts/Security_Administration/`
2. Dashboard auto-detects it
3. Appears in "Security Administration" category
4. Parameters parsed from PowerShell
5. Ready to execute

**Manual Work Needed:** None! ✅

### Scenario 2: Audit Agent Updates Existing Script Parameters

**What Happens:**
1. Script file updated
2. Dashboard re-parses on next load
3. New parameters appear in form
4. Old parameter values cleared

**Manual Work Needed:** None! ✅

### Scenario 3: New "Backup_Administration" Category Added

**What Happens:**
1. New directory created: `Scripts/Backup_Administration/`
2. Scripts added to it
3. Dashboard detects scripts
4. Category shows as "Backup Administration" (generic)

**Manual Work Needed:** 
- Add category to `CATEGORIES` dict in `script_scanner.py`
- Add icon to frontend (optional, uses default otherwise)

## Script Requirements

For automatic discovery to work, scripts should follow these standards:

### 1. Proper Location
```
Scripts/
└── [Category]_Administration/
    └── Get-ScriptName.ps1
```

### 2. Comment-Based Help
```powershell
<#
.SYNOPSIS
    Brief description

.DESCRIPTION
    Detailed description

.PARAMETER ParameterName
    Parameter description

.EXAMPLE
    .\Get-ScriptName.ps1 -ParameterName "value"

.NOTES
    Author: Agent Name
    Version: 1.0
#>
```

### 3. Parameter Block
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$RequiredParam,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Option1', 'Option2')]
    [string]$OptionalParam = 'Option1'
)
```

## Updating the Dashboard

### Backend Updates

```bash
cd Scripts/UI_Administration
source venv/bin/activate
pip install --upgrade -r requirements.txt
```

### Frontend Updates

```bash
cd frontend
npm install
npm run build
```

### Restart Services

```bash
# Stop Flask (Ctrl+C)
# Stop React (Ctrl+C)

# Restart
python app.py
cd frontend && npm start
```

## Database Management

### Clear Execution History

```bash
rm executions.db
# Database will be recreated on next run
```

### View Database

```bash
sqlite3 executions.db
> SELECT COUNT(*) FROM executions;
> .exit
```

## Troubleshooting

### New Script Not Appearing

1. Check file extension is `.ps1`
2. Check it's in `Scripts/[Category]/` directory
3. Check Flask logs for scanning errors
4. Click "Refresh" in UI
5. Restart Flask backend

### Parameters Not Showing

1. Check PowerShell comment-based help exists
2. Check `param()` block is properly formatted
3. Check Flask logs for parsing errors
4. Try running: `pwsh -Command "Get-Help ./path/to/script.ps1"`

### Script Execution Fails

1. Check M365 authentication: `../../Initialize-M365Session.ps1`
2. Check PowerShell path in `config.json`
3. Check script permissions
4. View execution error in History

## Best Practices

### For Agent Developers

1. ✅ Use proper PowerShell comment-based help
2. ✅ Follow parameter naming conventions
3. ✅ Include examples in help
4. ✅ Test scripts before committing
5. ✅ Use ValidateSet for dropdown options

### For Dashboard Maintenance

1. ✅ Monitor logs for errors
2. ✅ Keep dependencies updated
3. ✅ Test new script integrations
4. ✅ Clear old execution history periodically
5. ✅ Back up database before updates

## Future Enhancements

Potential features for future development:

- 🔄 Real-time output streaming (Server-Sent Events)
- 📅 Scheduled script execution
- 📧 Email notifications on completion
- 👥 Multi-user support with roles
- 🔐 Authentication and authorization
- 📊 Advanced analytics and reporting
- 🔔 Alert system for failed executions
- 💾 Export/import configurations
- 🎨 Custom themes and branding
- 🌐 API for external integrations

## Support

For questions or issues:

1. Review this maintenance guide
2. Check `README.md` for setup issues
3. Review `TROUBLESHOOTING.md`
4. Check Flask backend logs
5. Check browser console for frontend errors

---

**Remember:** The dashboard is designed to require minimal maintenance. Most script additions are handled automatically!

