/* 📊 Weltenwind Metrics Viewer - JavaScript */

// === GLOBALS === 
let accessToken = null;
let metricsData = {};
let charts = {};
let refreshInterval = null;
let currentTab = 'overview';

// === INITIALIZATION === 
window.onload = function() {
    const savedToken = localStorage.getItem('weltenwind_access_token');
    const savedUser = localStorage.getItem('weltenwind_user');

    if (savedToken && savedUser) {
        accessToken = savedToken;
        showMetricsViewer(JSON.parse(savedUser));
        initializeMetrics();
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
            showMetricsViewer(data.user);
            initializeMetrics();
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
function showMetricsViewer(user) {
    document.getElementById('loginContainer').classList.add('hidden');
    document.getElementById('metricsViewer').classList.remove('hidden');
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
    
    // Destroy charts
    Object.values(charts).forEach(chart => {
        if (chart && typeof chart.destroy === 'function') {
            chart.destroy();
        }
    });
    charts = {};
    
    document.getElementById('metricsViewer').classList.add('hidden');
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
        case 'api':
            loadApiMetrics();
            break;
        case 'users':
            loadUserMetrics();
            break;
        case 'system':
            loadSystemMetrics();
            break;
        case 'queries':
            loadQueryMetrics();
            break;
        default:
            // Overview is loaded by default
            break;
    }
}

// === METRICS INITIALIZATION ===
async function initializeMetrics() {
    try {
        await loadOverviewMetrics();
        initializeCharts();
        setupAutoRefresh();
        updateLastUpdated();
    } catch (error) {
        showError('Failed to initialize metrics: ' + error.message);
    }
}

async function refreshAllMetrics() {
    const button = document.getElementById('refreshButton');
    const originalText = button.textContent;
    
    button.disabled = true;
    button.textContent = '⏳ Refreshing...';
    
    try {
        await loadOverviewMetrics();
        
        // Refresh current tab data
        switch(currentTab) {
            case 'api':
                await loadApiMetrics();
                break;
            case 'users':
                await loadUserMetrics();
                break;
            case 'system':
                await loadSystemMetrics();
                break;
            case 'queries':
                await loadQueryMetrics();
                break;
        }
        
        updateCharts();
        updateLastUpdated();
        
    } catch (error) {
        showError('Failed to refresh metrics: ' + error.message);
    } finally {
        button.disabled = false;
        button.textContent = originalText;
    }
}

// === API CALLS ===
async function apiCall(endpoint) {
    const response = await fetch(endpoint, {
        headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        }
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

// === LOAD METRICS DATA ===
async function loadOverviewMetrics() {
    try {
        // Load multiple metrics in parallel
        const [overallMetrics, healthData, systemHealth] = await Promise.all([
            apiCall('/api/metrics'),
            apiCall('/api/health/detailed'),
            apiCall('/api/query-performance/health')
        ]);
        
        metricsData.overall = overallMetrics;
        metricsData.health = healthData;
        metricsData.queryHealth = systemHealth;
        
        updateStatusOverview();
        updateOverviewCards();
        
    } catch (error) {
        console.error('Failed to load overview metrics:', error);
        throw error;
    }
}

async function loadApiMetrics() {
    try {
        const apiMetrics = await apiCall('/api/metrics/api');
        metricsData.api = apiMetrics;
        updateApiTable();
        updateEndpointsChart();
    } catch (error) {
        console.error('Failed to load API metrics:', error);
        document.getElementById('apiMetricsTable').innerHTML = 
            '<div class="error">Failed to load API metrics: ' + error.message + '</div>';
    }
}

async function loadUserMetrics() {
    try {
        const userMetrics = await apiCall('/api/metrics/users');
        metricsData.users = userMetrics;
        updateUserTable();
        updateUserGrowthChart();
    } catch (error) {
        console.error('Failed to load user metrics:', error);
        document.getElementById('userMetricsTable').innerHTML = 
            '<div class="error">Failed to load user metrics: ' + error.message + '</div>';
    }
}

async function loadSystemMetrics() {
    try {
        const systemMetrics = await apiCall('/api/metrics/system');
        metricsData.system = systemMetrics;
        updateSystemTable();
        updateSystemCharts();
    } catch (error) {
        console.error('Failed to load system metrics:', error);
        document.getElementById('systemMetricsTable').innerHTML = 
            '<div class="error">Failed to load system metrics: ' + error.message + '</div>';
    }
}

async function loadQueryMetrics() {
    try {
        const [queryStats, slowQueries, recommendations] = await Promise.all([
            apiCall('/api/query-performance'),
            apiCall('/api/query-performance/slow-queries'),
            apiCall('/api/query-performance/recommendations')
        ]);
        
        metricsData.queries = queryStats;
        metricsData.slowQueries = slowQueries;
        metricsData.recommendations = recommendations;
        
        updateQueryTable();
        updateSlowQueriesTable();
        updateIndexRecommendations();
        
    } catch (error) {
        console.error('Failed to load query metrics:', error);
        document.getElementById('queryMetricsTable').innerHTML = 
            '<div class="error">Failed to load query metrics: ' + error.message + '</div>';
    }
}

// === UPDATE UI FUNCTIONS ===
function updateStatusOverview() {
    const health = metricsData.health;
    const queryHealth = metricsData.queryHealth;
    
    if (health) {
        updateStatusCard('system', health.status, health.status);
        updateStatusCard('database', health.database?.status || 'unknown', 
                        health.database?.status || 'Unknown');
    }
    
    if (queryHealth) {
        updateStatusCard('query', queryHealth.status, queryHealth.status);
    }
    
    // Update session status based on overall metrics
    if (metricsData.overall?.sessions) {
        const sessions = metricsData.overall.sessions;
        const status = sessions.activeSessions > 0 ? 'healthy' : 'degraded';
        updateStatusCard('session', status, `${sessions.activeSessions} active`);
    }
}

function updateStatusCard(type, status, text) {
    const indicator = document.getElementById(type + 'Indicator');
    const statusText = document.getElementById(type + 'StatusText');
    
    if (indicator && statusText) {
        // Remove old status classes
        indicator.classList.remove('healthy', 'degraded', 'critical');
        
        // Add new status class
        if (status === 'OK' || status === 'healthy') {
            indicator.classList.add('healthy');
        } else if (status === 'degraded' || status === 'DEGRADED') {
            indicator.classList.add('degraded');
        } else {
            indicator.classList.add('critical');
        }
        
        statusText.textContent = text;
    }
}

function updateOverviewCards() {
    const overall = metricsData.overall;
    const health = metricsData.health;
    
    if (overall) {
        // API Metrics
        if (overall.api) {
            setElementText('totalRequests', formatNumber(overall.api.totalRequests));
            setElementText('avgResponseTime', formatNumber(overall.api.avgResponseTime, 1) + 'ms');
            setElementText('errorRate', formatNumber(overall.api.errorRate, 2) + '%');
        }
        
        // User Metrics
        if (overall.users) {
            setElementText('totalUsers', formatNumber(overall.users.totalUsers));
            setElementText('activeUsers', formatNumber(overall.users.activeUsers));
            setElementText('recentLogins', formatNumber(overall.users.recentLogins));
        }
        
        // System Metrics
        if (overall.system) {
            setElementText('memoryUsage', formatNumber(overall.system.memoryUsage.percentage) + '%');
            setElementText('uptime', formatUptime(overall.system.uptime));
            setElementText('dbResponseTime', formatNumber(overall.system.databaseHealth.responseTime) + 'ms');
        }
        
        // Game Metrics
        if (overall.game) {
            setElementText('totalWorlds', formatNumber(overall.game.totalWorlds));
            setElementText('activeWorlds', formatNumber(overall.game.activeWorlds));
            setElementText('totalPlayers', formatNumber(overall.game.totalPlayers));
        }
    }
}

function updateApiTable() {
    const tableContainer = document.getElementById('apiMetricsTable');
    const apiData = metricsData.api;
    
    if (!apiData || !apiData.endpoints) {
        tableContainer.innerHTML = '<div class="loading">No API data available</div>';
        return;
    }
    
    let html = '<div class="table-header">API Endpoint Performance</div>';
    
    apiData.endpoints.forEach(endpoint => {
        const errorClass = endpoint.errorRate > 5 ? 'error' : endpoint.errorRate > 1 ? 'warning' : '';
        const responseClass = endpoint.avgResponseTime > 1000 ? 'error' : endpoint.avgResponseTime > 500 ? 'warning' : '';
        
        html += `
            <div class="table-row">
                <div class="table-cell">${endpoint.path}</div>
                <div class="table-cell metric">${formatNumber(endpoint.requestCount)}</div>
                <div class="table-cell ${responseClass}">${formatNumber(endpoint.avgResponseTime, 1)}ms</div>
                <div class="table-cell ${errorClass}">${formatNumber(endpoint.errorRate, 2)}%</div>
            </div>
        `;
    });
    
    tableContainer.innerHTML = html;
}

function updateUserTable() {
    const tableContainer = document.getElementById('userMetricsTable');
    const userData = metricsData.users;
    
    if (!userData) {
        tableContainer.innerHTML = '<div class="loading">No user data available</div>';
        return;
    }
    
    let html = '<div class="table-header">User Activity Metrics</div>';
    html += `
        <div class="table-row">
            <div class="table-cell">Total Registered Users</div>
            <div class="table-cell metric">${formatNumber(userData.totalUsers)}</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Active Users (24h)</div>
            <div class="table-cell metric">${formatNumber(userData.activeUsers)}</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Recent Logins</div>
            <div class="table-cell metric">${formatNumber(userData.recentLogins)}</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Account Lockouts</div>
            <div class="table-cell ${userData.accountLockouts > 0 ? 'warning' : 'metric'}">${formatNumber(userData.accountLockouts)}</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
    `;
    
    tableContainer.innerHTML = html;
}

function updateSystemTable() {
    const tableContainer = document.getElementById('systemMetricsTable');
    const systemData = metricsData.system;
    
    if (!systemData) {
        tableContainer.innerHTML = '<div class="loading">No system data available</div>';
        return;
    }
    
    let html = '<div class="table-header">System Performance Metrics</div>';
    html += `
        <div class="table-row">
            <div class="table-cell">Uptime</div>
            <div class="table-cell metric">${formatUptime(systemData.uptime)}</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Memory Usage</div>
            <div class="table-cell metric">${formatNumber(systemData.memoryUsage.used)}MB / ${formatNumber(systemData.memoryUsage.total)}MB</div>
            <div class="table-cell">${formatNumber(systemData.memoryUsage.percentage)}%</div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Database Response Time</div>
            <div class="table-cell ${systemData.databaseHealth.responseTime > 100 ? 'warning' : 'metric'}">${formatNumber(systemData.databaseHealth.responseTime)}ms</div>
            <div class="table-cell">${systemData.databaseHealth.status}</div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Active Sessions</div>
            <div class="table-cell metric">${formatNumber(systemData.sessionMetrics.active)}</div>
            <div class="table-cell">Total: ${formatNumber(systemData.sessionMetrics.total)}</div>
            <div class="table-cell"></div>
        </div>
    `;
    
    tableContainer.innerHTML = html;
}

function updateQueryTable() {
    const tableContainer = document.getElementById('queryMetricsTable');
    const queryData = metricsData.queries;
    
    if (!queryData) {
        tableContainer.innerHTML = '<div class="loading">No query data available</div>';
        return;
    }
    
    let html = '<div class="table-header">Query Performance Statistics</div>';
    html += `
        <div class="table-row">
            <div class="table-cell">Total Queries</div>
            <div class="table-cell metric">${formatNumber(queryData.totalQueries)}</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Slow Queries</div>
            <div class="table-cell ${queryData.slowQueries > 0 ? 'warning' : 'metric'}">${formatNumber(queryData.slowQueries)}</div>
            <div class="table-cell">${formatNumber((queryData.slowQueries / queryData.totalQueries) * 100, 2)}%</div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Average Duration</div>
            <div class="table-cell metric">${formatNumber(queryData.avgDuration, 1)}ms</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
        <div class="table-row">
            <div class="table-cell">Error Rate</div>
            <div class="table-cell ${queryData.errorRate > 1 ? 'error' : 'metric'}">${formatNumber(queryData.errorRate, 2)}%</div>
            <div class="table-cell"></div>
            <div class="table-cell"></div>
        </div>
    `;
    
    tableContainer.innerHTML = html;
}

function updateSlowQueriesTable() {
    const tableContainer = document.getElementById('slowQueriesTable');
    const slowQueries = metricsData.slowQueries?.slowQueries || [];
    
    if (slowQueries.length === 0) {
        tableContainer.innerHTML = '<div class="loading">No slow queries detected 🎉</div>';
        return;
    }
    
    let html = '<div class="table-header">Slow Query Analysis</div>';
    
    slowQueries.forEach(query => {
        html += `
            <div class="table-row">
                <div class="table-cell">${query.operation} (${query.table})</div>
                <div class="table-cell metric">${formatNumber(query.avgDuration, 1)}ms</div>
                <div class="table-cell">${formatNumber(query.count)} times</div>
                <div class="table-cell warning">${formatNumber(query.maxDuration)}ms max</div>
            </div>
        `;
    });
    
    tableContainer.innerHTML = html;
}

function updateIndexRecommendations() {
    const container = document.getElementById('indexRecommendations');
    const recommendations = metricsData.recommendations?.recommendations || [];
    
    if (recommendations.length === 0) {
        container.innerHTML = '<div class="loading">No index recommendations available</div>';
        return;
    }
    
    let html = '';
    recommendations.forEach(rec => {
        html += `
            <div class="recommendation-item">
                <div class="recommendation-title">📋 ${rec.table} - ${rec.columns.join(', ')}</div>
                <div class="recommendation-description">${rec.reason}</div>
                <div class="recommendation-query">${rec.query}</div>
                <div class="recommendation-impact ${rec.impact.toLowerCase()}">${rec.impact} Impact</div>
            </div>
        `;
    });
    
    container.innerHTML = html;
}

// === CHART FUNCTIONS ===
function initializeCharts() {
    // Initialize empty charts that will be updated with data
    initRequestsChart();
    initResponseTimesChart();
}

function initRequestsChart() {
    const ctx = document.getElementById('requestsChart')?.getContext('2d');
    if (!ctx) return;
    
    charts.requests = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Requests per Hour',
                data: [],
                borderColor: '#64ffda',
                backgroundColor: 'rgba(100, 255, 218, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: { color: '#e0e6ed' }
                }
            },
            scales: {
                x: { 
                    ticks: { color: '#8892b0' },
                    grid: { color: 'rgba(35, 53, 84, 0.5)' }
                },
                y: { 
                    ticks: { color: '#8892b0' },
                    grid: { color: 'rgba(35, 53, 84, 0.5)' }
                }
            }
        }
    });
}

function initResponseTimesChart() {
    const ctx = document.getElementById('responseTimesChart')?.getContext('2d');
    if (!ctx) return;
    
    charts.responseTimes = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [],
            datasets: [{
                label: 'Response Time (ms)',
                data: [],
                backgroundColor: 'rgba(100, 255, 218, 0.6)',
                borderColor: '#64ffda',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: { color: '#e0e6ed' }
                }
            },
            scales: {
                x: { 
                    ticks: { color: '#8892b0' },
                    grid: { color: 'rgba(35, 53, 84, 0.5)' }
                },
                y: { 
                    ticks: { color: '#8892b0' },
                    grid: { color: 'rgba(35, 53, 84, 0.5)' }
                }
            }
        }
    });
}

function updateEndpointsChart() {
    const ctx = document.getElementById('endpointsChart')?.getContext('2d');
    if (!ctx || !metricsData.api?.endpoints) return;
    
    if (charts.endpoints) {
        charts.endpoints.destroy();
    }
    
    const endpoints = metricsData.api.endpoints.slice(0, 10); // Top 10
    
    charts.endpoints = new Chart(ctx, {
        type: 'horizontalBar',
        data: {
            labels: endpoints.map(e => e.path),
            datasets: [{
                label: 'Request Count',
                data: endpoints.map(e => e.requestCount),
                backgroundColor: 'rgba(100, 255, 218, 0.6)',
                borderColor: '#64ffda',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: { color: '#e0e6ed' }
                }
            },
            scales: {
                x: { 
                    ticks: { color: '#8892b0' },
                    grid: { color: 'rgba(35, 53, 84, 0.5)' }
                },
                y: { 
                    ticks: { color: '#8892b0' },
                    grid: { color: 'rgba(35, 53, 84, 0.5)' }
                }
            }
        }
    });
}

function updateUserGrowthChart() {
    // Placeholder for user growth chart
    // Would need historical data from backend
}

function updateSystemCharts() {
    updateMemoryChart();
    updateDbHealthChart();
}

function updateMemoryChart() {
    const ctx = document.getElementById('memoryChart')?.getContext('2d');
    if (!ctx || !metricsData.system?.memoryUsage) return;
    
    if (charts.memory) {
        charts.memory.destroy();
    }
    
    const memory = metricsData.system.memoryUsage;
    
    charts.memory = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Used', 'Free'],
            datasets: [{
                data: [memory.used, memory.total - memory.used],
                backgroundColor: ['#64ffda', 'rgba(35, 53, 84, 0.5)'],
                borderColor: ['#64ffda', '#233554'],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: { color: '#e0e6ed' }
                }
            }
        }
    });
}

function updateDbHealthChart() {
    const ctx = document.getElementById('dbHealthChart')?.getContext('2d');
    if (!ctx || !metricsData.system?.databaseHealth) return;
    
    if (charts.dbHealth) {
        charts.dbHealth.destroy();
    }
    
    const dbHealth = metricsData.system.databaseHealth;
    const responseTime = dbHealth.responseTime;
    
    // Create a simple gauge-like chart
    charts.dbHealth = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Response Time', 'Optimal'],
            datasets: [{
                data: [responseTime, Math.max(0, 100 - responseTime)],
                backgroundColor: [
                    responseTime > 100 ? '#ff6b6b' : responseTime > 50 ? '#ffb84d' : '#00ff88',
                    'rgba(35, 53, 84, 0.5)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: { color: '#e0e6ed' }
                }
            }
        }
    });
}

function updateCharts() {
    // Update all charts with new data
    if (currentTab === 'api' && metricsData.api) {
        updateEndpointsChart();
    }
    if (currentTab === 'system' && metricsData.system) {
        updateSystemCharts();
    }
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

function formatUptime(seconds) {
    if (!seconds) return '-';
    
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (days > 0) {
        return `${days}d ${hours}h ${minutes}m`;
    } else if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else {
        return `${minutes}m`;
    }
}

function updateLastUpdated() {
    document.getElementById('lastUpdated').textContent = new Date().toLocaleTimeString();
}

function setupAutoRefresh() {
    const checkbox = document.getElementById('autoRefresh');
    
    function toggleAutoRefresh() {
        if (checkbox.checked) {
            refreshInterval = setInterval(refreshAllMetrics, 30000); // 30 seconds
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

// === ERROR HANDLING ===
function showError(message) {
    document.getElementById('errorMessage').textContent = message;
    document.getElementById('errorModal').classList.remove('hidden');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.add('hidden');
}

// === KEYBOARD SHORTCUTS ===
document.addEventListener('keydown', function(e) {
    if (e.ctrlKey || e.metaKey) {
        switch(e.key) {
            case 'r':
                e.preventDefault();
                refreshAllMetrics();
                break;
            case '1':
                e.preventDefault();
                switchTab('overview');
                break;
            case '2':
                e.preventDefault();
                switchTab('api');
                break;
            case '3':
                e.preventDefault();
                switchTab('users');
                break;
            case '4':
                e.preventDefault();
                switchTab('system');
                break;
            case '5':
                e.preventDefault();
                switchTab('queries');
                break;
        }
    }
});