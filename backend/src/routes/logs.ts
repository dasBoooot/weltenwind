import express from 'express';
import fs from 'fs';
import path from 'path';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';

const router = express.Router();

const logsDir = path.resolve(__dirname, '../../../logs');

// Log-Viewer (nur für Admins)
router.get('/viewer', async (req, res) => {
  const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Weltenwind Logs</title>
    <meta charset="utf-8">
    <style>
        body { font-family: monospace; margin: 20px; background: #1a1a1a; color: #fff; }
        .login-container { 
            max-width: 400px; 
            margin: 100px auto; 
            padding: 30px; 
            background: #333; 
            border-radius: 10px; 
            text-align: center;
        }
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
            <label>Log-Datei:</label>
            <select id="logFile" onchange="loadLogs()">
                <option value="app.log">App (Alle)</option>
                <option value="auth.log">Auth</option>
                <option value="security.log">Security</option>
                <option value="api.log">API</option>
                <option value="error.log">Errors</option>
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
        </div>
        
        <div id="logContainer" class="log-container">
            Lade Logs...
        </div>
    </div>

    <script>
        let accessToken = null;
        let autoRefreshInterval = null;
        
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
            document.getElementById('userInfo').textContent = \`Angemeldet als: \${user.username}\`;
            loadLogs();
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
        
        async function loadLogs() {
            if (!accessToken) return;
            
            const logFile = document.getElementById('logFile').value;
            const lines = document.getElementById('lines').value;
            
            try {
                const response = await fetch(\`/api/logs/data?file=\${logFile}&lines=\${lines}\`, {
                    headers: { 'Authorization': \`Bearer \${accessToken}\` }
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
            
            logs.forEach(log => {
                try {
                    const entry = JSON.parse(log);
                    const div = document.createElement('div');
                    div.className = \`log-entry \${entry.level}\`;
                    div.innerHTML = \`
                        <span class="timestamp">\${entry.timestamp}</span>
                        <span class="module">[\${entry.module}]</span>
                        \${entry.username ? \`<span class="username">{\${entry.username}}</span>\` : ''}
                        \${entry.ip ? \`<span class="ip">[\${entry.ip}]</span>\` : ''}
                        <span class="message">\${entry.message}</span>
                        \${entry.metadata ? \`<div class="metadata">\${JSON.stringify(entry.metadata, null, 2)}</div>\` : ''}
                    \`;
                    container.appendChild(div);
                } catch (e) {
                    // Plain text log entry
                    const div = document.createElement('div');
                    div.className = 'log-entry';
                    div.innerHTML = \`<span class="message">\${log}</span>\`;
                    container.appendChild(div);
                }
            });
            
            // Scroll to bottom
            container.scrollTop = container.scrollHeight;
        }
        
        function filterLogs() {
            const filter = document.getElementById('filter').value.toLowerCase();
            const entries = document.querySelectorAll('.log-entry');
            
            entries.forEach(entry => {
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
  if (!hasAdminPerm) {
    return res.status(403).json({ error: 'Keine Berechtigung' });
  }

  const logFile = req.query.file as string || 'app.log';
  const lines = parseInt(req.query.lines as string) || 100;
  
  try {
    const logPath = path.join(logsDir, logFile);
    
    if (!fs.existsSync(logPath)) {
      return res.json({ logs: [], message: 'Log-Datei nicht gefunden' });
    }
    
    // Tail-ähnliche Funktionalität (letzte N Zeilen)
    const content = fs.readFileSync(logPath, 'utf8');
    const allLines = content.split('\n').filter(line => line.trim());
    const lastLines = allLines.slice(-lines);
    
    res.json({
      logs: lastLines,
      totalLines: allLines.length,
      file: logFile,
      lastModified: fs.statSync(logPath).mtime
    });
    
  } catch (error: any) {
    res.status(500).json({ 
      error: 'Fehler beim Lesen der Log-Datei',
      details: error?.message || 'Unknown error'
    });
  }
});

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