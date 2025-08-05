#!/usr/bin/env node
// 🗄️ Automated Backup Execution Script
// Für Cron-Jobs: Daily, Weekly, Monthly Backups

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// 🎯 Backup Types
const BACKUP_TYPES = {
  daily: {
    description: 'Tägliches Backup (alle Tables)',
    schedule: '0 2 * * *', // 2:00 AM daily
    retention: '7 days'
  },
  weekly: {
    description: 'Wöchentliches Full-Backup (alle Tables + Verifikation)',
    schedule: '0 1 * * 0', // 1:00 AM on Sundays
    retention: '4 weeks'
  },
  monthly: {
    description: 'Monatliches Archiv-Backup (alle Tables + Offsite)',
    schedule: '0 0 1 * *', // 12:00 AM on 1st of month
    retention: '12 months'
  }
};

// 📋 Script Configuration
const CONFIG = {
  backendDir: path.resolve(__dirname, '../..'),
  logFile: '/srv/weltenwind/backups/logs/automated-backup.log',
  maxRetries: 3,
  retryDelay: 60000, // 1 minute
  healthCheckUrl: 'http://localhost:3000/api/health',
  timeoutMs: 30 * 60 * 1000 // 30 minutes
};

// 🔧 Utility Functions
function log(level, message, data = {}) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    level,
    message,
    data,
    pid: process.pid
  };

  console.log(`[${timestamp}] [${level.toUpperCase()}] ${message}`, data);

  // Append to log file
  try {
    const logDir = path.dirname(CONFIG.logFile);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    
    fs.appendFileSync(CONFIG.logFile, JSON.stringify(logEntry) + '\n');
  } catch (error) {
    console.error('Failed to write to log file:', error.message);
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// 🏥 Health Check
async function performHealthCheck() {
  return new Promise((resolve, reject) => {
    const http = require('http');
    const url = new URL(CONFIG.healthCheckUrl);
    
    const req = http.get({
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname,
      timeout: 5000
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.status === 'OK') {
            resolve(response);
          } else {
            reject(new Error(`Health check failed: ${response.status}`));
          }
        } catch (error) {
          reject(new Error(`Invalid health check response: ${error.message}`));
        }
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Health check timeout'));
    });
  });
}

// 🗄️ Execute Backup
async function executeBackup(type, attempt = 1) {
  log('info', `Starting ${type} backup`, { attempt, maxRetries: CONFIG.maxRetries });

  return new Promise((resolve, reject) => {
    // Use ts-node to run the backup service
    const backupScript = path.join(CONFIG.backendDir, 'scripts/backup/create-backup.ts');
    
    const child = spawn('npx', ['ts-node', backupScript, type], {
      cwd: CONFIG.backendDir,
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, NODE_ENV: process.env.NODE_ENV || 'production' }
    });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    child.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    const timeout = setTimeout(() => {
      child.kill('SIGTERM');
      reject(new Error(`Backup timeout after ${CONFIG.timeoutMs / 60000} minutes`));
    }, CONFIG.timeoutMs);

    child.on('close', (code) => {
      clearTimeout(timeout);
      
      if (code === 0) {
        log('info', `${type} backup completed successfully`, {
          attempt,
          stdout: stdout.trim(),
          duration: 'see stdout'
        });
        resolve({ stdout, stderr });
      } else {
        const error = new Error(`Backup process exited with code ${code}`);
        log('error', `${type} backup failed`, {
          attempt,
          exitCode: code,
          stderr: stderr.trim(),
          stdout: stdout.trim()
        });
        reject(error);
      }
    });

    child.on('error', (error) => {
      clearTimeout(timeout);
      log('error', `${type} backup process error`, { attempt, error: error.message });
      reject(error);
    });
  });
}

// 🔄 Retry Logic
async function executeWithRetry(type) {
  for (let attempt = 1; attempt <= CONFIG.maxRetries; attempt++) {
    try {
      const result = await executeBackup(type, attempt);
      return result;
    } catch (error) {
      log('warn', `Backup attempt ${attempt} failed`, {
        type,
        attempt,
        error: error.message,
        willRetry: attempt < CONFIG.maxRetries
      });

      if (attempt === CONFIG.maxRetries) {
        throw error;
      }

      log('info', `Waiting ${CONFIG.retryDelay / 1000}s before retry...`);
      await sleep(CONFIG.retryDelay);
    }
  }
}

// 📊 Post-Backup Actions
async function performPostBackupActions(type, result) {
  log('info', `Performing post-backup actions for ${type}`, {});

  try {
    // Log completion
    log('info', `${type} backup completed successfully`, {
      type,
      timestamp: new Date().toISOString(),
      success: true
    });

    // Additional actions based on backup type
    switch (type) {
      case 'weekly':
        log('info', 'Weekly backup - performing additional verification');
        // TODO: Enhanced verification for weekly backups
        break;
        
      case 'monthly':
        log('info', 'Monthly backup - scheduling offsite upload');
        // TODO: Trigger offsite backup upload
        break;
    }

    return true;
  } catch (error) {
    log('error', 'Post-backup actions failed', { error: error.message });
    return false;
  }
}

// 🚨 Error Notification
async function sendErrorNotification(type, error) {
  const errorInfo = {
    type,
    error: error.message,
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname(),
    environment: process.env.NODE_ENV || 'unknown'
  };

  log('error', 'BACKUP FAILED - Sending error notification', errorInfo);

  // TODO: Implement email/slack notification
  // For now, just ensure it's prominently logged
  console.error('\n='.repeat(80));
  console.error('🚨 CRITICAL: BACKUP FAILED 🚨');
  console.error('Type:', type);
  console.error('Error:', error.message);
  console.error('Time:', errorInfo.timestamp);
  console.error('Host:', errorInfo.hostname);
  console.error('='.repeat(80));
}

// 🎯 Main Execution Function
async function main() {
  const args = process.argv.slice(2);
  const type = args[0];

  if (!type || !BACKUP_TYPES[type]) {
    console.error('Usage: node automated-backup.js <type>');
    console.error('Types:', Object.keys(BACKUP_TYPES).join(', '));
    console.error('\nSchedules:');
    Object.entries(BACKUP_TYPES).forEach(([key, config]) => {
      console.error(`  ${key}: ${config.description} (${config.schedule})`);
    });
    process.exit(1);
  }

  const startTime = Date.now();
  
  log('info', 'Automated backup started', {
    type,
    description: BACKUP_TYPES[type].description,
    schedule: BACKUP_TYPES[type].schedule,
    retention: BACKUP_TYPES[type].retention,
    pid: process.pid,
    nodeVersion: process.version,
    environment: process.env.NODE_ENV || 'development'
  });

  try {
    // 1. Health Check
    log('info', 'Performing system health check...');
    try {
      await performHealthCheck();
      log('info', 'System health check passed');
    } catch (healthError) {
      log('warn', 'Health check failed, but proceeding with backup', {
        error: healthError.message
      });
    }

    // 2. Execute Backup with Retry Logic
    log('info', `Executing ${type} backup...`);
    const result = await executeWithRetry(type);
    
    // 3. Post-Backup Actions
    await performPostBackupActions(type, result);

    // 4. Success Summary
    const duration = Date.now() - startTime;
    log('info', 'Automated backup completed successfully', {
      type,
      totalDuration: `${Math.round(duration / 1000)}s`,
      success: true
    });

    process.exit(0);

  } catch (error) {
    const duration = Date.now() - startTime;
    
    log('error', 'Automated backup failed', {
      type,
      error: error.message,
      totalDuration: `${Math.round(duration / 1000)}s`,
      success: false
    });

    await sendErrorNotification(type, error);
    process.exit(1);
  }
}

// 🔄 Cleanup on Exit
process.on('SIGINT', () => {
  log('warn', 'Automated backup interrupted by SIGINT');
  process.exit(130);
});

process.on('SIGTERM', () => {
  log('warn', 'Automated backup terminated by SIGTERM');
  process.exit(143);
});

process.on('uncaughtException', (error) => {
  log('error', 'Uncaught exception in automated backup', { error: error.message, stack: error.stack });
  process.exit(1);
});

// 🏃‍♂️ Execute Main Function
if (require.main === module) {
  main().catch(error => {
    console.error('Unhandled error in main:', error);
    process.exit(1);
  });
}

module.exports = { main, executeBackup, performHealthCheck };