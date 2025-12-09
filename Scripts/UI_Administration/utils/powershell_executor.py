"""
PowerShell Executor - Executes PowerShell scripts safely
"""

import subprocess
import logging
import time
import re
from pathlib import Path
from typing import Dict, Any, Generator
import psutil

logger = logging.getLogger(__name__)


class PowerShellExecutor:
    """Executes PowerShell scripts with safety controls"""
    
    # Dangerous characters that should be sanitized
    DANGEROUS_CHARS = [';', '|', '&', '$', '`', '<', '>', '(', ')', '\n', '\r']
    
    def __init__(self, pwsh_path: str = 'pwsh', timeout: int = 3600):
        self.pwsh_path = pwsh_path
        self.timeout = timeout
    
    def validate_script_path(self, script_path: str, allowed_directory: str = None) -> bool:
        """Validate script path for security"""
        try:
            script_path = Path(script_path).resolve()
            
            # Must be a .ps1 file
            if script_path.suffix.lower() != '.ps1':
                logger.warning(f"Invalid script extension: {script_path}")
                return False
            
            # Must exist
            if not script_path.exists():
                logger.warning(f"Script does not exist: {script_path}")
                return False
            
            # If allowed directory specified, must be within it
            if allowed_directory:
                allowed_dir = Path(allowed_directory).resolve()
                if not str(script_path).startswith(str(allowed_dir)):
                    logger.warning(f"Script outside allowed directory: {script_path}")
                    return False
            
            return True
            
        except Exception as e:
            logger.error(f"Error validating script path: {e}")
            return False
    
    def sanitize_parameter(self, value: Any) -> str:
        """Sanitize parameter value to prevent injection"""
        if value is None:
            return ''
        
        value_str = str(value)
        
        # Remove dangerous characters
        for char in self.DANGEROUS_CHARS:
            value_str = value_str.replace(char, '')
        
        return value_str
    
    def build_command(self, script_path: str, parameters: Dict[str, Any] = None) -> list:
        """Build PowerShell command with parameters"""
        cmd = [
            self.pwsh_path,
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', script_path
        ]
        
        if parameters:
            for key, value in parameters.items():
                # Sanitize parameter name and value
                param_name = re.sub(r'[^a-zA-Z0-9_]', '', key)
                
                if isinstance(value, bool):
                    # For switch parameters
                    if value:
                        cmd.append(f'-{param_name}')
                elif isinstance(value, (list, tuple)):
                    # For array parameters
                    sanitized_values = [self.sanitize_parameter(v) for v in value]
                    cmd.extend([f'-{param_name}', ','.join(sanitized_values)])
                else:
                    # For regular parameters
                    sanitized_value = self.sanitize_parameter(value)
                    if sanitized_value:
                        cmd.extend([f'-{param_name}', sanitized_value])
        
        return cmd
    
    def execute_script(
        self,
        script_path: str,
        parameters: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """Execute a PowerShell script and return results"""
        start_time = time.time()
        
        try:
            logger.info(f"Executing script: {script_path}")
            
            # Validate script path
            if not self.validate_script_path(script_path):
                return {
                    'success': False,
                    'exit_code': -1,
                    'stdout': '',
                    'stderr': 'Invalid script path',
                    'duration': 0
                }
            
            # Build command
            cmd = self.build_command(script_path, parameters)
            logger.info(f"Command: {' '.join(cmd)}")
            
            # Execute
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=self.timeout,
                encoding='utf-8',
                errors='replace'
            )
            
            duration = time.time() - start_time
            
            logger.info(f"Script completed in {duration:.2f}s with exit code {result.returncode}")
            
            return {
                'success': result.returncode == 0,
                'exit_code': result.returncode,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'duration': duration
            }
            
        except subprocess.TimeoutExpired:
            duration = time.time() - start_time
            logger.error(f"Script execution timed out after {duration:.2f}s")
            return {
                'success': False,
                'exit_code': -2,
                'stdout': '',
                'stderr': f'Script execution timed out after {duration:.2f} seconds',
                'duration': duration
            }
            
        except Exception as e:
            duration = time.time() - start_time
            logger.error(f"Error executing script: {e}", exc_info=True)
            return {
                'success': False,
                'exit_code': -3,
                'stdout': '',
                'stderr': str(e),
                'duration': duration
            }
    
    def execute_script_stream(
        self,
        script_path: str,
        parameters: Dict[str, Any] = None
    ) -> Generator[Dict[str, str], None, None]:
        """Execute a PowerShell script with streaming output"""
        start_time = time.time()
        
        try:
            logger.info(f"Executing script with streaming: {script_path}")
            
            # Validate script path
            if not self.validate_script_path(script_path):
                yield {
                    'type': 'error',
                    'message': 'Invalid script path',
                    'timestamp': time.time()
                }
                return
            
            # Build command
            cmd = self.build_command(script_path, parameters)
            
            # Send start event
            yield {
                'type': 'start',
                'message': f'Starting execution of {Path(script_path).name}',
                'timestamp': time.time()
            }
            
            # Execute with streaming
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            # Stream stdout
            for line in iter(process.stdout.readline, ''):
                if line:
                    yield {
                        'type': 'stdout',
                        'message': line.rstrip(),
                        'timestamp': time.time()
                    }
            
            # Wait for process to complete
            process.wait(timeout=self.timeout)
            
            # Get stderr if any
            stderr = process.stderr.read()
            if stderr:
                yield {
                    'type': 'stderr',
                    'message': stderr,
                    'timestamp': time.time()
                }
            
            duration = time.time() - start_time
            
            # Send completion event
            yield {
                'type': 'complete',
                'message': f'Execution completed in {duration:.2f}s',
                'exit_code': process.returncode,
                'duration': duration,
                'timestamp': time.time()
            }
            
        except subprocess.TimeoutExpired:
            duration = time.time() - start_time
            logger.error(f"Script execution timed out after {duration:.2f}s")
            yield {
                'type': 'error',
                'message': f'Script execution timed out after {duration:.2f} seconds',
                'timestamp': time.time()
            }
            
        except Exception as e:
            logger.error(f"Error executing script: {e}", exc_info=True)
            yield {
                'type': 'error',
                'message': str(e),
                'timestamp': time.time()
            }
    
    def test_powershell(self) -> Dict[str, Any]:
        """Test if PowerShell is available"""
        try:
            result = subprocess.run(
                [self.pwsh_path, '-Command', '$PSVersionTable | ConvertTo-Json'],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0:
                import json
                version_info = json.loads(result.stdout)
                return {
                    'available': True,
                    'version': version_info.get('PSVersion', 'Unknown'),
                    'edition': version_info.get('PSEdition', 'Unknown')
                }
            else:
                return {
                    'available': False,
                    'error': result.stderr
                }
                
        except Exception as e:
            return {
                'available': False,
                'error': str(e)
            }

