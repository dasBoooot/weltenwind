#!/usr/bin/env ts-node
// 🗄️ Create Backup Script - TypeScript Interface
// Called by automated-backup.js for actual backup execution

import { backupService } from '../../src/services/backup.service';
import { loggers } from '../../src/config/logger.config';

// 🎯 Backup Types
type BackupType = 'daily' | 'weekly' | 'monthly' | 'manual';

// 📊 Script Results
interface BackupResult {
  success: boolean;
  jobId: string;
  type: BackupType;
  duration: number;
  fileSize?: number;
  filePath?: string;
  tablesBackedUp: number;
  error?: string;
}

// 🔧 Parse Command Line Arguments
function parseArguments(): { type: BackupType; tables?: string[] } {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    throw new Error('Backup type is required. Usage: ts-node create-backup.ts <type> [table1,table2,...]');
  }

  const type = args[0] as BackupType;
  if (!['daily', 'weekly', 'monthly', 'manual'].includes(type)) {
    throw new Error(`Invalid backup type: ${type}. Valid types: daily, weekly, monthly, manual`);
  }

  let tables: string[] | undefined;
  if (args[1]) {
    tables = args[1].split(',').map(t => t.trim()).filter(t => t.length > 0);
  }

  return { type, tables };
}

// 🎯 Main Backup Execution
async function createBackup(): Promise<BackupResult> {
  const startTime = Date.now();
  let result: BackupResult;

  try {
    const { type, tables } = parseArguments();

    console.log(`🗄️ Starting ${type} backup...`);
    console.log(`📅 Time: ${new Date().toISOString()}`);
    console.log(`🔧 Node: ${process.version}`);
    console.log(`📋 Tables: ${tables ? tables.join(', ') : 'all (auto-discovered)'}`);

    // Ensure backup service is ready
    console.log('🔍 Discovering database structure...');
    await backupService.discoverDatabaseStructure();

    const tableInfo = await backupService.getTableInfo();
    console.log(`📊 Discovered ${tableInfo.length} tables`);
    
    // Print table summary
    const categorySummary = tableInfo.reduce((acc, table) => {
      acc[table.category] = (acc[table.category] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
    
    console.log('📋 Table Categories:');
    Object.entries(categorySummary).forEach(([category, count]) => {
      console.log(`   ${category}: ${count} tables`);
    });

    // Execute backup job
    console.log(`🚀 Creating ${type} backup job...`);
    const job = await backupService.createBackup(type, tables);

    // Wait for completion (polling)
    console.log(`⏳ Backup job started: ${job.id}`);
    console.log('⏳ Waiting for completion...');

    let attempts = 0;
    const maxAttempts = 600; // 30 minutes (30s intervals)
    
    while (job.status === 'pending' || job.status === 'running') {
      await new Promise(resolve => setTimeout(resolve, 3000)); // 3s interval
      attempts++;
      
      if (attempts % 10 === 0) { // Every 30 seconds
        console.log(`⏳ Still running... (${Math.round(attempts * 3 / 60)}min)`);
      }
      
      if (attempts > maxAttempts) {
        throw new Error('Backup timeout - job did not complete within 30 minutes');
      }

      // Check current job status
      const activeJobs = await backupService.getActiveJobs();
      const currentJob = activeJobs.find(j => j.id === job.id);
      if (currentJob) {
        job.status = currentJob.status;
        job.endTime = currentJob.endTime;
        job.duration = currentJob.duration;
        job.filePath = currentJob.filePath;
        job.fileSize = currentJob.fileSize;
        job.error = currentJob.error;
      }
    }

    const duration = Date.now() - startTime;

    if (job.status === 'completed') {
      result = {
        success: true,
        jobId: job.id,
        type,
        duration,
        fileSize: job.fileSize,
        filePath: job.filePath,
        tablesBackedUp: job.tables.length
      };

      console.log('✅ Backup completed successfully!');
      console.log(`📁 File: ${job.filePath}`);
      console.log(`📊 Size: ${job.fileSize ? Math.round(job.fileSize / 1024 / 1024 * 100) / 100 : '?'} MB`);
      console.log(`⏱️  Duration: ${Math.round(duration / 1000)}s`);
      console.log(`📋 Tables: ${job.tables.length}`);

      // Verification status
      if (job.verification) {
        console.log(`🔍 Verification: ${job.verification.status}`);
        if (job.verification.status === 'failed' && job.verification.error) {
          console.log(`⚠️  Verification Error: ${job.verification.error}`);
        }
      }

    } else {
      throw new Error(job.error || `Backup job failed with status: ${job.status}`);
    }

  } catch (error: any) {
    const duration = Date.now() - startTime;
    
    result = {
      success: false,
      jobId: 'unknown',
      type: 'manual',
      duration,
      tablesBackedUp: 0,
      error: error.message
    };

    console.error('❌ Backup failed!');
    console.error(`💥 Error: ${error.message}`);
    console.error(`⏱️  Duration: ${Math.round(duration / 1000)}s`);

    // Log to system logger
    loggers.system.error('Backup script execution failed', {
      error: error.message,
      duration,
      stack: error.stack
    });
  }

  return result;
}

// 🎯 Script Entry Point
async function main() {
  try {
    const result = await createBackup();
    
    // Output machine-readable result
    console.log('\n' + '='.repeat(60));
    console.log('📊 BACKUP RESULT:');
    console.log(JSON.stringify(result, null, 2));
    console.log('='.repeat(60));

    // Exit with appropriate code
    process.exit(result.success ? 0 : 1);

  } catch (error: any) {
    console.error('\n💥 FATAL ERROR:');
    console.error(error.message);
    console.error('\nStack trace:');
    console.error(error.stack);
    
    process.exit(1);
  }
}

// 🔄 Signal Handling
process.on('SIGINT', () => {
  console.log('\n⚠️  Backup interrupted by user (SIGINT)');
  process.exit(130);
});

process.on('SIGTERM', () => {
  console.log('\n⚠️  Backup terminated (SIGTERM)');
  process.exit(143);
});

// 🏃‍♂️ Execute if called directly
if (require.main === module) {
  main();
}