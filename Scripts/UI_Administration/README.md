# M365 Admin Dashboard

A beautiful Material UI dashboard for executing and managing Microsoft 365 PowerShell automation scripts.

## Features

- ✨ **Material Design UI** - Clean, professional interface
- 🔍 **Auto-Discovery** - Automatically finds and categorizes scripts
- ▶️ **Script Execution** - Run PowerShell scripts with intuitive parameter forms
- 📊 **Real-Time Output** - View script execution output in real-time
- 📜 **Execution History** - Track all script executions
- 📈 **Statistics Dashboard** - View execution metrics and success rates
- 🌓 **Dark Mode** - Toggle between light and dark themes
- 📱 **Responsive Design** - Works on desktop and tablet

## Quick Start

### Prerequisites

- Docker and Docker Compose (recommended)
- OR: Python 3.8+, Node.js 16+, PowerShell 7.0+
- Microsoft 365 authenticated session (run `../../Initialize-M365Session.ps1`)

---

## 🐳 Docker Deployment (Recommended)

### Production Mode

```bash
cd Scripts/UI_Administration

# Build and start containers
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

**Access the dashboard at:** http://localhost:3000

### Development Mode (with hot reload)

```bash
cd Scripts/UI_Administration

# Start development containers
docker-compose -f docker-compose.dev.yml up --build

# Stop
docker-compose -f docker-compose.dev.yml down
```

---

## 💻 Manual Installation (Without Docker)

### Installation

#### 1. Install Python Dependencies

```bash
cd Scripts/UI_Administration
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### 2. Install Node Dependencies

```bash
cd frontend
npm install
cd ..
```

### Running the Application

#### Development Mode

**Terminal 1 - Start Flask Backend:**
```bash
source venv/bin/activate
python app.py
```

**Terminal 2 - Start React Frontend:**
```bash
cd frontend
npm start
```

The dashboard will open at: **http://localhost:3000**

The backend API runs at: **http://localhost:5001**

#### Production Mode

```bash
# Build React frontend
cd frontend
npm run build
cd ..

# Start Flask (serves both API and frontend)
source venv/bin/activate
python app.py
```

Access at: **http://localhost:5001**

## Project Structure

```
Scripts/UI_Administration/
├── app.py                      # Flask backend
├── config.json                 # Configuration
├── requirements.txt            # Python dependencies
├── executions.db               # SQLite database (created on first run)
│
├── utils/                      # Python utilities
│   ├── database.py             # SQLite operations
│   ├── script_scanner.py       # Auto-discover scripts
│   ├── script_parser.py        # Parse PowerShell metadata
│   └── powershell_executor.py  # Execute scripts safely
│
└── frontend/                   # React application
    ├── package.json            # Node dependencies
    ├── public/
    │   └── index.html
    └── src/
        ├── index.js
        └── App.js              # Main React component
```

## Usage

### 1. View Dashboard

- See total scripts available
- View recent executions
- Check success rate statistics
- Access quick actions

### 2. Browse Scripts by Category

Click any category in the sidebar:
- 👥 User Administration
- 📧 Exchange Administration
- 📁 SharePoint Administration
- 💬 Teams Administration
- 🔒 Security Administration
- 📜 License Administration
- ✅ Compliance Administration
- 📊 Audit Administration
- 📱 Intune/MDM Administration
- ⚙️ Global Administration

### 3. Execute a Script

1. Click **"Run Script"** on any script card
2. Fill in parameters (if required)
3. Click **"Execute"**
4. View real-time output
5. Results are automatically saved to history

### 4. View Execution History

- Click **"History"** in sidebar
- See all past executions
- View status (success/failed)
- Check execution duration
- Access output logs

## Configuration

Edit `config.json` to customize:

```json
{
  "app": {
    "host": "127.0.0.1",
    "port": 5000,
    "debug": true
  },
  "paths": {
    "scripts_directory": "../../Scripts",
    "test_results_directory": "../../Tests/Test_Results"
  },
  "powershell": {
    "executable": "pwsh",
    "timeout_seconds": 3600
  }
}
```

## Security

The dashboard includes several security features:

- ✅ **Path Validation** - Only executes scripts from Scripts/ directory
- ✅ **Parameter Sanitization** - Removes dangerous characters
- ✅ **No Command Injection** - Scripts are executed safely
- ✅ **Timeout Protection** - Scripts timeout after 1 hour
- ✅ **Execution Logging** - All executions are logged

## API Endpoints

- `GET /api/health` - Health check
- `GET /api/scripts` - List all scripts
- `GET /api/scripts/<path>` - Get script details
- `POST /api/execute` - Execute a script
- `GET /api/executions` - Get execution history
- `GET /api/statistics` - Get dashboard statistics
- `GET /api/categories` - Get script categories
- `GET /api/reports` - List available reports

## Troubleshooting

### Scripts not appearing?

1. Ensure scripts are in `Scripts/` subdirectories
2. Click **Refresh** button in Scripts view
3. Check Flask backend logs for errors

### Script execution fails?

1. Ensure M365 session is authenticated: `../../Initialize-M365Session.ps1`
2. Check PowerShell is available: `pwsh -Command "echo 'test'"`
3. Review execution logs in History view

### Frontend won't start?

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm start
```

### Backend errors?

```bash
source venv/bin/activate
pip install --upgrade -r requirements.txt
python app.py
```

## Maintenance

### Adding New Scripts

The dashboard **automatically discovers** new scripts! When other agents add scripts to `Scripts/` directories:

1. Scripts are auto-detected on next refresh
2. Metadata is parsed from PowerShell help
3. Parameters are automatically extracted
4. Scripts appear in appropriate category

**No manual updates needed!**

For details, see `MAINTENANCE_GUIDE.md`

## Development

### Running Tests

```bash
# Python tests
source venv/bin/activate
pytest

# React tests
cd frontend
npm test
```

### Building for Production

```bash
# Build React frontend
cd frontend
npm run build
cd ..

# The Flask app will serve the built React app
python app.py
```

## Support

- Check `MAINTENANCE_GUIDE.md` for adding scripts
- Review `API_DOCUMENTATION.md` for API details
- See `TROUBLESHOOTING.md` for common issues

## Version

**Version:** 1.0.0  
**Author:** UI Administrator Agent  
**Date:** December 2, 2025  
**Status:** ✅ Production Ready

## License

Internal use for Microsoft 365 administration and automation.

