# Dashboard UI Mockup - Material Design

## Overview
Visual guide for the Material UI Dashboard that the UI Administrator will create.

---

## 🎨 Design Concept

### Color Scheme (Material Design)
```
Primary:   #1976d2 (Blue)
Secondary: #dc004e (Pink)
Success:   #2e7d32 (Green)
Warning:   #ed6c02 (Orange)
Error:     #d32f2f (Red)
Info:      #0288d1 (Light Blue)
```

---

## 📱 Dashboard Layout

### Main Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  M365 Admin Dashboard                        🔔 👤 ⚙️  🌓      │ ← AppBar
├─────────────────────────────────────────────────────────────────┤
│         │                                                        │
│  📊 Home│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  👥 Users│  │ Total Scripts│  │Recent Runs   │  │  Success Rate││
│  📧 Email│  │      24      │  │     156      │  │     94%      ││
│  🔒 Sec  │  └──────────────┘  └──────────────┘  └──────────────┘│
│  📋 Audit│                                                       │
│  📱 Intune│  Recent Executions                                  │
│  ⚙️ Global│  ┌────────────────────────────────────────────────┐│
│         │  │ Security Review    | Success | 2 min ago  [View]││
│         │  │ User License Audit | Success | 1 hr ago   [View]││
│         │  │ MFA Status Report  | Success | 3 hrs ago  [View]││
│  Sidebar│  └────────────────────────────────────────────────┘│
│         │                                                       │
│         │  Quick Actions                                       │
│         │  [▶ Run Security Review]  [📊 View Reports]         │
└─────────┴───────────────────────────────────────────────────────┘
```

### Script Browser View

```
┌─────────────────────────────────────────────────────────────────┐
│  M365 Admin Dashboard > Scripts > Security Administration       │
├─────────────────────────────────────────────────────────────────┤
│         │                                                        │
│  Categories │  🔍 Search scripts...                   [Grid][List]│
│         │                                                        │
│  👥 Users│  ┌─────────────────────┐  ┌─────────────────────┐  │
│  📧 Exchange│  │ 🔒 Security Review │  │ 👤 MFA Status     │  │
│  📁 SharePoint│  │                   │  │                    │  │
│  💬 Teams│  │ Comprehensive      │  │ Check user MFA    │  │
│  🔒 Security│  │ security assessment│  │ registration      │  │
│  📜 License│  │                   │  │                    │  │
│  ✓ Compliance│  │ 10 security domains│  │ Admin accounts   │  │
│  📊 Audit│  │                   │  │                    │  │
│  📱 Intune│  │ [▶ Run Script]   │  │ [▶ Run Script]    │  │
│  ⚙️ Global│  └─────────────────────┘  └─────────────────────┘  │
└─────────┴───────────────────────────────────────────────────────┘
```

### Script Execution View

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back to Scripts        Get-M365SecurityReview.ps1            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  📋 Script Details                                              │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ Name: Get-M365SecurityReview.ps1                           ││
│  │ Description: Comprehensive security assessment             ││
│  │ Author: Security Administrator                             ││
│  │ Version: 1.0                                               ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ⚙️ Parameters                                                  │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ Output Format:  [HTML ▼]                                   ││
│  │ Output Path:    [Tests/Test_Results/] 📁                  ││
│  │ Skip Domains:   [Select domains...        ▼]              ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                  │
│  [▶ Execute Script]  [⚙️ Advanced Options]                     │
│                                                                  │
│  📊 Output                                                      │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ [2025-12-02 14:30:15] [Info] Starting security review...  ││
│  │ [2025-12-02 14:30:16] [Info] Connected to Microsoft Graph ││
│  │ [2025-12-02 14:30:20] [Info] Checking Conditional Access  ││
│  │ ▓▓▓▓▓▓▓▓░░░░░░░░  50% - Processing security domains...    ││
│  │                                                             ││
│  │ [Auto-scrolls as output arrives]                           ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                  │
│  [⬇ Download Output]  [📊 View Report]  [🔄 Run Again]        │
└──────────────────────────────────────────────────────────────────┘
```

### Execution History View

```
┌─────────────────────────────────────────────────────────────────┐
│  Execution History                                               │
├─────────────────────────────────────────────────────────────────┤
│  Filter: [All ▼]  Search: [         🔍]        [📤 Export]     │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ Date/Time          │ Script           │Status │Duration│   ││
│  ├────────────────────────────────────────────────────────────┤│
│  │ 2025-12-02 14:30  │ Security Review  │ ✓    │ 8m 15s │[📄]││
│  │ 2025-12-02 14:15  │ MFA Status       │ ✓    │ 2m 30s │[📄]││
│  │ 2025-12-02 13:45  │ User Audit       │ ✗    │ 1m 05s │[📄]││
│  │ 2025-12-02 12:30  │ License Report   │ ✓    │ 3m 45s │[📄]││
│  │ [Load More...]                                              ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                  │
│  Status Legend: ✓ Success  ⏳ Running  ✗ Failed  ⊗ Cancelled   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Material-UI Components to Use

### Navigation
- **AppBar** - Top navigation bar
- **Drawer** - Left sidebar (persistent or temporary)
- **List** - Navigation menu items
- **ListItemButton** - Clickable menu items
- **Divider** - Section separators

### Content Display
- **Card** - Script cards, stat cards
- **CardContent** - Card content area
- **CardActions** - Card action buttons
- **Grid** - Responsive grid layout
- **Typography** - Text styling
- **Chip** - Status badges, tags

### Forms & Inputs
- **TextField** - Text input fields
- **Select** - Dropdown selections
- **Button** - Action buttons
- **IconButton** - Icon-only buttons
- **Switch** - Toggle switches
- **Checkbox** - Checkboxes

### Feedback & Progress
- **Alert** - Success/error messages
- **Snackbar** - Toast notifications
- **CircularProgress** - Loading spinners
- **LinearProgress** - Progress bars
- **Badge** - Notification badges

### Data Display
- **Table** - Data tables
- **TablePagination** - Table pagination
- **DataGrid** - Advanced data grid (optional)
- **Accordion** - Expandable sections

### Dialogs
- **Dialog** - Modal dialogs
- **DialogTitle** - Dialog header
- **DialogContent** - Dialog body
- **DialogActions** - Dialog buttons

---

## 🎯 Key Features to Implement

### 1. Script Categories (Sidebar)
- Collapsible sidebar
- Icons for each category
- Badge with script count
- Active state highlighting

### 2. Script Cards
- Script name and description
- Last run timestamp
- Success rate
- Quick run button
- View details button

### 3. Execution Panel
- Parameter form (dynamic based on script)
- Execute button with confirmation
- Real-time output stream
- Progress indicator
- Cancel button

### 4. Output Display
- Monospace font for code
- Color coding for log levels:
  * Info: Gray
  * Success: Green
  * Warning: Orange
  * Error: Red
- Auto-scroll to bottom
- Copy to clipboard button
- Download button

### 5. Report Viewer
- HTML report preview (iframe)
- Download buttons for CSV/JSON
- Full-screen view option
- Report metadata display

---

## 📱 Responsive Design

### Desktop (>1200px)
- Sidebar always visible
- Two-column layout for cards
- Full-width tables

### Tablet (768-1200px)
- Collapsible sidebar
- Single-column cards
- Responsive tables

### Mobile (Not required but nice to have)
- Hidden sidebar (hamburger menu)
- Stacked layout
- Bottom navigation

---

## 🌓 Dark Mode Support

Implement theme toggle with:
- Light theme (default)
- Dark theme option
- System preference detection
- Persistent theme selection

**Material-UI ThemeProvider:**
```javascript
const lightTheme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#1976d2' },
    background: { default: '#f5f5f5' }
  }
});

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: { main: '#90caf9' },
    background: { default: '#121212' }
  }
});
```

---

## 🔐 Security Features

### Input Validation
- Validate all parameters before execution
- Prevent command injection
- Whitelist allowed file paths
- Sanitize user inputs

### Execution Safety
- Only execute .ps1 files from Scripts/
- No arbitrary commands
- Timeout protection (1 hour max)
- Log all executions

### Optional Authentication
- Simple login page
- Session management
- CSRF protection
- Rate limiting

---

## 📊 Dashboard Statistics

### Home Dashboard Cards
1. **Total Scripts Available**
   - Count of all .ps1 files
   - Icon: 📜

2. **Recent Executions**
   - Last 24 hours count
   - Icon: 🔄

3. **Success Rate**
   - Percentage of successful runs
   - Icon: ✓

4. **Active Scripts**
   - Currently running scripts
   - Icon: ⏳

---

## ⚡ Performance Considerations

- **Lazy loading** for script list
- **Pagination** for execution history
- **Virtualization** for large lists
- **Debouncing** for search inputs
- **Caching** for script metadata
- **WebSocket** for real-time updates (optional)

---

## 🎓 Expected User Experience

### For Non-Technical Users:
1. Open dashboard in browser (http://localhost:5000)
2. Browse scripts by category (intuitive icons)
3. Click "Run Script" button
4. Fill in parameters (if any) with helpful tooltips
5. Click "Execute"
6. Watch real-time output
7. View/download generated reports
8. See execution history

### For Admins:
1. Same experience as non-technical users
2. Additional access to all scripts
3. Execution history with details
4. Advanced parameters (if available)
5. Settings configuration

---

**The UI Administrator Agent will create a beautiful, professional Material UI dashboard that makes running PowerShell scripts as easy as clicking a button!** 🎨✨

