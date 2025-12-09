"""
Schedule Manager - Manages cron jobs for PowerShell script scheduling
"""

import os
import logging
import json
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional
from crontab import CronTab

logger = logging.getLogger(__name__)


class ScheduleManager:
    """Manages cron jobs for scheduled script execution"""
    
    # Cron job comment prefix to identify our jobs
    CRON_COMMENT_PREFIX = "M365_ADMIN_DASHBOARD"
    
    def __init__(self, scripts_directory: str, pwsh_path: str = "pwsh", log_directory: str = None):
        self.scripts_directory = Path(scripts_directory).resolve()
        self.pwsh_path = pwsh_path
        self.log_directory = Path(log_directory) if log_directory else self.scripts_directory.parent / "Logs" / "Scheduled"
        self.log_directory.mkdir(parents=True, exist_ok=True)
        
        # Get the current user's crontab
        self.cron = CronTab(user=True)
        
        logger.info(f"ScheduleManager initialized - Scripts: {self.scripts_directory}, Logs: {self.log_directory}")
    
    def _get_job_comment(self, schedule_id: int) -> str:
        """Generate unique comment for cron job"""
        return f"{self.CRON_COMMENT_PREFIX}_{schedule_id}"
    
    def _build_command(self, script_path: str, parameters: Dict = None, schedule_id: int = None) -> str:
        """Build the cron command for script execution"""
        full_script_path = self.scripts_directory / script_path
        
        # Build parameter string
        param_str = ""
        if parameters:
            for key, value in parameters.items():
                if value is not None and value != "":
                    # Handle different parameter types
                    if isinstance(value, bool):
                        if value:
                            param_str += f" -{key}"
                    elif isinstance(value, (list, tuple)):
                        param_str += f" -{key} {','.join(str(v) for v in value)}"
                    else:
                        # Escape special characters in values
                        escaped_value = str(value).replace("'", "'\\''")
                        param_str += f" -{key} '{escaped_value}'"
        
        # Log file for this schedule
        log_file = self.log_directory / f"schedule_{schedule_id}_{datetime.now().strftime('%Y%m%d')}.log"
        
        # Build command with logging
        command = (
            f"{self.pwsh_path} -NoProfile -ExecutionPolicy Bypass "
            f"-File '{full_script_path}'{param_str} "
            f">> '{log_file}' 2>&1"
        )
        
        return command
    
    def create_schedule(self, schedule_id: int, script_path: str, cron_expression: str, 
                       parameters: Dict = None, enabled: bool = True) -> Dict:
        """Create a new cron job for scheduled script execution"""
        try:
            # Parse cron expression (minute hour day month weekday)
            parts = cron_expression.strip().split()
            if len(parts) != 5:
                raise ValueError(f"Invalid cron expression: {cron_expression}. Expected 5 parts (minute hour day month weekday)")
            
            # Remove existing job if any
            self.delete_schedule(schedule_id)
            
            # Build command
            command = self._build_command(script_path, parameters, schedule_id)
            
            # Create new cron job
            job = self.cron.new(command=command, comment=self._get_job_comment(schedule_id))
            
            # Set schedule
            job.setall(cron_expression)
            
            # Enable/disable
            job.enable(enabled)
            
            # Write to crontab
            self.cron.write()
            
            logger.info(f"Created schedule {schedule_id} for {script_path}: {cron_expression}")
            
            return {
                "success": True,
                "schedule_id": schedule_id,
                "cron_expression": cron_expression,
                "command": command,
                "next_run": str(job.schedule().get_next()) if enabled else None
            }
            
        except Exception as e:
            logger.error(f"Error creating schedule {schedule_id}: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e)
            }
    
    def update_schedule(self, schedule_id: int, script_path: str = None, 
                       cron_expression: str = None, parameters: Dict = None,
                       enabled: bool = None) -> Dict:
        """Update an existing schedule"""
        try:
            job = self._find_job(schedule_id)
            
            if not job:
                return {
                    "success": False,
                    "error": f"Schedule {schedule_id} not found"
                }
            
            # Update command if script or parameters changed
            if script_path is not None or parameters is not None:
                current_script = script_path or self._extract_script_from_command(job.command)
                command = self._build_command(current_script, parameters, schedule_id)
                job.set_command(command)
            
            # Update schedule if provided
            if cron_expression:
                parts = cron_expression.strip().split()
                if len(parts) != 5:
                    raise ValueError(f"Invalid cron expression: {cron_expression}")
                job.setall(cron_expression)
            
            # Update enabled status
            if enabled is not None:
                job.enable(enabled)
            
            # Write changes
            self.cron.write()
            
            logger.info(f"Updated schedule {schedule_id}")
            
            return {
                "success": True,
                "schedule_id": schedule_id,
                "next_run": str(job.schedule().get_next()) if job.is_enabled() else None
            }
            
        except Exception as e:
            logger.error(f"Error updating schedule {schedule_id}: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e)
            }
    
    def delete_schedule(self, schedule_id: int) -> Dict:
        """Delete a scheduled job"""
        try:
            comment = self._get_job_comment(schedule_id)
            removed = False
            
            for job in self.cron:
                if job.comment == comment:
                    self.cron.remove(job)
                    removed = True
                    break
            
            if removed:
                self.cron.write()
                logger.info(f"Deleted schedule {schedule_id}")
            
            return {
                "success": True,
                "removed": removed
            }
            
        except Exception as e:
            logger.error(f"Error deleting schedule {schedule_id}: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_schedule(self, schedule_id: int) -> Optional[Dict]:
        """Get details of a specific schedule"""
        job = self._find_job(schedule_id)
        
        if not job:
            return None
        
        return self._job_to_dict(job, schedule_id)
    
    def list_schedules(self) -> List[Dict]:
        """List all M365 Admin Dashboard schedules"""
        schedules = []
        
        for job in self.cron:
            if job.comment and job.comment.startswith(self.CRON_COMMENT_PREFIX):
                try:
                    schedule_id = int(job.comment.split("_")[-1])
                    schedules.append(self._job_to_dict(job, schedule_id))
                except (ValueError, IndexError):
                    continue
        
        return schedules
    
    def toggle_schedule(self, schedule_id: int, enabled: bool) -> Dict:
        """Enable or disable a schedule"""
        try:
            job = self._find_job(schedule_id)
            
            if not job:
                return {
                    "success": False,
                    "error": f"Schedule {schedule_id} not found"
                }
            
            job.enable(enabled)
            self.cron.write()
            
            logger.info(f"Schedule {schedule_id} {'enabled' if enabled else 'disabled'}")
            
            return {
                "success": True,
                "enabled": enabled,
                "next_run": str(job.schedule().get_next()) if enabled else None
            }
            
        except Exception as e:
            logger.error(f"Error toggling schedule {schedule_id}: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_schedule_logs(self, schedule_id: int, lines: int = 100) -> Dict:
        """Get recent log output for a schedule"""
        try:
            # Find log files for this schedule
            log_files = sorted(
                self.log_directory.glob(f"schedule_{schedule_id}_*.log"),
                reverse=True
            )
            
            if not log_files:
                return {
                    "success": True,
                    "logs": [],
                    "message": "No logs found"
                }
            
            # Read from most recent log file
            log_content = []
            for log_file in log_files[:5]:  # Check last 5 log files
                try:
                    with open(log_file, 'r') as f:
                        file_lines = f.readlines()
                        log_content.extend([
                            {
                                "file": log_file.name,
                                "line": line.strip()
                            }
                            for line in file_lines[-lines:]
                        ])
                except Exception as e:
                    logger.warning(f"Error reading log file {log_file}: {e}")
            
            return {
                "success": True,
                "logs": log_content[-lines:],
                "log_files": [f.name for f in log_files[:10]]
            }
            
        except Exception as e:
            logger.error(f"Error getting logs for schedule {schedule_id}: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e)
            }
    
    def _find_job(self, schedule_id: int):
        """Find a cron job by schedule ID"""
        comment = self._get_job_comment(schedule_id)
        for job in self.cron:
            if job.comment == comment:
                return job
        return None
    
    def _job_to_dict(self, job, schedule_id: int) -> Dict:
        """Convert cron job to dictionary"""
        try:
            next_run = str(job.schedule().get_next()) if job.is_enabled() else None
        except:
            next_run = None
        
        return {
            "schedule_id": schedule_id,
            "command": job.command,
            "cron_expression": str(job.slices),
            "enabled": job.is_enabled(),
            "next_run": next_run,
            "comment": job.comment
        }
    
    def _extract_script_from_command(self, command: str) -> str:
        """Extract script path from cron command"""
        # Look for -File 'path' pattern
        import re
        match = re.search(r"-File\s+'([^']+)'", command)
        if match:
            full_path = match.group(1)
            try:
                return str(Path(full_path).relative_to(self.scripts_directory))
            except ValueError:
                return full_path
        return ""
    
    @staticmethod
    def validate_cron_expression(expression: str) -> Dict:
        """Validate a cron expression"""
        try:
            parts = expression.strip().split()
            if len(parts) != 5:
                return {
                    "valid": False,
                    "error": "Cron expression must have 5 parts: minute hour day month weekday"
                }
            
            # Create a temporary job to validate
            temp_cron = CronTab(tab="")
            job = temp_cron.new(command="echo test")
            job.setall(expression)
            
            return {
                "valid": True,
                "description": str(job.description()),
                "next_runs": [str(t) for t in job.schedule().get_next(5)]
            }
            
        except Exception as e:
            return {
                "valid": False,
                "error": str(e)
            }
    
    @staticmethod
    def get_preset_schedules() -> List[Dict]:
        """Get list of common schedule presets"""
        return [
            {"label": "Every hour", "expression": "0 * * * *"},
            {"label": "Every 6 hours", "expression": "0 */6 * * *"},
            {"label": "Daily at midnight", "expression": "0 0 * * *"},
            {"label": "Daily at 6 AM", "expression": "0 6 * * *"},
            {"label": "Daily at 9 AM", "expression": "0 9 * * *"},
            {"label": "Daily at 6 PM", "expression": "0 18 * * *"},
            {"label": "Weekly on Monday at 9 AM", "expression": "0 9 * * 1"},
            {"label": "Weekly on Friday at 5 PM", "expression": "0 17 * * 5"},
            {"label": "First day of month at 9 AM", "expression": "0 9 1 * *"},
            {"label": "Every 15 minutes", "expression": "*/15 * * * *"},
            {"label": "Every 30 minutes", "expression": "*/30 * * * *"},
            {"label": "Weekdays at 9 AM", "expression": "0 9 * * 1-5"},
            {"label": "Weekends at noon", "expression": "0 12 * * 0,6"},
        ]

