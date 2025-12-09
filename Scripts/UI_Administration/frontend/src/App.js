import React, { useState, useEffect, useCallback } from 'react';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
  CssBaseline, Box, AppBar, Toolbar, Typography, Drawer, List, ListItem,
  ListItemButton, ListItemIcon, ListItemText, Grid, Card,
  CardContent, Button, TextField, Select, MenuItem, FormControl,
  InputLabel, Chip, Alert, CircularProgress, Paper, Divider, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, Switch, FormControlLabel,
  Tooltip, Table, TableBody, TableCell, TableContainer, TableHead, TableRow
} from '@mui/material';
import {
  Dashboard as DashboardIcon, People, Email, Folder, Forum, Security,
  Assignment, VerifiedUser, Assessment, PhoneAndroid, Settings,
  PlayArrow, History, Refresh, Menu as MenuIcon,
  DarkMode, LightMode, Close, Schedule, Add, Delete, Edit,
  PowerSettingsNew, Build
} from '@mui/icons-material';

// Use relative URL for production (nginx proxy), absolute for development
const API_BASE = process.env.NODE_ENV === 'production' ? '' : 'http://localhost:5001';
const drawerWidth = 240;

// Material UI Theme
const lightTheme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#1976d2' },
    success: { main: '#2e7d32' },
    warning: { main: '#ed6c02' },
    error: { main: '#d32f2f' },
    info: { main: '#0288d1' }
  }
});

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: { main: '#90caf9' },
    success: { main: '#66bb6a' },
    warning: { main: '#ffa726' },
    error: { main: '#f44336' },
    info: { main: '#29b6f6' }
  }
});

const categoryIcons = {
  'User': <People />,
  'Exchange': <Email />,
  'SharePoint': <Folder />,
  'Teams': <Forum />,
  'Security': <Security />,
  'License': <Assignment />,
  'Compliance': <VerifiedUser />,
  'Audit': <Assessment />,
  'Intune': <PhoneAndroid />,
  'Global': <Settings />,
  'UI': <DashboardIcon />,
  'Utilities': <Build />
};

function App() {
  const [darkMode, setDarkMode] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [currentView, setCurrentView] = useState('dashboard');
  const [categories, setCategories] = useState([]);
  const [scripts, setScripts] = useState([]);
  const [executions, setExecutions] = useState([]);
  const [statistics, setStatistics] = useState({});
  const [loading, setLoading] = useState(true);
  const [selectedScript, setSelectedScript] = useState(null);
  const [scriptDetails, setScriptDetails] = useState(null);
  const [executeDialogOpen, setExecuteDialogOpen] = useState(false);
  const [parameters, setParameters] = useState({});
  const [executing, setExecuting] = useState(false);
  const [executionOutput, setExecutionOutput] = useState('');
  const [error, setError] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('all');
  
  // Schedule state
  const [schedules, setSchedules] = useState([]);
  const [scheduleDialogOpen, setScheduleDialogOpen] = useState(false);
  const [schedulePresets, setSchedulePresets] = useState([]);
  const [editingSchedule, setEditingSchedule] = useState(null);
  const [scheduleForm, setScheduleForm] = useState({
    name: '',
    script_path: '',
    cron_expression: '',
    description: '',
    enabled: true
  });
  const [cronValidation, setCronValidation] = useState(null);

  const theme = darkMode ? darkTheme : lightTheme;

  // API Functions
  const loadCategories = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE}/api/categories`);
      const data = await response.json();
      if (data.success) {
        setCategories(data.categories || []);
      }
    } catch (err) {
      console.error('Error loading categories:', err);
    }
  }, []);

  const loadScripts = useCallback(async (category = null) => {
    try {
      const url = category && category !== 'all' 
        ? `${API_BASE}/api/scripts?category=${category}`
        : `${API_BASE}/api/scripts`;
      const response = await fetch(url);
      const data = await response.json();
      if (data.success) {
        setScripts(data.scripts || []);
      }
    } catch (err) {
      console.error('Error loading scripts:', err);
    }
  }, []);

  const loadStatistics = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE}/api/statistics`);
      const data = await response.json();
      if (data.success) {
        setStatistics(data.statistics || {});
      }
    } catch (err) {
      console.error('Error loading statistics:', err);
    }
  }, []);

  const loadExecutions = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE}/api/executions?limit=10`);
      const data = await response.json();
      if (data.success) {
        setExecutions(data.executions || []);
      }
    } catch (err) {
      console.error('Error loading executions:', err);
    }
  }, []);

  const loadSchedules = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE}/api/schedules`);
      const data = await response.json();
      if (data.success) {
        setSchedules(data.schedules || []);
      }
    } catch (err) {
      console.error('Error loading schedules:', err);
    }
  }, []);

  const loadSchedulePresets = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE}/api/schedules/presets`);
      const data = await response.json();
      if (data.success) {
        setSchedulePresets(data.presets || []);
      }
    } catch (err) {
      console.error('Error loading presets:', err);
    }
  }, []);

  // Initial data load
  useEffect(() => {
    const loadAllData = async () => {
      setLoading(true);
      try {
        await Promise.all([
          loadCategories(),
          loadScripts(),
          loadStatistics(),
          loadExecutions(),
          loadSchedules(),
          loadSchedulePresets()
        ]);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    loadAllData();
  }, [loadCategories, loadScripts, loadStatistics, loadExecutions, loadSchedules, loadSchedulePresets]);

  const handleCategoryClick = async (category) => {
    setSelectedCategory(category);
    await loadScripts(category);
    setCurrentView('scripts');
  };

  const handleScriptClick = async (script) => {
    setSelectedScript(script);
    try {
      const response = await fetch(`${API_BASE}/api/scripts/${encodeURIComponent(script.path)}`);
      const data = await response.json();
      if (data.success) {
        setScriptDetails(data.script);
      } else {
        setScriptDetails(script);
      }
      setParameters({});
      setExecutionOutput('');
      setExecuteDialogOpen(true);
    } catch (err) {
      setScriptDetails(script);
      setExecuteDialogOpen(true);
    }
  };

  const handleExecuteScript = async () => {
    if (!selectedScript) return;

    setExecuting(true);
    setExecutionOutput('Starting script execution...\n');
    setError(null);

    try {
      const response = await fetch(`${API_BASE}/api/execute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          script_path: selectedScript.path,
          parameters: parameters
        })
      });

      const data = await response.json();

      if (data.success) {
        const output = data.result.stdout || 'Script executed successfully!\n';
        const errorOutput = data.result.stderr ? `\nErrors:\n${data.result.stderr}` : '';
        setExecutionOutput(output + errorOutput);
        loadExecutions();
        loadStatistics();
      } else {
        setError(data.error || 'Execution failed');
        setExecutionOutput(`Error: ${data.error}`);
      }
    } catch (err) {
      setError(err.message);
      setExecutionOutput(`Error: ${err.message}`);
    } finally {
      setExecuting(false);
    }
  };

  const handleParameterChange = (paramName, value) => {
    setParameters(prev => ({ ...prev, [paramName]: value }));
  };

  // Schedule handlers
  const handleOpenScheduleDialog = (schedule = null) => {
    if (schedule) {
      setEditingSchedule(schedule);
      setScheduleForm({
        name: schedule.name,
        script_path: schedule.script_path,
        cron_expression: schedule.cron_expression,
        description: schedule.description || '',
        enabled: schedule.enabled
      });
    } else {
      setEditingSchedule(null);
      setScheduleForm({
        name: '',
        script_path: '',
        cron_expression: '0 9 * * *',
        description: '',
        enabled: true
      });
    }
    setCronValidation(null);
    setScheduleDialogOpen(true);
  };

  const handleScheduleFormChange = (field, value) => {
    setScheduleForm(prev => ({ ...prev, [field]: value }));
    if (field === 'cron_expression') {
      validateCron(value);
    }
  };

  const validateCron = async (expression) => {
    try {
      const response = await fetch(`${API_BASE}/api/schedules/validate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ expression })
      });
      const data = await response.json();
      setCronValidation(data);
    } catch (err) {
      setCronValidation({ valid: false, error: err.message });
    }
  };

  const handleSaveSchedule = async () => {
    try {
      const url = editingSchedule 
        ? `${API_BASE}/api/schedules/${editingSchedule.id}`
        : `${API_BASE}/api/schedules`;
      
      const response = await fetch(url, {
        method: editingSchedule ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(scheduleForm)
      });

      const data = await response.json();

      if (data.success) {
        setScheduleDialogOpen(false);
        loadSchedules();
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const handleDeleteSchedule = async (scheduleId) => {
    if (!window.confirm('Are you sure you want to delete this schedule?')) return;

    try {
      const response = await fetch(`${API_BASE}/api/schedules/${scheduleId}`, {
        method: 'DELETE'
      });

      const data = await response.json();

      if (data.success) {
        loadSchedules();
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const handleToggleSchedule = async (scheduleId, enabled) => {
    try {
      const response = await fetch(`${API_BASE}/api/schedules/${scheduleId}/toggle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ enabled })
      });

      const data = await response.json();

      if (data.success) {
        loadSchedules();
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError(err.message);
    }
  };

  const drawer = (
    <Box>
      <Toolbar>
        <Typography variant="h6" noWrap sx={{ fontWeight: 'bold' }}>
          M365 Admin
        </Typography>
      </Toolbar>
      <Divider />
      <List>
        <ListItem disablePadding>
          <ListItemButton 
            selected={currentView === 'dashboard'}
            onClick={() => setCurrentView('dashboard')}
          >
            <ListItemIcon><DashboardIcon /></ListItemIcon>
            <ListItemText primary="Dashboard" />
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton 
            selected={currentView === 'schedules'}
            onClick={() => setCurrentView('schedules')}
          >
            <ListItemIcon><Schedule /></ListItemIcon>
            <ListItemText primary="Schedules" />
            {schedules.length > 0 && (
              <Chip size="small" label={schedules.length} color="primary" />
            )}
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton 
            selected={currentView === 'history'}
            onClick={() => setCurrentView('history')}
          >
            <ListItemIcon><History /></ListItemIcon>
            <ListItemText primary="History" />
          </ListItemButton>
        </ListItem>
      </List>
      <Divider />
      <List>
        <ListItem>
          <ListItemText 
            primary="Categories" 
            secondary={`${categories.filter(c => c.count > 0).length} with scripts`} 
          />
        </ListItem>
        {categories.map((cat) => (
          <ListItem key={cat.key} disablePadding>
            <ListItemButton 
              selected={selectedCategory === cat.key && currentView === 'scripts'}
              onClick={() => handleCategoryClick(cat.key)}
            >
              <ListItemIcon>{categoryIcons[cat.key] || <Folder />}</ListItemIcon>
              <ListItemText 
                primary={cat.label} 
                secondary={`${cat.count} scripts`}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  );

  const renderDashboard = () => (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Dashboard
      </Typography>
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Total Scripts</Typography>
              <Typography variant="h3" color="primary">
                {statistics.total_scripts || scripts.length || 0}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Scheduled Tasks</Typography>
              <Typography variant="h3" color="primary">
                {schedules.filter(s => s.enabled).length}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Total Executions</Typography>
              <Typography variant="h3" color="primary">
                {statistics.total_executions || 0}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Success Rate</Typography>
              <Typography variant="h3" color="success.main">
                {statistics.success_rate || 0}%
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Typography variant="h5" gutterBottom sx={{ fontWeight: 'bold', mt: 4 }}>
        Recent Executions
      </Typography>
      <Paper elevation={2}>
        {executions.length === 0 ? (
          <Box p={4} textAlign="center">
            <Typography color="textSecondary">No executions yet. Run a script to see history here.</Typography>
          </Box>
        ) : (
          executions.map((exec) => (
            <Box key={exec.id} p={2} borderBottom={1} borderColor="divider">
              <Grid container spacing={2} alignItems="center">
                <Grid item xs={12} sm={5}>
                  <Typography variant="subtitle1" fontWeight="medium">{exec.script_name}</Typography>
                  <Typography variant="caption" color="textSecondary">
                    {new Date(exec.started_at).toLocaleString()}
                  </Typography>
                </Grid>
                <Grid item xs={6} sm={3}>
                  <Chip 
                    label={exec.status} 
                    color={exec.status === 'success' ? 'success' : 'error'}
                    size="small"
                  />
                </Grid>
                <Grid item xs={6} sm={4}>
                  <Typography variant="body2">
                    Duration: {exec.duration_seconds ? `${exec.duration_seconds.toFixed(2)}s` : 'N/A'}
                  </Typography>
                </Grid>
              </Grid>
            </Box>
          ))
        )}
      </Paper>

      <Box mt={4}>
        <Typography variant="h5" gutterBottom sx={{ fontWeight: 'bold' }}>
          Quick Actions
        </Typography>
        <Grid container spacing={2}>
          <Grid item>
            <Button 
              variant="contained" 
              startIcon={<Schedule />}
              onClick={() => setCurrentView('schedules')}
            >
              Manage Schedules
            </Button>
          </Grid>
          <Grid item>
            <Button 
              variant="contained" 
              startIcon={<Security />}
              onClick={() => handleCategoryClick('Security')}
            >
              Security Scripts
            </Button>
          </Grid>
          <Grid item>
            <Button 
              variant="contained" 
              startIcon={<Assessment />}
              onClick={() => handleCategoryClick('Audit')}
            >
              Audit Scripts
            </Button>
          </Grid>
          <Grid item>
            <Button 
              variant="outlined" 
              startIcon={<Refresh />}
              onClick={() => {
                loadCategories();
                loadScripts();
                loadStatistics();
                loadExecutions();
                loadSchedules();
              }}
            >
              Refresh All
            </Button>
          </Grid>
        </Grid>
      </Box>
    </Box>
  );

  const renderSchedules = () => (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" sx={{ fontWeight: 'bold' }}>
          <Schedule sx={{ mr: 1, verticalAlign: 'bottom' }} />
          Scheduled Tasks
        </Typography>
        <Box>
          <Button 
            startIcon={<Refresh />} 
            onClick={loadSchedules}
            sx={{ mr: 2 }}
          >
            Refresh
          </Button>
          <Button 
            variant="contained"
            startIcon={<Add />}
            onClick={() => handleOpenScheduleDialog()}
          >
            New Schedule
          </Button>
        </Box>
      </Box>

      {schedules.length === 0 ? (
        <Paper elevation={2} sx={{ p: 4, textAlign: 'center' }}>
          <Schedule sx={{ fontSize: 60, color: 'text.secondary', mb: 2 }} />
          <Typography variant="h6" color="textSecondary" gutterBottom>
            No Scheduled Tasks
          </Typography>
          <Typography color="textSecondary" paragraph>
            Create a schedule to automatically run scripts on a cron schedule.
          </Typography>
          <Button 
            variant="contained" 
            startIcon={<Add />}
            onClick={() => handleOpenScheduleDialog()}
          >
            Create First Schedule
          </Button>
        </Paper>
      ) : (
        <TableContainer component={Paper} elevation={2}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Status</TableCell>
                <TableCell>Name</TableCell>
                <TableCell>Script</TableCell>
                <TableCell>Schedule</TableCell>
                <TableCell>Next Run</TableCell>
                <TableCell>Last Status</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {schedules.map((schedule) => (
                <TableRow key={schedule.id} hover>
                  <TableCell>
                    <Switch
                      checked={schedule.enabled}
                      onChange={(e) => handleToggleSchedule(schedule.id, e.target.checked)}
                      color="success"
                    />
                  </TableCell>
                  <TableCell>
                    <Typography fontWeight="medium">{schedule.name}</Typography>
                    {schedule.description && (
                      <Typography variant="caption" color="textSecondary" display="block">
                        {schedule.description}
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={schedule.script_name} 
                      size="small"
                      icon={categoryIcons[schedule.category] || <Folder />}
                    />
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" fontFamily="monospace">
                      {schedule.cron_expression}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    {schedule.enabled && schedule.next_run ? (
                      <Typography variant="body2">
                        {new Date(schedule.next_run).toLocaleString()}
                      </Typography>
                    ) : (
                      <Typography variant="body2" color="textSecondary">
                        {schedule.enabled ? 'Calculating...' : 'Disabled'}
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    {schedule.last_status ? (
                      <Chip 
                        label={schedule.last_status}
                        size="small"
                        color={schedule.last_status === 'success' ? 'success' : 'error'}
                      />
                    ) : (
                      <Typography variant="body2" color="textSecondary">Never run</Typography>
                    )}
                  </TableCell>
                  <TableCell align="right">
                    <Tooltip title="Edit">
                      <IconButton 
                        size="small" 
                        onClick={() => handleOpenScheduleDialog(schedule)}
                      >
                        <Edit />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title="Delete">
                      <IconButton 
                        size="small" 
                        color="error"
                        onClick={() => handleDeleteSchedule(schedule.id)}
                      >
                        <Delete />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );

  const renderScripts = () => (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" sx={{ fontWeight: 'bold' }}>
          {selectedCategory === 'all' ? 'All Scripts' : `${selectedCategory} Scripts`}
        </Typography>
        <Button 
          startIcon={<Refresh />} 
          onClick={() => loadScripts(selectedCategory)}
          variant="outlined"
        >
          Refresh
        </Button>
      </Box>
      
      {scripts.length === 0 ? (
        <Paper elevation={2} sx={{ p: 4, textAlign: 'center' }}>
          <Typography color="textSecondary">
            No scripts found in this category. Scripts will appear here when added to the Scripts directory.
          </Typography>
        </Paper>
      ) : (
        <Grid container spacing={3}>
          {scripts.filter(script => 
            selectedCategory === 'all' || script.category === selectedCategory
          ).map((script) => (
            <Grid item xs={12} sm={6} md={4} key={script.path}>
              <Card elevation={3} sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box display="flex" alignItems="center" mb={1}>
                    {categoryIcons[script.category] || <Folder />}
                    <Typography variant="h6" sx={{ ml: 1, fontWeight: 'medium' }}>
                      {script.name}
                    </Typography>
                  </Box>
                  <Typography variant="body2" color="textSecondary" sx={{ mb: 2, minHeight: 40 }}>
                    {script.synopsis || script.description || 'PowerShell automation script'}
                  </Typography>
                  <Chip 
                    label={script.category_label || script.category} 
                    size="small" 
                    color="primary"
                    variant="outlined"
                  />
                </CardContent>
                <Box p={2} pt={0} display="flex" gap={1}>
                  <Button 
                    variant="contained" 
                    startIcon={<PlayArrow />}
                    onClick={() => handleScriptClick(script)}
                    sx={{ flex: 1 }}
                  >
                    Run
                  </Button>
                  <Tooltip title="Schedule this script">
                    <Button
                      variant="outlined"
                      onClick={() => {
                        setScheduleForm(prev => ({ ...prev, script_path: script.path, name: `${script.name} Schedule` }));
                        setScheduleDialogOpen(true);
                      }}
                    >
                      <Schedule />
                    </Button>
                  </Tooltip>
                </Box>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}
    </Box>
  );

  const renderHistory = () => (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" sx={{ fontWeight: 'bold' }}>Execution History</Typography>
        <Button startIcon={<Refresh />} onClick={loadExecutions} variant="outlined">
          Refresh
        </Button>
      </Box>
      <Paper elevation={2}>
        {executions.length === 0 ? (
          <Box p={4} textAlign="center">
            <Typography color="textSecondary">No executions yet</Typography>
          </Box>
        ) : (
          executions.map((exec) => (
            <Box key={exec.id} p={2} borderBottom={1} borderColor="divider">
              <Grid container spacing={2} alignItems="center">
                <Grid item xs={12} md={4}>
                  <Typography variant="subtitle1" fontWeight="medium">{exec.script_name}</Typography>
                  <Typography variant="caption" color="textSecondary">
                    {new Date(exec.started_at).toLocaleString()}
                  </Typography>
                </Grid>
                <Grid item xs={6} md={2}>
                  <Chip 
                    label={exec.status} 
                    color={exec.status === 'success' ? 'success' : 'error'}
                    size="small"
                  />
                </Grid>
                <Grid item xs={6} md={2}>
                  <Typography variant="body2">
                    {exec.duration_seconds ? `${exec.duration_seconds.toFixed(2)}s` : 'N/A'}
                  </Typography>
                </Grid>
                <Grid item xs={12} md={4}>
                  <Typography variant="body2" color="textSecondary" noWrap>
                    {exec.category || 'Unknown category'}
                  </Typography>
                </Grid>
              </Grid>
            </Box>
          ))
        )}
      </Paper>
    </Box>
  );

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Box sx={{ display: 'flex' }}>
        <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
          <Toolbar>
            <IconButton
              color="inherit"
              edge="start"
              onClick={() => setMobileOpen(!mobileOpen)}
              sx={{ mr: 2, display: { sm: 'none' } }}
            >
              <MenuIcon />
            </IconButton>
            <DashboardIcon sx={{ mr: 2 }} />
            <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
              M365 Admin Dashboard
            </Typography>
            <IconButton color="inherit" onClick={() => setDarkMode(!darkMode)}>
              {darkMode ? <LightMode /> : <DarkMode />}
            </IconButton>
          </Toolbar>
        </AppBar>

        <Drawer
          variant="permanent"
          sx={{
            width: drawerWidth,
            flexShrink: 0,
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { width: drawerWidth, boxSizing: 'border-box' },
          }}
        >
          <Toolbar />
          {drawer}
        </Drawer>

        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={() => setMobileOpen(false)}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { width: drawerWidth, boxSizing: 'border-box' },
          }}
        >
          <Toolbar />
          {drawer}
        </Drawer>

        <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
          <Toolbar />
          {loading ? (
            <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
              <CircularProgress size={60} />
            </Box>
          ) : (
            <>
              {error && (
                <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
                  {error}
                </Alert>
              )}
              {currentView === 'dashboard' && renderDashboard()}
              {currentView === 'scripts' && renderScripts()}
              {currentView === 'history' && renderHistory()}
              {currentView === 'schedules' && renderSchedules()}
            </>
          )}
        </Box>
      </Box>

      {/* Execute Script Dialog */}
      <Dialog 
        open={executeDialogOpen} 
        onClose={() => !executing && setExecuteDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6">
            Execute: {selectedScript?.name}
          </Typography>
          <IconButton
            onClick={() => !executing && setExecuteDialogOpen(false)}
            disabled={executing}
            size="small"
          >
            <Close />
          </IconButton>
        </DialogTitle>
        <DialogContent dividers>
          {scriptDetails && (
            <Box mb={3}>
              <Typography variant="body1" color="textSecondary" paragraph>
                {scriptDetails.synopsis || scriptDetails.description || 'PowerShell automation script'}
              </Typography>
              
              {scriptDetails.parameters && scriptDetails.parameters.length > 0 && (
                <Box mt={3}>
                  <Typography variant="h6" gutterBottom>Parameters</Typography>
                  {scriptDetails.parameters.map((param) => (
                    <Box key={param.name} mb={2}>
                      {param.valid_values && param.valid_values.length > 0 ? (
                        <FormControl fullWidth>
                          <InputLabel>{param.name}{param.mandatory ? ' *' : ''}</InputLabel>
                          <Select
                            value={parameters[param.name] || ''}
                            label={param.name}
                            onChange={(e) => handleParameterChange(param.name, e.target.value)}
                          >
                            <MenuItem value="">-- Select --</MenuItem>
                            {param.valid_values.map((val) => (
                              <MenuItem key={val} value={val}>{val}</MenuItem>
                            ))}
                          </Select>
                        </FormControl>
                      ) : (
                        <TextField
                          fullWidth
                          label={`${param.name}${param.mandatory ? ' *' : ''}`}
                          helperText={param.description || `Type: ${param.type || 'string'}`}
                          required={param.mandatory}
                          value={parameters[param.name] || ''}
                          onChange={(e) => handleParameterChange(param.name, e.target.value)}
                        />
                      )}
                    </Box>
                  ))}
                </Box>
              )}
            </Box>
          )}
          
          {executionOutput && (
            <Box mt={2}>
              <Typography variant="h6" gutterBottom>Output</Typography>
              <Paper 
                sx={{ 
                  p: 2, 
                  bgcolor: darkMode ? 'grey.900' : 'grey.100', 
                  maxHeight: 400, 
                  overflow: 'auto' 
                }}
              >
                <Typography 
                  component="pre" 
                  variant="body2" 
                  sx={{ 
                    fontFamily: 'monospace', 
                    whiteSpace: 'pre-wrap',
                    wordBreak: 'break-word',
                    m: 0
                  }}
                >
                  {executionOutput}
                </Typography>
              </Paper>
            </Box>
          )}
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button 
            onClick={() => setExecuteDialogOpen(false)} 
            disabled={executing}
          >
            {executionOutput ? 'Close' : 'Cancel'}
          </Button>
          <Button 
            variant="contained" 
            onClick={handleExecuteScript}
            disabled={executing}
            startIcon={executing ? <CircularProgress size={20} color="inherit" /> : <PlayArrow />}
            color="primary"
          >
            {executing ? 'Executing...' : 'Execute Script'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Schedule Dialog */}
      <Dialog 
        open={scheduleDialogOpen} 
        onClose={() => setScheduleDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          {editingSchedule ? 'Edit Schedule' : 'Create Schedule'}
        </DialogTitle>
        <DialogContent dividers>
          <Box display="flex" flexDirection="column" gap={3} pt={1}>
            <TextField
              label="Schedule Name"
              fullWidth
              required
              value={scheduleForm.name}
              onChange={(e) => handleScheduleFormChange('name', e.target.value)}
              placeholder="e.g., Daily Security Audit"
            />

            <FormControl fullWidth required>
              <InputLabel>Script</InputLabel>
              <Select
                value={scheduleForm.script_path}
                label="Script"
                onChange={(e) => handleScheduleFormChange('script_path', e.target.value)}
              >
                {scripts.map((script) => (
                  <MenuItem key={script.path} value={script.path}>
                    {script.name} ({script.category})
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <Box>
              <Typography variant="subtitle2" gutterBottom>
                Schedule (Cron Expression)
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={8}>
                  <TextField
                    fullWidth
                    required
                    value={scheduleForm.cron_expression}
                    onChange={(e) => handleScheduleFormChange('cron_expression', e.target.value)}
                    placeholder="0 9 * * *"
                    helperText="Format: minute hour day month weekday"
                    error={cronValidation && !cronValidation.valid}
                  />
                </Grid>
                <Grid item xs={4}>
                  <FormControl fullWidth size="small">
                    <InputLabel>Presets</InputLabel>
                    <Select
                      value=""
                      label="Presets"
                      onChange={(e) => handleScheduleFormChange('cron_expression', e.target.value)}
                    >
                      {schedulePresets.map((preset) => (
                        <MenuItem key={preset.expression} value={preset.expression}>
                          {preset.label}
                        </MenuItem>
                      ))}
                    </Select>
                  </FormControl>
                </Grid>
              </Grid>
              {cronValidation && (
                <Box mt={1}>
                  {cronValidation.valid ? (
                    <Alert severity="success" sx={{ py: 0 }}>
                      <Typography variant="body2">
                        {cronValidation.description}
                      </Typography>
                      {cronValidation.next_runs && cronValidation.next_runs.length > 0 && (
                        <Typography variant="caption" display="block">
                          Next: {new Date(cronValidation.next_runs[0]).toLocaleString()}
                        </Typography>
                      )}
                    </Alert>
                  ) : (
                    <Alert severity="error" sx={{ py: 0 }}>
                      {cronValidation.error}
                    </Alert>
                  )}
                </Box>
              )}
            </Box>

            <TextField
              label="Description (optional)"
              fullWidth
              multiline
              rows={2}
              value={scheduleForm.description}
              onChange={(e) => handleScheduleFormChange('description', e.target.value)}
              placeholder="What does this schedule do?"
            />

            <FormControlLabel
              control={
                <Switch
                  checked={scheduleForm.enabled}
                  onChange={(e) => handleScheduleFormChange('enabled', e.target.checked)}
                  color="success"
                />
              }
              label={scheduleForm.enabled ? "Schedule is enabled" : "Schedule is disabled"}
            />
          </Box>
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setScheduleDialogOpen(false)}>
            Cancel
          </Button>
          <Button 
            variant="contained"
            onClick={handleSaveSchedule}
            disabled={!scheduleForm.name || !scheduleForm.script_path || !scheduleForm.cron_expression || (cronValidation && !cronValidation.valid)}
            startIcon={<Schedule />}
          >
            {editingSchedule ? 'Update Schedule' : 'Create Schedule'}
          </Button>
        </DialogActions>
      </Dialog>
    </ThemeProvider>
  );
}

export default App;
