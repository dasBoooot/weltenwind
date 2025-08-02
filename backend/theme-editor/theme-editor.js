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
        renderModularEditor();
        updatePreview();
        enableButtons();
        
        console.log(`🎨 Theme loaded: ${themeData.name}, Active tab: ${currentActiveTab}`);
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
    
    // Show bundle information
    if (themeData.bundle) {
        document.getElementById('bundleType').textContent = themeData.bundle.name || themeData.bundle.type || 'Standard';
        document.getElementById('bundleContext').textContent = themeData.bundle.context || 'Universal';
    } else {
        document.getElementById('bundleType').textContent = 'Legacy';
        document.getElementById('bundleContext').textContent = 'N/A';
    }
    
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
    
    // Count modules
    let moduleCount = 0;
    ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects'].forEach(module => {
        if (themeData[module]) moduleCount++;
    });
    document.getElementById('moduleCount').textContent = moduleCount;
}

function enableButtons() {
    document.getElementById('saveButton').disabled = false;
    document.getElementById('exportButton').disabled = false;
    document.getElementById('backupButton').disabled = false;
    document.getElementById('resetButton').disabled = false;
    document.getElementById('previewButton').disabled = false;
    document.getElementById('cloneButton').disabled = false;
}

// === COLOR EDITOR === 
function renderColorEditor() {
    const contentContainer = document.getElementById('editorContent');
    if (!contentContainer) return;
    
    if (!themeData || !themeData.colors) {
        contentContainer.innerHTML = '<div class="error">❌ Keine Farbdaten gefunden</div>';
        return;
    }
    
    contentContainer.innerHTML = '';
    
    const colors = themeData.colors;
    
    // Create colors wrapper
    const colorEditor = document.createElement('div');
    colorEditor.className = 'tab-content colors-content';
    
    // Render each color group
    Object.keys(colors).forEach(groupName => {
        const group = colors[groupName];
        if (typeof group === 'object' && group !== null) {
            const groupDiv = createColorGroup(groupName, group);
            colorEditor.appendChild(groupDiv);
        }
    });
    
    contentContainer.appendChild(colorEditor);
    console.log('🎨 Color editor rendered with', Object.keys(colors).length, 'groups');
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

// === MODULAR EDITOR ===
let currentActiveTab = 'colors';

function renderModularEditor() {
    if (!themeData) return;
    
    // Remember current active tab
    const currentTab = document.querySelector('.editor-tab.active')?.dataset.tab || currentActiveTab;
    currentActiveTab = currentTab;
    
    // Create tab navigation
    renderEditorTabs();
    
    // Render active tab content
    renderTabContent(currentActiveTab);
}

function renderEditorTabs() {
    const tabsContainer = document.getElementById('editorTabs');
    if (!tabsContainer) return;
    
    const tabs = [
        { id: 'colors', name: '🎨 Farben', available: !!themeData.colors },
        { id: 'typography', name: '📝 Typography', available: !!themeData.typography },
        { id: 'spacing', name: '📏 Spacing', available: !!themeData.spacing },
        { id: 'radius', name: '🔲 Radius', available: !!themeData.radius },
        { id: 'gaming', name: '🎮 Gaming', available: !!themeData.gaming },
        { id: 'effects', name: '✨ Effects', available: !!themeData.effects },
        { id: 'bundle', name: '📦 Bundle', available: !!themeData.bundle }
    ];
    
    // Check if the current active tab is still available, otherwise fallback to first available
    const availableTabs = tabs.filter(tab => tab.available);
    if (availableTabs.length === 0) return;
    
    const currentTabAvailable = availableTabs.find(tab => tab.id === currentActiveTab);
    if (!currentTabAvailable) {
        currentActiveTab = availableTabs[0].id;
    }
    
    tabsContainer.innerHTML = '';
    
    tabs.forEach((tab) => {
        const tabButton = document.createElement('button');
        const isActive = tab.id === currentActiveTab && tab.available;
        tabButton.className = `editor-tab ${isActive ? 'active' : ''} ${!tab.available ? 'disabled' : ''}`;
        tabButton.dataset.tab = tab.id;
        tabButton.textContent = tab.name;
        tabButton.disabled = !tab.available;
        
        if (tab.available) {
            tabButton.addEventListener('click', () => switchTab(tab.id));
        }
        
        tabsContainer.appendChild(tabButton);
    });
}

function switchTab(tabId) {
    // Update current active tab
    currentActiveTab = tabId;
    
    // Update tab buttons
    document.querySelectorAll('.editor-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabId}"]`)?.classList.add('active');
    
    // Render tab content
    renderTabContent(tabId);
    
    console.log(`🔄 Switched to tab: ${tabId}`);
}

function renderTabContent(tabId) {
    const contentContainer = document.getElementById('editorContent');
    if (!contentContainer) return;
    
    switch (tabId) {
        case 'colors':
            renderColorEditor();
            break;
        case 'typography':
            renderTypographyEditor();
            break;
        case 'spacing':
            renderSpacingEditor();
            break;
        case 'radius':
            renderRadiusEditor();
            break;
        case 'gaming':
            renderGamingEditor();
            break;
        case 'effects':
            renderEffectsEditor();
            break;
        case 'bundle':
            renderBundleEditor();
            break;
        default:
            contentContainer.innerHTML = '<div class="error">❌ Unbekannter Tab</div>';
    }
}

function renderTypographyEditor() {
    const contentContainer = document.getElementById('editorContent');
    
    if (!themeData.typography) {
        contentContainer.innerHTML = '<div class="info">ℹ️ Keine Typography-Daten verfügbar</div>';
        return;
    }
    
    contentContainer.innerHTML = '<h4>📝 Typography Settings</h4>';
    
    const typography = themeData.typography;
    
    // Font Families
    if (typography.fontFamilies) {
        const fontSection = document.createElement('div');
        fontSection.className = 'editor-section';
        fontSection.innerHTML = '<h5>🔤 Font Families</h5>';
        
        Object.entries(typography.fontFamilies).forEach(([key, value]) => {
            const fontItem = createTextInput(`typography.fontFamilies.${key}`, key, value);
            fontSection.appendChild(fontItem);
        });
        
        contentContainer.appendChild(fontSection);
    }
    
    // Text Styles
    if (typography.textStyles) {
        const stylesSection = document.createElement('div');
        stylesSection.className = 'editor-section';
        stylesSection.innerHTML = '<h5>✍️ Text Styles</h5>';
        
        Object.entries(typography.textStyles).forEach(([styleName, style]) => {
            const styleGroup = document.createElement('div');
            styleGroup.className = 'style-group';
            styleGroup.innerHTML = `<h6>${getDisplayName(styleName)}</h6>`;
            
            if (typeof style === 'object') {
                Object.entries(style).forEach(([prop, value]) => {
                    const propItem = createTextInput(
                        `typography.textStyles.${styleName}.${prop}`, 
                        prop, 
                        value
                    );
                    styleGroup.appendChild(propItem);
                });
            }
            
            stylesSection.appendChild(styleGroup);
        });
        
        contentContainer.appendChild(stylesSection);
    }
}

function renderSpacingEditor() {
    const contentContainer = document.getElementById('editorContent');
    
    if (!themeData.spacing) {
        contentContainer.innerHTML = '<div class="info">ℹ️ Keine Spacing-Daten verfügbar</div>';
        return;
    }
    
    contentContainer.innerHTML = '<h4>📏 Spacing Settings</h4>';
    
    const spacing = themeData.spacing;
    
    // Base spacing values
    ['xs', 'sm', 'md', 'lg', 'xl', 'xxl'].forEach(size => {
        if (spacing[size] !== undefined) {
            const item = createNumberInput(`spacing.${size}`, size.toUpperCase(), spacing[size], 'px');
            contentContainer.appendChild(item);
        }
    });
    
    // Semantic spacing
    if (spacing.semantic) {
        const semanticSection = document.createElement('div');
        semanticSection.className = 'editor-section';
        semanticSection.innerHTML = '<h5>🏷️ Semantic Spacing</h5>';
        
        Object.entries(spacing.semantic).forEach(([category, values]) => {
            if (typeof values === 'object') {
                const categoryGroup = document.createElement('div');
                categoryGroup.className = 'spacing-group';
                categoryGroup.innerHTML = `<h6>${getDisplayName(category)}</h6>`;
                
                Object.entries(values).forEach(([key, value]) => {
                    const item = createNumberInput(
                        `spacing.semantic.${category}.${key}`, 
                        key, 
                        value, 
                        'px'
                    );
                    categoryGroup.appendChild(item);
                });
                
                semanticSection.appendChild(categoryGroup);
            }
        });
        
        contentContainer.appendChild(semanticSection);
    }
}

function renderRadiusEditor() {
    const contentContainer = document.getElementById('editorContent');
    
    if (!themeData.radius) {
        contentContainer.innerHTML = '<div class="info">ℹ️ Keine Radius-Daten verfügbar</div>';
        return;
    }
    
    contentContainer.innerHTML = '<h4>🔲 Border Radius Settings</h4>';
    
    const radius = themeData.radius;
    
    // Base radius values
    ['sm', 'md', 'lg', 'xl', 'round'].forEach(size => {
        if (radius[size] !== undefined) {
            const item = createNumberInput(`radius.${size}`, size.toUpperCase(), radius[size], 'px');
            contentContainer.appendChild(item);
        }
    });
    
    // Category-specific radius
    Object.entries(radius).forEach(([category, values]) => {
        if (typeof values === 'object' && !['sm', 'md', 'lg', 'xl', 'round'].includes(category)) {
            const categorySection = document.createElement('div');
            categorySection.className = 'editor-section';
            categorySection.innerHTML = `<h5>🏷️ ${getDisplayName(category)}</h5>`;
            
            Object.entries(values).forEach(([key, value]) => {
                const item = createNumberInput(
                    `radius.${category}.${key}`, 
                    key, 
                    value, 
                    'px'
                );
                categorySection.appendChild(item);
            });
            
            contentContainer.appendChild(categorySection);
        }
    });
}

function renderGamingEditor() {
    const contentContainer = document.getElementById('editorContent');
    
    if (!themeData.gaming) {
        contentContainer.innerHTML = '<div class="info">ℹ️ Keine Gaming-Daten verfügbar</div>';
        return;
    }
    
    contentContainer.innerHTML = '<h4>🎮 Gaming Module Settings</h4>';
    
    const gaming = themeData.gaming;
    
    // Gaming modules
    ['inventory', 'progress', 'hud'].forEach(module => {
        if (gaming[module]) {
            const moduleSection = document.createElement('div');
            moduleSection.className = 'editor-section';
            moduleSection.innerHTML = `<h5>🎯 ${getDisplayName(module)}</h5>`;
            
            Object.entries(gaming[module]).forEach(([key, value]) => {
                let item;
                if (typeof value === 'string' && value.startsWith('#')) {
                    item = createColorInput(`gaming.${module}.${key}`, key, value);
                } else if (typeof value === 'number') {
                    item = createNumberInput(`gaming.${module}.${key}`, key, value, 'px');
                } else if (typeof value === 'boolean') {
                    item = createBooleanInput(`gaming.${module}.${key}`, key, value);
                } else {
                    item = createTextInput(`gaming.${module}.${key}`, key, value);
                }
                moduleSection.appendChild(item);
            });
            
            contentContainer.appendChild(moduleSection);
        }
    });
}

function renderEffectsEditor() {
    const contentContainer = document.getElementById('editorContent');
    
    if (!themeData.effects) {
        contentContainer.innerHTML = '<div class="info">ℹ️ Keine Effects-Daten verfügbar</div>';
        return;
    }
    
    contentContainer.innerHTML = '<h4>✨ Effects Settings</h4>';
    
    const effects = themeData.effects;
    
    Object.entries(effects).forEach(([category, values]) => {
        if (typeof values === 'object') {
            const categorySection = document.createElement('div');
            categorySection.className = 'editor-section';
            categorySection.innerHTML = `<h5>🌟 ${getDisplayName(category)}</h5>`;
            
            renderNestedObject(values, `effects.${category}`, categorySection);
            contentContainer.appendChild(categorySection);
        }
    });
}

function renderBundleEditor() {
    const contentContainer = document.getElementById('editorContent');
    
    if (!themeData.bundle) {
        contentContainer.innerHTML = '<div class="info">ℹ️ Keine Bundle-Konfiguration verfügbar</div>';
        return;
    }
    
    contentContainer.innerHTML = '<h4>📦 Bundle Configuration</h4>';
    
    const bundle = themeData.bundle;
    
    // Bundle basic info
    const basicSection = document.createElement('div');
    basicSection.className = 'editor-section';
    basicSection.innerHTML = '<h5>ℹ️ Bundle Information</h5>';
    
    ['name', 'type', 'context'].forEach(key => {
        if (bundle[key]) {
            const item = createTextInput(`bundle.${key}`, key, bundle[key]);
            if (key === 'name') {
                // Bundle name can be edited - important for theme-to-bundle mappings
                item.querySelector('input').addEventListener('input', function() {
                    themeData.bundle.name = this.value;
                });
            } else {
                item.querySelector('input').readOnly = true; // Make read-only
            }
            basicSection.appendChild(item);
        }
    });
    
    contentContainer.appendChild(basicSection);
    
    // Bundle modules
    if (bundle.modules && Array.isArray(bundle.modules)) {
        const modulesSection = document.createElement('div');
        modulesSection.className = 'editor-section';
        modulesSection.innerHTML = '<h5>🧩 Bundle Modules</h5>';
        
        const modulesList = document.createElement('div');
        modulesList.className = 'modules-list';
        bundle.modules.forEach(module => {
            const moduleTag = document.createElement('span');
            moduleTag.className = 'module-tag';
            moduleTag.textContent = module;
            modulesList.appendChild(moduleTag);
        });
        
        modulesSection.appendChild(modulesList);
        contentContainer.appendChild(modulesSection);
    }
}

// Helper functions for creating input elements
function createTextInput(path, label, value) {
    const container = document.createElement('div');
    container.className = 'input-group';
    
    const labelEl = document.createElement('label');
    labelEl.textContent = getDisplayName(label);
    
    const input = document.createElement('input');
    input.type = 'text';
    input.value = value || '';
    input.addEventListener('change', (e) => updateThemeValue(path, e.target.value));
    
    container.appendChild(labelEl);
    container.appendChild(input);
    
    return container;
}

function createNumberInput(path, label, value, unit = '') {
    const container = document.createElement('div');
    container.className = 'input-group';
    
    const labelEl = document.createElement('label');
    labelEl.textContent = `${getDisplayName(label)} ${unit}`;
    
    const input = document.createElement('input');
    input.type = 'number';
    input.value = value || 0;
    input.addEventListener('change', (e) => updateThemeValue(path, parseInt(e.target.value)));
    
    container.appendChild(labelEl);
    container.appendChild(input);
    
    return container;
}

function createColorInput(path, label, value) {
    const container = document.createElement('div');
    container.className = 'input-group color-input-group';
    
    const labelEl = document.createElement('label');
    labelEl.textContent = getDisplayName(label);
    
    const preview = document.createElement('div');
    preview.className = 'color-preview-small';
    preview.style.backgroundColor = value;
    
    const input = document.createElement('input');
    input.type = 'color';
    input.value = value || '#000000';
    input.addEventListener('change', (e) => {
        updateThemeValue(path, e.target.value);
        preview.style.backgroundColor = e.target.value;
    });
    
    container.appendChild(labelEl);
    container.appendChild(preview);
    container.appendChild(input);
    
    return container;
}

function createBooleanInput(path, label, value) {
    const container = document.createElement('div');
    container.className = 'input-group';
    
    const labelEl = document.createElement('label');
    labelEl.textContent = getDisplayName(label);
    
    const input = document.createElement('input');
    input.type = 'checkbox';
    input.checked = !!value;
    input.addEventListener('change', (e) => updateThemeValue(path, e.target.checked));
    
    container.appendChild(labelEl);
    container.appendChild(input);
    
    return container;
}

function renderNestedObject(obj, basePath, container) {
    Object.entries(obj).forEach(([key, value]) => {
        if (typeof value === 'object' && !Array.isArray(value)) {
            const nestedSection = document.createElement('div');
            nestedSection.className = 'nested-section';
            nestedSection.innerHTML = `<h6>${getDisplayName(key)}</h6>`;
            renderNestedObject(value, `${basePath}.${key}`, nestedSection);
            container.appendChild(nestedSection);
        } else {
            let item;
            if (typeof value === 'string' && value.startsWith('#')) {
                item = createColorInput(`${basePath}.${key}`, key, value);
            } else if (typeof value === 'number') {
                item = createNumberInput(`${basePath}.${key}`, key, value);
            } else if (typeof value === 'boolean') {
                item = createBooleanInput(`${basePath}.${key}`, key, value);
            } else {
                item = createTextInput(`${basePath}.${key}`, key, value);
            }
            container.appendChild(item);
        }
    });
}

function updateThemeValue(path, value) {
    if (!themeData) return;
    
    const keys = path.split('.');
    let current = themeData;
    
    // Navigate to parent object
    for (let i = 0; i < keys.length - 1; i++) {
        if (!current[keys[i]]) {
            current[keys[i]] = {};
        }
        current = current[keys[i]];
    }
    
    // Set value
    current[keys[keys.length - 1]] = value;
    
    // Update preview
    updatePreview();
}

// === BACKUP MANAGEMENT ===
let currentBackups = [];
let currentAuditTrail = [];
let backupFilter = 'all';

function showBackupDialog() {
    if (!currentTheme) return;
    
    document.getElementById('backupThemeName').textContent = themeData?.name || currentTheme;
    document.getElementById('backupDialog').classList.remove('hidden');
    
    // Reset filter
    backupFilter = 'all';
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector('.filter-btn[onclick="filterBackups(\'all\')"]').classList.add('active');
    
    loadBackups();
}

function closeBackupDialog() {
    document.getElementById('backupDialog').classList.add('hidden');
}

async function loadBackups() {
    if (!currentTheme) return;
    
    const backupList = document.getElementById('backupList');
    backupList.innerHTML = '<div class="loading">⏳ Lade Backups...</div>';
    
    try {
        const response = await fetch(`/api/themes/${currentTheme}/backups`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden der Backups');
        }

        const data = await response.json();
        currentBackups = data.backups || [];
        
        renderBackupList();
        
    } catch (error) {
        console.error('❌ Error loading backups:', error);
        backupList.innerHTML = `<div class="error">❌ ${error.message}</div>`;
    }
}

function renderBackupList() {
    const backupList = document.getElementById('backupList');
    
    if (currentBackups.length === 0) {
        backupList.innerHTML = '<div class="no-backups">📭 Keine Backups gefunden</div>';
        return;
    }
    
    // Filter backups
    const filteredBackups = currentBackups.filter(backup => {
        if (backupFilter === 'all') return true;
        return backup.type === backupFilter;
    });
    
    if (filteredBackups.length === 0) {
        backupList.innerHTML = '<div class="no-backups">📭 Keine Backups für diesen Filter</div>';
        return;
    }
    
    const backupHTML = filteredBackups.map(backup => {
        const modulesList = backup.modulesModified && backup.modulesModified.length > 0 
            ? backup.modulesModified.map(mod => `<span class="module-tag">${mod}</span>`).join('')
            : '<span class="module-tag">Keine Änderungen</span>';
            
        const typeIcon = getBackupTypeIcon(backup.type);
        const versionChange = backup.originalVersion !== backup.newVersion 
            ? `<span class="version-change">${backup.originalVersion} → ${backup.newVersion}</span>`
            : `<span class="version-same">v${backup.originalVersion}</span>`;
            
        return `
            <div class="backup-item" data-type="${backup.type}">
                <div class="backup-header">
                    <div class="backup-info">
                        <span class="backup-type">${typeIcon} ${getBackupTypeLabel(backup.type)}</span>
                        <span class="backup-date">${backup.displayName}</span>
                    </div>
                    <div class="backup-meta">
                        <span class="backup-user">👤 ${backup.createdBy}</span>
                        <span class="backup-size">${formatFileSize(backup.size)}</span>
                    </div>
                </div>
                <div class="backup-details">
                    <div class="backup-modules">
                        <strong>Geänderte Module:</strong> ${modulesList}
                    </div>
                    <div class="backup-version">
                        <strong>Version:</strong> ${versionChange}
                    </div>
                </div>
            </div>
        `;
    }).join('');
    
    backupList.innerHTML = backupHTML;
}

function filterBackups(filter) {
    backupFilter = filter;
    
    // Update active filter button
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`.filter-btn[onclick="filterBackups('${filter}')"]`).classList.add('active');
    
    renderBackupList();
}

function getBackupTypeIcon(type) {
    const icons = {
        'manual_save': '💾',
        'theme_clone': '📋',
        'auto_save': '⚡',
        'pre_restore': '🔄'
    };
    return icons[type] || '📁';
}

function getBackupTypeLabel(type) {
    const labels = {
        'manual_save': 'Manueller Save',
        'theme_clone': 'Theme-Klon',
        'auto_save': 'Auto-Save',
        'pre_restore': 'Vor Wiederherstellung'
    };
    return labels[type] || 'Unbekannt';
}

function formatFileSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// === AUDIT TRAIL ===
function showAuditDialog() {
    document.getElementById('auditThemeName').textContent = themeData?.name || currentTheme;
    document.getElementById('auditDialog').classList.remove('hidden');
    loadAuditTrail();
}

function closeAuditDialog() {
    document.getElementById('auditDialog').classList.add('hidden');
}

async function loadAuditTrail() {
    if (!currentTheme) return;
    
    const auditList = document.getElementById('auditList');
    auditList.innerHTML = '<div class="loading">⏳ Lade Audit-Trail...</div>';
    
    try {
        const response = await fetch(`/api/themes/${currentTheme}/audit`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden des Audit-Trails');
        }

        const data = await response.json();
        currentAuditTrail = data.auditTrail || [];
        
        // Update stats
        document.getElementById('totalAuditEntries').textContent = data.totalEntries || 0;
        
        if (data.oldestEntry && data.newestEntry) {
            const oldDate = new Date(data.oldestEntry).toLocaleDateString('de-DE');
            const newDate = new Date(data.newestEntry).toLocaleDateString('de-DE');
            document.getElementById('auditDateRange').textContent = `${oldDate} - ${newDate}`;
        } else {
            document.getElementById('auditDateRange').textContent = 'N/A';
        }
        
        renderAuditTrail();
        
    } catch (error) {
        console.error('❌ Error loading audit trail:', error);
        auditList.innerHTML = `<div class="error">❌ ${error.message}</div>`;
    }
}

function renderAuditTrail() {
    const auditList = document.getElementById('auditList');
    
    if (currentAuditTrail.length === 0) {
        auditList.innerHTML = '<div class="no-audit">📭 Keine Audit-Einträge gefunden</div>';
        return;
    }
    
    const auditHTML = currentAuditTrail.map(entry => {
        const date = new Date(entry.createdAt).toLocaleString('de-DE');
        const typeIcon = getBackupTypeIcon(entry.type || entry.action);
        const typeLabel = getBackupTypeLabel(entry.type || entry.action);
        
        let actionDetails = '';
        if (entry.modulesModified && entry.modulesModified.length > 0) {
            const modulesList = entry.modulesModified.map(mod => `<span class="module-tag">${mod}</span>`).join('');
            actionDetails += `<div><strong>Module:</strong> ${modulesList}</div>`;
        }
        
        if (entry.originalVersion && entry.newVersion && entry.originalVersion !== entry.newVersion) {
            actionDetails += `<div><strong>Version:</strong> ${entry.originalVersion} → ${entry.newVersion}</div>`;
        }
        
        if (entry.sourceTheme && entry.targetTheme) {
            actionDetails += `<div><strong>Klonung:</strong> ${entry.sourceTheme} → ${entry.targetTheme}</div>`;
        }
        
        return `
            <div class="audit-item" data-action="${entry.action || entry.type}">
                <div class="audit-header">
                    <div class="audit-info">
                        <span class="audit-type">${typeIcon} ${typeLabel}</span>
                        <span class="audit-date">${date}</span>
                    </div>
                    <div class="audit-user">👤 ${entry.createdBy}</div>
                </div>
                ${actionDetails ? `<div class="audit-details">${actionDetails}</div>` : ''}
            </div>
        `;
    }).join('');
    
    auditList.innerHTML = auditHTML;
}

function exportAuditTrail() {
    if (currentAuditTrail.length === 0) {
        showMessage('❌ Keine Audit-Daten zum Exportieren vorhanden', 'error');
        return;
    }
    
    const exportData = {
        theme: currentTheme,
        exportDate: new Date().toISOString(),
        totalEntries: currentAuditTrail.length,
        auditTrail: currentAuditTrail
    };
    
    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    
    const link = document.createElement('a');
    link.href = URL.createObjectURL(dataBlob);
    link.download = `${currentTheme}-audit-trail-${new Date().toISOString().slice(0, 10)}.json`;
    link.click();
    
    showMessage('✅ Audit-Trail erfolgreich exportiert!', 'success');
}

function getDisplayName(key) {
    const displayNames = {
        'fontFamily': 'Font Family',
        'fontSize': 'Font Size',
        'fontWeight': 'Font Weight',
        'letterSpacing': 'Letter Spacing',
        'lineHeight': 'Line Height',
        'textTransform': 'Text Transform',
        'surface_dark': 'Surface Dark',
        'surface_medium': 'Surface Medium',
        'surface_light': 'Surface Light',
        'surface_lighter': 'Surface Lighter',
        'surface_gray': 'Surface Gray',
        'slotSize': 'Slot Size',
        'slotSpacing': 'Slot Spacing',
        'backgroundColor': 'Background Color',
        'borderColor': 'Border Color',
        'hoverColor': 'Hover Color',
        'barHeight': 'Bar Height',
        'fillColor': 'Fill Color',
        'textColor': 'Text Color',
        'accentColor': 'Accent Color',
        // Add more as needed
    };
    
    return displayNames[key] || key.charAt(0).toUpperCase() + key.slice(1);
}

// === EXTENDED MODULAR PREVIEW === 
function updatePreview() {
    if (!themeData) return;
    
    const root = document.documentElement;
    
    // Update Colors Module
    updateColorPreview(root);
    
    // Update Typography Module  
    updateTypographyPreview(root);
    
    // Update Spacing Module
    updateSpacingPreview(root);
    
    // Update Radius Module
    updateRadiusPreview(root);
    
    // Update Gaming Module
    updateGamingPreview(root);
    
    // Update Effects Module
    updateEffectsPreview(root);
    
    console.log('🎨 Preview updated for all modules');
}

function updateColorPreview(root) {
    const colors = themeData.colors;
    if (!colors) return;
    
    // Primary Colors
    if (colors.primary) {
        root.style.setProperty('--primary-color', colors.primary.value || colors.primary.main || '#4B3B79');
    }
    if (colors.secondary) {
        root.style.setProperty('--secondary-color', colors.secondary.value || colors.secondary.main || '#D4AF37');
    }
    if (colors.tertiary) {
        root.style.setProperty('--tertiary-color', colors.tertiary.value || colors.tertiary.main || '#808080');
    }
    
    // Status Colors
    if (colors.status) {
        root.style.setProperty('--success-color', colors.status.success || '#10B981');
        root.style.setProperty('--error-color', colors.status.error || '#EF4444');
        root.style.setProperty('--warning-color', colors.status.warning || '#F59E0B');
        root.style.setProperty('--info-color', colors.status.info || '#3B82F6');
    }
    
    // Background Colors
    if (colors.background) {
        root.style.setProperty('--surface-dark', colors.background.surface_dark || '#1E1E2E');
        root.style.setProperty('--surface-light', colors.background.surface_light || '#3A3A52');
        root.style.setProperty('--background-primary', colors.background.primary || '#0D1117');
    }
    
    // Text Colors
    if (colors.text) {
        root.style.setProperty('--text-primary', colors.text.primary || '#E0E0E0');
        root.style.setProperty('--text-secondary', colors.text.secondary || '#B0B0B0');
        root.style.setProperty('--text-muted', colors.text.muted || '#6B7280');
    }
    
    // Fantasy/Gaming Colors
    if (colors.fantasy) {
        root.style.setProperty('--fantasy-magic', colors.fantasy.magic || colors.fantasy?.value || '#9D4EDD');
        root.style.setProperty('--fantasy-nature', colors.fantasy.nature || '#228B22');
        root.style.setProperty('--fantasy-fire', colors.fantasy.fire || '#FF4500');
    }
    
    // Effects Colors
    if (colors.effects) {
        root.style.setProperty('--glow-color', colors.effects.glow || '#9D4EDD');
        root.style.setProperty('--shimmer-color', colors.effects.shimmer || '#FFD700');
    }
}

function updateTypographyPreview(root) {
    const typography = themeData.typography;
    if (!typography) return;
    
    // Primary Font
    if (typography.primaryFont) {
        const fontFamily = `"${typography.primaryFont.family || 'Inter'}", ${typography.primaryFont.fallback || 'sans-serif'}`;
        root.style.setProperty('--font-primary', fontFamily);
    }
    
    // Secondary Font
    if (typography.secondaryFont) {
        const fontFamily = `"${typography.secondaryFont.family || 'Inter'}", ${typography.secondaryFont.fallback || 'sans-serif'}`;
        root.style.setProperty('--font-secondary', fontFamily);
    }
    
    // Heading Sizes
    if (typography.headingSizes) {
        root.style.setProperty('--font-size-h1', typography.headingSizes.h1 || '2.5rem');
        root.style.setProperty('--font-size-h2', typography.headingSizes.h2 || '2rem');
        root.style.setProperty('--font-size-h3', typography.headingSizes.h3 || '1.5rem');
    }
    
    // Body Sizes
    if (typography.bodySizes) {
        root.style.setProperty('--font-size-body', typography.bodySizes.normal || '1rem');
        root.style.setProperty('--font-size-caption', typography.bodySizes.small || '0.875rem');
    }
    
    // Font Weights
    if (typography.fontWeights) {
        root.style.setProperty('--font-weight-normal', typography.fontWeights.normal || '400');
        root.style.setProperty('--font-weight-bold', typography.fontWeights.bold || '600');
    }
}

function updateSpacingPreview(root) {
    const spacing = themeData.spacing;
    if (!spacing) return;
    
    root.style.setProperty('--spacing-xs', spacing.xs || '0.25rem');
    root.style.setProperty('--spacing-sm', spacing.sm || '0.5rem');
    root.style.setProperty('--spacing-md', spacing.md || '1rem');
    root.style.setProperty('--spacing-lg', spacing.lg || '1.5rem');
    root.style.setProperty('--spacing-xl', spacing.xl || '2rem');
    root.style.setProperty('--spacing-xxl', spacing.xxl || '3rem');
}

function updateRadiusPreview(root) {
    const radius = themeData.radius;
    if (!radius) return;
    
    root.style.setProperty('--radius-small', radius.small || '4px');
    root.style.setProperty('--radius-medium', radius.medium || '8px');
    root.style.setProperty('--radius-large', radius.large || '12px');
    root.style.setProperty('--radius-xl', radius.xl || '16px');
}

function updateGamingPreview(root) {
    const gaming = themeData.gaming;
    if (!gaming) return;
    
    // Health Bar Colors
    if (gaming.progress && gaming.progress.health) {
        root.style.setProperty('--health-color', gaming.progress.health.color || '#22C55E');
        root.style.setProperty('--health-bg', gaming.progress.health.background || '#374151');
    }
    
    // Mana Bar Colors
    if (gaming.progress && gaming.progress.mana) {
        root.style.setProperty('--mana-color', gaming.progress.mana.color || '#3B82F6');
        root.style.setProperty('--mana-bg', gaming.progress.mana.background || '#374151');
    }
    
    // Experience Bar Colors
    if (gaming.progress && gaming.progress.experience) {
        root.style.setProperty('--xp-color', gaming.progress.experience.color || '#F59E0B');
        root.style.setProperty('--xp-bg', gaming.progress.experience.background || '#374151');
    }
    
    // Inventory Colors
    if (gaming.inventory) {
        root.style.setProperty('--inventory-slot-bg', gaming.inventory.slotBackground || '#1F2937');
        root.style.setProperty('--inventory-slot-border', gaming.inventory.slotBorder || '#4B5563');
        root.style.setProperty('--inventory-slot-hover', gaming.inventory.slotHover || '#374151');
    }
    
    // HUD Colors
    if (gaming.hud) {
        root.style.setProperty('--hud-bg', gaming.hud.background || 'rgba(0, 0, 0, 0.7)');
        root.style.setProperty('--hud-text', gaming.hud.textColor || '#F3F4F6');
        root.style.setProperty('--hud-value', gaming.hud.valueColor || '#FFD700');
    }
}

function updateEffectsPreview(root) {
    const effects = themeData.effects;
    if (!effects) return;
    
    // Visual Effects
    if (effects.visual) {
        if (effects.visual.glow) {
            root.style.setProperty('--glow-color', effects.visual.glow.color || '#9D4EDD');
            root.style.setProperty('--glow-intensity', effects.visual.glow.intensity || '10px');
        }
        
        if (effects.visual.shimmer) {
            root.style.setProperty('--shimmer-color', effects.visual.shimmer.color || '#FFD700');
        }
        
        if (effects.visual.glass) {
            root.style.setProperty('--glass-bg', effects.visual.glass.background || 'rgba(255, 255, 255, 0.1)');
            root.style.setProperty('--glass-blur', effects.visual.glass.blur || '10px');
        }
    }
    
    // Animation Settings
    if (effects.animations) {
        root.style.setProperty('--animation-duration', effects.animations.duration || '0.3s');
        root.style.setProperty('--animation-easing', effects.animations.easing || 'ease-in-out');
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
        renderModularEditor();
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

// === IMPORT FUNCTIONALITY === 

function showImportDialog() {
    document.getElementById('importDialog').classList.remove('hidden');
    // Reset form
    document.getElementById('importFile').value = '';
    document.getElementById('importJson').value = '';
    document.getElementById('importValidation').classList.add('hidden');
    document.getElementById('importExecuteButton').disabled = true;
    
    // Reset import mode
    document.querySelector('input[name="importMode"][value="new"]').checked = true;
    toggleImportMode();
    
    // Populate existing themes dropdown
    populateTargetThemeSelector();
}

function closeImportDialog() {
    document.getElementById('importDialog').classList.add('hidden');
}

function loadFileContent() {
    const fileInput = document.getElementById('importFile');
    const file = fileInput.files[0];
    
    if (!file) {
        showMessage('❌ Bitte wähle eine Datei aus', 'error');
        return;
    }
    
    if (!file.name.endsWith('.json')) {
        showMessage('❌ Bitte wähle eine JSON-Datei aus', 'error');
        return;
    }
    
    const reader = new FileReader();
    reader.onload = function(e) {
        try {
            const content = e.target.result;
            // Prüfe, ob es valides JSON ist
            JSON.parse(content);
            document.getElementById('importJson').value = content;
            showMessage('✅ Datei erfolgreich geladen', 'success');
        } catch (error) {
            showMessage('❌ Ungültige JSON-Datei: ' + error.message, 'error');
        }
    };
    
    reader.readAsText(file);
}

function validateImport() {
    const jsonContent = document.getElementById('importJson').value.trim();
    
    if (!jsonContent) {
        showMessage('❌ Bitte füge JSON-Inhalt ein oder lade eine Datei', 'error');
        return;
    }
    
    let importData;
    try {
        importData = JSON.parse(jsonContent);
    } catch (error) {
        showMessage('❌ Ungültiges JSON: ' + error.message, 'error');
        return;
    }
    
    const importMode = document.querySelector('input[name="importMode"]:checked').value;
    const validationResults = validateThemeData(importData, importMode);
    displayValidationResults(validationResults);
    
    // Enable import button if validation passed
    const hasErrors = validationResults.some(result => result.type === 'error');
    document.getElementById('importExecuteButton').disabled = hasErrors;
    
    if (!hasErrors) {
        showMessage('✅ Theme-Validierung erfolgreich!', 'success');
    }
}

function validateThemeData(data, importMode = 'new') {
    const results = [];
    
    if (importMode === 'update') {
        // Update mode - more relaxed validation
        const targetTheme = document.getElementById('targetTheme').value;
        if (!targetTheme) {
            results.push({
                type: 'error',
                message: 'Bitte wähle ein Ziel-Theme für das Update aus'
            });
        } else {
            results.push({
                type: 'success',
                message: `Update-Ziel: ${targetTheme} ✓`
            });
        }
        
        // Bundle validation - warn if present (will be ignored)
        if (data.bundle) {
            results.push({
                type: 'warning',
                message: 'Bundle-Konfiguration wird ignoriert (Ziel-Theme behält seine Bundle-Einstellungen)'
            });
        }
        
        // Optional fields for update mode
        const optionalFields = ['name', 'version', 'description'];
        optionalFields.forEach(field => {
            if (data[field]) {
                results.push({
                    type: 'success',
                    message: `${field} wird aktualisiert: ${data[field]} ✓`
                });
            }
        });
        
    } else {
        // New theme mode - strict validation
        const requiredFields = [
            { field: 'name', type: 'string', description: 'Theme-Name' },
            { field: 'version', type: 'string', description: 'Version' },
            { field: 'description', type: 'string', description: 'Beschreibung' }
        ];
        
        requiredFields.forEach(req => {
            if (!data[req.field]) {
                results.push({
                    type: 'error',
                    message: `${req.description} fehlt (${req.field})`
                });
            } else if (typeof data[req.field] !== req.type) {
                results.push({
                    type: 'error',
                    message: `${req.description} muss vom Typ ${req.type} sein`
                });
            } else {
                results.push({
                    type: 'success',
                    message: `${req.description} ✓`
                });
            }
        });
        
        // Bundle validation for new themes
        if (data.bundle) {
            if (typeof data.bundle !== 'object') {
                results.push({
                    type: 'error',
                    message: 'Bundle muss ein Objekt sein'
                });
            } else {
                if (data.bundle.name) {
                    results.push({
                        type: 'success',
                        message: `Bundle-Name: ${data.bundle.name} ✓`
                    });
                } else {
                    results.push({
                        type: 'warning',
                        message: 'Bundle-Name nicht gefunden (wird Standard verwendet)'
                    });
                }
            }
        } else {
            results.push({
                type: 'warning',
                message: 'Keine Bundle-Konfiguration gefunden'
            });
        }
        
        // File name validation for new themes
        if (data.filename) {
            if (!/^[a-z0-9-_]+$/.test(data.filename)) {
                results.push({
                    type: 'error',
                    message: 'Dateiname darf nur Kleinbuchstaben, Zahlen, Bindestriche und Unterstriche enthalten'
                });
            } else {
                results.push({
                    type: 'success',
                    message: `Dateiname: ${data.filename} ✓`
                });
            }
        } else {
            // Generate filename from name
            const generatedFilename = data.name ? data.name.toLowerCase().replace(/[^a-z0-9-_]/g, '-') : 'imported-theme';
            results.push({
                type: 'warning',
                message: `Kein Dateiname gefunden, wird generiert: ${generatedFilename}`
            });
            data.filename = generatedFilename;
        }
    }
    
    // Colors validation (common for both modes)
    if (data.colors) {
        if (typeof data.colors !== 'object') {
            results.push({
                type: 'error',
                message: 'Colors muss ein Objekt sein'
            });
        } else {
            const colorCount = countColors(data.colors);
            results.push({
                type: 'success',
                message: `${colorCount} Farben gefunden ✓`
            });
        }
    } else {
        results.push({
            type: 'warning',
            message: 'Keine Farb-Definition gefunden'
        });
    }
    
    // Content modules validation
    const contentModules = ['typography', 'spacing', 'radius', 'gaming', 'effects'];
    const foundModules = contentModules.filter(module => data[module]);
    if (foundModules.length > 0) {
        results.push({
            type: 'success',
            message: `${foundModules.length} Content-Module gefunden: ${foundModules.join(', ')} ✓`
        });
    }
    
    return results;
}

function countColors(colors) {
    let count = 0;
    for (const [key, value] of Object.entries(colors)) {
        if (typeof value === 'object' && value !== null) {
            count += countColors(value);
        } else if (typeof value === 'string' && value.match(/^#[0-9A-Fa-f]{6}$/)) {
            count++;
        }
    }
    return count;
}

function displayValidationResults(results) {
    const validationDiv = document.getElementById('importValidation');
    const resultsDiv = document.getElementById('validationResults');
    
    resultsDiv.innerHTML = '';
    
    results.forEach(result => {
        const item = document.createElement('div');
        item.className = `validation-item ${result.type}`;
        
        const icon = result.type === 'success' ? '✅' : 
                     result.type === 'error' ? '❌' : '⚠️';
        
        item.innerHTML = `<span class="validation-icon">${icon}</span>${result.message}`;
        resultsDiv.appendChild(item);
    });
    
    validationDiv.classList.remove('hidden');
}

async function executeImport() {
    const jsonContent = document.getElementById('importJson').value.trim();
    const importMode = document.querySelector('input[name="importMode"]:checked').value;
    let importData;
    
    try {
        importData = JSON.parse(jsonContent);
    } catch (error) {
        showMessage('❌ Ungültiges JSON', 'error');
        return;
    }
    
    // Final validation
    const validationResults = validateThemeData(importData, importMode);
    const hasErrors = validationResults.some(result => result.type === 'error');
    
    if (hasErrors) {
        showMessage('❌ Theme hat Validierungsfehler', 'error');
        return;
    }
    
    try {
        let finalThemeData;
        let targetFilename;
        
        if (importMode === 'update') {
            // Update existing theme
            targetFilename = document.getElementById('targetTheme').value;
            
            // Load existing theme
            const existingResponse = await fetch(`/api/themes/${targetFilename}`, {
                headers: {
                    'Authorization': `Bearer ${accessToken}`
                }
            });
            
            if (!existingResponse.ok) {
                throw new Error('Ziel-Theme konnte nicht geladen werden');
            }
            
            const existingTheme = await existingResponse.json();
            
            // Merge import data with existing theme
            finalThemeData = mergeThemeData(existingTheme, importData);
            
        } else {
            // Create new theme
            finalThemeData = importData;
            
            // Generate filename if not present
            if (!finalThemeData.filename) {
                finalThemeData.filename = finalThemeData.name.toLowerCase().replace(/[^a-z0-9-_]/g, '-');
            }
            
            targetFilename = finalThemeData.filename;
        }
        
        // Add metadata
        finalThemeData.lastModified = new Date().toISOString();
        finalThemeData.modifiedBy = document.getElementById('userInfo').textContent;
        
        if (importMode === 'new') {
            finalThemeData.importedAt = new Date().toISOString();
            finalThemeData.importedBy = document.getElementById('userInfo').textContent;
        } else {
            finalThemeData.updatedAt = new Date().toISOString();
            finalThemeData.updatedBy = document.getElementById('userInfo').textContent;
        }
        
        // Save theme
        const response = await fetch(`/api/themes/${targetFilename}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(finalThemeData)
        });
        
        if (response.ok) {
            const action = importMode === 'update' ? 'aktualisiert' : 'importiert';
            showMessage(`✅ Theme "${finalThemeData.name}" erfolgreich ${action}!`, 'success');
            closeImportDialog();
            
            // Reload available themes and select the imported/updated one
            await loadAvailableThemes();
            currentTheme = targetFilename;
            document.getElementById('themeSelector').value = currentTheme;
            await loadTheme(currentTheme);
            
        } else {
            const errorData = await response.json();
            showMessage(`❌ Import fehlgeschlagen: ${errorData.error}`, 'error');
        }
        
    } catch (error) {
        console.error('Import error:', error);
        showMessage('❌ Import fehlgeschlagen: ' + error.message, 'error');
    }
}

function toggleImportMode() {
    const importMode = document.querySelector('input[name="importMode"]:checked').value;
    const existingThemeSelector = document.getElementById('existingThemeSelector');
    
    if (importMode === 'update') {
        existingThemeSelector.classList.remove('hidden');
    } else {
        existingThemeSelector.classList.add('hidden');
    }
}

function populateTargetThemeSelector() {
    const selector = document.getElementById('targetTheme');
    selector.innerHTML = '<option value="">Theme auswählen...</option>';
    
    availableThemes.forEach(theme => {
        const option = document.createElement('option');
        option.value = theme.filename;
        option.textContent = `${theme.name} (${theme.filename})`;
        selector.appendChild(option);
    });
}

function mergeThemeData(existingTheme, importData) {
    // Start with existing theme as base
    const merged = JSON.parse(JSON.stringify(existingTheme));
    
    // Content fields that can be updated
    const updatableFields = [
        'colors', 'typography', 'spacing', 'radius', 
        'gaming', 'effects', 'extensions'
    ];
    
    // Metadata fields that can be updated
    const metadataFields = ['name', 'version', 'description', 'category', 'author'];
    
    // Update content fields
    updatableFields.forEach(field => {
        if (importData[field]) {
            if (typeof importData[field] === 'object' && merged[field]) {
                // Deep merge objects
                merged[field] = deepMerge(merged[field], importData[field]);
            } else {
                // Replace completely
                merged[field] = importData[field];
            }
        }
    });
    
    // Update metadata fields if present
    metadataFields.forEach(field => {
        if (importData[field]) {
            merged[field] = importData[field];
        }
    });
    
    // Keep existing bundle configuration (never overwrite)
    // This is the safety measure requested by the user
    
    return merged;
}

function deepMerge(target, source) {
    const result = JSON.parse(JSON.stringify(target));
    
    for (const key in source) {
        if (source.hasOwnProperty(key)) {
            if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
                if (result[key] && typeof result[key] === 'object') {
                    result[key] = deepMerge(result[key], source[key]);
                } else {
                    result[key] = source[key];
                }
            } else {
                result[key] = source[key];
            }
        }
    }
    
    return result;
}