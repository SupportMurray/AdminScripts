"""
Script Parser - Extracts metadata from PowerShell scripts
"""

import subprocess
import re
import logging
from pathlib import Path
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)


class ScriptParser:
    """Parses PowerShell script metadata"""
    
    def __init__(self, pwsh_path: str = 'pwsh'):
        self.pwsh_path = pwsh_path
    
    def parse_script_metadata(self, script_path: str) -> Dict:
        """Parse script metadata using Get-Help and manual parsing"""
        metadata = {
            'synopsis': '',
            'description': '',
            'parameters': [],
            'examples': [],
            'notes': '',
            'author': '',
            'version': '',
            'requires': []
        }
        
        try:
            # Resolve to absolute path
            from pathlib import Path
            full_path = str(Path(script_path).resolve())
            
            # Try using Get-Help
            help_data = self._get_help(full_path)
            if help_data:
                metadata.update(help_data)
            
            # Also parse file directly for additional info
            file_data = self._parse_file(full_path)
            
            # Merge file data (file data takes precedence if Get-Help failed)
            for key, value in file_data.items():
                if value and not metadata.get(key):
                    metadata[key] = value
            
        except Exception as e:
            logger.debug(f"Error parsing script metadata for {script_path}: {e}")
        
        return metadata
    
    def _get_help(self, script_path: str) -> Optional[Dict]:
        """Get script help using PowerShell Get-Help"""
        try:
            # Run Get-Help command
            cmd = [
                self.pwsh_path,
                '-NoProfile',
                '-Command',
                f"Get-Help -Full '{script_path}' | ConvertTo-Json -Depth 5"
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode != 0:
                logger.debug(f"Get-Help failed for {script_path}: {result.stderr}")
                return None
            
            import json
            help_data = json.loads(result.stdout)
            
            # Extract relevant information
            metadata = {}
            
            # Synopsis
            if 'Synopsis' in help_data:
                metadata['synopsis'] = help_data['Synopsis'].strip()
            
            # Description
            if 'Description' in help_data:
                desc = help_data['Description']
                if isinstance(desc, list):
                    metadata['description'] = '\n'.join(d.get('Text', '') for d in desc)
                elif isinstance(desc, dict):
                    metadata['description'] = desc.get('Text', '')
                else:
                    metadata['description'] = str(desc)
            
            # Parameters
            if 'Parameters' in help_data and help_data['Parameters']:
                params = []
                for param in help_data['Parameters'].get('Parameter', []):
                    param_info = {
                        'name': param.get('Name', ''),
                        'type': param.get('ParameterValue', 'string'),
                        'description': '',
                        'mandatory': param.get('Required', 'false').lower() == 'true',
                        'default': param.get('DefaultValue', ''),
                        'valid_values': []
                    }
                    
                    # Get description
                    if 'Description' in param:
                        desc = param['Description']
                        if isinstance(desc, list):
                            param_info['description'] = '\n'.join(d.get('Text', '') for d in desc)
                        elif isinstance(desc, dict):
                            param_info['description'] = desc.get('Text', '')
                    
                    params.append(param_info)
                
                metadata['parameters'] = params
            
            # Examples
            if 'Examples' in help_data and help_data['Examples']:
                examples = []
                for example in help_data['Examples'].get('Example', []):
                    examples.append({
                        'title': example.get('Title', ''),
                        'code': example.get('Code', ''),
                        'remarks': example.get('Remarks', '')
                    })
                metadata['examples'] = examples
            
            return metadata
            
        except Exception as e:
            logger.debug(f"Error running Get-Help: {e}")
            return None
    
    def _parse_file(self, script_path: str) -> Dict:
        """Parse script file directly for metadata"""
        metadata = {
            'synopsis': '',
            'description': '',
            'parameters': [],
            'author': '',
            'version': '',
            'requires': []
        }
        
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract comment-based help block
            help_block = self._extract_help_block(content)
            
            if help_block:
                # Parse synopsis
                synopsis_match = re.search(r'\.SYNOPSIS\s+(.+?)(?=\.|$)', help_block, re.DOTALL | re.IGNORECASE)
                if synopsis_match:
                    metadata['synopsis'] = synopsis_match.group(1).strip()
                
                # Parse description
                desc_match = re.search(r'\.DESCRIPTION\s+(.+?)(?=\.|$)', help_block, re.DOTALL | re.IGNORECASE)
                if desc_match:
                    metadata['description'] = desc_match.group(1).strip()
                
                # Parse notes
                notes_match = re.search(r'\.NOTES\s+(.+?)(?=\.|#>|$)', help_block, re.DOTALL | re.IGNORECASE)
                if notes_match:
                    notes = notes_match.group(1).strip()
                    metadata['notes'] = notes
                    
                    # Extract author
                    author_match = re.search(r'Author:\s*(.+)', notes, re.IGNORECASE)
                    if author_match:
                        metadata['author'] = author_match.group(1).strip()
                    
                    # Extract version
                    version_match = re.search(r'Version:\s*(.+)', notes, re.IGNORECASE)
                    if version_match:
                        metadata['version'] = version_match.group(1).strip()
            
            # Parse parameters from param block
            param_block = self._extract_param_block(content)
            if param_block:
                metadata['parameters'] = self._parse_parameters(param_block)
            
            # Extract requires statements
            requires = re.findall(r'#Requires\s+-(.+)', content, re.IGNORECASE)
            metadata['requires'] = [r.strip() for r in requires]
            
        except Exception as e:
            logger.warning(f"Error parsing file {script_path}: {e}")
        
        return metadata
    
    def _extract_help_block(self, content: str) -> Optional[str]:
        """Extract comment-based help block"""
        match = re.search(r'<#\s*(.+?)\s*#>', content, re.DOTALL)
        if match:
            return match.group(1)
        return None
    
    def _extract_param_block(self, content: str) -> Optional[str]:
        """Extract param block"""
        match = re.search(r'param\s*\((.*?)\)', content, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1)
        return None
    
    def _parse_parameters(self, param_block: str) -> List[Dict]:
        """Parse parameters from param block"""
        parameters = []
        
        # Split by [Parameter(...)] attributes
        param_sections = re.split(r'\[Parameter\([^\]]*\)\]', param_block)
        
        for section in param_sections:
            if not section.strip():
                continue
            
            # Extract parameter definition
            param_match = re.search(r'\[([^\]]+)\]\s*\$(\w+)', section)
            if param_match:
                param_type = param_match.group(1)
                param_name = param_match.group(2)
                
                # Check if mandatory
                mandatory = 'Mandatory=$true' in section or 'Mandatory = $true' in section
                
                # Extract ValidateSet values
                validate_match = re.search(r'\[ValidateSet\((.*?)\)\]', section)
                valid_values = []
                if validate_match:
                    values_str = validate_match.group(1)
                    valid_values = [v.strip().strip("'\"") for v in values_str.split(',')]
                
                parameters.append({
                    'name': param_name,
                    'type': param_type,
                    'mandatory': mandatory,
                    'valid_values': valid_values,
                    'description': '',
                    'default': ''
                })
        
        return parameters

