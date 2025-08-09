/* Weltenwind Log-Viewer JavaScript */
/* Professional Admin Tool Logic */

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
            body: JSON.stringify({ identifier: username, password: password })
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
    loadLogInfo();
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

// Load available log files from backend
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
        
        // Direkt alle Log-Dateien laden (ohne Kategorie-Auswahl)
        updateLogFiles();
        
    } catch (err) {
        console.error('Failed to load categories:', err);
        document.getElementById('logContainer').innerHTML = 'Fehler beim Laden der Log-Dateien: ' + err.message;
    }
}

// Update log file dropdown based on selected category
function updateLogFiles() {
    const logFileSelect = document.getElementById('logFile');
    logFileSelect.innerHTML = '<option value="">-- Wähle Log-Datei --</option>';
    
    // Sammle alle verfügbaren Log-Dateien aus allen Kategorien
    const allFiles = {};
    
    if (availableCategories.application) {
        Object.entries(availableCategories.application).forEach(([file, description]) => {
            allFiles[file] = description;
        });
    }
    
    if (availableCategories.services) {
        Object.entries(availableCategories.services).forEach(([file, description]) => {
            allFiles[file] = description;
        });
    }
    
    if (availableCategories.infrastructure) {
        Object.entries(availableCategories.infrastructure).forEach(([file, description]) => {
            allFiles[file] = description;
        });
    }
    
    // Sortiere Dateien alphabetisch und füge sie hinzu
    Object.entries(allFiles)
        .sort(([a], [b]) => a.localeCompare(b))
        .forEach(([file, description]) => {
            const option = document.createElement('option');
            option.value = file;
            option.textContent = description;
            logFileSelect.appendChild(option);
        });
    
    if (Object.keys(allFiles).length === 0) {
        logFileSelect.innerHTML = '<option value="">Keine Log-Dateien verfügbar</option>';
    }

    // Standardauswahl treffen und initial laden
    if (Object.keys(allFiles).length > 0) {
        if (allFiles['app.log']) {
            logFileSelect.value = 'app.log';
        } else {
            // Wähle die erste verfügbare Datei
            logFileSelect.selectedIndex = 1; // 0 ist der Placeholder
        }
        // Initiale Logs laden
        loadLogs();
    }
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
        const div = document.createElement('div');
        
        try {
            const entry = JSON.parse(log);
            div.className = 'log-entry ' + (entry.level || 'info').toLowerCase();
            
            let html = '<span class="timestamp">' + (entry.timestamp || 'N/A') + '</span>';
            html += '<span class="level ' + (entry.level || 'info').toLowerCase() + '">' + (entry.level || 'INFO').toUpperCase().padEnd(5) + '</span>';
            html += '<span class="module">[' + (entry.module || 'UNKNOWN') + ']</span>';
            
            if (entry.action) {
                html += '<span class="action">[' + entry.action + ']</span>';
            }
            
            if (entry.username) {
                html += '<span class="username">{' + entry.username + '}</span>';
            }
            if (entry.ip) {
                html += '<span class="ip">[' + entry.ip + ']</span>';
            }
            
            html += '<span class="message">' + escapeHtml(entry.message || '') + '</span>';

            // Zeige restliche Schlüssel als Metadaten (Winston JSON: alle Felder flach)
            const knownKeys = new Set(['level','message','timestamp','module','action','username','ip','category','method','url','status','statusCode','userAgent','duration','error','stack','event','configKeys']);
            const meta = {};
            Object.keys(entry).forEach((key) => {
                if (!knownKeys.has(key)) {
                    meta[key] = entry[key];
                }
            });
            
            // Fehlerdetails bevorzugt gesondert darstellen
            if (entry.error || entry.stack) {
                meta.error = entry.error || meta.error;
                meta.stack = entry.stack || meta.stack;
            }

            if (Object.keys(meta).length > 0) {
                html += '<div class="metadata">' + JSON.stringify(meta, null, 2) + '</div>';
            }
            
            div.innerHTML = html;
        } catch (e) {
            // Versuche strukturierte Winston-Logs zu parsen
            if (log.match(/^\d{2}:\d{2}:\d{2}\s+(INFO|WARN|ERROR|DEBUG)\s+\[/)) {
                parseStructuredLog(log, div);
            } else {
                // Plain text log entry
                div.className = 'log-entry raw';
                div.innerHTML = '<span class="message">' + escapeHtml(log) + '</span>';
            }
        }
        
        container.appendChild(div);
    });

    // Scroll to bottom
    container.scrollTop = container.scrollHeight;
}

// Diese Funktion wurde durch die verbesserte Version unten ersetzt

function autoRefresh() {
    if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
        autoRefreshInterval = null;
        document.querySelector('button[onclick="autoRefresh()"]').textContent = '⏰ Auto-Refresh';
    } else {
        // Häufigere Updates für Live-Logs
        autoRefreshInterval = setInterval(loadLogs, 2000); // 2 Sekunden statt 5
        document.querySelector('button[onclick="autoRefresh()"]').textContent = '⏸️ Stop Refresh';
        
        // Sofort einmal laden
        loadLogs();
    }
}

// Neueste Logs laden (nur die letzten 50 Zeilen für schnelle Updates)
async function loadLatestLogs() {
    const originalLines = document.getElementById('lines').value;
    document.getElementById('lines').value = '50';
    
    try {
        await loadLogs();
    } catch (error) {
        console.error('Fehler beim Laden der neuesten Logs:', error);
    } finally {
        document.getElementById('lines').value = originalLines;
    }
}

// Log-Informationen laden
async function loadLogInfo() {
    if (!accessToken) return;

    try {
        const response = await fetch('/api/logs/info', {
            headers: { 'Authorization': 'Bearer ' + accessToken }
        });

        if (!response.ok) {
            throw new Error('Failed to load log info');
        }

        const logInfo = await response.json();
        displayLogInfo(logInfo);

    } catch (err) {
        document.getElementById('logInfoContent').innerHTML = 
            '<div style="color: #f44336;">Fehler beim Laden der Log-Informationen: ' + err.message + '</div>';
    }
}

// Log-Informationen anzeigen
function displayLogInfo(logInfo) {
    const content = document.getElementById('logInfoContent');
    
    let html = '<div class="log-info-detail"><strong>Log-Verzeichnis:</strong> ' + logInfo.logDirectory + '</div>';
    html += '<div class="log-info-detail"><strong>Environment:</strong> ' + logInfo.environment + '</div>';
    html += '<div class="log-info-detail"><strong>Log-Level:</strong> ' + logInfo.logLevel + '</div>';
    html += '<div class="log-info-detail"><strong>File-Logging:</strong> ' + (logInfo.logToFile ? '✅ Aktiv' : '❌ Deaktiviert') + '</div>';
    html += '<div class="log-info-detail"><strong>Console-Logging:</strong> ' + (logInfo.logToConsole ? '✅ Aktiv' : '❌ Deaktiviert') + '</div>';
    
    if (logInfo.availableFiles && logInfo.availableFiles.length > 0) {
        html += '<div class="log-info-detail"><strong>Verfügbare Dateien:</strong></div>';
        html += '<div class="log-info-files">' + logInfo.availableFiles.join('<br>') + '</div>';
    }
    
    content.innerHTML = html;
}

// Log-Info-Panel ein-/ausklappen
function toggleLogInfo() {
    const panel = document.getElementById('logInfo');
    const button = document.getElementById('logInfoToggle');
    
    if (panel.classList.contains('expanded')) {
        panel.classList.remove('expanded');
        button.textContent = 'ℹ️ Info';
    } else {
        panel.classList.add('expanded');
        button.textContent = '❌ Schließen';
    }
}

// Parse strukturierte Winston-Logs (neues Format)
function parseStructuredLog(log, div) {
    const match = log.match(/^(\d{2}:\d{2}:\d{2})\s+(INFO|WARN|ERROR|DEBUG)\s+\[([^\]]+)\](?:\[([^\]]+)\])?\:\s+(.+?)(?:\s+\|\s+(.+))?$/);
    
    if (match) {
        const [, timestamp, level, module, action, message, metadata] = match;
        
        div.className = 'log-entry ' + level.toLowerCase();
        
        let html = '<span class="timestamp">' + timestamp + '</span>';
        html += '<span class="level ' + level.toLowerCase() + '">' + level.padEnd(5) + '</span>';
        html += '<span class="module">[' + module + ']</span>';
        
        if (action) {
            html += '<span class="action">[' + action + ']</span>';
        }
        
        html += '<span class="message">' + escapeHtml(message) + '</span>';
        
        if (metadata) {
            try {
                const metaObj = JSON.parse(metadata);
                html += '<div class="metadata">' + JSON.stringify(metaObj, null, 2) + '</div>';
            } catch (e) {
                html += '<div class="metadata">' + escapeHtml(metadata) + '</div>';
            }
        }
        
        div.innerHTML = html;
    } else {
        // Fallback für unbekanntes strukturiertes Format
        div.className = 'log-entry raw';
        div.innerHTML = '<span class="message">' + escapeHtml(log) + '</span>';
    }
}

// HTML-Escaping für Sicherheit
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Log-Container leeren
function clearLogs() {
    const container = document.getElementById('logContainer');
    container.innerHTML = '<div style="color: #888; text-align: center; padding: 20px;">Log-Anzeige geleert. Klicke "🔄 Aktualisieren" um Logs zu laden.</div>';
}

// Zum Ende scrollen
function scrollToBottom() {
    const container = document.getElementById('logContainer');
    container.scrollTop = container.scrollHeight;
}

// Nach oben scrollen
function scrollToTop() {
    const container = document.getElementById('logContainer');
    container.scrollTop = 0;
}

// Verbesserte Filter-Funktion mit Highlighting
function filterLogs() {
    const filter = document.getElementById('filter').value.toLowerCase();
    const entries = document.querySelectorAll('.log-entry');
    let visibleCount = 0;

    entries.forEach(function(entry) {
        const text = entry.textContent.toLowerCase();
        const isVisible = !filter || text.includes(filter);
        
        entry.style.display = isVisible ? 'block' : 'none';
        
        if (isVisible) {
            visibleCount++;
            
            // Highlighting (einfach)
            if (filter && filter.length > 2) {
                highlightText(entry, filter);
            } else {
                removeHighlight(entry);
            }
        }
    });
    
    // Zeige Anzahl der gefilterten Einträge
    updateFilterStatus(visibleCount, entries.length, filter);
}

// Text-Highlighting
function highlightText(element, searchTerm) {
    // Einfaches Highlighting - kann erweitert werden
    const messageSpan = element.querySelector('.message');
    if (messageSpan && messageSpan.textContent.toLowerCase().includes(searchTerm)) {
        messageSpan.style.backgroundColor = 'rgba(255, 255, 0, 0.3)';
    }
}

// Highlighting entfernen
function removeHighlight(element) {
    const messageSpan = element.querySelector('.message');
    if (messageSpan) {
        messageSpan.style.backgroundColor = '';
    }
}

// Filter-Status anzeigen
function updateFilterStatus(visibleCount, totalCount, filter) {
    let statusDiv = document.getElementById('filterStatus');
    if (!statusDiv) {
        statusDiv = document.createElement('div');
        statusDiv.id = 'filterStatus';
        statusDiv.style.cssText = 'padding: 5px; background: #333; border-radius: 3px; margin: 5px 0; font-size: 0.9em; color: #ccc;';
        document.querySelector('.controls').appendChild(statusDiv);
    }
    
    if (filter) {
        statusDiv.textContent = `🔍 Filter: "${filter}" - ${visibleCount} von ${totalCount} Einträgen angezeigt`;
        statusDiv.style.display = 'block';
    } else {
        statusDiv.style.display = 'none';
    }
}