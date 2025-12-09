"""
Script Scanner - Automatically discovers PowerShell scripts
"""

import os
import logging
from pathlib import Path
from typing import List, Dict

logger = logging.getLogger(__name__)


class ScriptScanner:
    """Scans Scripts directory for PowerShell scripts"""
    
    # Category definitions with icons and labels
    CATEGORIES = {
        'User_Administration': {
            'key': 'User',
            'label': 'User Administration',
            'icon': 'people',
            'description': 'User management scripts'
        },
        'Exchange_Administration': {
            'key': 'Exchange',
            'label': 'Exchange Administration',
            'icon': 'email',
            'description': 'Exchange and mailbox scripts'
        },
        'SharePoint_Administration': {
            'key': 'SharePoint',
            'label': 'SharePoint Administration',
            'icon': 'folder',
            'description': 'SharePoint and OneDrive scripts'
        },
        'Teams_Administration': {
            'key': 'Teams',
            'label': 'Teams Administration',
            'icon': 'forum',
            'description': 'Microsoft Teams scripts'
        },
        'Security_Administration': {
            'key': 'Security',
            'label': 'Security Administration',
            'icon': 'security',
            'description': 'Security and compliance scripts'
        },
        'License_Administration': {
            'key': 'License',
            'label': 'License Administration',
            'icon': 'assignment',
            'description': 'License management scripts'
        },
        'Compliance_Administration': {
            'key': 'Compliance',
            'label': 'Compliance Administration',
            'icon': 'verified_user',
            'description': 'Compliance and governance scripts'
        },
        'Audit_Administration': {
            'key': 'Audit',
            'label': 'Audit Administration',
            'icon': 'assessment',
            'description': 'Auditing and reporting scripts'
        },
        'Intune_Administration': {
            'key': 'Intune',
            'label': 'Intune/MDM Administration',
            'icon': 'phone_android',
            'description': 'Intune and device management scripts'
        },
        'Global_Administration': {
            'key': 'Global',
            'label': 'Global Administration',
            'icon': 'settings',
            'description': 'Global and tenant-wide scripts'
        },
        'UI_Administration': {
            'key': 'UI',
            'label': 'UI Administration',
            'icon': 'dashboard',
            'description': 'Dashboard and UI scripts'
        },
        'Utilities': {
            'key': 'Utilities',
            'label': 'Utilities',
            'icon': 'build',
            'description': 'Helper and utility scripts'
        }
    }
    
    def __init__(self, scripts_directory: str):
        self.scripts_directory = Path(scripts_directory).resolve()
        logger.info(f"ScriptScanner initialized: {self.scripts_directory}")
    
    def scan_scripts(self) -> List[Dict]:
        """Scan for all PowerShell scripts"""
        scripts = []
        
        if not self.scripts_directory.exists():
            logger.warning(f"Scripts directory does not exist: {self.scripts_directory}")
            return scripts
        
        try:
            # Walk through all subdirectories
            for category_dir in self.scripts_directory.iterdir():
                if not category_dir.is_dir():
                    continue
                
                if category_dir.name.startswith('.') or category_dir.name == '__pycache__':
                    continue
                
                category_name = category_dir.name
                category_info = self.CATEGORIES.get(category_name, {
                    'key': category_name,
                    'label': category_name.replace('_', ' '),
                    'icon': 'folder',
                    'description': ''
                })
                
                # Find all .ps1 files in this category
                for script_file in category_dir.glob('*.ps1'):
                    try:
                        stat = script_file.stat()
                        
                        # Get relative path from Scripts directory
                        relative_path = script_file.relative_to(self.scripts_directory)
                        
                        scripts.append({
                            'name': script_file.stem,
                            'filename': script_file.name,
                            'path': str(relative_path),
                            'full_path': str(script_file),
                            'category': category_info['key'],
                            'category_label': category_info['label'],
                            'category_icon': category_info['icon'],
                            'size': stat.st_size,
                            'modified': stat.st_mtime,
                            'created': stat.st_ctime
                        })
                        
                    except Exception as e:
                        logger.warning(f"Error processing script {script_file}: {e}")
                        continue
            
            logger.info(f"Found {len(scripts)} scripts")
            return scripts
            
        except Exception as e:
            logger.error(f"Error scanning scripts: {e}", exc_info=True)
            return scripts
    
    def get_categories(self) -> List[Dict]:
        """Get list of all categories with script counts"""
        categories = []
        
        try:
            scripts = self.scan_scripts()
            
            # Count scripts per category
            category_counts = {}
            for script in scripts:
                category = script['category']
                category_counts[category] = category_counts.get(category, 0) + 1
            
            # Build category list
            for category_dir_name, category_info in self.CATEGORIES.items():
                category_key = category_info['key']
                categories.append({
                    'key': category_key,
                    'label': category_info['label'],
                    'icon': category_info['icon'],
                    'description': category_info['description'],
                    'count': category_counts.get(category_key, 0)
                })
            
            # Sort by label
            categories.sort(key=lambda x: x['label'])
            
            return categories
            
        except Exception as e:
            logger.error(f"Error getting categories: {e}", exc_info=True)
            return []
    
    def find_script(self, script_name: str) -> Dict:
        """Find a script by name"""
        scripts = self.scan_scripts()
        for script in scripts:
            if script['name'] == script_name or script['filename'] == script_name:
                return script
        return None
    
    def get_scripts_by_category(self, category: str) -> List[Dict]:
        """Get all scripts in a specific category"""
        scripts = self.scan_scripts()
        return [s for s in scripts if s['category'] == category]

