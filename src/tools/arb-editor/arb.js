/* 🌍 Weltenwind ARB Manager - JavaScript */

// === GLOBALS === 
let accessToken = null;
let arbData = null;
let filteredEntries = [];
let currentLanguage = 'de';
let availableLanguages = [];
let languageExplicitlySelected = false;
let userPermissions = {}; // Store user's ARB permissions

// === INITIALIZATION === 
window.onload = function() {
    const savedToken = localStorage.getItem('weltenwind_access_token');
    const savedUser = localStorage.getItem('weltenwind_user');

    if (savedToken && savedUser) {
        accessToken = savedToken;
        showARBManager(JSON.parse(savedUser));
        loadAvailableLanguages(); // Verfügbare Sprachen laden und dann ARB-Daten
        loadUserPermissions(); // Benutzer-Permissions laden
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
            body: JSON.stringify({ identifier: username, password: password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            accessToken = data.accessToken;
            localStorage.setItem('weltenwind_access_token', accessToken);
            localStorage.setItem('weltenwind_user', JSON.stringify(data.user));
            showARBManager(data.user);
            loadAvailableLanguages(); // Verfügbare Sprachen laden und dann ARB-Daten
            loadUserPermissions(); // Benutzer-Permissions laden
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
function showARBManager(user) {
    document.getElementById('loginContainer').classList.add('hidden');
    document.getElementById('arbManager').classList.remove('hidden');
    document.getElementById('userInfo').textContent = `👤 ${user.username}`;
}

function logout() {
    localStorage.removeItem('weltenwind_access_token');
    localStorage.removeItem('weltenwind_user');
    accessToken = null;
    document.getElementById('loginContainer').classList.remove('hidden');
    document.getElementById('arbManager').classList.add('hidden');
}

// === LANGUAGE MANAGEMENT === 
async function loadAvailableLanguages() {
    try {
        const response = await fetch('/api/arb/languages', {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden der verfügbaren Sprachen');
        }

        const data = await response.json();
        availableLanguages = data.languages || [];
        
        // Language selector befüllen
        const selector = document.getElementById('languageSelector');
        selector.innerHTML = '<option value="">🌐 Sprache wählen...</option>';
        
        for (const lang of availableLanguages) {
            const option = document.createElement('option');
            option.value = lang.code;
            option.textContent = `${getLanguageFlag(lang.code)} ${lang.name} (${lang.keyCount} Keys)${lang.isMaster ? ' 👑' : ''}`;
            selector.appendChild(option);
        }
        
        // Nur Standard-Sprache laden wenn noch keine Sprache explizit ausgewählt wurde
        if (!languageExplicitlySelected) {
            currentLanguage = 'de';
            selector.value = currentLanguage;
            loadARB(currentLanguage);
        } else {
            // Bestehende Sprache im Selector anzeigen
            selector.value = currentLanguage;
        }
        
    } catch (error) {
        showMessage(`❌ Fehler beim Laden der Sprachen: ${error.message}`, 'error');
        // Fallback: Standard-Sprache laden
        loadARB('de');
    }
}

function getLanguageFlag(code) {
    const flags = {
        'de': '🇩🇪',
        'en': '🇬🇧',
        'fr': '🇫🇷',
        'es': '🇪🇸',
        'it': '🇮🇹'
    };
    return flags[code] || '🌐';
}

function loadSelectedLanguage() {
    const selector = document.getElementById('languageSelector');
    const selectedLang = selector.value;
    
    if (selectedLang && selectedLang !== currentLanguage) {
        currentLanguage = selectedLang;
        languageExplicitlySelected = true;
        loadARB(selectedLang);
    }
}

// === ARB DATA LOADING === 
async function loadARB(language = 'de') {
    const container = document.getElementById('arbContainer');
    const languageInfo = availableLanguages.find(l => l.code === language);
    const languageName = languageInfo ? languageInfo.name : language.toUpperCase();
    
    container.innerHTML = `
        <div class="loading">
            <div class="spinner"></div>
            <div>Lade ${languageName} ARB-Einträge...</div>
        </div>
    `;

    try {
        const response = await fetch(`/api/arb/${language}`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden der ARB-Datei');
        }

        const data = await response.json();
        arbData = data;
        filteredEntries = data.entries;
        currentLanguage = language;
        
        // Markiere als explizit ausgewählt wenn nicht Standard-Sprache
        if (language !== 'de') {
            languageExplicitlySelected = true;
        }
        
        // Update language title
        const languageInfo = availableLanguages.find(l => l.code === language);
        const flag = getLanguageFlag(language);
        const name = languageInfo ? languageInfo.name : language.toUpperCase();
        document.getElementById('currentLanguageTitle').textContent = `${flag} ${name}${languageInfo && languageInfo.isMaster ? ' (Master)' : ''}`;
        
        // Update stats
        document.getElementById('keyCount').textContent = data.metadata.keyCount;
        
        // Update save button state - all languages are now editable
        const saveButton = document.getElementById('saveButton');
        saveButton.disabled = false;
        saveButton.textContent = '💾 Speichern';
        saveButton.title = 'ARB-Datei speichern';
        
        // Enable backup button
        const backupButton = document.getElementById('backupButton');
        backupButton.disabled = false;
        
        populateContextFilter();
        renderEntries();
        
        showMessage(`✅ ${name} ARB-Datei erfolgreich geladen`, 'success');
        
    } catch (error) {
        container.innerHTML = `
            <div class="error">
                <strong>❌ Fehler:</strong> ${error.message}
            </div>
        `;
    }
}

// === RENDERING === 
function renderEntries() {
    const container = document.getElementById('arbContainer');
    
    if (filteredEntries.length === 0) {
        container.innerHTML = `
            <div class="info">
                <strong>ℹ️ Keine Einträge gefunden</strong><br>
                ${document.getElementById('searchBox').value ? 'Versuche einen anderen Suchbegriff.' : 'Die ARB-Datei ist leer.'}
            </div>
        `;
        return;
    }

    container.innerHTML = filteredEntries.map((entry, index) => `
        <div class="arb-entry">
            <div class="arb-key">${entry.key}</div>
            <div class="arb-value">
                <textarea 
                    data-key="${entry.key}" 
                    onchange="updateEntry('${entry.key}', this.value)"
                >${entry.value}</textarea>
            </div>
            ${entry.metadata ? `
                <div class="arb-metadata">
                    ${entry.metadata.description ? `📝 <strong>Beschreibung:</strong> ${entry.metadata.description}<br>` : ''}
                    ${entry.metadata.context ? `🏷️ <strong>Kontext:</strong> ${entry.metadata.context}<br>` : ''}
                    ${entry.metadata.placeholders ? `🔣 <strong>Platzhalter:</strong> ${Object.keys(entry.metadata.placeholders).join(', ')}` : ''}
                </div>
            ` : ''}
        </div>
    `).join('');
}

// === DATA MANIPULATION === 
function updateEntry(key, value) {
    const entry = arbData.entries.find(e => e.key === key);
    if (entry) {
        // Input sofort sanitisieren
        const sanitizedValue = sanitizeInput(value);
        entry.value = sanitizedValue;
        
        // Textarea aktualisieren falls sanitized
        if (sanitizedValue !== value) {
            const textarea = document.querySelector(`textarea[data-key="${key}"]`);
            if (textarea) {
                textarea.value = sanitizedValue;
                showMessage('⚠️ Eingabe wurde aus Sicherheitsgründen bereinigt', 'info');
            }
        }
    }
}

function populateContextFilter() {
    const contextFilter = document.getElementById('contextFilter');
    const contexts = new Set();
    
    // Sammle alle verfügbaren Kontexte
    arbData.entries.forEach(entry => {
        if (entry.metadata && entry.metadata.context) {
            contexts.add(entry.metadata.context);
        }
    });
    
    // Sortiere Kontexte alphabetisch
    const sortedContexts = Array.from(contexts).sort();
    
    // Aktuelle Auswahl merken
    const currentValue = contextFilter.value;
    
    // Dropdown neu befüllen
    contextFilter.innerHTML = '<option value="">🏷️ Alle Kontexte</option>';
    sortedContexts.forEach(context => {
        const option = document.createElement('option');
        option.value = context;
        option.textContent = `🏷️ ${context}`;
        contextFilter.appendChild(option);
    });
    
    // Auswahl wiederherstellen
    contextFilter.value = currentValue;
}

// === FILTERING === 
function filterEntries() {
    const search = document.getElementById('searchBox').value.toLowerCase();
    const selectedContext = document.getElementById('contextFilter').value;
    
    if (!search && !selectedContext) {
        filteredEntries = arbData.entries;
    } else {
        filteredEntries = arbData.entries.filter(entry => {
            // Text-Filter
            const matchesSearch = !search || 
                entry.key.toLowerCase().includes(search) || 
                entry.value.toLowerCase().includes(search);
            
            // Kontext-Filter
            const matchesContext = !selectedContext || 
                (entry.metadata && entry.metadata.context === selectedContext);
            
            return matchesSearch && matchesContext;
        });
    }
    
    renderEntries();
    
    // Update filtered count display
    const totalCount = arbData.entries.length;
    const filteredCount = filteredEntries.length;
    if (filteredCount !== totalCount) {
        document.getElementById('keyCount').textContent = `${filteredCount} / ${totalCount}`;
    } else {
        document.getElementById('keyCount').textContent = totalCount;
    }
}

// === SAVE FUNCTIONALITY === 
async function showSaveConfirmDialog() {
    if (!arbData || !arbData.entries) {
        showMessage('❌ Keine ARB-Daten zum Speichern', 'error');
        return;
    }
    
    // Update save stats
    document.getElementById('saveKeyCount').textContent = arbData.entries.length;
    
    // Calculate changed entries (simplified - shows all as potentially changed)
    const changedCount = arbData.entries.filter(entry => entry.value && entry.value.trim().length > 0).length;
    document.getElementById('saveChangedCount').textContent = changedCount;
    
    // Show current language
    const currentLang = availableLanguages.find(lang => lang.code === currentLanguage);
    const languageDisplay = currentLang ? `${currentLang.flag} ${currentLang.name} (${currentLanguage.toUpperCase()})` : currentLanguage.toUpperCase();
    document.getElementById('saveLanguageDisplay').textContent = languageDisplay;
    
    // Show dialog
    document.getElementById('saveConfirmDialog').classList.remove('hidden');
}

function closeSaveConfirmDialog() {
    document.getElementById('saveConfirmDialog').classList.add('hidden');
}

async function confirmSave() {
    // Close confirmation dialog
    closeSaveConfirmDialog();
    
    // Proceed with actual save
    await saveARB();
}

async function saveARB() {
    const button = document.getElementById('saveButton');
    button.disabled = true;
    button.textContent = '💾 Speichert...';

    // Debug: Aktuelle Sprache loggen
    console.log(`🔄 Speichere ARB für Sprache: ${currentLanguage}`);

    try {
        // Alle Einträge vor dem Speichern validieren und sanitisieren
        const sanitizedEntries = [];
        const validationErrors = [];
        
        for (const entry of arbData.entries) {
            const sanitizedValue = sanitizeInput(entry.value);
            const errors = validateARBEntry(entry.key, sanitizedValue);
            
            if (errors.length > 0) {
                validationErrors.push(`${entry.key}: ${errors.join(', ')}`);
            } else {
                sanitizedEntries.push({
                    key: entry.key,
                    value: sanitizedValue,
                    metadata: entry.metadata
                });
            }
        }
        
        if (validationErrors.length > 0) {
            throw new Error(`Validierungsfehler:\n${validationErrors.join('\n')}`);
        }

        const response = await fetch(`/api/arb/${currentLanguage}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                entries: sanitizedEntries
            })
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Speichern der ARB-Datei');
        }

        const data = await response.json();
        showMessage(`✅ ${data.message}<br><small>💡 ${data.nextStep}</small>`, 'success');
        
    } catch (error) {
        showMessage(`❌ ${error.message}`, 'error');
    } finally {
        button.disabled = false;
        button.textContent = '💾 Speichern';
    }
}

// === BACKUP MANAGEMENT ===

async function showBackupDialog() {
    const dialog = document.getElementById('backupDialog');
    const languageName = document.getElementById('backupLanguageName');
    const backupList = document.getElementById('backupList');
    
    // Zeige aktuellen Sprachnamen
    const currentLang = availableLanguages.find(lang => lang.code === currentLanguage);
    languageName.textContent = currentLang ? `${currentLang.flag} ${currentLang.name}` : currentLanguage.toUpperCase();
    
    // Dialog anzeigen
    dialog.classList.remove('hidden');
    
    // Backups laden
    await loadBackups();
}

function closeBackupDialog() {
    const dialog = document.getElementById('backupDialog');
    dialog.classList.add('hidden');
}

async function loadBackups() {
    const backupList = document.getElementById('backupList');
    
    // Loading state
    backupList.innerHTML = `
        <div class="loading">
            <div class="spinner"></div>
            <div>Lade Backups...</div>
        </div>
    `;
    
    try {
        const response = await fetch(`/api/arb/${currentLanguage}/backups`, {
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
        
        // Store data for new filter system
        currentARBBackups = data.backups || [];
        
        console.log('🗂️ ARB Backups loaded:', currentARBBackups.length, 'backups');
        
        // Reset filter to 'all'
        arbBackupFilter = 'all';
        document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
        const allFilterBtn = document.querySelector('.filter-btn[onclick="filterARBBackups(\'all\')"]');
        if (allFilterBtn) allFilterBtn.classList.add('active');
        
        // Use new render system
        renderARBBackupList();
        
    } catch (error) {
        backupList.innerHTML = `
            <div class="backup-empty">
                <p>❌ ${error.message}</p>
            </div>
        `;
    }
}

async function deleteBackup(timestamp, displayName) {
    // Permission Check
    if (!hasPermission('arb.backup.delete')) {
        showMessage('❌ Keine Berechtigung für Backup-Löschung', 'error');
        return;
    }
    
    if (!confirm(`Möchtest du das Backup "${displayName}" wirklich löschen?\n\nDiese Aktion kann nicht rückgängig gemacht werden.`)) {
        return;
    }
    
    try {
        const response = await fetch(`/api/arb/${currentLanguage}/backups/${timestamp}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (response.status === 401) {
            logout();
            return;
        }
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Fehler beim Löschen');
        }
        
        const data = await response.json();
        
        // Erfolgsmeldung anzeigen
        showMessage(`✅ ${data.message}`, 'success');
        
        // Backup-Liste neu laden
        await loadBackups();
        
    } catch (error) {
        showMessage(`❌ ${error.message}`, 'error');
    }
}

async function restoreBackup(timestamp) {
    // Permission Check
    if (!hasPermission('arb.backup.restore')) {
        showMessage('❌ Keine Berechtigung für Backup-Wiederherstellung', 'error');
        return;
    }
    
    if (!confirm(`Möchtest du das Backup vom ${timestamp.replace('_', ' um ').replace(/-/g, '.')} wiederherstellen?\n\nDie aktuelle Version wird automatisch als Backup gesichert.`)) {
        return;
    }
    
    try {
        const response = await fetch(`/api/arb/${currentLanguage}/restore/${timestamp}`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (response.status === 401) {
            logout();
            return;
        }
        
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Fehler beim Wiederherstellen');
        }
        
        const data = await response.json();
        
        // Dialog schließen
        closeBackupDialog();
        
        // Erfolgsmeldung anzeigen
        showMessage(`✅ ${data.message}<br><small>💡 ${data.nextStep}</small>`, 'success');
        
        // Nach kurzer Verzögerung neu laden
        setTimeout(() => {
            location.reload();
        }, 2000);
        
    } catch (error) {
        showMessage(`❌ ${error.message}`, 'error');
    }
}

// === MULTI-LANGUAGE COMPARE VIEW ===
let compareData = null;
let compareViewActive = false;
let filteredCompareEntries = [];
let selectedTargetLanguage = null; // Will be set to first available non-master language

async function toggleCompareView() {
    const compareContainer = document.getElementById('compareContainer');
    const arbContainer = document.getElementById('arbContainer');
    const compareButton = document.getElementById('compareButton');
    
    if (!compareViewActive) {
        // Switch to compare view
        await loadCompareView();
    } else {
        // Switch back to normal view
        compareContainer.classList.add('hidden');
        arbContainer.classList.remove('hidden');
        compareViewActive = false;
        compareButton.textContent = '📊 Vergleichsansicht';
        compareButton.classList.remove('btn-success');
    }
}

async function loadCompareView() {
    const compareContainer = document.getElementById('compareContainer');
    const arbContainer = document.getElementById('arbContainer');
    const compareButton = document.getElementById('compareButton');
    
    try {
        // Show loading state
        const compareLoading = document.querySelector('.compare-loading');
        const compareTable = document.getElementById('compareTable');
        
        compareLoading.classList.remove('hidden');
        compareTable.classList.add('hidden');
        
        // Switch to compare view
        arbContainer.classList.add('hidden');
        compareContainer.classList.remove('hidden');
        compareViewActive = true;
        compareButton.textContent = '📝 Einzelansicht';
        compareButton.classList.add('btn-success');
        
        // Load compare data from API
        const response = await fetch('/api/arb/compare', {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden der Vergleichsdaten');
        }

        compareData = await response.json();
        
        // Populate the compare view
        populateCompareStatistics();
        populateLanguageReportCards();
        populateTargetLanguageSelector();
        updateCompareView();
        
        // Initialize filters
        filteredCompareEntries = [...Object.keys(compareData.comparisonMatrix[compareData.masterLanguage] || {})];
        filterCompareEntries();
        
        // Hide loading, show table
        compareLoading.classList.add('hidden');
        compareTable.classList.remove('hidden');
        
        showMessage('📊 Multi-Language Vergleichsansicht geladen!', 'success');
        
    } catch (error) {
        showMessage(`❌ Fehler beim Laden der Vergleichsansicht: ${error.message}`, 'error');
        
        // Switch back to normal view on error
        compareContainer.classList.add('hidden');
        arbContainer.classList.remove('hidden');
        compareViewActive = false;
        compareButton.textContent = '📊 Vergleichsansicht';
        compareButton.classList.remove('btn-success');
    }
}

function populateCompareStatistics() {
    if (!compareData || !compareData.statistics) return;
    
    document.getElementById('compareLanguageCount').textContent = compareData.statistics.totalLanguages;
    document.getElementById('compareTotalKeys').textContent = compareData.statistics.masterKeyCount;
    document.getElementById('compareAvgCompleteness').textContent = compareData.statistics.averageCompleteness.toFixed(1) + '%';
    document.getElementById('compareMissingLanguages').textContent = compareData.statistics.languagesWithMissingKeys;
}

function populateLanguageReportCards() {
    if (!compareData || !compareData.languages) return;
    
    const reportCardsContainer = document.getElementById('languageReportCards');
    reportCardsContainer.innerHTML = '';
    
    compareData.languages.forEach(lang => {
        const report = compareData.missingKeysReport[lang.code];
        if (!report) return;
        
        const completenessValue = parseFloat(report.completeness);
        const cardClass = lang.isMaster ? 'master' : 
                         completenessValue < 50 ? 'missing-keys' : 
                         completenessValue < 100 ? 'incomplete' : '';
        
        const completenessClass = completenessValue >= 90 ? '' :
                                 completenessValue >= 70 ? 'warning' : 'danger';
        
        const card = document.createElement('div');
        card.className = `language-card ${cardClass}`;
        card.innerHTML = `
            <div class="language-card-header">
                <div>
                    <span class="language-flag">${getLanguageFlag(lang.code)}</span>
                    <span class="language-name">${lang.name}</span>
                </div>
                <span class="language-badge ${lang.isMaster ? 'master' : 'target'}">
                    ${lang.isMaster ? 'Master' : 'Target'}
                </span>
            </div>
            
            <div class="language-metrics">
                <div class="metric">
                    <span class="metric-value">${lang.keyCount}</span>
                    <span class="metric-label">Keys</span>
                </div>
                <div class="metric">
                    <span class="metric-value">${report.missingCount}</span>
                    <span class="metric-label">Fehlend</span>
                </div>
                <div class="metric">
                    <span class="metric-value">${report.extraCount}</span>
                    <span class="metric-label">Extra</span>
                </div>
                <div class="metric">
                    <span class="metric-value">${report.completeness}%</span>
                    <span class="metric-label">Vollständig</span>
                </div>
            </div>
            
            <div class="completeness-bar">
                <div class="completeness-fill ${completenessClass}" style="width: ${report.completeness}%"></div>
            </div>
        `;
        
        reportCardsContainer.appendChild(card);
    });
}

function populateTargetLanguageSelector() {
    if (!compareData || !compareData.languages) return;
    
    const selector = document.getElementById('compareTargetLanguage');
    selector.innerHTML = '<option value="">Zielsprache wählen...</option>';
    
    // Add all non-master languages
    const targetLanguages = compareData.languages.filter(lang => !lang.isMaster);
    targetLanguages.forEach(lang => {
        const option = document.createElement('option');
        option.value = lang.code;
        option.textContent = `${getLanguageFlag(lang.code)} ${lang.name}`;
        
        // Select first available language as default
        if (!selectedTargetLanguage) {
            selectedTargetLanguage = lang.code;
            option.selected = true;
        } else if (selectedTargetLanguage === lang.code) {
            option.selected = true;
        }
        
        selector.appendChild(option);
    });
}

function updateCompareView() {
    const selector = document.getElementById('compareTargetLanguage');
    selectedTargetLanguage = selector.value;
    
    if (selectedTargetLanguage) {
        populateCompareTable();
        filterCompareEntries();
    }
}

function populateCompareTable() {
    if (!compareData || !compareData.comparisonMatrix || !selectedTargetLanguage) return;
    
    const tableHeader = document.getElementById('compareTableHeader');
    const tableBody = document.getElementById('compareTableBody');
    
    // Clear existing content
    tableHeader.innerHTML = '';
    tableBody.innerHTML = '';
    
    // Find master and target languages
    const masterLang = compareData.languages.find(lang => lang.isMaster);
    const targetLang = compareData.languages.find(lang => lang.code === selectedTargetLanguage);
    
    if (!masterLang || !targetLang) return;
    
    // Create header - only 2 columns: Master + Selected
    const keyHeader = document.createElement('th');
    keyHeader.textContent = '🔑 ARB Key';
    tableHeader.appendChild(keyHeader);
    
    const masterHeader = document.createElement('th');
    masterHeader.className = 'language-header';
    masterHeader.innerHTML = `${getLanguageFlag(masterLang.code)} ${masterLang.name} (Master)`;
    tableHeader.appendChild(masterHeader);
    
    const targetHeader = document.createElement('th');
    targetHeader.className = 'language-header';
    targetHeader.innerHTML = `${getLanguageFlag(targetLang.code)} ${targetLang.name}`;
    tableHeader.appendChild(targetHeader);
    
    // Create rows for all keys from master language
    const masterKeys = Object.keys(compareData.comparisonMatrix[compareData.masterLanguage] || {});
    
    masterKeys.forEach(key => {
        const row = document.createElement('tr');
        row.dataset.key = key;
        
        // Key column
        const keyCell = document.createElement('td');
        keyCell.innerHTML = `<div class="compare-row-key">${key}</div>`;
        row.appendChild(keyCell);
        
        // Master language column
        const masterCell = document.createElement('td');
        const masterData = compareData.comparisonMatrix[masterLang.code][key];
        if (masterData && masterData.present && masterData.value) {
            masterCell.innerHTML = `
                <div class="compare-cell">
                    <div class="compare-value master present">${masterData.value}</div>
                    <span class="compare-status-icon present">✅</span>
                </div>
            `;
        } else {
            masterCell.innerHTML = `
                <div class="compare-cell">
                    <div class="compare-value missing">❌ Fehlt</div>
                    <span class="compare-status-icon missing">❌</span>
                </div>
            `;
        }
        row.appendChild(masterCell);
        
        // Target language column
        const targetCell = document.createElement('td');
        const targetData = compareData.comparisonMatrix[targetLang.code][key];
        if (targetData && targetData.present && targetData.value) {
            targetCell.innerHTML = `
                <div class="compare-cell">
                    <div class="compare-value present">${targetData.value}</div>
                    <span class="compare-status-icon present">✅</span>
                </div>
            `;
        } else {
            targetCell.innerHTML = `
                <div class="compare-cell">
                    <div class="compare-value missing">❌ Fehlt</div>
                    <span class="compare-status-icon missing">❌</span>
                </div>
            `;
        }
        row.appendChild(targetCell);
        
        tableBody.appendChild(row);
    });
}

function filterCompareEntries() {
    if (!compareData || !selectedTargetLanguage) return;
    
    const filterValue = document.getElementById('compareKeyFilter').value;
    const searchValue = document.getElementById('compareSearchBox').value.toLowerCase();
    const masterKeys = Object.keys(compareData.comparisonMatrix[compareData.masterLanguage] || {});
    
    // Apply filters
    let filtered = masterKeys;
    
    // Apply key filter - only consider master and selected target language
    if (filterValue === 'missing') {
        // Show keys that are missing in the target language
        filtered = masterKeys.filter(key => {
            const targetData = compareData.comparisonMatrix[selectedTargetLanguage][key];
            return !targetData || !targetData.present;
        });
    } else if (filterValue === 'complete') {
        // Show keys that are present in both master and target
        filtered = masterKeys.filter(key => {
            const masterData = compareData.comparisonMatrix[compareData.masterLanguage][key];
            const targetData = compareData.comparisonMatrix[selectedTargetLanguage][key];
            return (masterData && masterData.present) && (targetData && targetData.present);
        });
    } else if (filterValue === 'incomplete') {
        // Show keys that are present in master but missing in target
        filtered = masterKeys.filter(key => {
            const masterData = compareData.comparisonMatrix[compareData.masterLanguage][key];
            const targetData = compareData.comparisonMatrix[selectedTargetLanguage][key];
            return (masterData && masterData.present) && (!targetData || !targetData.present);
        });
    }
    
    // Apply search filter
    if (searchValue) {
        filtered = filtered.filter(key => {
            // Search in key name
            if (key.toLowerCase().includes(searchValue)) return true;
            
            // Search in master value
            const masterData = compareData.comparisonMatrix[compareData.masterLanguage][key];
            if (masterData && masterData.value && masterData.value.toLowerCase().includes(searchValue)) {
                return true;
            }
            
            // Search in target value
            const targetData = compareData.comparisonMatrix[selectedTargetLanguage][key];
            if (targetData && targetData.value && targetData.value.toLowerCase().includes(searchValue)) {
                return true;
            }
            
            return false;
        });
    }
    
    // Update table visibility
    const tableBody = document.getElementById('compareTableBody');
    const rows = tableBody.querySelectorAll('tr');
    
    rows.forEach(row => {
        const key = row.dataset.key;
        if (filtered.includes(key)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
    
    // Update filtered count in title
    const title = document.querySelector('.compare-title h3');
    const totalKeys = masterKeys.length;
    const filteredCount = filtered.length;
    
    const targetLang = compareData.languages.find(lang => lang.code === selectedTargetLanguage);
    const targetName = targetLang ? targetLang.name : selectedTargetLanguage;
    
    if (filteredCount === totalKeys) {
        title.textContent = `📊 Vergleich: Deutsch ↔ ${targetName}`;
    } else {
        title.textContent = `📊 Vergleich: Deutsch ↔ ${targetName} (${filteredCount}/${totalKeys} Keys)`;
    }
}

// === SECURITY === 
function sanitizeInput(text) {
    if (typeof text !== 'string') return '';
    
    // XSS-gefährliche Patterns entfernen/escapen
    return text
        // HTML-Tags escapen
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        // JavaScript-Events entfernen (erweitert)
        .replace(/on\w+\s*=/gi, '')
        .replace(/on\w+\s*\(/gi, 'blocked(')
        // Script-Tags komplett entfernen
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        // JavaScript-URLs entfernen
        .replace(/javascript:/gi, 'blocked:')
        .replace(/vbscript:/gi, 'blocked:')
        // Data-URLs mit JavaScript entfernen
        .replace(/data:\s*text\/html/gi, 'blocked:text/html')
        .replace(/data:\s*application\/javascript/gi, 'blocked:javascript')
        // Expression() und eval() blockieren
        .replace(/expression\s*\(/gi, 'blocked(')
        .replace(/eval\s*\(/gi, 'blocked(')
        // Führende/Trailing Whitespace entfernen
        .trim();
}

function detectXSSPatterns(text) {
    if (typeof text !== 'string') return [];
    
    const xssPatterns = [
        // Script-Tags und Events
        /<script\b/gi,
        /on\w+\s*=/gi,
        /javascript:/gi,
        /vbscript:/gi,
        // Gefährliche Functions
        /eval\s*\(/gi,
        /expression\s*\(/gi,
        /setTimeout\s*\(/gi,
        /setInterval\s*\(/gi,
        // Data-URLs
        /data:\s*text\/html/gi,
        /data:\s*application\/javascript/gi,
        // Meta-Tags
        /<meta\b[^>]*http-equiv/gi,
        // Iframe/Object/Embed
        /<iframe\b/gi,
        /<object\b/gi,
        /<embed\b/gi,
        // Form-Actions
        /<form\b[^>]*action/gi
    ];
    
    const detectedPatterns = [];
    for (const pattern of xssPatterns) {
        if (pattern.test(text)) {
            detectedPatterns.push(pattern.toString());
        }
    }
    
    return detectedPatterns;
}

function validateARBEntry(key, value) {
    const errors = [];
    
    // Key-Validation
    if (!key || typeof key !== 'string') {
        errors.push('Key ist erforderlich');
    } else if (key.length > 100) {
        errors.push('Key zu lang (max. 100 Zeichen)');
    } else if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(key)) {
        errors.push('Key darf nur Buchstaben, Zahlen und _ enthalten');
    }
    
    // Value-Validation
    if (typeof value !== 'string') {
        errors.push('Value muss ein String sein');
    } else if (value.length > 1000) {
        errors.push('Value zu lang (max. 1000 Zeichen)');
    }
    
    // XSS-Pattern Detection
    const xssPatterns = detectXSSPatterns(value);
    if (xssPatterns.length > 0) {
        errors.push(`Gefährliche Patterns erkannt: ${xssPatterns.length} XSS-Risiken`);
    }
    
    // Zusätzliche Content-Validierung für ARB-Strings
    if (value.includes('\0')) {
        errors.push('Null-Bytes nicht erlaubt');
    }
    
    // Übermäßige Sonderzeichen prüfen
    const specialCharCount = (value.match(/[<>'"&;(){}[\]]/g) || []).length;
    if (specialCharCount > value.length * 0.3) {
        errors.push('Zu viele Sonderzeichen (verdächtig)');
    }
    
    return errors;
}

// === EXPORT FUNCTIONALITY === 
function showExportDialog() {
    if (!arbData || !arbData.entries) {
        showMessage('❌ Keine ARB-Daten geladen', 'error');
        return;
    }
    
    // Update export info
    document.getElementById('exportKeyCount').textContent = `${arbData.entries.length} Keys`;
    
    // Show dialog
    document.getElementById('exportDialog').classList.remove('hidden');
}

function closeExportDialog() {
    document.getElementById('exportDialog').classList.add('hidden');
}

async function exportARB(format) {
    if (!arbData || !arbData.entries) {
        showMessage('❌ Keine ARB-Daten zum Exportieren', 'error');
        return;
    }
    
    try {
        let exportData;
        let filename;
        let mimeType;
        
        if (format === 'arb') {
            // Standard ARB-Format erstellen
            const arbContent = {};
            
            for (const entry of arbData.entries) {
                arbContent[entry.key] = entry.value;
                
                if (entry.metadata) {
                    arbContent[`@${entry.key}`] = entry.metadata;
                }
            }
            
            exportData = JSON.stringify(arbContent, null, 2);
            filename = `app_de_export_${new Date().toISOString().slice(0, 10)}.arb`;
            mimeType = 'application/json';
            
        } else if (format === 'json') {
            // Strukturiertes JSON-Format
            const jsonContent = {
                metadata: {
                    language: 'de',
                    exportDate: new Date().toISOString(),
                    keyCount: arbData.entries.length,
                    exportedBy: 'Weltenwind ARB Manager'
                },
                entries: arbData.entries
            };
            
            exportData = JSON.stringify(jsonContent, null, 2);
            filename = `weltenwind_arb_export_${new Date().toISOString().slice(0, 10)}.json`;
            mimeType = 'application/json';
        }
        
        // Download erstellen
        const blob = new Blob([exportData], { type: mimeType });
        const url = URL.createObjectURL(blob);
        
        const downloadLink = document.createElement('a');
        downloadLink.href = url;
        downloadLink.download = filename;
        downloadLink.style.display = 'none';
        
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
        
        // URL wieder freigeben
        URL.revokeObjectURL(url);
        
        closeExportDialog();
        showMessage(`✅ Export erfolgreich: ${filename}`, 'success');
        
    } catch (error) {
        showMessage(`❌ Export-Fehler: ${error.message}`, 'error');
    }
}

// ESC-Key zum Schließen der Dialoge
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const exportDialog = document.getElementById('exportDialog');
        if (!exportDialog.classList.contains('hidden')) {
            closeExportDialog();
            return;
        }
        
        const importPreviewDialog = document.getElementById('importPreviewDialog');
        if (!importPreviewDialog.classList.contains('hidden')) {
            closeImportPreview();
            return;
        }
        
        const importDialog = document.getElementById('importDialog');
        if (!importDialog.classList.contains('hidden')) {
            closeImportDialog();
            return;
        }
        
        const saveConfirmDialog = document.getElementById('saveConfirmDialog');
        if (!saveConfirmDialog.classList.contains('hidden')) {
            closeSaveConfirmDialog();
            return;
        }
        
        const backupDialog = document.getElementById('backupDialog');
        if (!backupDialog.classList.contains('hidden')) {
            closeBackupDialog();
            return;
        }
        
        // Close compare view if active
        if (compareViewActive) {
            toggleCompareView();
            return;
        }
    }
});

// Click außerhalb des Dialogs zum Schließen
document.addEventListener('click', function(e) {
    const exportDialog = document.getElementById('exportDialog');
    if (!exportDialog.classList.contains('hidden')) {
        if (e.target.classList.contains('dialog-overlay')) {
            closeExportDialog();
        }
    }
    
    const importDialog = document.getElementById('importDialog');
    if (!importDialog.classList.contains('hidden')) {
        if (e.target.classList.contains('dialog-overlay')) {
            closeImportDialog();
        }
    }
    
    const importPreviewDialog = document.getElementById('importPreviewDialog');
    if (!importPreviewDialog.classList.contains('hidden')) {
        if (e.target.classList.contains('dialog-overlay')) {
            closeImportPreview();
        }
    }
    
    const saveConfirmDialog = document.getElementById('saveConfirmDialog');
    if (!saveConfirmDialog.classList.contains('hidden')) {
        if (e.target.classList.contains('dialog-overlay')) {
            closeSaveConfirmDialog();
        }
    }
    
    const backupDialog = document.getElementById('backupDialog');
    if (!backupDialog.classList.contains('hidden')) {
        if (e.target.classList.contains('dialog-overlay')) {
            closeBackupDialog();
        }
    }
});

// === IMPORT FUNCTIONALITY === 
let importData = null;
let importPreviewData = null;

function showImportDialog() {
    // Reset dialog state
    document.getElementById('importFileInput').value = '';
    document.getElementById('importFileName').textContent = '';
    document.getElementById('importInfo').classList.add('hidden');
    document.getElementById('importError').classList.add('hidden');
    document.getElementById('importPreviewButton').disabled = true;
    importData = null;
    
    // Show dialog
    document.getElementById('importDialog').classList.remove('hidden');
}

function closeImportDialog() {
    document.getElementById('importDialog').classList.add('hidden');
}

function closeImportPreview() {
    document.getElementById('importPreviewDialog').classList.add('hidden');
}

// File input handler
document.addEventListener('DOMContentLoaded', function() {
    const fileInput = document.getElementById('importFileInput');
    if (fileInput) {
        fileInput.addEventListener('change', handleImportFile);
    }
});

async function handleImportFile(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    const errorDiv = document.getElementById('importError');
    const infoDiv = document.getElementById('importInfo');
    const previewButton = document.getElementById('importPreviewButton');
    
    // Reset state
    errorDiv.classList.add('hidden');
    infoDiv.classList.add('hidden');
    previewButton.disabled = true;
    importData = null;
    
    try {
        // Validate file type
        const fileExtension = file.name.split('.').pop().toLowerCase();
        if (!['arb', 'json'].includes(fileExtension)) {
            throw new Error('Nur .arb und .json Dateien sind erlaubt');
        }
        
        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
            throw new Error('Datei zu groß (max. 5MB)');
        }
        
        // Read file content
        const fileContent = await readFileAsText(file);
        
        // Parse and validate content
        let parsedData;
        try {
            parsedData = JSON.parse(fileContent);
        } catch (e) {
            throw new Error('Ungültiges JSON-Format');
        }
        
        // Process different formats
        let entries = [];
        let format = '';
        
        if (parsedData.entries && Array.isArray(parsedData.entries)) {
            // Structured JSON format (from our export)
            entries = parsedData.entries;
            format = 'Strukturiertes JSON (Weltenwind Export)';
        } else {
            // Standard ARB format
            const keys = Object.keys(parsedData).filter(key => !key.startsWith('@'));
            for (const key of keys) {
                const metaKey = `@${key}`;
                entries.push({
                    key,
                    value: parsedData[key],
                    metadata: parsedData[metaKey] || null
                });
            }
            format = 'Standard ARB-Format';
        }
        
        // Validate entries
        const validationErrors = [];
        const sanitizedEntries = [];
        
        for (const entry of entries) {
            if (!entry.key || typeof entry.value !== 'string') {
                validationErrors.push(`Ungültiger Eintrag: ${entry.key || 'unbekannt'}`);
                continue;
            }
            
            // Sanitize and validate
            const sanitizedValue = sanitizeInput(entry.value);
            const errors = validateARBEntry(entry.key, sanitizedValue);
            
            if (errors.length > 0) {
                validationErrors.push(`${entry.key}: ${errors.join(', ')}`);
                continue;
            }
            
            sanitizedEntries.push({
                key: entry.key,
                value: sanitizedValue,
                metadata: entry.metadata
            });
        }
        
        if (validationErrors.length > 0 && sanitizedEntries.length === 0) {
            throw new Error(`Keine gültigen Einträge gefunden:\n${validationErrors.join('\n')}`);
        }
        
        // Store validated data
        importData = {
            originalEntries: entries,
            sanitizedEntries: sanitizedEntries,
            validationErrors: validationErrors
        };
        
        // Update UI
        document.getElementById('importFileName').textContent = `📁 ${file.name}`;
        document.getElementById('importFileSize').textContent = `Größe: ${formatFileSize(file.size)}`;
        document.getElementById('importKeyCount').textContent = `Keys: ${sanitizedEntries.length}${validationErrors.length > 0 ? ` (${validationErrors.length} Fehler)` : ''}`;
        document.getElementById('importFormat').textContent = `Format: ${format}`;
        
        infoDiv.classList.remove('hidden');
        previewButton.disabled = false;
        
        // Show validation warnings if any
        if (validationErrors.length > 0) {
            errorDiv.innerHTML = `⚠️ ${validationErrors.length} Einträge wurden aufgrund von Validierungsfehlern übersprungen.`;
            errorDiv.classList.remove('hidden');
        }
        
    } catch (error) {
        errorDiv.textContent = `❌ ${error.message}`;
        errorDiv.classList.remove('hidden');
    }
}

function readFileAsText(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = e => resolve(e.target.result);
        reader.onerror = e => reject(new Error('Fehler beim Lesen der Datei'));
        reader.readAsText(file);
    });
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function showImportPreview() {
    if (!importData || !arbData) {
        showMessage('❌ Keine Import-Daten verfügbar', 'error');
        return;
    }
    
    // Analyze changes
    const currentEntries = new Map(arbData.entries.map(e => [e.key, e.value]));
    const newEntries = importData.sanitizedEntries;
    
    const changes = {
        new: [],
        updated: [],
        unchanged: []
    };
    
    for (const entry of newEntries) {
        const currentValue = currentEntries.get(entry.key);
        
        if (currentValue === undefined) {
            changes.new.push(entry);
        } else if (currentValue !== entry.value) {
            changes.updated.push({
                ...entry,
                oldValue: currentValue
            });
        } else {
            changes.unchanged.push(entry);
        }
    }
    
    // Store preview data
    importPreviewData = changes;
    
    // Update stats
    document.getElementById('previewNewCount').textContent = changes.new.length;
    document.getElementById('previewUpdateCount').textContent = changes.updated.length;
    document.getElementById('previewUnchangedCount').textContent = changes.unchanged.length;
    
    // Render preview
    const previewContent = document.getElementById('importPreviewContent');
    let html = '';
    
    // Show new entries
    if (changes.new.length > 0) {
        html += '<h4 style="color: #4CAF50;">🆕 Neue Keys:</h4>';
        for (const entry of changes.new) {
            html += `
                <div class="preview-entry new">
                    <div class="preview-key">${entry.key}</div>
                    <div class="preview-value new">${entry.value}</div>
                    <div class="preview-status">Wird hinzugefügt</div>
                </div>
            `;
        }
    }
    
    // Show updated entries
    if (changes.updated.length > 0) {
        html += '<h4 style="color: #FF9800;">📝 Aktualisierte Keys:</h4>';
        for (const entry of changes.updated) {
            html += `
                <div class="preview-entry updated">
                    <div class="preview-key">${entry.key}</div>
                    <div class="preview-value old">${entry.oldValue}</div>
                    <div class="preview-value new">${entry.value}</div>
                    <div class="preview-status">Wird aktualisiert</div>
                </div>
            `;
        }
    }
    
    // Show unchanged entries (limit to first 10)
    if (changes.unchanged.length > 0) {
        html += `<h4 style="color: #666;">🔄 Unveränderte Keys (${changes.unchanged.length > 10 ? 'erste 10 von ' : ''}${changes.unchanged.length}):</h4>`;
        const displayUnchanged = changes.unchanged.slice(0, 10);
        for (const entry of displayUnchanged) {
            html += `
                <div class="preview-entry unchanged">
                    <div class="preview-key">${entry.key}</div>
                    <div class="preview-value">${entry.value}</div>
                    <div class="preview-status">Keine Änderung</div>
                </div>
            `;
        }
    }
    
    if (html === '') {
        html = '<div class="info">Keine Änderungen gefunden.</div>';
    }
    
    previewContent.innerHTML = html;
    
    // Show preview dialog
    document.getElementById('importPreviewDialog').classList.remove('hidden');
}

async function confirmImport() {
    if (!importData || !importPreviewData) {
        showMessage('❌ Keine Import-Daten verfügbar', 'error');
        return;
    }
    
    const button = document.getElementById('confirmImportButton');
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = '⏳ Importiert...';
    
    try {
        // Apply changes to current data
        const currentEntries = new Map(arbData.entries.map(e => [e.key, e]));
        
        // Add/update entries from import
        for (const entry of importData.sanitizedEntries) {
            const existingEntry = currentEntries.get(entry.key);
            if (existingEntry) {
                existingEntry.value = entry.value;
                if (entry.metadata) {
                    existingEntry.metadata = entry.metadata;
                }
            } else {
                arbData.entries.push(entry);
            }
        }
        
        // Update filtered entries and re-render
        filteredEntries = arbData.entries;
        populateContextFilter();
        renderEntries();
        
        // Update stats
        document.getElementById('keyCount').textContent = arbData.entries.length;
        
        // Close dialogs
        closeImportPreview();
        closeImportDialog();
        
        // Show success message
        const totalChanges = importPreviewData.new.length + importPreviewData.updated.length;
        showMessage(`✅ Import erfolgreich: ${totalChanges} Änderungen übernommen`, 'success');
        
    } catch (error) {
        showMessage(`❌ Import-Fehler: ${error.message}`, 'error');
    } finally {
        button.disabled = false;
        button.textContent = originalText;
    }
}

// === UTILITY === 
function showMessage(message, type) {
    const messageDiv = document.getElementById('arbMessage');
    messageDiv.className = type;
    messageDiv.innerHTML = message;
    messageDiv.classList.remove('hidden');
    
    setTimeout(() => {
        messageDiv.classList.add('hidden');
    }, 5000);
}

// === PERMISSION MANAGEMENT ===

async function loadUserPermissions() {
    if (!accessToken) {
        console.log('🔐 Keine Access Token - Permissions nicht geladen');
        return false;
    }

    try {
        const response = await fetch('/api/auth/permissions', {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.status === 401) {
            logout();
            return false;
        }

        if (!response.ok) {
            throw new Error('Fehler beim Laden der Berechtigungen');
        }

        const data = await response.json();
        userPermissions = data.permissions;
        
        console.log('🔐 User Permissions geladen:', userPermissions);
        
        // UI basierend auf Permissions anpassen
        updateUIBasedOnPermissions();
        
        return true;
        
    } catch (error) {
        console.error('❌ Fehler beim Laden der Permissions:', error);
        showMessage('❌ Fehler beim Laden der Berechtigungen', 'error');
        return false;
    }
}

function hasPermission(permission) {
    return userPermissions[permission] === true;
}

function updateUIBasedOnPermissions() {
    // Buttons und UI-Elemente basierend auf Permissions ein/ausblenden
    
    // Edit/Save funktionen
    const saveButton = document.getElementById('saveButton');
    const editCells = document.querySelectorAll('.editable');
    
    if (!hasPermission('arb.save')) {
        if (saveButton) {
            saveButton.disabled = true;
            saveButton.title = 'Keine Berechtigung zum Speichern';
            saveButton.textContent = '🔒 Speichern (keine Berechtigung)';
        }
    }
    
    if (!hasPermission('arb.edit')) {
        editCells.forEach(cell => {
            cell.contentEditable = 'false';
            cell.style.backgroundColor = '#333';
            cell.style.cursor = 'not-allowed';
            cell.title = 'Keine Berechtigung zum Bearbeiten';
        });
    }
    
    // Export Button
    const exportButton = document.getElementById('exportButton');
    if (exportButton && !hasPermission('arb.export')) {
        exportButton.disabled = true;
        exportButton.title = 'Keine Berechtigung zum Exportieren';
        exportButton.textContent = '🔒 Export';
    }
    
    // Import Button  
    const importButton = document.getElementById('importButton');
    if (importButton && !hasPermission('arb.import')) {
        importButton.disabled = true;
        importButton.title = 'Keine Berechtigung zum Importieren';
        importButton.style.display = 'none'; // Hide completely
    }
    
    // Compare Button
    const compareButton = document.getElementById('compareToggle');
    if (compareButton && !hasPermission('arb.compare')) {
        compareButton.disabled = true;
        compareButton.title = 'Keine Berechtigung für Vergleichsansicht';
        compareButton.textContent = '🔒 Vergleich';
    }
    
    // Backup Button
    const backupButton = document.getElementById('backupButton');
    if (backupButton && !hasPermission('arb.backup.view')) {
        backupButton.disabled = true;
        backupButton.title = 'Keine Berechtigung für Backups';
        backupButton.style.display = 'none'; // Hide completely
    }
    
    console.log('🎨 UI wurde basierend auf Permissions angepasst');
}

// === ENHANCED BACKUP MANAGEMENT ===
let currentARBBackups = [];
let currentARBAuditTrail = [];
let arbBackupFilter = 'all';

function filterARBBackups(filter) {
    arbBackupFilter = filter;
    
    // Update active filter button
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`.filter-btn[onclick="filterARBBackups('${filter}')"]`).classList.add('active');
    
    renderARBBackupList();
}

function renderARBBackupList() {
    const backupList = document.getElementById('backupList');
    
    if (currentARBBackups.length === 0) {
        backupList.innerHTML = '<div class="no-backups">📭 Keine Backups gefunden</div>';
        return;
    }
    
    // Filter backups
    const filteredBackups = currentARBBackups.filter(backup => {
        if (arbBackupFilter === 'all') return true;
        return backup.type === arbBackupFilter;
    });
    
    if (filteredBackups.length === 0) {
        backupList.innerHTML = '<div class="no-backups">📭 Keine Backups für diesen Filter</div>';
        return;
    }
    
    const backupHTML = filteredBackups.map(backup => {
        const keysList = backup.keysModified && backup.keysModified.length > 0 
            ? backup.keysModified.slice(0, 5).map(key => `<span class="key-tag">${key}</span>`).join('')
            : '<span class="key-tag">ARB-Backup</span>';
            
        const moreKeys = backup.keysModified && backup.keysModified.length > 5 
            ? `<span class="key-tag">+${backup.keysModified.length - 5} weitere</span>`
            : '';
            
        const typeIcon = getARBBackupTypeIcon(backup.type);
        const versionChange = backup.originalVersion && backup.newVersion && backup.originalVersion !== backup.newVersion 
            ? `<span class="version-change">${backup.originalVersion} → ${backup.newVersion}</span>`
            : backup.version ? `<span class="version-same">v${backup.version}</span>` : '';
            
        // Action buttons based on permissions
        let actionButtons = '';
        
        if (hasPermission('arb.backup.restore')) {
            actionButtons += `<button class="btn-success btn-small" onclick="restoreBackup('${backup.timestamp}')" title="Dieses Backup wiederherstellen">
                🔄 Wiederherstellen
            </button>`;
        }
        
        if (hasPermission('arb.backup.delete')) {
            actionButtons += `<button class="btn-danger btn-small" onclick="deleteBackup('${backup.timestamp}', '${backup.displayName}')" title="Dieses Backup löschen">
                🗑️ Löschen
            </button>`;
        }
            
        return `
            <div class="backup-item" data-type="${backup.type}">
                <div class="backup-header">
                    <div class="backup-info-section">
                        <span class="backup-type">${typeIcon} ${getARBBackupTypeLabel(backup.type)}</span>
                        <span class="backup-date">${backup.displayName}</span>
                    </div>
                    <div class="backup-meta">
                        <span class="backup-user">👤 ${backup.createdBy}</span>
                        <span class="backup-size">${formatARBFileSize(backup.size)}</span>
                    </div>
                </div>
                <div class="backup-details">
                    <div class="backup-keys">
                        <strong>Backup-Info:</strong> ${keysList}${moreKeys}
                    </div>
                    ${versionChange ? `<div class="backup-version"><strong>Version:</strong> ${versionChange}</div>` : ''}
                    ${actionButtons ? `<div class="backup-actions-new">${actionButtons}</div>` : ''}
                </div>
            </div>
        `;
    }).join('');
    
    backupList.innerHTML = backupHTML;
}

function getARBBackupTypeIcon(type) {
    const icons = {
        'manual_save': '💾',
        'import': '📥',
        'auto_backup': '⚡',
        'pre_restore': '🔄'
    };
    return icons[type] || '📁';
}

function getARBBackupTypeLabel(type) {
    const labels = {
        'manual_save': 'Manueller Save',
        'import': 'Import',
        'auto_backup': 'Auto-Backup',
        'pre_restore': 'Vor Wiederherstellung'
    };
    return labels[type] || 'Unbekannt';
}

function formatARBFileSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// === ARB AUDIT TRAIL ===
function showARBAuditDialog() {
    const currentLang = availableLanguages.find(lang => lang.code === currentLanguage);
    document.getElementById('auditLanguageName').textContent = currentLang ? `${currentLang.flag} ${currentLang.name}` : currentLanguage.toUpperCase();
    document.getElementById('arbAuditDialog').classList.remove('hidden');
    loadARBAuditTrail();
}

function closeARBAuditDialog() {
    document.getElementById('arbAuditDialog').classList.add('hidden');
}

async function loadARBAuditTrail() {
    if (!currentLanguage) return;
    
    const auditList = document.getElementById('arbAuditList');
    auditList.innerHTML = '<div class="loading">⏳ Lade Audit-Trail...</div>';
    
    try {
        const response = await fetch(`/api/arb/${currentLanguage}/audit`, {
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
        currentARBAuditTrail = data.auditTrail || [];
        
        // Update stats
        document.getElementById('totalARBAuditEntries').textContent = data.totalEntries || 0;
        document.getElementById('arbAuditKeyChanges').textContent = data.totalKeyChanges || 0;
        
        if (data.oldestEntry && data.newestEntry) {
            const oldDate = new Date(data.oldestEntry).toLocaleDateString('de-DE');
            const newDate = new Date(data.newestEntry).toLocaleDateString('de-DE');
            document.getElementById('arbAuditDateRange').textContent = `${oldDate} - ${newDate}`;
        } else {
            document.getElementById('arbAuditDateRange').textContent = 'N/A';
        }
        
        renderARBAuditTrail();
        
    } catch (error) {
        console.error('❌ Error loading ARB audit trail:', error);
        auditList.innerHTML = `<div class="error">❌ ${error.message}</div>`;
    }
}

function renderARBAuditTrail() {
    const auditList = document.getElementById('arbAuditList');
    
    if (currentARBAuditTrail.length === 0) {
        auditList.innerHTML = '<div class="no-audit">📭 Keine Audit-Einträge gefunden</div>';
        return;
    }
    
    const auditHTML = currentARBAuditTrail.map(entry => {
        const date = new Date(entry.createdAt).toLocaleString('de-DE');
        const typeIcon = getARBBackupTypeIcon(entry.type || entry.action);
        const typeLabel = getARBBackupTypeLabel(entry.type || entry.action);
        
        let actionDetails = '';
        if (entry.keysModified && entry.keysModified.length > 0) {
            const keysList = entry.keysModified.slice(0, 3).map(key => `<span class="key-tag">${key}</span>`).join('');
            const moreKeys = entry.keysModified.length > 3 ? ` (+${entry.keysModified.length - 3})` : '';
            actionDetails += `<div><strong>Keys:</strong> ${keysList}${moreKeys}</div>`;
        }
        
        if (entry.originalVersion && entry.newVersion && entry.originalVersion !== entry.newVersion) {
            actionDetails += `<div><strong>Version:</strong> ${entry.originalVersion} → ${entry.newVersion}</div>`;
        }
        
        if (entry.totalKeys) {
            actionDetails += `<div><strong>Gesamt-Keys:</strong> ${entry.totalKeys}</div>`;
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

function exportARBAuditTrail() {
    if (currentARBAuditTrail.length === 0) {
        showMessage('❌ Keine Audit-Daten zum Exportieren vorhanden', 'error');
        return;
    }
    
    const currentLang = availableLanguages.find(lang => lang.code === currentLanguage);
    const languageName = currentLang ? currentLang.name : currentLanguage.toUpperCase();
    
    const exportData = {
        language: currentLanguage,
        languageName: languageName,
        exportDate: new Date().toISOString(),
        totalEntries: currentARBAuditTrail.length,
        auditTrail: currentARBAuditTrail
    };
    
    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    
    const link = document.createElement('a');
    link.href = URL.createObjectURL(dataBlob);
    link.download = `${currentLanguage}-arb-audit-trail-${new Date().toISOString().slice(0, 10)}.json`;
    link.click();
    
    showMessage('✅ ARB-Audit-Trail erfolgreich exportiert!', 'success');
}