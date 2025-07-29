import express from 'express';
import fs from 'fs';
import path from 'path';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';

const router = express.Router();
const isDevelopment = process.env.NODE_ENV !== 'production';
const logsDir = isDevelopment
  ? path.resolve(__dirname, '../../../logs')
  : '/var/log/weltenwind';

// Systemd Service Log-Pfade (nur in Production)
const systemdLogsDir = '/var/log/weltenwind';

// Log-Kategorien definieren
const logCategories = {
  // Winston Structured Logs
  winston: {
    'app.log': 'App (Alle Winston-Logs)',
    'auth.log': 'Auth (Login/Register/Logout)',
    'security.log': 'Security (Rate Limits, CSRF, Lockouts)',  
    'api.log': 'API (Requests/Responses)',
    'error.log': 'Errors (Nur Fehler)'
  },
  // Systemd Service Logs (nur Production)
  services: isDevelopment ? {} : {
    'backend.log': 'Backend Service (stdout)',
    'backend.error.log': 'Backend Service (stderr)',
    'docs.log': 'Documentation Service',
    'studio.log': 'Prisma Studio Service'
  },
  // System Logs (nur Production/Linux)
  system: isDevelopment ? {} : {
    'syslog': 'System Log',
    'auth.log': 'System Auth Log',
    'nginx/access.log': 'Nginx Access',
    'nginx/error.log': 'Nginx Errors'
  }
};

// Alle verfügbaren Log-Dateien sammeln
function getAllLogFiles(): Record<string, string> {
  const allLogs: Record<string, string> = {};
  
  // Winston Logs hinzufügen
  Object.entries(logCategories.winston).forEach(([file, description]) => {
    allLogs[file] = description;
  });
  
  // Service Logs hinzufügen (nur Production)
  if (!isDevelopment) {
    Object.entries(logCategories.services).forEach(([file, description]) => {
      allLogs[file] = description;
    });
    
    // System Logs hinzufügen (nur Production)
    Object.entries(logCategories.system).forEach(([file, description]) => {
      allLogs[file] = description;
    });
  }
  
  return allLogs;
}

// Log-Datei-Pfad auflösen
function resolveLogPath(logFile: string): string {
  // Winston Logs
  if (logFile in logCategories.winston) {
    return path.join(logsDir, logFile);
  }
  
  // Service Logs (nur Production)
  if (!isDevelopment && logFile in logCategories.services) {
    return path.join(systemdLogsDir, logFile);
  }
  
  // System Logs (nur Production)
  if (!isDevelopment && logFile in logCategories.system) {
    if (logFile.startsWith('nginx/')) {
      return path.join('/var/log', logFile);
    }
    return path.join('/var/log', logFile);
  }
  
  // Default: Winston logs
  return path.join(logsDir, logFile);
}

// Log-Viewer (HTML page with integrated login)
router.get('/viewer', async (req, res) => {
  const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Weltenwind Logs</title>
    <meta charset="utf-8">
    <style>
        body { font-family: monospace; margin: 20px; background: #1a1a1a; color: #fff; }
        .login-container { max-width: 400px; margin: 100px auto; padding: 30px; background: #333; border-radius: 10px; text-align: center; }
        .controls { margin-bottom: 20px; padding: 10px; background: #333; border-radius: 5px; }
        select, input, button { margin: 5px; padding: 8px; background: #555; color: #fff; border: 1px solid #777; border-radius: 3px; }
        input[type="text"], input[type="password"] { width: 200px; }
        button { cursor: pointer; }
        button:hover { background: #666; }
        .log-container { background: #222; padding: 15px; border-radius: 5px; height: 70vh; overflow-y: auto; }
        .log-entry { margin: 2px 0; padding: 5px; border-left: 3px solid #555; }
        .log-entry.INFO { border-color: #4CAF50; }
        .log-entry.WARN { border-color: #FF9800; }
        .log-entry.ERROR { border-color: #F44336; }
        .timestamp { color: #888; }
        .module { color: #2196F3; font-weight: bold; }
        .username { color: #4CAF50; }
        .ip { color: #FF9800; }
        .message { color: #fff; }
        .metadata { color: #999; font-size: 0.9em; margin-left: 20px; }
        .hidden { display: none; }
        .error { color: #F44336; margin: 10px 0; }
        .success { color: #4CAF50; margin: 10px 0; }
    </style>
</head>
<body>
    <!-- Login Form -->
    <div id="loginContainer" class="login-container">
        <h1>🔐 Weltenwind Log-Viewer</h1>
        <p>Admin-Login erforderlich</p>
        <div id="loginError" class="error hidden"></div>
        <form id="loginForm">
            <div>
                <input type="text" id="username" placeholder="Username" required>
            </div>
            <div>
                <input type="password" id="password" placeholder="Password" required>
            </div>
            <div>
                <button type="submit">🔓 Anmelden</button>
            </div>
        </form>
    </div>

    <!-- Log Viewer (hidden initially) -->
    <div id="logViewer" class="hidden">
        <h1>🔍 Weltenwind Log Viewer</h1>
        <div style="float: right;">
            <span id="userInfo"></span>
            <button onclick="logout()">🚪 Abmelden</button>
        </div>

        <div class="controls">
            <label>Log-Kategorie:</label>
            <select id="logCategory" onchange="updateLogFiles()">
                <option value="winston">🔧 Winston (Strukturiert)</option>
                <option value="services">⚙️ Services (systemd)</option>
                <option value="system">🖥️ System (Linux)</option>
            </select>

            <label>Log-Datei:</label>
            <select id="logFile" onchange="loadLogs()">
                <option value="app.log">Lade Kategorien...</option>
            </select>

            <label>Filter:</label>
            <input type="text" id="filter" placeholder="Suchbegriff..." onkeyup="filterLogs()">

            <label>Zeilen:</label>
            <select id="lines" onchange="loadLogs()">
                <option value="100">100</option>
                <option value="500">500</option>
                <option value="1000">1000</option>
            </select>

            <button onclick="loadLogs()">🔄 Aktualisieren</button>
            <button onclick="autoRefresh()">⏰ Auto-Refresh</button>
            <button onclick="loadCategories()">📂 Kategorien laden</button>
        </div>

        <div id="logContainer" class="log-container">
            Lade Logs...
        </div>
    </div>

    <script>
        let accessToken = null;
        let autoRefreshInterval = null;
        let availableCategories = {};

        // Check for existing token in localStorage
        window.onload = function() {
            const savedToken = localStorage.getItem('weltenwind_access_token');
            const savedUser = localStorage.getItem('weltenwind_user');

            if (savedToken && savedUser) {
                accessToken = savedToken;
                showLogViewer(JSON.parse(savedUser));
            }
        };

        // Handle login form
        document.getElementById('loginForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const errorDiv = document.getElementById('loginError');

            try {
                const response = await fetch('/api/auth/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ username, password })
                });

                const data = await response.json();

                if (response.ok) {
                    accessToken = data.accessToken;
                    localStorage.setItem('weltenwind_access_token', accessToken);
                    localStorage.setItem('weltenwind_user', JSON.stringify(data.user));
                    showLogViewer(data.user);
                } else {
                    errorDiv.textContent = data.error || 'Login fehlgeschlagen';
                    errorDiv.classList.remove('hidden');
                }
            } catch (error) {
                errorDiv.textContent = 'Verbindungsfehler: ' + error.message;
                errorDiv.classList.remove('hidden');
            }
        });

        function showLogViewer(user) {
            document.getElementById('loginContainer').classList.add('hidden');
            document.getElementById('logViewer').classList.remove('hidden');
            document.getElementById('userInfo').textContent = 'Angemeldet als: ' + user.username;
            
            // Load categories first, then logs
            loadCategories();
        }

        function logout() {
            localStorage.removeItem('weltenwind_access_token');
            localStorage.removeItem('weltenwind_user');
            accessToken = null;

            document.getElementById('logViewer').classList.add('hidden');
            document.getElementById('loginContainer').classList.remove('hidden');
            document.getElementById('loginError').classList.add('hidden');

            if (autoRefreshInterval) {
                clearInterval(autoRefreshInterval);
                autoRefreshInterval = null;
            }
        }

        // Load available log categories from backend
        async function loadCategories() {
            if (!accessToken) return;
            
            try {
                const response = await fetch('/api/logs/categories', {
                    headers: { 'Authorization': 'Bearer ' + accessToken }
                });
                
                if (response.status === 401) {
                    logout();
                    return;
                }
                
                const data = await response.json();
                availableCategories = data.categories;
                
                // Update category dropdown
                const categorySelect = document.getElementById('logCategory');
                categorySelect.innerHTML = '';
                
                if (data.categories.winston && Object.keys(data.categories.winston).length > 0) {
                    categorySelect.innerHTML += '<option value="winston">🔧 Winston (Strukturiert)</option>';
                }
                if (data.categories.services && Object.keys(data.categories.services).length > 0) {
                    categorySelect.innerHTML += '<option value="services">⚙️ Services (systemd)</option>';  
                }
                if (data.categories.system && Object.keys(data.categories.system).length > 0) {
                    categorySelect.innerHTML += '<option value="system">🖥️ System (Linux)</option>';
                }
                
                updateLogFiles();
                
            } catch (err) {
                console.error('Failed to load categories:', err);
                document.getElementById('logContainer').innerHTML = 'Fehler beim Laden der Kategorien: ' + err.message;
            }
        }

        // Update log file dropdown based on selected category
        function updateLogFiles() {
            const category = document.getElementById('logCategory').value;
            const logFileSelect = document.getElementById('logFile');
            
            logFileSelect.innerHTML = '';
            
            if (availableCategories[category]) {
                Object.entries(availableCategories[category]).forEach(function(entry) {
                    const file = entry[0];
                    const description = entry[1];
                    const option = document.createElement('option');
                    option.value = file;
                    option.textContent = description;
                    logFileSelect.appendChild(option);
                });
            }
            
            // Auto-load logs after updating files
            loadLogs();
        }

        async function loadLogs() {
            if (!accessToken) return;

            const logFile = document.getElementById('logFile').value;
            const lines = document.getElementById('lines').value;

            try {
                const response = await fetch('/api/logs/data?file=' + logFile + '&lines=' + lines, {
                    headers: { 'Authorization': 'Bearer ' + accessToken }
                });

                if (response.status === 401) {
                    logout();
                    return;
                }

                const data = await response.json();
                displayLogs(data.logs);

            } catch (err) {
                document.getElementById('logContainer').innerHTML = 
                    '<div style="color: red;">Error loading logs: ' + err.message + '</div>';
            }
        }

        function displayLogs(logs) {
            const container = document.getElementById('logContainer');
            container.innerHTML = '';

            logs.forEach(function(log) {
                try {
                    const entry = JSON.parse(log);
                    const div = document.createElement('div');
                    div.className = 'log-entry ' + entry.level;
                    
                    let html = '<span class="timestamp">' + entry.timestamp + '</span>';
                    html += '<span class="module">[' + entry.module + ']</span>';
                    
                    if (entry.username) {
                        html += '<span class="username">{' + entry.username + '}</span>';
                    }
                    if (entry.ip) {
                        html += '<span class="ip">[' + entry.ip + ']</span>';
                    }
                    
                    html += '<span class="message">' + entry.message + '</span>';
                    
                    if (entry.metadata) {
                        html += '<div class="metadata">' + JSON.stringify(entry.metadata, null, 2) + '</div>';
                    }
                    
                    div.innerHTML = html;
                    container.appendChild(div);
                } catch (e) {
                    // Plain text log entry
                    const div = document.createElement('div');
                    div.className = 'log-entry';
                    div.innerHTML = '<span class="message">' + log + '</span>';
                    container.appendChild(div);
                }
            });

            // Scroll to bottom
            container.scrollTop = container.scrollHeight;
        }

        function filterLogs() {
            const filter = document.getElementById('filter').value.toLowerCase();
            const entries = document.querySelectorAll('.log-entry');

            entries.forEach(function(entry) {
                const text = entry.textContent.toLowerCase();
                entry.style.display = text.includes(filter) ? 'block' : 'none';
            });
        }

        function autoRefresh() {
            if (autoRefreshInterval) {
                clearInterval(autoRefreshInterval);
                autoRefreshInterval = null;
                document.querySelector('button[onclick="autoRefresh()"]').textContent = '⏰ Auto-Refresh';
            } else {
                autoRefreshInterval = setInterval(loadLogs, 5000);
                document.querySelector('button[onclick="autoRefresh()"]').textContent = '⏸️ Stop Refresh';
            }
        }
    </script>
</body>
</html>`;
  res.send(html);
});

// API für Log-Daten
router.get('/data', authenticate, async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) { return res.status(403).json({ error: 'Keine Berechtigung' }); }
  
  const logFile = req.query.file as string || 'app.log';
  const lines = parseInt(req.query.lines as string) || 100;
  
  try {
    const logPath = resolveLogPath(logFile);
    
    if (!fs.existsSync(logPath)) { 
      return res.json({ 
        logs: [], 
        message: `Log-Datei nicht gefunden: ${logFile}`,
        path: logPath
      }); 
    }
    
    const content = fs.readFileSync(logPath, 'utf8');
    const allLines = content.split('\n').filter(line => line.trim());
    const lastLines = allLines.slice(-lines);
    
    res.json({ 
      logs: lastLines, 
      totalLines: allLines.length, 
      file: logFile, 
      path: logPath,
      category: getLogCategory(logFile),
      lastModified: fs.statSync(logPath).mtime 
    });
  } catch (error: any) {
    res.status(500).json({ 
      error: 'Fehler beim Lesen der Log-Datei', 
      details: error?.message || 'Unknown error',
      file: logFile
    });
  }
});

// API für verfügbare Log-Kategorien
router.get('/categories', authenticate, async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) { return res.status(403).json({ error: 'Keine Berechtigung' }); }
  
  res.json({
    categories: logCategories,
    allFiles: getAllLogFiles(),
    environment: isDevelopment ? 'development' : 'production',
    paths: {
      winston: logsDir,
      services: systemdLogsDir,
      system: '/var/log'
    }
  });
});

// Helper: Log-Kategorie bestimmen
function getLogCategory(logFile: string): string {
  if (logFile in logCategories.winston) return 'winston';
  if (!isDevelopment && logFile in logCategories.services) return 'services';
  if (!isDevelopment && logFile in logCategories.system) return 'system';
  return 'unknown';
}

// Log-Statistiken
router.get('/stats', authenticate, async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) {
    return res.status(403).json({ error: 'Keine Berechtigung' });
  }

  try {
    const logFiles = ['app.log', 'auth.log', 'security.log', 'api.log', 'error.log'];
    const stats: Record<string, any> = {};
    
    for (const file of logFiles) {
      const logPath = path.join(logsDir, file);
      if (fs.existsSync(logPath)) {
        const stat = fs.statSync(logPath);
        const content = fs.readFileSync(logPath, 'utf8');
        const lines = content.split('\n').filter(line => line.trim()).length;
        
        stats[file] = {
          size: stat.size,
          lines: lines,
          lastModified: stat.mtime,
          readable: true
        };
      } else {
        stats[file] = {
          size: 0,
          lines: 0,
          lastModified: null,
          readable: false
        };
      }
    }
    
    res.json(stats);
  } catch (error: any) {
    res.status(500).json({ 
      error: 'Fehler beim Lesen der Log-Statistiken',
      details: error?.message || 'Unknown error'
    });
  }
});

export default router;