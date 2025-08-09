/* 🗄️ Weltenwind Backup Manager - JavaScript */

// === GLOBALS === 
let accessToken = null;
let backupData = {};
let refreshInterval = null;
let currentTab = 'overview';
let selectedBackup = null;

// === INITIALIZATION === 
window.onload = function() {
    const savedToken = localStorage.getItem('weltenwind_access_token');
    const savedUser = localStorage.getItem('weltenwind_user');

    if (savedToken && savedUser) {
        accessToken = savedToken;
        showBackupManager(JSON.parse(savedUser));
        initializeBackupManager();
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
            showBackupManager(data.user);
            initializeBackupManager();
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
function showBackupManager(user) {
    document.getElementById('loginContainer').classList.add('hidden');
    document.getElementById('backupManager').classList.remove('hidden');
    document.getElementById('userInfo').textContent = `👤 ${user.username}`;
}

function logout() {
    localStorage.removeItem('weltenwind_access_token');
    localStorage.removeItem('weltenwind_user');
    accessToken = null;
    
    // Clear intervals
    if (refreshInterval) {
        clearInterval(refreshInterval);
        refreshInterval = null;
    }
    
    document.getElementById('backupManager').classList.add('hidden');
    document.getElementById('loginContainer').classList.remove('hidden');
    
    // Reset form
    document.getElementById('loginForm').reset();
}

// === TAB MANAGEMENT ===
function switchTab(tabName) {
    // Update tab buttons
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName + 'Tab').classList.add('active');
    
    currentTab = tabName;
    
    // Load tab-specific data
    switch(tabName) {
        case 'jobs':
            loadBackupJobs();
            break;
        case 'tables':
            loadDatabaseTables();
            break;
        case 'schedule':
            loadScheduleInfo();
            break;
        case 'recovery':
            loadAvailableBackups();
            break;
        default:
            // Overview is loaded by default
            break;
    }
}

// === BACKUP MANAGER INITIALIZATION ===
async function initializeBackupManager() {
    try {
        await loadOverviewData();
        setupAutoRefresh();
        updateLastUpdated();
    } catch (error) {
        showError('Failed to initialize backup manager: ' + error.message);
    }
}

async function refreshData() {
    const button = document.getElementById('refreshButton');
    const originalText = button.textContent;
    
    button.disabled = true;
    button.textContent = '⏳ Refreshing...';
    
    try {
        await loadOverviewData();
        
        // Refresh current tab data
        switch(currentTab) {
            case 'jobs':
                await loadBackupJobs();
                break;
            case 'tables':
                await loadDatabaseTables();
                break;
            case 'schedule':
                await loadScheduleInfo();
                break;
            case 'recovery':
                await loadAvailableBackups();
                break;
        }
        
        updateLastUpdated();
        
    } catch (error) {
        showError('Failed to refresh data: ' + error.message);
    } finally {
        button.disabled = false;
        button.textContent = originalText;
    }
}

// === API CALLS ===
async function apiCall(endpoint, options = {}) {
    const response = await fetch(endpoint, {
        headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
            ...options.headers
        },
        ...options
    });
    
    if (!response.ok) {
        if (response.status === 401) {
            logout();
            throw new Error('Session expired. Please login again.');
        }
        const errorData = await response.json();
        throw new Error(errorData.error || `HTTP ${response.status}`);
    }
    
    return response.json();
}

// === LOAD DATA FUNCTIONS ===
async function loadOverviewData() {
    try {
        const [backupOverview, healthData] = await Promise.all([
            apiCall('/api/backup'),
            apiCall('/api/backup/health')
        ]);
        
        backupData.overview = backupOverview;
        backupData.health = healthData;
        
        updateStatusOverview();
        updateOverviewMetrics();
        updateHealthChecks();
        updateConfiguration();
        
    } catch (error) {
        console.error('Failed to load overview data:', error);
        throw error;
    }
}

async function loadBackupJobs() {
    try {
        const jobsData = await apiCall('/api/backup/jobs');
        backupData.jobs = jobsData;
        updateJobsList();
        updateJobStats();
    } catch (error) {
        console.error('Failed to load backup jobs:', error);
        document.getElementById('jobsList').innerHTML = 
            '<div class="error">Failed to load backup jobs: ' + error.message + '</div>';
    }
}

async function loadDatabaseTables() {
    try {
        const tablesData = await apiCall('/api/backup/tables');
        backupData.tables = tablesData;
        updateTablesGrid();
        updateTablesSummary();
    } catch (error) {
        console.error('Failed to load database tables:', error);
        document.getElementById('tablesGrid').innerHTML = 
            '<div class="error">Failed to load database tables: ' + error.message + '</div>';
    }
}

async function loadScheduleInfo() {
    // Schedule info is mostly static, but we can check for cron job status
    updateScheduleCards();
}

async function loadAvailableBackups() {
    try {
        // This would need a new API endpoint to list available backup files
        // For now, we'll show a placeholder
        const availableBackupsContainer = document.getElementById('availableBackups');
        availableBackupsContainer.innerHTML = `
            <div class="backup-item" onclick="selectBackup('daily_2024-01-15_backup.sql.gz')">
                <div class="backup-header">
                    <div class="backup-filename">daily_2024-01-15_backup.sql.gz</div>
                    <div class="backup-type daily">Daily</div>
                </div>
                <div class="backup-details">
                    <div>Size: 45.2 MB</div>
                    <div>Created: 2024-01-15 02:00</div>
                    <div>Tables: 12</div>
                    <div>Status: Verified</div>
                </div>
            </div>
            <div class="backup-item" onclick="selectBackup('weekly_2024-01-14_backup.sql.gz')">
                <div class="backup-header">
                    <div class="backup-filename">weekly_2024-01-14_backup.sql.gz</div>
                    <div class="backup-type weekly">Weekly</div>
                </div>
                <div class="backup-details">
                    <div>Size: 45.8 MB</div>
                    <div>Created: 2024-01-14 01:00</div>
                    <div>Tables: 12</div>
                    <div>Status: Verified</div>
                </div>
            </div>
        `;
    } catch (error) {
        console.error('Failed to load available backups:', error);
    }
}

// === UPDATE UI FUNCTIONS ===
function updateStatusOverview() {
    const overview = backupData.overview;
    const health = backupData.health;
    
    if (overview && overview.config) {
        // System status
        const systemStatus = overview.config.enabled ? 'healthy' : 'critical';
        updateStatusCard('system', systemStatus, overview.config.enabled ? 'Enabled' : 'Disabled');
        
        // Last backup
        if (overview.stats && overview.stats.lastBackup) {
            const lastBackup = new Date(overview.stats.lastBackup);
            const now = new Date();
            const timeDiff = now - lastBackup;
            const hoursDiff = Math.floor(timeDiff / (1000 * 60 * 60));
            
            let status = 'healthy';
            let text = `${hoursDiff}h ago`;
            
            if (hoursDiff > 48) {
                status = 'critical';
                text = `${Math.floor(hoursDiff / 24)}d ago`;
            } else if (hoursDiff > 24) {
                status = 'degraded';
                text = `${Math.floor(hoursDiff / 24)}d ago`;
            }
            
            updateStatusCard('lastBackup', status, text);
        }
        
        // Disk usage
        if (overview.stats && overview.stats.diskUsage) {
            const diskUsage = overview.stats.diskUsage;
            let status = 'healthy';
            
            if (diskUsage.percentage > 90) {
                status = 'critical';
            } else if (diskUsage.percentage > 80) {
                status = 'degraded';
            }
            
            updateStatusCard('diskUsage', status, `${diskUsage.percentage}%`);
        }
    }
    
    if (health) {
        // Active jobs (placeholder)
        updateStatusCard('activeJobs', 'healthy', '0');
    }
}

function updateStatusCard(type, status, text) {
    const indicator = document.getElementById(type + 'Indicator');
    const statusText = document.getElementById(type + 'StatusText');
    
    if (indicator && statusText) {
        // Remove old status classes
        indicator.classList.remove('healthy', 'degraded', 'critical');
        
        // Add new status class
        indicator.classList.add(status);
        statusText.textContent = text;
    }
}

function updateOverviewMetrics() {
    const stats = backupData.overview?.stats;
    
    if (stats) {
        setElementText('totalBackups', formatNumber(stats.totalBackups));
        setElementText('totalSize', formatBytes(stats.totalSize));
        setElementText('successRate', formatNumber(stats.successRate, 1) + '%');
        
        // Update disk usage visual
        updateDiskUsageVisual(stats.diskUsage);
    }
}

function updateDiskUsageVisual(diskUsage) {
    if (!diskUsage) return;
    
    const diskUsedBar = document.getElementById('diskUsedBar');
    const diskUsedText = document.getElementById('diskUsedText');
    const diskTotalText = document.getElementById('diskTotalText');
    const diskPercentText = document.getElementById('diskPercentText');
    
    if (diskUsedBar) {
        diskUsedBar.style.width = diskUsage.percentage + '%';
    }
    
    if (diskUsedText) {
        diskUsedText.textContent = formatBytes(diskUsage.used);
    }
    
    if (diskTotalText) {
        diskTotalText.textContent = formatBytes(diskUsage.used + diskUsage.available);
    }
    
    if (diskPercentText) {
        diskPercentText.textContent = formatNumber(diskUsage.percentage, 1) + '%';
    }
}

function updateHealthChecks() {
    const health = backupData.health;
    const container = document.getElementById('healthChecks');
    
    if (!health || !health.checks) {
        container.innerHTML = '<div class="loading">No health data available</div>';
        return;
    }
    
    let html = '';
    health.checks.forEach(check => {
        html += `
            <div class="health-check">
                <div class="health-check-name">${check.name.replace(/_/g, ' ')}</div>
                <div class="health-check-status ${check.status}">${check.status}</div>
            </div>
        `;
    });
    
    container.innerHTML = html;
}

function updateConfiguration() {
    const config = backupData.overview?.config;
    
    if (config) {
        setConfigValue('autoDiscovery', config.autoDiscovery);
        setConfigValue('compressionEnabled', config.compression?.enabled);
        setConfigValue('autoVerification', config.autoVerification);
        setConfigValue('offsiteEnabled', config.offsite?.enabled);
    }
}

function setConfigValue(id, value) {
    const element = document.getElementById(id);
    if (element) {
        element.textContent = value ? 'Enabled' : 'Disabled';
        element.className = 'config-value ' + (value ? 'enabled' : 'disabled');
    }
}

function updateJobsList() {
    const container = document.getElementById('jobsList');
    const jobs = backupData.jobs?.jobs || [];
    
    if (jobs.length === 0) {
        container.innerHTML = '<div class="loading">No backup jobs found</div>';
        return;
    }
    
    let html = '';
    jobs.forEach(job => {
        const duration = job.duration ? formatDuration(job.duration) : '-';
        const fileSize = job.fileSize ? formatBytes(job.fileSize) : '-';
        
        html += `
            <div class="job-item">
                <div class="job-header">
                    <div class="job-title">${capitalizeFirst(job.type)} Backup - ${job.id.slice(0, 8)}</div>
                    <div class="job-status ${job.status}">${job.status}</div>
                </div>
                <div class="job-details">
                    <div class="job-detail">
                        <div class="job-detail-label">Started</div>
                        <div class="job-detail-value">${formatDateTime(job.startTime)}</div>
                    </div>
                    <div class="job-detail">
                        <div class="job-detail-label">Duration</div>
                        <div class="job-detail-value">${duration}</div>
                    </div>
                    <div class="job-detail">
                        <div class="job-detail-label">Size</div>
                        <div class="job-detail-value">${fileSize}</div>
                    </div>
                    <div class="job-detail">
                        <div class="job-detail-label">Tables</div>
                        <div class="job-detail-value">${job.tables.length}</div>
                    </div>
                </div>
                ${job.error ? `<div class="job-error">Error: ${job.error}</div>` : ''}
            </div>
        `;
    });
    
    container.innerHTML = html;
}

function updateJobStats() {
    const container = document.getElementById('jobStats');
    const summary = backupData.jobs?.summary;
    
    if (!summary) {
        container.innerHTML = '<div class="loading">No job statistics available</div>';
        return;
    }
    
    container.innerHTML = `
        <div class="metric-stats">
            <div class="stat">
                <div class="stat-value">${summary.total}</div>
                <div class="stat-label">Total Jobs</div>
            </div>
            <div class="stat">
                <div class="stat-value">${summary.completed}</div>
                <div class="stat-label">Completed</div>
            </div>
            <div class="stat">
                <div class="stat-value">${summary.active}</div>
                <div class="stat-label">Active</div>
            </div>
            <div class="stat">
                <div class="stat-value">${summary.failed}</div>
                <div class="stat-label">Failed</div>
            </div>
        </div>
    `;
}

function updateTablesGrid() {
    const container = document.getElementById('tablesGrid');
    const tables = backupData.tables?.tables || [];
    
    if (tables.length === 0) {
        container.innerHTML = '<div class="loading">No database tables found</div>';
        return;
    }
    
    let html = '';
    tables.forEach(table => {
        html += `
            <div class="table-card ${table.category}" data-category="${table.category}">
                <div class="table-header">
                    <div class="table-name">${table.name}</div>
                    <div class="table-category ${table.category}">${table.category}</div>
                </div>
                <div class="table-info">
                    <div class="table-info-item">
                        <span>Rows:</span>
                        <span class="table-info-value">${formatNumber(table.estimatedRows)}</span>
                    </div>
                    <div class="table-info-item">
                        <span>Size:</span>
                        <span class="table-info-value">${formatNumber(table.estimatedSizeMB, 1)} MB</span>
                    </div>
                    <div class="table-info-item">
                        <span>Priority:</span>
                        <span class="table-info-value">${table.backupPriority}/10</span>
                    </div>
                    <div class="table-info-item">
                        <span>Strategy:</span>
                        <span class="table-info-value">${table.backupStrategy}</span>
                    </div>
                </div>
            </div>
        `;
    });
    
    container.innerHTML = html;
}

function updateTablesSummary() {
    const container = document.getElementById('tablesSummary');
    const summary = backupData.tables?.summary;
    
    if (!summary) {
        container.innerHTML = '<div class="loading">No table summary available</div>';
        return;
    }
    
    const categories = Object.entries(summary.categories).map(([category, count]) => 
        `<div class="stat">
            <div class="stat-value">${count}</div>
            <div class="stat-label">${capitalizeFirst(category)} Tables</div>
        </div>`
    ).join('');
    
    container.innerHTML = `
        <div class="metric-stats">
            <div class="stat">
                <div class="stat-value">${summary.totalTables}</div>
                <div class="stat-label">Total Tables</div>
            </div>
            <div class="stat">
                <div class="stat-value">${formatNumber(summary.totalSizeMB, 1)} MB</div>
                <div class="stat-label">Total Size</div>
            </div>
            ${categories}
        </div>
    `;
}

function updateScheduleCards() {
    // Schedule status is mostly static
    setElementText('dailyStatus', 'Active');
    setElementText('weeklyStatus', 'Active');
    setElementText('monthlyStatus', 'Active');
}

// === FILTER FUNCTIONS ===
function filterTables(category) {
    // Update filter buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // Filter table cards
    const tableCards = document.querySelectorAll('.table-card');
    tableCards.forEach(card => {
        if (category === 'all' || card.dataset.category === category) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// === ACTION FUNCTIONS ===
async function createManualBackup() {
    showModal('manualBackupModal');
}

document.getElementById('manualBackupForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const backupType = document.getElementById('backupType').value;
    const tablesText = document.getElementById('selectedTables').value.trim();
    const tables = tablesText ? tablesText.split(',').map(t => t.trim()) : undefined;
    
    closeModal('manualBackupModal');
    showProgressModal('Creating Backup', 'Preparing backup job...');
    
    try {
        const result = await apiCall('/api/backup/create', {
            method: 'POST',
            body: JSON.stringify({
                type: backupType,
                tables: tables
            })
        });
        
        updateProgress(50, 'Backup job started: ' + result.job.id);
        
        // Poll for job completion
        const jobId = result.job.id;
        await pollJobCompletion(jobId);
        
        closeModal('progressModal');
        showSuccess('Backup created successfully!');
        
        // Refresh data
        await refreshData();
        
    } catch (error) {
        closeModal('progressModal');
        showError('Failed to create backup: ' + error.message);
    }
});

async function pollJobCompletion(jobId) {
    let attempts = 0;
    const maxAttempts = 60; // 5 minutes max
    
    while (attempts < maxAttempts) {
        try {
            const jobsData = await apiCall('/api/backup/jobs');
            const job = jobsData.jobs.find(j => j.id === jobId);
            
            if (job) {
                if (job.status === 'completed') {
                    updateProgress(100, 'Backup completed successfully!');
                    return;
                } else if (job.status === 'failed') {
                    throw new Error(job.error || 'Backup job failed');
                }
                
                // Update progress
                const progress = Math.min(50 + (attempts * 2), 90);
                updateProgress(progress, `Job ${job.status}... (${attempts * 5}s)`);
            }
            
            await new Promise(resolve => setTimeout(resolve, 5000)); // Wait 5 seconds
            attempts++;
            
        } catch (error) {
            throw error;
        }
    }
    
    throw new Error('Backup job timeout');
}

async function rediscoverDatabase() {
    try {
        showProgressModal('Database Discovery', 'Analyzing database structure...');
        
        const result = await apiCall('/api/backup/discover', {
            method: 'POST'
        });
        
        updateProgress(100, `Discovered ${result.tablesDiscovered} tables`);
        
        setTimeout(() => {
            closeModal('progressModal');
            showSuccess(`Database rediscovered! Found ${result.tablesDiscovered} tables.`);
            
            // Refresh tables tab if active
            if (currentTab === 'tables') {
                loadDatabaseTables();
            }
        }, 1000);
        
    } catch (error) {
        closeModal('progressModal');
        showError('Failed to rediscover database: ' + error.message);
    }
}

function downloadBackup() {
    showError('Download backup feature not yet implemented. Use recovery scripts on the server.');
}

function showRecoveryModal() {
    showModal('recoveryModal');
}

function selectRecoveryType(type) {
    closeModal('recoveryModal');
    
    if (type === 'test') {
        showError('Test recovery feature not yet implemented. Use recovery.js script on the server.');
    } else if (type === 'full') {
        showFullRecoveryModal();
    }
}

function showFullRecoveryModal() {
    showError('Full recovery is extremely dangerous and must be performed using the recovery.js script on the server with proper precautions.');
}

function testSchedule() {
    showError('Schedule testing not yet implemented. Check cron job status on the server.');
}

function showCronSetup() {
    showModal('cronSetupModal');
}

function checkNextRun() {
    showError('Next run time checking not yet implemented. Use "crontab -l" on the server.');
}

function testRecovery() {
    showError('Recovery testing not yet implemented. Use recovery.js script on the server.');
}

function downloadRecoveryScript() {
    const content = `#!/bin/bash
# Recovery Script - Generated by Weltenwind Backup Manager
# Usage: ./recovery.sh

echo "🔄 Weltenwind Database Recovery"
echo "=============================="
echo ""
echo "Available recovery scripts:"
echo "1. Interactive recovery: node /srv/weltenwind/backend/scripts/backup/recovery.js"
echo "2. Command line recovery: node recovery.js <backup-file> <test|full>"
echo ""
echo "⚠️  WARNING: Full recovery will completely replace your database!"
echo "Always test backups before performing full recovery."
echo ""
echo "For more information, see the backup documentation."
`;

    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'weltenwind-recovery.sh';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function selectBackup(filename) {
    // Remove previous selection
    document.querySelectorAll('.backup-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    // Add selection to clicked item
    event.currentTarget.classList.add('selected');
    selectedBackup = filename;
}

// === MODAL FUNCTIONS ===
function showModal(modalId) {
    document.getElementById(modalId).classList.remove('hidden');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.add('hidden');
}

function showProgressModal(title, text) {
    document.getElementById('progressTitle').textContent = title;
    document.getElementById('progressText').textContent = text;
    document.getElementById('progressFill').style.width = '0%';
    document.getElementById('progressLog').innerHTML = '';
    showModal('progressModal');
}

function updateProgress(percent, text) {
    document.getElementById('progressFill').style.width = percent + '%';
    document.getElementById('progressText').textContent = text;
    
    // Add to log
    const log = document.getElementById('progressLog');
    const timestamp = new Date().toLocaleTimeString();
    log.innerHTML += `[${timestamp}] ${text}\n`;
    log.scrollTop = log.scrollHeight;
}

function showError(message) {
    document.getElementById('errorMessage').textContent = message;
    showModal('errorModal');
}

function showSuccess(message) {
    document.getElementById('successMessage').textContent = message;
    showModal('successModal');
}

// === UTILITY FUNCTIONS ===
function setElementText(id, value) {
    const element = document.getElementById(id);
    if (element) {
        element.textContent = value;
    }
}

function formatNumber(num, decimals = 0) {
    if (num === null || num === undefined || isNaN(num)) {
        return '-';
    }
    return Number(num).toFixed(decimals).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function formatBytes(bytes) {
    if (!bytes) return '-';
    
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round((bytes / Math.pow(1024, i)) * 100) / 100 + ' ' + sizes[i];
}

function formatDuration(ms) {
    if (!ms) return '-';
    
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) {
        return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
    } else if (minutes > 0) {
        return `${minutes}m ${seconds % 60}s`;
    } else {
        return `${seconds}s`;
    }
}

function formatDateTime(dateString) {
    if (!dateString) return '-';
    
    const date = new Date(dateString);
    return date.toLocaleString();
}

function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function updateLastUpdated() {
    document.getElementById('lastUpdated').textContent = new Date().toLocaleTimeString();
}

function setupAutoRefresh() {
    const checkbox = document.getElementById('autoRefresh');
    
    function toggleAutoRefresh() {
        if (checkbox.checked) {
            refreshInterval = setInterval(refreshData, 30000); // 30 seconds
        } else {
            if (refreshInterval) {
                clearInterval(refreshInterval);
                refreshInterval = null;
            }
        }
    }
    
    checkbox.addEventListener('change', toggleAutoRefresh);
    
    // Start auto-refresh by default
    if (checkbox.checked) {
        toggleAutoRefresh();
    }
}

// === KEYBOARD SHORTCUTS ===
document.addEventListener('keydown', function(e) {
    if (e.ctrlKey || e.metaKey) {
        switch(e.key) {
            case 'r':
                e.preventDefault();
                refreshData();
                break;
            case '1':
                e.preventDefault();
                switchTab('overview');
                break;
            case '2':
                e.preventDefault();
                switchTab('jobs');
                break;
            case '3':
                e.preventDefault();
                switchTab('tables');
                break;
            case '4':
                e.preventDefault();
                switchTab('schedule');
                break;
            case '5':
                e.preventDefault();
                switchTab('recovery');
                break;
        }
    }
});

// === CLOSE MODALS ON OUTSIDE CLICK ===
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal')) {
        e.target.classList.add('hidden');
    }
});