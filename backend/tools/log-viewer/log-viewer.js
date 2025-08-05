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