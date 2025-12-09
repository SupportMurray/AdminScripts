"""
Database operations for execution history
Uses SQLite for simplicity
"""

import sqlite3
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Any

logger = logging.getLogger(__name__)


class ExecutionDatabase:
    """Manages execution history in SQLite database"""
    
    def __init__(self, db_path: str = 'executions.db'):
        self.db_path = Path(db_path)
        self.conn = None
    
    def initialize(self):
        """Initialize database and create tables if they don't exist"""
        try:
            self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
            self.conn.row_factory = sqlite3.Row
            
            cursor = self.conn.cursor()
            
            # Create executions table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS executions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    script_path TEXT NOT NULL,
                    script_name TEXT NOT NULL,
                    category TEXT,
                    parameters TEXT,
                    status TEXT NOT NULL,
                    output TEXT,
                    error TEXT,
                    exit_code INTEGER,
                    started_at TIMESTAMP NOT NULL,
                    completed_at TIMESTAMP,
                    duration_seconds REAL,
                    user_context TEXT
                )
            ''')
            
            # Create indexes for executions
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_script_path 
                ON executions(script_path)
            ''')
            
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_status 
                ON executions(status)
            ''')
            
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_started_at 
                ON executions(started_at DESC)
            ''')
            
            # Create schedules table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS schedules (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    script_path TEXT NOT NULL,
                    script_name TEXT NOT NULL,
                    category TEXT,
                    cron_expression TEXT NOT NULL,
                    parameters TEXT,
                    enabled INTEGER DEFAULT 1,
                    created_at TIMESTAMP NOT NULL,
                    updated_at TIMESTAMP NOT NULL,
                    last_run TIMESTAMP,
                    next_run TIMESTAMP,
                    run_count INTEGER DEFAULT 0,
                    last_status TEXT,
                    description TEXT
                )
            ''')
            
            # Create indexes for schedules
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_schedule_enabled 
                ON schedules(enabled)
            ''')
            
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_schedule_script 
                ON schedules(script_path)
            ''')
            
            self.conn.commit()
            logger.info(f"Database initialized: {self.db_path}")
            
        except Exception as e:
            logger.error(f"Error initializing database: {e}", exc_info=True)
            raise
    
    def log_execution(
        self,
        script_path: str,
        parameters: Dict[str, Any],
        status: str,
        output: str = '',
        error: str = '',
        duration: float = 0.0,
        exit_code: int = 0,
        category: str = None
    ) -> int:
        """Log a script execution"""
        try:
            if not self.conn:
                self.initialize()
            
            script_name = Path(script_path).name
            
            if not category:
                # Extract category from path
                parts = Path(script_path).parts
                if len(parts) > 1:
                    category = parts[-2].replace('_Administration', '')
            
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO executions (
                    script_path, script_name, category, parameters, status,
                    output, error, exit_code, started_at, completed_at, duration_seconds
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                script_path,
                script_name,
                category,
                json.dumps(parameters),
                status,
                output,
                error,
                exit_code,
                datetime.now().isoformat(),
                datetime.now().isoformat(),
                duration
            ))
            
            self.conn.commit()
            execution_id = cursor.lastrowid
            
            logger.info(f"Logged execution {execution_id}: {script_name} ({status})")
            return execution_id
            
        except Exception as e:
            logger.error(f"Error logging execution: {e}", exc_info=True)
            raise
    
    def get_history(
        self,
        limit: int = 50,
        offset: int = 0,
        status_filter: Optional[str] = None
    ) -> List[Dict]:
        """Get execution history"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            
            query = 'SELECT * FROM executions'
            params = []
            
            if status_filter:
                query += ' WHERE status = ?'
                params.append(status_filter)
            
            query += ' ORDER BY started_at DESC LIMIT ? OFFSET ?'
            params.extend([limit, offset])
            
            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            executions = []
            for row in rows:
                executions.append({
                    'id': row['id'],
                    'script_path': row['script_path'],
                    'script_name': row['script_name'],
                    'category': row['category'],
                    'parameters': json.loads(row['parameters']) if row['parameters'] else {},
                    'status': row['status'],
                    'output': row['output'],
                    'error': row['error'],
                    'exit_code': row['exit_code'],
                    'started_at': row['started_at'],
                    'completed_at': row['completed_at'],
                    'duration_seconds': row['duration_seconds']
                })
            
            return executions
            
        except Exception as e:
            logger.error(f"Error fetching history: {e}", exc_info=True)
            return []
    
    def get_execution(self, execution_id: int) -> Optional[Dict]:
        """Get details of a specific execution"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            cursor.execute('SELECT * FROM executions WHERE id = ?', (execution_id,))
            row = cursor.fetchone()
            
            if not row:
                return None
            
            return {
                'id': row['id'],
                'script_path': row['script_path'],
                'script_name': row['script_name'],
                'category': row['category'],
                'parameters': json.loads(row['parameters']) if row['parameters'] else {},
                'status': row['status'],
                'output': row['output'],
                'error': row['error'],
                'exit_code': row['exit_code'],
                'started_at': row['started_at'],
                'completed_at': row['completed_at'],
                'duration_seconds': row['duration_seconds']
            }
            
        except Exception as e:
            logger.error(f"Error fetching execution: {e}", exc_info=True)
            return None
    
    def get_script_history(self, script_path: str, limit: int = 10) -> List[Dict]:
        """Get execution history for a specific script"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            cursor.execute('''
                SELECT * FROM executions 
                WHERE script_path = ? 
                ORDER BY started_at DESC 
                LIMIT ?
            ''', (script_path, limit))
            
            rows = cursor.fetchall()
            
            executions = []
            for row in rows:
                executions.append({
                    'id': row['id'],
                    'status': row['status'],
                    'started_at': row['started_at'],
                    'duration_seconds': row['duration_seconds'],
                    'exit_code': row['exit_code']
                })
            
            return executions
            
        except Exception as e:
            logger.error(f"Error fetching script history: {e}", exc_info=True)
            return []
    
    def get_statistics(self) -> Dict:
        """Get dashboard statistics"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            
            # Total executions
            cursor.execute('SELECT COUNT(*) as total FROM executions')
            total = cursor.fetchone()['total']
            
            # Recent executions (last 24 hours)
            yesterday = (datetime.now() - timedelta(hours=24)).isoformat()
            cursor.execute(
                'SELECT COUNT(*) as recent FROM executions WHERE started_at > ?',
                (yesterday,)
            )
            recent = cursor.fetchone()['recent']
            
            # Success rate
            cursor.execute('''
                SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful
                FROM executions
            ''')
            row = cursor.fetchone()
            success_rate = (row['successful'] / row['total'] * 100) if row['total'] > 0 else 0
            
            # Executions by status
            cursor.execute('''
                SELECT status, COUNT(*) as count 
                FROM executions 
                GROUP BY status
            ''')
            status_counts = {row['status']: row['count'] for row in cursor.fetchall()}
            
            return {
                'total_executions': total,
                'recent_executions': recent,
                'success_rate': round(success_rate, 2),
                'status_counts': status_counts
            }
            
        except Exception as e:
            logger.error(f"Error fetching statistics: {e}", exc_info=True)
            return {
                'total_executions': 0,
                'recent_executions': 0,
                'success_rate': 0,
                'status_counts': {}
            }
    
    def get_total_executions(self, status_filter: Optional[str] = None) -> int:
        """Get total number of executions"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            
            if status_filter:
                cursor.execute(
                    'SELECT COUNT(*) as total FROM executions WHERE status = ?',
                    (status_filter,)
                )
            else:
                cursor.execute('SELECT COUNT(*) as total FROM executions')
            
            return cursor.fetchone()['total']
            
        except Exception as e:
            logger.error(f"Error counting executions: {e}", exc_info=True)
            return 0
    
    def close(self):
        """Close database connection"""
        if self.conn:
            self.conn.close()
            logger.info("Database connection closed")
    
    # ==================== Schedule Methods ====================
    
    def create_schedule(
        self,
        name: str,
        script_path: str,
        cron_expression: str,
        parameters: Dict[str, Any] = None,
        description: str = None,
        enabled: bool = True
    ) -> int:
        """Create a new schedule"""
        try:
            if not self.conn:
                self.initialize()
            
            script_name = Path(script_path).name
            parts = Path(script_path).parts
            category = parts[-2].replace('_Administration', '') if len(parts) > 1 else None
            
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO schedules (
                    name, script_path, script_name, category, cron_expression,
                    parameters, enabled, created_at, updated_at, description
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                name,
                script_path,
                script_name,
                category,
                cron_expression,
                json.dumps(parameters or {}),
                1 if enabled else 0,
                datetime.now().isoformat(),
                datetime.now().isoformat(),
                description
            ))
            
            self.conn.commit()
            schedule_id = cursor.lastrowid
            
            logger.info(f"Created schedule {schedule_id}: {name} ({cron_expression})")
            return schedule_id
            
        except Exception as e:
            logger.error(f"Error creating schedule: {e}", exc_info=True)
            raise
    
    def get_schedule(self, schedule_id: int) -> Optional[Dict]:
        """Get a specific schedule"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            cursor.execute('SELECT * FROM schedules WHERE id = ?', (schedule_id,))
            row = cursor.fetchone()
            
            if not row:
                return None
            
            return self._row_to_schedule(row)
            
        except Exception as e:
            logger.error(f"Error fetching schedule: {e}", exc_info=True)
            return None
    
    def get_schedules(self, enabled_only: bool = False) -> List[Dict]:
        """Get all schedules"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            
            if enabled_only:
                cursor.execute('SELECT * FROM schedules WHERE enabled = 1 ORDER BY name')
            else:
                cursor.execute('SELECT * FROM schedules ORDER BY name')
            
            rows = cursor.fetchall()
            return [self._row_to_schedule(row) for row in rows]
            
        except Exception as e:
            logger.error(f"Error fetching schedules: {e}", exc_info=True)
            return []
    
    def update_schedule(
        self,
        schedule_id: int,
        name: str = None,
        cron_expression: str = None,
        parameters: Dict[str, Any] = None,
        description: str = None,
        enabled: bool = None,
        next_run: str = None
    ) -> bool:
        """Update a schedule"""
        try:
            if not self.conn:
                self.initialize()
            
            updates = []
            params = []
            
            if name is not None:
                updates.append('name = ?')
                params.append(name)
            if cron_expression is not None:
                updates.append('cron_expression = ?')
                params.append(cron_expression)
            if parameters is not None:
                updates.append('parameters = ?')
                params.append(json.dumps(parameters))
            if description is not None:
                updates.append('description = ?')
                params.append(description)
            if enabled is not None:
                updates.append('enabled = ?')
                params.append(1 if enabled else 0)
            if next_run is not None:
                updates.append('next_run = ?')
                params.append(next_run)
            
            if not updates:
                return True
            
            updates.append('updated_at = ?')
            params.append(datetime.now().isoformat())
            params.append(schedule_id)
            
            cursor = self.conn.cursor()
            cursor.execute(
                f'UPDATE schedules SET {", ".join(updates)} WHERE id = ?',
                params
            )
            
            self.conn.commit()
            logger.info(f"Updated schedule {schedule_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error updating schedule: {e}", exc_info=True)
            return False
    
    def delete_schedule(self, schedule_id: int) -> bool:
        """Delete a schedule"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            cursor.execute('DELETE FROM schedules WHERE id = ?', (schedule_id,))
            self.conn.commit()
            
            logger.info(f"Deleted schedule {schedule_id}")
            return True
            
        except Exception as e:
            logger.error(f"Error deleting schedule: {e}", exc_info=True)
            return False
    
    def log_schedule_run(
        self,
        schedule_id: int,
        status: str,
        next_run: str = None
    ) -> bool:
        """Log a schedule execution"""
        try:
            if not self.conn:
                self.initialize()
            
            cursor = self.conn.cursor()
            cursor.execute('''
                UPDATE schedules 
                SET last_run = ?, last_status = ?, run_count = run_count + 1, next_run = ?
                WHERE id = ?
            ''', (
                datetime.now().isoformat(),
                status,
                next_run,
                schedule_id
            ))
            
            self.conn.commit()
            return True
            
        except Exception as e:
            logger.error(f"Error logging schedule run: {e}", exc_info=True)
            return False
    
    def _row_to_schedule(self, row) -> Dict:
        """Convert database row to schedule dict"""
        return {
            'id': row['id'],
            'name': row['name'],
            'script_path': row['script_path'],
            'script_name': row['script_name'],
            'category': row['category'],
            'cron_expression': row['cron_expression'],
            'parameters': json.loads(row['parameters']) if row['parameters'] else {},
            'enabled': bool(row['enabled']),
            'created_at': row['created_at'],
            'updated_at': row['updated_at'],
            'last_run': row['last_run'],
            'next_run': row['next_run'],
            'run_count': row['run_count'],
            'last_status': row['last_status'],
            'description': row['description']
        }

