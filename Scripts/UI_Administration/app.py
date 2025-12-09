"""
M365 Admin Dashboard - Flask Backend
Main application file with API endpoints
"""

import os
import json
import logging
from datetime import datetime
from pathlib import Path
from flask import Flask, jsonify, request, send_file, Response, send_from_directory
from flask_cors import CORS
import threading
import queue

# Import utility modules
from utils.database import ExecutionDatabase
from utils.script_scanner import ScriptScanner
from utils.script_parser import ScriptParser
from utils.powershell_executor import PowerShellExecutor

# Initialize Flask app
app = Flask(__name__, static_folder='frontend/build', static_url_path='')
CORS(app)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load configuration
config_path = Path(__file__).parent / 'config.json'
with open(config_path, 'r') as f:
    config = json.load(f)

# Override with environment variables if set (for Docker)
scripts_dir = os.environ.get('SCRIPTS_DIR', config['paths']['scripts_directory'])
results_dir = os.environ.get('RESULTS_DIR', config['paths']['test_results_directory'])
db_file = os.environ.get('DB_FILE', config['paths']['database_file'])
pwsh_path = os.environ.get('PWSH_PATH', config['powershell']['executable'])

# Update config with overrides
config['paths']['scripts_directory'] = scripts_dir
config['paths']['test_results_directory'] = results_dir
config['paths']['database_file'] = db_file
config['powershell']['executable'] = pwsh_path

# Initialize components
db = ExecutionDatabase(config['paths']['database_file'])
scanner = ScriptScanner(config['paths']['scripts_directory'])
parser = ScriptParser(config['powershell']['executable'])
executor = PowerShellExecutor(
    pwsh_path=config['powershell']['executable'],
    timeout=config['powershell']['timeout_seconds']
)

# Active executions tracking
active_executions = {}


#region API Endpoints

@app.route('/')
def serve_frontend():
    """Serve React frontend"""
    return send_from_directory(app.static_folder, 'index.html')


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'version': config['app']['version'],
        'timestamp': datetime.now().isoformat()
    })


@app.route('/api/scripts', methods=['GET'])
def get_scripts():
    """Get list of all available scripts (fast - no metadata parsing)"""
    try:
        category = request.args.get('category', None)
        search = request.args.get('search', None)
        
        logger.info(f"Fetching scripts - category: {category}, search: {search}")
        
        # Scan for scripts (fast - just file system scan)
        scripts = scanner.scan_scripts()
        
        # Quick inline metadata parsing (file-based only, no PowerShell)
        for script in scripts:
            try:
                # Quick parse - just read file header for synopsis
                script['synopsis'] = quick_parse_synopsis(script['full_path'])
            except Exception:
                script['synopsis'] = 'PowerShell automation script'
        
        # Filter by category
        if category and category != 'all':
            scripts = [s for s in scripts if s.get('category') == category]
        
        # Filter by search term
        if search:
            search_lower = search.lower()
            scripts = [
                s for s in scripts 
                if search_lower in s.get('name', '').lower() 
                or search_lower in s.get('synopsis', '').lower()
            ]
        
        logger.info(f"Returning {len(scripts)} scripts")
        
        return jsonify({
            'success': True,
            'scripts': scripts,
            'total': len(scripts)
        })
        
    except Exception as e:
        logger.error(f"Error fetching scripts: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


def quick_parse_synopsis(script_path):
    """Quick parse just the synopsis from file (no PowerShell)"""
    try:
        with open(script_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read(4000)  # Read first 4KB only
        
        import re
        match = re.search(r'\.SYNOPSIS\s+(.+?)(?=\.|$)', content, re.DOTALL | re.IGNORECASE)
        if match:
            synopsis = match.group(1).strip()
            # Clean up - take first line only
            synopsis = synopsis.split('\n')[0].strip()
            return synopsis[:200]  # Limit length
        return 'PowerShell automation script'
    except Exception:
        return 'PowerShell automation script'


@app.route('/api/scripts/<path:script_path>', methods=['GET'])
def get_script_details(script_path):
    """Get detailed information about a specific script"""
    try:
        # Validate and resolve script path
        scripts_dir = Path(config['paths']['scripts_directory']).resolve()
        full_path = (scripts_dir / script_path).resolve()
        
        # Security check
        if not str(full_path).startswith(str(scripts_dir)):
            return jsonify({
                'success': False,
                'error': 'Invalid script path'
            }), 400
        
        if not full_path.exists():
            return jsonify({
                'success': False,
                'error': 'Script not found'
            }), 404
        
        # Parse script metadata
        metadata = parser.parse_script_metadata(str(full_path))
        
        # Get execution history for this script
        history = db.get_script_history(script_path, limit=10)
        
        return jsonify({
            'success': True,
            'script': metadata,
            'history': history
        })
        
    except Exception as e:
        logger.error(f"Error fetching script details: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/execute', methods=['POST'])
def execute_script():
    """Execute a PowerShell script"""
    try:
        data = request.json
        script_path = data.get('script_path')
        parameters = data.get('parameters', {})
        
        if not script_path:
            return jsonify({
                'success': False,
                'error': 'Script path is required'
            }), 400
        
        logger.info(f"Executing script: {script_path}")
        logger.info(f"Parameters: {parameters}")
        
        # Validate script path
        scripts_dir = Path(config['paths']['scripts_directory']).resolve()
        full_path = (scripts_dir / script_path).resolve()
        
        # Security check
        if not str(full_path).startswith(str(scripts_dir)):
            return jsonify({
                'success': False,
                'error': 'Invalid script path'
            }), 400
        
        if not full_path.exists():
            return jsonify({
                'success': False,
                'error': 'Script not found'
            }), 404
        
        # Execute script
        result = executor.execute_script(str(full_path), parameters)
        
        # Store execution in database
        execution_id = db.log_execution(
            script_path=script_path,
            parameters=parameters,
            status='success' if result['exit_code'] == 0 else 'failed',
            output=result['stdout'],
            error=result['stderr'],
            duration=result['duration'],
            exit_code=result['exit_code']
        )
        
        return jsonify({
            'success': True,
            'execution_id': execution_id,
            'result': result
        })
        
    except Exception as e:
        logger.error(f"Error executing script: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/execute/stream', methods=['POST'])
def execute_script_stream():
    """Execute a PowerShell script with streaming output"""
    try:
        data = request.json
        script_path = data.get('script_path')
        parameters = data.get('parameters', {})
        
        if not script_path:
            return jsonify({
                'success': False,
                'error': 'Script path is required'
            }), 400
        
        # Validate script path
        scripts_dir = Path(config['paths']['scripts_directory']).resolve()
        full_path = (scripts_dir / script_path).resolve()
        
        # Security check
        if not str(full_path).startswith(str(scripts_dir)):
            return jsonify({
                'success': False,
                'error': 'Invalid script path'
            }), 400
        
        if not full_path.exists():
            return jsonify({
                'success': False,
                'error': 'Script not found'
            }), 404
        
        def generate():
            """Generator for streaming output"""
            for line in executor.execute_script_stream(str(full_path), parameters):
                yield f"data: {json.dumps(line)}\n\n"
        
        return Response(generate(), mimetype='text/event-stream')
        
    except Exception as e:
        logger.error(f"Error streaming script execution: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/executions', methods=['GET'])
def get_executions():
    """Get execution history"""
    try:
        limit = request.args.get('limit', 50, type=int)
        offset = request.args.get('offset', 0, type=int)
        status_filter = request.args.get('status', None)
        
        executions = db.get_history(limit=limit, offset=offset, status_filter=status_filter)
        total = db.get_total_executions(status_filter=status_filter)
        
        return jsonify({
            'success': True,
            'executions': executions,
            'total': total,
            'limit': limit,
            'offset': offset
        })
        
    except Exception as e:
        logger.error(f"Error fetching executions: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/executions/<int:execution_id>', methods=['GET'])
def get_execution_details(execution_id):
    """Get details of a specific execution"""
    try:
        execution = db.get_execution(execution_id)
        
        if not execution:
            return jsonify({
                'success': False,
                'error': 'Execution not found'
            }), 404
        
        return jsonify({
            'success': True,
            'execution': execution
        })
        
    except Exception as e:
        logger.error(f"Error fetching execution details: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/statistics', methods=['GET'])
def get_statistics():
    """Get dashboard statistics"""
    try:
        stats = db.get_statistics()
        
        # Add script count
        scripts = scanner.scan_scripts()
        stats['total_scripts'] = len(scripts)
        
        # Scripts by category
        category_counts = {}
        for script in scripts:
            category = script.get('category', 'Unknown')
            category_counts[category] = category_counts.get(category, 0) + 1
        
        stats['scripts_by_category'] = category_counts
        
        return jsonify({
            'success': True,
            'statistics': stats
        })
        
    except Exception as e:
        logger.error(f"Error fetching statistics: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/reports', methods=['GET'])
def get_reports():
    """Get list of available reports"""
    try:
        reports_dir = Path(config['paths']['test_results_directory']).resolve()
        
        if not reports_dir.exists():
            return jsonify({
                'success': True,
                'reports': []
            })
        
        reports = []
        for file_path in reports_dir.iterdir():
            if file_path.is_file():
                stat = file_path.stat()
                reports.append({
                    'name': file_path.name,
                    'path': str(file_path.relative_to(reports_dir.parent)),
                    'size': stat.st_size,
                    'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
                    'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
                    'extension': file_path.suffix
                })
        
        # Sort by modified date (newest first)
        reports.sort(key=lambda x: x['modified'], reverse=True)
        
        return jsonify({
            'success': True,
            'reports': reports
        })
        
    except Exception as e:
        logger.error(f"Error fetching reports: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/reports/<path:report_path>', methods=['GET'])
def download_report(report_path):
    """Download a report file"""
    try:
        reports_dir = Path(config['paths']['test_results_directory']).resolve()
        full_path = (reports_dir / report_path).resolve()
        
        # Security check
        if not str(full_path).startswith(str(reports_dir)):
            return jsonify({
                'success': False,
                'error': 'Invalid report path'
            }), 400
        
        if not full_path.exists():
            return jsonify({
                'success': False,
                'error': 'Report not found'
            }), 404
        
        return send_file(full_path, as_attachment=True)
        
    except Exception as e:
        logger.error(f"Error downloading report: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/categories', methods=['GET'])
def get_categories():
    """Get list of script categories"""
    categories = scanner.get_categories()
    return jsonify({
        'success': True,
        'categories': categories
    })


#endregion


#region Error Handlers

@app.errorhandler(404)
def not_found(e):
    """Handle 404 errors"""
    # Serve React app for client-side routing
    return send_from_directory(app.static_folder, 'index.html')


@app.errorhandler(500)
def internal_error(e):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {e}", exc_info=True)
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500

#endregion


if __name__ == '__main__':
    logger.info(f"Starting {config['app']['name']} v{config['app']['version']}")
    logger.info(f"Scripts directory: {config['paths']['scripts_directory']}")
    logger.info(f"Reports directory: {config['paths']['test_results_directory']}")
    
    # Initialize database
    db.initialize()
    
    # Start Flask app
    app.run(
        host=config['app']['host'],
        port=config['app']['port'],
        debug=config['app']['debug']
    )

