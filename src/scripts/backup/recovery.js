#!/usr/bin/env node
// 🔄 Database Recovery Script
// Für sichere Wiederherstellung von PostgreSQL-Backups

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// 📋 Recovery Configuration
const CONFIG = {
  backupDir: process.env.BACKUP_DIR || '/srv/weltenwind/backups',
  recoveryLogFile: '/srv/weltenwind/backups/logs/recovery.log',
  tempRestoreDb: 'weltenwind_recovery_test',
  maxRestoreTimeMinutes: 60,
  confirmationRequired: true
};

// 🔧 Utility Functions
function log(level, message, data = {}) {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] [${level.toUpperCase()}] ${message} ${JSON.stringify(data)}`;
  
  console.log(logEntry);
  
  try {
    const logDir = path.dirname(CONFIG.recoveryLogFile);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    fs.appendFileSync(CONFIG.recoveryLogFile, logEntry + '\n');
  } catch (error) {
    console.error('Failed to write to recovery log:', error.message);
  }
}

function getDatabaseUrlComponents() {
  const dbUrl = process.env.DATABASE_URL;
  if (!dbUrl) {
    throw new Error('DATABASE_URL not configured');
  }

  const url = new URL(dbUrl);
  return {
    host: url.hostname,
    port: url.port || 5432,
    username: url.username,
    password: url.password,
    database: url.pathname.slice(1), // Remove leading slash
    connectionString: dbUrl
  };
}

async function askConfirmation(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise((resolve) => {
    rl.question(question + ' (yes/no): ', (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === 'yes' || answer.toLowerCase() === 'y');
    });
  });
}

// 📁 Backup File Discovery
function findBackupFiles() {
  const backupFiles = [];
  const backupTypes = ['daily', 'weekly', 'monthly', 'manual'];

  for (const type of backupTypes) {
    const typeDir = path.join(CONFIG.backupDir, type);
    if (fs.existsSync(typeDir)) {
      const files = fs.readdirSync(typeDir)
        .filter(file => file.endsWith('.sql') || file.endsWith('.sql.gz'))
        .map(file => {
          const filePath = path.join(typeDir, file);
          const stats = fs.statSync(filePath);
          return {
            type,
            filename: file,
            path: filePath,
            size: stats.size,
            created: stats.mtime,
            sizeHuman: `${Math.round(stats.size / 1024 / 1024 * 100) / 100} MB`
          };
        });
      
      backupFiles.push(...files);
    }
  }

  return backupFiles.sort((a, b) => b.created.getTime() - a.created.getTime());
}

function displayBackupFiles() {
  const files = findBackupFiles();
  
  if (files.length === 0) {
    console.log('❌ Keine Backup-Dateien gefunden!');
    console.log(`📁 Backup-Verzeichnis: ${CONFIG.backupDir}`);
    return [];
  }

  console.log('\n📋 Verfügbare Backup-Dateien:');
  console.log('='.repeat(80));
  
  files.forEach((file, index) => {
    const age = Math.round((Date.now() - file.created.getTime()) / (1000 * 60 * 60));
    console.log(`${index + 1}. [${file.type.toUpperCase()}] ${file.filename}`);
    console.log(`   📅 Erstellt: ${file.created.toLocaleString()}`);
    console.log(`   📊 Größe: ${file.sizeHuman}`);
    console.log(`   ⏰ Alter: ${age < 24 ? age + 'h' : Math.round(age / 24) + 'd'}`);
    console.log('');
  });

  return files;
}

// 🔍 Backup Verification
async function verifyBackupFile(filePath) {
  log('info', 'Verifying backup file', { filePath });

  try {
    // Check if file exists and has content
    const stats = fs.statSync(filePath);
    if (stats.size < 1024) {
      throw new Error('Backup file too small (< 1KB)');
    }

    // For compressed files, test compression
    if (filePath.endsWith('.gz')) {
      execSync(`gzip -t "${filePath}"`, { stdio: 'pipe' });
      log('info', 'Compressed backup file verification passed');
    }

    // Try to peek at the backup content
    let command;
    if (filePath.endsWith('.gz')) {
      command = `zcat "${filePath}" | head -20`;
    } else {
      command = `head -20 "${filePath}"`;
    }

    const content = execSync(command, { encoding: 'utf8' });
    if (!content.includes('PostgreSQL database dump')) {
      console.warn('⚠️  Warning: File may not be a valid PostgreSQL dump');
    }

    log('info', 'Backup file verification completed', {
      size: stats.size,
      sizeHuman: `${Math.round(stats.size / 1024 / 1024 * 100) / 100} MB`
    });

    return true;
  } catch (error) {
    log('error', 'Backup file verification failed', { error: error.message });
    throw new Error(`Backup verification failed: ${error.message}`);
  }
}

// 🧪 Test Recovery (Safe Mode)
async function testRecovery(backupPath) {
  log('info', 'Starting test recovery', { backupPath });

  const db = getDatabaseUrlComponents();
  const testDb = CONFIG.tempRestoreDb;

  try {
    // Create temporary test database
    console.log('🔧 Creating temporary test database...');
    execSync(`createdb -h ${db.host} -p ${db.port} -U ${db.username} "${testDb}"`, {
      env: { ...process.env, PGPASSWORD: db.password },
      stdio: 'pipe'
    });

    log('info', 'Test database created', { testDatabase: testDb });

    // Restore to test database
    console.log('🔄 Restoring backup to test database...');
    let restoreCommand;
    
    if (backupPath.endsWith('.gz')) {
      restoreCommand = `zcat "${backupPath}" | psql -h ${db.host} -p ${db.port} -U ${db.username} -d "${testDb}"`;
    } else {
      restoreCommand = `psql -h ${db.host} -p ${db.port} -U ${db.username} -d "${testDb}" < "${backupPath}"`;
    }

    execSync(restoreCommand, {
      env: { ...process.env, PGPASSWORD: db.password },
      stdio: 'pipe',
      timeout: CONFIG.maxRestoreTimeMinutes * 60 * 1000
    });

    // Verify restored data
    console.log('✅ Test restore completed, verifying data...');
    const tableCount = execSync(
      `psql -h ${db.host} -p ${db.port} -U ${db.username} -d "${testDb}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"`,
      {
        env: { ...process.env, PGPASSWORD: db.password },
        encoding: 'utf8'
      }
    ).trim();

    log('info', 'Test recovery verification completed', {
      tablesRestored: parseInt(tableCount) || 0
    });

    console.log(`📊 Test recovery successful! ${tableCount} tables restored.`);
    return true;

  } catch (error) {
    log('error', 'Test recovery failed', { error: error.message });
    throw error;
  } finally {
    // Cleanup test database
    try {
      execSync(`dropdb -h ${db.host} -p ${db.port} -U ${db.username} "${testDb}"`, {
        env: { ...process.env, PGPASSWORD: db.password },
        stdio: 'pipe'
      });
      log('info', 'Test database cleaned up');
    } catch (cleanupError) {
      log('warn', 'Failed to cleanup test database', { error: cleanupError.message });
    }
  }
}

// 🔄 Full Recovery (Production)
async function performFullRecovery(backupPath) {
  log('warn', 'Starting FULL RECOVERY - THIS WILL REPLACE PRODUCTION DATA', { backupPath });

  const db = getDatabaseUrlComponents();

  try {
    console.log('🚨 PRODUCTION RECOVERY STARTING...');
    console.log('⚠️  This will COMPLETELY REPLACE the current database!');
    
    // Final confirmation
    if (CONFIG.confirmationRequired) {
      const confirmed = await askConfirmation('Are you ABSOLUTELY SURE you want to proceed?');
      if (!confirmed) {
        console.log('❌ Recovery cancelled by user');
        return false;
      }
    }

    // Create backup of current database first
    console.log('💾 Creating safety backup of current database...');
    const safetyBackupPath = path.join(
      CONFIG.backupDir, 
      'manual', 
      `safety_backup_before_recovery_${new Date().toISOString().replace(/[:.]/g, '-')}.sql.gz`
    );

    execSync(
      `pg_dump "${db.connectionString}" | gzip > "${safetyBackupPath}"`,
      { stdio: 'pipe', timeout: 10 * 60 * 1000 }
    );

    log('info', 'Safety backup created', { safetyBackupPath });
    console.log(`💾 Safety backup created: ${safetyBackupPath}`);

    // Terminate all connections to the database
    console.log('🔌 Terminating database connections...');
    execSync(
      `psql -h ${db.host} -p ${db.port} -U ${db.username} -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${db.database}' AND pid <> pg_backend_pid();"`,
      {
        env: { ...process.env, PGPASSWORD: db.password },
        stdio: 'pipe'
      }
    );

    // Drop and recreate database
    console.log('🗑️  Dropping current database...');
    execSync(`dropdb -h ${db.host} -p ${db.port} -U ${db.username} "${db.database}"`, {
      env: { ...process.env, PGPASSWORD: db.password },
      stdio: 'pipe'
    });

    console.log('🔧 Creating fresh database...');
    execSync(`createdb -h ${db.host} -p ${db.port} -U ${db.username} "${db.database}"`, {
      env: { ...process.env, PGPASSWORD: db.password },
      stdio: 'pipe'
    });

    // Restore from backup
    console.log('🔄 Restoring from backup...');
    console.log('⏳ This may take several minutes...');

    let restoreCommand;
    if (backupPath.endsWith('.gz')) {
      restoreCommand = `zcat "${backupPath}" | psql -h ${db.host} -p ${db.port} -U ${db.username} -d "${db.database}"`;
    } else {
      restoreCommand = `psql -h ${db.host} -p ${db.port} -U ${db.username} -d "${db.database}" < "${backupPath}"`;
    }

    execSync(restoreCommand, {
      env: { ...process.env, PGPASSWORD: db.password },
      stdio: 'inherit', // Show progress
      timeout: CONFIG.maxRestoreTimeMinutes * 60 * 1000
    });

    // Verify restoration
    console.log('✅ Verifying restored database...');
    const tableCount = execSync(
      `psql -h ${db.host} -p ${db.port} -U ${db.username} -d "${db.database}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"`,
      {
        env: { ...process.env, PGPASSWORD: db.password },
        encoding: 'utf8'
      }
    ).trim();

    log('info', 'Full recovery completed successfully', {
      backupPath,
      tablesRestored: parseInt(tableCount) || 0,
      safetyBackupPath
    });

    console.log('🎉 DATABASE RECOVERY COMPLETED SUCCESSFULLY!');
    console.log(`📊 Tables restored: ${tableCount}`);
    console.log(`💾 Safety backup: ${safetyBackupPath}`);
    console.log('⚠️  Remember to restart your application services!');

    return true;

  } catch (error) {
    log('error', 'Full recovery failed', { error: error.message });
    console.error('💥 RECOVERY FAILED!');
    console.error(`Error: ${error.message}`);
    console.error('⚠️  Database may be in an inconsistent state!');
    console.error('🔧 Consider restoring from the safety backup or try recovery again.');
    throw error;
  }
}

// 🎯 Interactive Recovery Mode
async function interactiveRecovery() {
  console.log('🔄 Weltenwind Database Recovery Tool');
  console.log('===================================\n');

  // Show available backups
  const backupFiles = displayBackupFiles();
  if (backupFiles.length === 0) {
    return;
  }

  // Get user selection
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  const selection = await new Promise((resolve) => {
    rl.question('\n📋 Select backup number (or 0 to cancel): ', resolve);
  });

  const selectedIndex = parseInt(selection) - 1;
  if (selectedIndex < 0 || selectedIndex >= backupFiles.length) {
    console.log('❌ Invalid selection or cancelled');
    rl.close();
    return;
  }

  const selectedBackup = backupFiles[selectedIndex];
  console.log(`\n✅ Selected: ${selectedBackup.filename}`);

  // Choose recovery type
  const recoveryType = await new Promise((resolve) => {
    rl.question('\n🔧 Recovery type:\n1. Test recovery (safe)\n2. Full recovery (DANGEROUS)\n\nSelect (1-2): ', resolve);
  });

  rl.close();

  try {
    // Verify backup file
    await verifyBackupFile(selectedBackup.path);

    if (recoveryType === '1') {
      console.log('\n🧪 Starting TEST RECOVERY (safe mode)...');
      await testRecovery(selectedBackup.path);
      console.log('✅ Test recovery completed successfully!');
    } else if (recoveryType === '2') {
      console.log('\n🚨 Starting FULL RECOVERY (PRODUCTION)...');
      await performFullRecovery(selectedBackup.path);
    } else {
      console.log('❌ Invalid recovery type selected');
      return;
    }

  } catch (error) {
    console.error(`💥 Recovery failed: ${error.message}`);
    process.exit(1);
  }
}

// 🎯 Command Line Recovery Mode
async function commandLineRecovery() {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.error('Usage: node recovery.js <backup-file> <test|full>');
    process.exit(1);
  }

  const backupPath = args[0];
  const mode = args[1];

  if (!fs.existsSync(backupPath)) {
    console.error(`❌ Backup file not found: ${backupPath}`);
    process.exit(1);
  }

  if (!['test', 'full'].includes(mode)) {
    console.error('❌ Mode must be "test" or "full"');
    process.exit(1);
  }

  try {
    await verifyBackupFile(backupPath);

    if (mode === 'test') {
      await testRecovery(backupPath);
    } else {
      await performFullRecovery(backupPath);
    }

  } catch (error) {
    console.error(`💥 Recovery failed: ${error.message}`);
    process.exit(1);
  }
}

// 🎯 Main Function
async function main() {
  try {
    if (process.argv.length > 2) {
      await commandLineRecovery();
    } else {
      await interactiveRecovery();
    }
  } catch (error) {
    log('error', 'Recovery script failed', { error: error.message });
    console.error(`💥 Fatal error: ${error.message}`);
    process.exit(1);
  }
}

// 🏃‍♂️ Execute
if (require.main === module) {
  main();
}