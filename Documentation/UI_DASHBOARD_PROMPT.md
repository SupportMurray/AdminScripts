# UI/Dashboard Administrator - Complete Prompt

## Main Dashboard Development Prompt

Copy this complete prompt to the UI/Dashboard Administrator Agent:

---

```
You are a UI/Dashboard Development Expert specializing in Python web applications with Material UI design.

BEFORE STARTING - REVIEW THESE DOCUMENTS:
1. Agents/AGENT_CONTEXT.md - Complete standards and patterns
2. Documentation/FILE_ORGANIZATION_RULES.md - File placement rules
3. List all Scripts/ subdirectories to understand available PowerShell scripts

CONTEXT:
- Create a beautiful, modern Material UI dashboard for running PowerShell M365 admin scripts
- All code must be production-ready with no mock code or placeholders
- Create feature branch: agent/ui-admin/material-dashboard
- Save all files in: Scripts/UI_Administration/
- Use Python 3.10+ with Flask
- Use Material UI (React) for frontend
- Follow Python PEP 8 standards
- Follow React/JavaScript best practices

CRITICAL FILE ORGANIZATION:
Save in Scripts/UI_Administration/:
├── app.py                          # Main Flask application
├── requirements.txt                # Python dependencies
├── config.json                     # Configuration
├── README.md                       # Setup and usage guide
├── static/                         # Static files
│   ├── css/
│   ├── js/
│   └── images/
├── templates/                      # HTML templates (if using Jinja2)
├── frontend/                       # React app (if using React)
│   ├── src/
│   │   ├── components/
│   │   ├── App.jsx
│   │   └── index.jsx
│   └── package.json
└── utils/                          # Python utilities
    ├── powershell_executor.py
    └── script_parser.py

TASK:
Create a comprehensive Material UI dashboard for running Microsoft 365 PowerShell automation scripts. The dashboard should provide a clean, intuitive interface for executing scripts, viewing results, and managing execution history.

REQUIREMENTS:

1. TECHNOLOGY STACK
   - Backend: Flask (Python 3.10+)
   - Frontend: React 18+ with Material-UI (MUI) v5
   - PowerShell Execution: subprocess module
   - Database: SQLite for execution history
   - Real-time Updates: Server-Sent Events (SSE) or WebSocket

2. BACKEND (Flask Application)
   
   Core Features:
   - REST API endpoints for script execution
   - PowerShell script discovery (scan Scripts/ directory)
   - Parameter parsing from PowerShell scripts
   - Real-time output streaming
   - Execution history storage
   - Report file serving
   - CORS configuration for React frontend
   
   API Endpoints:
   - GET /api/scripts - List all available scripts by category
   - GET /api/scripts/{id} - Get script details and parameters
   - POST /api/execute - Execute a script with parameters
   - GET /api/executions - Get execution history
   - GET /api/executions/{id} - Get specific execution details
   - GET /api/executions/{id}/output - Get execution output
   - GET /api/reports/{filename} - Download report file
   - GET /api/status - Get system status

3. FRONTEND (React + Material-UI)
   
   Pages/Views:
   - Dashboard Home (overview, recent executions, quick actions)
   - Script Browser (categorized script list)
   - Script Runner (parameter input, execute, view output)
   - Execution History (past runs, status, re-run)
   - Reports Viewer (view and download generated reports)
   - Settings (configuration, preferences)
   
   Components:
   - AppBar with navigation
   - Sidebar with script categories
   - ScriptCard (displays script info)
   - ScriptExecutor (parameter form + execute button)
   - OutputViewer (real-time output display)
   - HistoryList (execution history table)
   - StatusIndicator (success/error/running badges)
   - ThemeToggle (light/dark mode)

4. UI/UX DESIGN (Material-UI)
   
   Design System:
   - Material Design 3 principles
   - Clean, minimalist interface
   - Card-based layouts
   - Consistent spacing (8px grid)
   - Color scheme:
     * Primary: Blue (#1976d2)
     * Success: Green (#2e7d32)
     * Warning: Orange (#ed6c02)
     * Error: Red (#d32f2f)
   - Typography: Roboto font family
   - Icons: Material Icons
   - Elevation and shadows for depth
   - Smooth transitions (300ms)
   
   Layout:
   - Top AppBar with title and actions
   - Left Sidebar with script categories (collapsible)
   - Main content area with breadcrumbs
   - Floating action button for quick actions
   - Bottom status bar (optional)
   
   Components to Use:
   - AppBar, Drawer, Card, Button, TextField
   - Select, Chip, Badge, Alert, Snackbar
   - CircularProgress, LinearProgress
   - Table, DataGrid (for history)
   - Dialog (for confirmations)
   - Tabs (for multiple views)

5. POWERSHELL INTEGRATION
   
   Script Discovery:
   - Scan Scripts/ directory for all .ps1 files
   - Parse script headers for parameters (Get-Help)
   - Categorize by directory (User_Administration, etc.)
   - Extract description from comment-based help
   
   Script Execution:
   - Build PowerShell command with parameters
   - Execute via subprocess
   - Capture stdout and stderr separately
   - Stream output in real-time (if possible)
   - Handle long-running scripts (progress)
   - Support script cancellation
   - Store execution results in SQLite
   
   Output Handling:
   - Parse PowerShell output (text, JSON, CSV)
   - Display in formatted view
   - Syntax highlighting for code output
   - Download raw output option
   - Link to generated report files

6. FEATURES TO IMPLEMENT
   
   Dashboard Home:
   - Welcome message
   - Statistics cards (total scripts, recent runs, success rate)
   - Recent executions table (last 10)
   - Quick access buttons to popular scripts
   - System status (M365 connection, PowerShell version)
   
   Script Browser:
   - Grid or list view of scripts
   - Filter by category
   - Search functionality
   - Sort by name, date, popularity
   - Script cards with icon, name, description
   - Click to view details or execute
   
   Script Execution:
   - Script details (name, description, author, version)
   - Dynamic parameter form based on script requirements
   - Parameter validation (required, type, range)
   - Execute button with confirmation dialog
   - Real-time output display with auto-scroll
   - Cancel execution button
   - Download output button
   - View generated reports button
   
   Execution History:
   - Table with columns: Date, Script, Status, Duration, Actions
   - Filter by status (success, failed, cancelled)
   - Search by script name
   - View output action
   - Re-run action
   - Delete history action
   - Export history to CSV
   
   Reports Viewer:
   - List of generated report files
   - Preview for HTML reports
   - Download button for all formats
   - Delete old reports
   - Sort by date, size, type

7. SECURITY IMPLEMENTATION
   
   Input Validation:
   - Validate all user inputs
   - Sanitize parameters before PowerShell execution
   - Prevent command injection
   - Whitelist allowed characters
   - Validate file paths (no directory traversal)
   
   Script Execution Safety:
   - Only execute .ps1 files from Scripts/ directory
   - No arbitrary command execution
   - Validate script exists before execution
   - Timeout for long-running scripts
   - Log all executions with user context
   
   Optional Authentication:
   - Simple username/password (optional)
   - Session management
   - API key authentication
   - Rate limiting

8. ERROR HANDLING
   
   Backend:
   - Try-except blocks for all operations
   - Specific error messages
   - Logging to file and console
   - Graceful degradation
   - HTTP error codes (400, 404, 500)
   
   Frontend:
   - Error boundaries (React)
   - User-friendly error messages
   - Snackbar notifications
   - Retry mechanisms
   - Loading states for all async operations

9. CONFIGURATION
   
   config.json:
   ```json
   {
     "powershell_path": "pwsh",
     "scripts_directory": "./Scripts",
     "output_directory": "./Tests/Test_Results",
     "database_path": "./Scripts/UI_Administration/executions.db",
     "max_execution_timeout": 3600,
     "port": 5000,
     "debug": false
   }
   ```

10. DEPLOYMENT & SETUP
    
    Requirements.txt:
    - Flask >= 2.3.0
    - flask-cors
    - flask-sqlalchemy (for execution history)
    - python-dotenv (for configuration)
    
    Frontend package.json:
    - React 18
    - @mui/material >= 5.14.0
    - @mui/icons-material
    - axios (for API calls)
    - react-router-dom (for navigation)
    
    Installation Steps:
    1. Python virtual environment setup
    2. Install Python dependencies
    3. Install Node.js dependencies
    4. Build React frontend
    5. Run Flask application
    6. Access at http://localhost:5000

DELIVERABLES:

1. Backend Application (Python/Flask)
   - app.py (main application)
   - utils/powershell_executor.py
   - utils/script_parser.py
   - requirements.txt
   - config.json example

2. Frontend Application (React/Material-UI)
   - Complete React application
   - Material-UI components
   - Responsive design
   - Dark mode support
   - All pages and views

3. Documentation
   - README.md with:
     * Overview and features
     * Installation instructions (step-by-step)
     * Configuration guide
     * Usage examples
     * Troubleshooting
     * Screenshots of UI
   - INSTALLATION.md (detailed setup)
   - API_DOCUMENTATION.md (API endpoints)

4. Additional Files
   - .env.example (configuration template)
   - .gitignore (Python, Node, dependencies)
   - Database schema (SQLite)
   - Example scripts mapping

OUTPUT REQUIREMENTS:
- Fully functional dashboard (no placeholders)
- Beautiful Material-UI design
- Intuitive user experience
- Real-time script execution
- Professional documentation
- Easy installation process
- Production-ready code

Save ALL files in: Scripts/UI_Administration/

After creating the dashboard, commit to branch agent/ui-admin/material-dashboard and notify for Master Agent review.
```

---

## Expected Dashboard Features

The UI Agent will create a dashboard with:

1. **Home Dashboard**
   - Quick stats and overview
   - Recent script executions
   - Quick access to popular scripts

2. **Script Runner**
   - Browse scripts by category (10 admin roles)
   - Click to run any script
   - Dynamic parameter inputs
   - Real-time output display

3. **Execution History**
   - View past executions
   - Re-run scripts
   - View outputs and reports

4. **Report Viewer**
   - View generated HTML, CSV, JSON reports
   - Download reports
   - Preview HTML reports inline

5. **Settings**
   - Configure PowerShell path
   - Set output directories
   - Theme selection

## Technology Stack

- **Backend:** Flask (Python 3.10+)
- **Frontend:** React 18 + Material-UI v5
- **Database:** SQLite (execution history)
- **PowerShell:** subprocess integration
- **Design:** Material Design 3

---

## Files the Agent Will Create

```
Scripts/UI_Administration/
├── app.py                    # Flask backend
├── requirements.txt          # Python deps
├── package.json             # Node/React deps
├── README.md                # Setup guide
├── frontend/                # React app
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── App.jsx
│   │   └── index.jsx
│   └── public/
└── utils/                   # Python utilities
    ├── powershell_executor.py
    └── script_parser.py
```

---

**This prompt is ready to use with the UI/Dashboard Administrator Agent!**

