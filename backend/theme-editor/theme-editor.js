/* 🎨 Weltenwind Theme Editor - JavaScript */

// === GLOBALS === 
let accessToken = null;
let themeData = null;
let availableThemes = [];
let currentTheme = null;
let userPermissions = {};
let originalThemeData = null; // For reset functionality

// === INITIALIZATION === 
window.onload = function() {
    const savedToken = localStorage.getItem('weltenwind_access_token');
    const savedUser = localStorage.getItem('weltenwind_user');

    if (savedToken && savedUser) {
        accessToken = savedToken;
        showThemeEditor(JSON.parse(savedUser));
        loadAvailableThemes();
        loadUserPermissions();
    }
};

// === LOGIN HANDLING === 
document.getElementById('loginForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const button = document.getElementById('loginButton');
    const errorDiv = document.getElementById('loginError');
    
    button.disabled = true;
    button.textContent = '⏳ Anmeldung läuft...';
    errorDiv.classList.add('hidden');
    
    try {
        const response = await fetch('/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ 
                identifier: username, 
                password: password 
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            accessToken = data.accessToken;
            localStorage.setItem('weltenwind_access_token', accessToken);
            localStorage.setItem('weltenwind_user', JSON.stringify(data.user));
            showThemeEditor(data.user);
            loadAvailableThemes();
            loadUserPermissions();
        } else {
            throw new Error(data.error || 'Anmeldung fehlgeschlagen');
        }
    } catch (error) {
        errorDiv.textContent = '❌ ' + error.message;
        errorDiv.classList.remove('hidden');
    } finally {
        button.disabled = false;
        button.textContent = '🔓 Anmelden';
    }
});

// === UI MANAGEMENT === 
function showThemeEditor(user) {
    document.getElementById('loginContainer').classList.add('hidden');
    document.getElementById('themeEditor').classList.remove('hidden');
    document.getElementById('userInfo').textContent = `👤 ${user.username}`;
}

function logout() {
    localStorage.removeItem('weltenwind_access_token');
    localStorage.removeItem('weltenwind_user');
    accessToken = null;
    document.getElementById('loginContainer').classList.remove('hidden');
    document.getElementById('themeEditor').classList.add('hidden');
}

// === USER PERMISSIONS === 
async function loadUserPermissions() {
    try {
        const response = await fetch('/api/auth/user/permissions', {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (response.ok) {
            const data = await response.json();
            userPermissions = data.permissions;
            console.log('🔐 User permissions loaded:', userPermissions);
        }
    } catch (error) {
        console.error('❌ Error loading user permissions:', error);
    }
}

// === THEME MANAGEMENT === 
async function loadAvailableThemes() {
    try {
        const response = await fetch('/api/themes', {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden der Themes');
        }

        const data = await response.json();
        availableThemes = data.themes;
        
        populateThemeSelector();
        
        // Load first theme by default
        if (availableThemes.length > 0) {
            currentTheme = availableThemes[0].filename;
            document.getElementById('themeSelector').value = currentTheme;
            loadTheme(currentTheme);
        } else {
            showMessage('⚠️ Keine Themes gefunden', 'error');
        }
        
    } catch (error) {
        console.error('❌ Error loading themes:', error);
        showMessage('❌ ' + error.message, 'error');
    }
}

function populateThemeSelector() {
    const selector = document.getElementById('themeSelector');
    selector.innerHTML = '<option value="">🎨 Theme wählen...</option>';
    
    availableThemes.forEach(theme => {
        const option = document.createElement('option');
        option.value = theme.filename;
        option.textContent = `${theme.name} (v${theme.version})`;
        selector.appendChild(option);
    });
}

async function loadSelectedTheme() {
    const selector = document.getElementById('themeSelector');
    const selectedTheme = selector.value;
    
    if (selectedTheme) {
        currentTheme = selectedTheme;
        await loadTheme(selectedTheme);
    }
}

async function loadTheme(themeName) {
    try {
        const response = await fetch(`/api/themes/${themeName}`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error(`Fehler beim Laden des Themes: ${themeName}`);
        }

        themeData = await response.json();
        originalThemeData = JSON.parse(JSON.stringify(themeData)); // Deep copy for reset
        
        updateThemeInfo();
        renderColorEditor();
        updatePreview();
        enableButtons();
        
        showMessage(`✅ Theme "${themeData.name}" geladen`, 'success');
        
    } catch (error) {
        console.error('❌ Error loading theme:', error);
        showMessage('❌ ' + error.message, 'error');
    }
}

function updateThemeInfo() {
    if (!themeData) return;
    
    document.getElementById('themeName').textContent = themeData.name;
    document.getElementById('themeVersion').textContent = themeData.version;
    
    // Count colors
    let colorCount = 0;
    if (themeData.colors) {
        const colors = themeData.colors;
        Object.keys(colors).forEach(group => {
            if (typeof colors[group] === 'object') {
                colorCount += Object.keys(colors[group]).length;
            }
        });
    }
    document.getElementById('colorCount').textContent = colorCount;
}

function enableButtons() {
    document.getElementById('saveButton').disabled = false;
    document.getElementById('exportButton').disabled = false;
    document.getElementById('resetButton').disabled = false;
    document.getElementById('previewButton').disabled = false;
    document.getElementById('cloneButton').disabled = false;
}

// === COLOR EDITOR === 
function renderColorEditor() {
    const colorEditor = document.getElementById('colorEditor');
    
    if (!themeData || !themeData.colors) {
        colorEditor.innerHTML = '<div class="error">❌ Keine Farbdaten gefunden</div>';
        return;
    }
    
    colorEditor.innerHTML = '';
    
    const colors = themeData.colors;
    
    // Render each color group
    Object.keys(colors).forEach(groupName => {
        const group = colors[groupName];
        if (typeof group === 'object' && group !== null) {
            const groupDiv = createColorGroup(groupName, group);
            colorEditor.appendChild(groupDiv);
        }
    });
}

function createColorGroup(groupName, colors) {
    const groupDiv = document.createElement('div');
    groupDiv.className = 'color-group';
    
    const title = document.createElement('h4');
    title.textContent = getGroupDisplayName(groupName);
    groupDiv.appendChild(title);
    
    Object.keys(colors).forEach(colorName => {
        const colorValue = colors[colorName];
        if (typeof colorValue === 'string' && colorValue.startsWith('#')) {
            const colorItem = createColorItem(groupName, colorName, colorValue);
            groupDiv.appendChild(colorItem);
        }
    });
    
    return groupDiv;
}

function createColorItem(groupName, colorName, colorValue) {
    const item = document.createElement('div');
    item.className = 'color-item';
    
    // Color preview
    const preview = document.createElement('div');
    preview.className = 'color-preview';
    preview.style.backgroundColor = colorValue;
    
    // Color info
    const info = document.createElement('div');
    info.className = 'color-info';
    
    const label = document.createElement('div');
    label.className = 'color-label';
    label.textContent = getColorDisplayName(colorName);
    
    const value = document.createElement('div');
    value.className = 'color-value';
    value.textContent = colorValue;
    
    info.appendChild(label);
    info.appendChild(value);
    
    // Color input
    const input = document.createElement('input');
    input.type = 'color';
    input.value = colorValue;
    input.addEventListener('change', (e) => {
        updateColor(groupName, colorName, e.target.value);
    });
    
    item.appendChild(preview);
    item.appendChild(info);
    item.appendChild(input);
    
    return item;
}

function updateColor(groupName, colorName, colorValue) {
    if (themeData && themeData.colors && themeData.colors[groupName]) {
        themeData.colors[groupName][colorName] = colorValue;
        
        // Update preview
        const preview = event.target.parentNode.querySelector('.color-preview');
        const valueDiv = event.target.parentNode.querySelector('.color-value');
        
        preview.style.backgroundColor = colorValue;
        valueDiv.textContent = colorValue;
        
        updatePreview();
    }
}

// === PREVIEW === 
function updatePreview() {
    if (!themeData || !themeData.colors) return;
    
    const root = document.documentElement;
    const colors = themeData.colors;
    
    // Update CSS variables for preview
    if (colors.primary) {
        root.style.setProperty('--primary-color', colors.primary.value || colors.primary.main || '#4B3B79');
    }
    if (colors.secondary) {
        root.style.setProperty('--secondary-color', colors.secondary.value || colors.secondary.main || '#D4AF37');
    }
    if (colors.status) {
        root.style.setProperty('--success-color', colors.status.success || '#10B981');
        root.style.setProperty('--error-color', colors.status.error || '#EF4444');
    }
    if (colors.background) {
        root.style.setProperty('--surface-dark', colors.background.surface_dark || '#1E1E2E');
        root.style.setProperty('--surface-light', colors.background.surface_light || '#3A3A52');
    }
    if (colors.text) {
        root.style.setProperty('--text-primary', colors.text.primary || '#E0E0E0');
    }
}

function togglePreview() {
    const panel = document.getElementById('previewPanel');
    panel.classList.toggle('hidden');
    
    const button = document.getElementById('previewButton');
    if (panel.classList.contains('hidden')) {
        button.textContent = '👀 Live-Preview anzeigen';
    } else {
        button.textContent = '🙈 Live-Preview ausblenden';
    }
}

// === SAVE FUNCTIONALITY === 
function showSaveConfirmDialog() {
    if (!themeData) return;
    
    document.getElementById('saveThemeDisplay').textContent = themeData.name;
    document.getElementById('saveConfirmDialog').classList.remove('hidden');
}

function closeSaveConfirmDialog() {
    document.getElementById('saveConfirmDialog').classList.add('hidden');
}

async function confirmSave() {
    if (!themeData || !currentTheme) return;
    
    try {
        const response = await fetch(`/api/themes/${currentTheme}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify(themeData)
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Speichern des Themes');
        }

        closeSaveConfirmDialog();
        showMessage('✅ Theme erfolgreich gespeichert!', 'success');
        
        // Update original data
        originalThemeData = JSON.parse(JSON.stringify(themeData));
        
    } catch (error) {
        console.error('❌ Error saving theme:', error);
        showMessage('❌ ' + error.message, 'error');
    }
}

// === CLONE FUNCTIONALITY === 
function showCloneDialog() {
    if (!themeData) return;
    
    document.getElementById('cloneSourceName').textContent = themeData.name;
    document.getElementById('cloneNewName').value = `${themeData.name} Copy`;
    document.getElementById('cloneNewDescription').value = `Copy of ${themeData.name}`;
    document.getElementById('cloneDialog').classList.remove('hidden');
}

function closeCloneDialog() {
    document.getElementById('cloneDialog').classList.add('hidden');
}

async function confirmClone() {
    const newName = document.getElementById('cloneNewName').value.trim();
    const newDescription = document.getElementById('cloneNewDescription').value.trim();
    
    if (!newName) {
        showMessage('❌ Name ist erforderlich', 'error');
        return;
    }
    
    if (!themeData || !currentTheme) return;
    
    try {
        const response = await fetch(`/api/themes/${currentTheme}/clone`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({
                newName: newName,
                newDescription: newDescription
            })
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Fehler beim Klonen des Themes');
        }

        closeCloneDialog();
        showMessage('✅ Theme erfolgreich geklont!', 'success');
        
        // Refresh themes list
        await loadAvailableThemes();
        
    } catch (error) {
        console.error('❌ Error cloning theme:', error);
        showMessage('❌ ' + error.message, 'error');
    }
}

// === EXPORT FUNCTIONALITY === 
function showExportDialog() {
    if (!themeData) return;
    document.getElementById('exportDialog').classList.remove('hidden');
}

function closeExportDialog() {
    document.getElementById('exportDialog').classList.add('hidden');
}

function exportTheme() {
    if (!themeData) return;
    
    const dataStr = JSON.stringify(themeData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    
    const link = document.createElement('a');
    link.href = URL.createObjectURL(dataBlob);
    link.download = `${themeData.name.replace(/\s+/g, '-').toLowerCase()}-theme.json`;
    link.click();
    
    closeExportDialog();
    showMessage('📤 Theme exportiert!', 'success');
}

// === RESET FUNCTIONALITY === 
function resetTheme() {
    if (!originalThemeData) return;
    
    if (confirm('🔄 Theme auf ursprüngliche Werte zurücksetzen?\n\nAlle ungespeicherten Änderungen gehen verloren.')) {
        themeData = JSON.parse(JSON.stringify(originalThemeData));
        renderColorEditor();
        updatePreview();
        updateThemeInfo();
        showMessage('🔄 Theme zurückgesetzt', 'success');
    }
}

// === UTILITY FUNCTIONS === 
function getGroupDisplayName(groupName) {
    const names = {
        'primary': '🎨 Primary Colors',
        'secondary': '🎭 Secondary Colors', 
        'tertiary': '🌿 Tertiary Colors',
        'background': '🖼️ Background Colors',
        'text': '📝 Text Colors',
        'status': '🚨 Status Colors',
        'effects': '✨ Effect Colors'
    };
    return names[groupName] || groupName.charAt(0).toUpperCase() + groupName.slice(1);
}

function getColorDisplayName(colorName) {
    const names = {
        'value': 'Main',
        'light': 'Light',
        'dark': 'Dark',
        'surface': 'Surface',
        'accent': 'Accent',
        'surface_dark': 'Surface Dark',
        'surface_darker': 'Surface Darker',
        'surface_medium': 'Surface Medium',
        'surface_light': 'Surface Light',
        'surface_white': 'Surface White',
        'surface_gray': 'Surface Gray',
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
        'disabled': 'Disabled',
        'primary_light': 'Primary Light',
        'secondary_light': 'Secondary Light',
        'success': 'Success',
        'warning': 'Warning',
        'error': 'Error',
        'info': 'Info',
        'glow': 'Glow',
        'shimmer': 'Shimmer',
        'overlay': 'Overlay',
        'glass': 'Glass'
    };
    return names[colorName] || colorName.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
}

function showMessage(message, type = 'info') {
    const messageDiv = document.getElementById('themeMessage');
    messageDiv.textContent = message;
    messageDiv.className = type;
    messageDiv.classList.remove('hidden');
    
    setTimeout(() => {
        messageDiv.classList.add('hidden');
    }, 5000);
}