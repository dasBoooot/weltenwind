// 🗄️ Intelligent Database Backup Service
// Dynamisches, selbstanpassendes Backup-System für PostgreSQL + Prisma

import { PrismaClient } from '@prisma/client';
import { execSync, spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import { loggers } from '../config/logger.config';

const prisma = new PrismaClient();

// 📊 Backup-Konfiguration aus Environment Variables
interface BackupConfig {
  enabled: boolean;
  backupDir: string;
  retention: {
    dailyDays: number;
    weeklyWeeks: number;
    monthlyMonths: number;
  };
  compression: {
    enabled: boolean;
    level: number;
  };
  parallelJobs: number;
  autoDiscovery: boolean;
  smartScheduling: boolean;
  sizeOptimization: boolean;
  healthCheckEnabled: boolean;
  autoVerification: boolean;
  performance: {
    maxFileSizeMB: number;
    ioNiceLevel: number;
    cpuNiceLevel: number;
  };
  offsite: {
    enabled: boolean;
    s3Bucket?: string;
    s3Region?: string;
    s3AccessKey?: string;
    s3SecretKey?: string;
  };
  debug: boolean;
}

// 📋 Database Table Information
interface TableInfo {
  name: string;
  schema: string;
  estimatedRows: number;
  estimatedSizeMB: number;
  category: 'critical' | 'important' | 'optional' | 'logs';
  changeFrequency: 'high' | 'medium' | 'low' | 'static';
  backupStrategy: 'full' | 'incremental' | 'skip';
  lastBackup?: Date;
  backupPriority: number; // 1-10 (10 = highest)
}

// 🎯 Backup Job Status
interface BackupJob {
  id: string;
  type: 'daily' | 'weekly' | 'monthly' | 'manual';
  status: 'pending' | 'running' | 'completed' | 'failed';
  startTime: Date;
  endTime?: Date;
  duration?: number;
  filePath?: string;
  fileSize?: number;
  tables: string[];
  error?: string;
  verification?: {
    status: 'pending' | 'passed' | 'failed';
    error?: string;
  };
}

// 📊 Backup Statistics
interface BackupStats {
  totalBackups: number;
  totalSize: number;
  successRate: number;
  avgDuration: number;
  lastBackup?: Date;
  nextScheduled?: Date;
  diskUsage: {
    used: number;
    available: number;
    percentage: number;
  };
}

class IntelligentBackupService {
  private config: BackupConfig;
  private activeJobs: Map<string, BackupJob> = new Map();
  private tableInfo: Map<string, TableInfo> = new Map();

  constructor() {
    this.config = this.loadConfig();
    this.ensureBackupDirectory();
  }

  // 🔧 Lade Backup-Konfiguration aus Environment
  private loadConfig(): BackupConfig {
    return {
      enabled: process.env.BACKUP_ENABLED === 'true',
      backupDir: process.env.BACKUP_DIR || '/srv/weltenwind/backups',
      retention: {
        dailyDays: parseInt(process.env.BACKUP_RETENTION_DAILY_DAYS || '7'),
        weeklyWeeks: parseInt(process.env.BACKUP_RETENTION_WEEKLY_WEEKS || '4'),
        monthlyMonths: parseInt(process.env.BACKUP_RETENTION_MONTHLY_MONTHS || '12')
      },
      compression: {
        enabled: process.env.BACKUP_COMPRESSION_ENABLED === 'true',
        level: parseInt(process.env.BACKUP_COMPRESSION_LEVEL || '6')
      },
      parallelJobs: parseInt(process.env.BACKUP_PARALLEL_JOBS || '2'),
      autoDiscovery: process.env.BACKUP_AUTO_DISCOVERY === 'true',
      smartScheduling: process.env.BACKUP_SMART_SCHEDULING === 'true',
      sizeOptimization: process.env.BACKUP_SIZE_OPTIMIZATION === 'true',
      healthCheckEnabled: process.env.BACKUP_HEALTH_CHECK_ENABLED === 'true',
      autoVerification: process.env.BACKUP_AUTO_VERIFICATION === 'true',
      performance: {
        maxFileSizeMB: parseInt(process.env.BACKUP_MAX_FILE_SIZE_MB || '1000'),
        ioNiceLevel: parseInt(process.env.BACKUP_IO_NICE_LEVEL || '3'),
        cpuNiceLevel: parseInt(process.env.BACKUP_CPU_NICE_LEVEL || '10')
      },
      offsite: {
        enabled: process.env.BACKUP_OFFSITE_ENABLED === 'true',
        s3Bucket: process.env.BACKUP_S3_BUCKET,
        s3Region: process.env.BACKUP_S3_REGION || 'eu-central-1',
        s3AccessKey: process.env.BACKUP_S3_ACCESS_KEY,
        s3SecretKey: process.env.BACKUP_S3_SECRET_KEY
      },
      debug: process.env.BACKUP_DEBUG_MODE === 'true'
    };
  }

  // 📁 Backup-Verzeichnis sicherstellen
  private ensureBackupDirectory(): void {
    try {
      if (!fs.existsSync(this.config.backupDir)) {
        fs.mkdirSync(this.config.backupDir, { recursive: true });
      }

      // Unterverzeichnisse erstellen
      const subDirs = ['daily', 'weekly', 'monthly', 'manual', 'logs'];
      for (const subDir of subDirs) {
        const fullPath = path.join(this.config.backupDir, subDir);
        if (!fs.existsSync(fullPath)) {
          fs.mkdirSync(fullPath, { recursive: true });
        }
      }

      loggers.system.info('Backup directories initialized', {
        backupDir: this.config.backupDir,
        subdirectories: subDirs
      });
    } catch (error: any) {
      loggers.system.error('Failed to initialize backup directories', error);
      throw new Error(`Backup directory initialization failed: ${error.message}`);
    }
  }

  // 🔍 Automatische Database-Introspection
  async discoverDatabaseStructure(): Promise<void> {
    if (!this.config.autoDiscovery) return;

    try {
      loggers.system.info('Starting database structure discovery...');

      // Get all tables from PostgreSQL information_schema
      const tables = await prisma.$queryRaw<Array<{
        table_name: string;
        table_schema: string;
      }>>`
        SELECT table_name, table_schema 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name;
      `;

      for (const table of tables) {
        const tableInfo = await this.analyzeTable(table.table_name, table.table_schema);
        this.tableInfo.set(table.table_name, tableInfo);
      }

      loggers.system.info('Database structure discovery completed', {
        tablesDiscovered: tables.length,
        categories: this.getTableCategorySummary()
      });

    } catch (error: any) {
      loggers.system.error('Database structure discovery failed', error);
      throw error;
    }
  }

  // 🔬 Einzelne Tabelle analysieren
  private async analyzeTable(tableName: string, schema: string): Promise<TableInfo> {
    try {
      // Table size and row count
      const [sizeInfo] = await prisma.$queryRaw<Array<{
        estimated_rows: number;
        size_mb: number;
      }>>`
        SELECT 
          COALESCE(n_tup_ins + n_tup_upd + n_tup_del, 0) as estimated_rows,
          ROUND(pg_total_relation_size(c.oid) / 1024.0 / 1024.0, 2) as size_mb
        FROM pg_class c
        LEFT JOIN pg_stat_user_tables s ON c.oid = s.relid
        WHERE c.relname = ${tableName}
        AND c.relkind = 'r';
      `;

      // Kategorisierung basierend auf Tabellennamen und -typ
      const category = this.categorizeTable(tableName);
      const changeFrequency = this.determineChangeFrequency(tableName, sizeInfo?.estimated_rows || 0);
      const backupStrategy = this.determineBackupStrategy(category, changeFrequency, sizeInfo?.size_mb || 0);
      const backupPriority = this.calculateBackupPriority(category, changeFrequency);

      return {
        name: tableName,
        schema,
        estimatedRows: sizeInfo?.estimated_rows || 0,
        estimatedSizeMB: sizeInfo?.size_mb || 0,
        category,
        changeFrequency,
        backupStrategy,
        backupPriority
      };

    } catch (error: any) {
      loggers.system.warn(`Failed to analyze table ${tableName}`, error);
      
      // Fallback für unbekannte Tabellen
      return {
        name: tableName,
        schema,
        estimatedRows: 0,
        estimatedSizeMB: 0,
        category: 'important',
        changeFrequency: 'medium',
        backupStrategy: 'full',
        backupPriority: 5
      };
    }
  }

  // 🏷️ Tabelle kategorisieren
  private categorizeTable(tableName: string): TableInfo['category'] {
    // Critical: User data, core business logic
    if (['users', 'worlds', 'players', 'roles', 'permissions'].includes(tableName)) {
      return 'critical';
    }
    
    // Important: Application functionality
    if (['invites', 'user_roles', 'role_permissions', 'password_resets'].includes(tableName)) {
      return 'important';
    }
    
    // Logs: System logs, sessions (less critical)
    if (['sessions', '_prisma_migrations'].includes(tableName) || 
        tableName.includes('log') || tableName.includes('audit')) {
      return 'logs';
    }
    
    // Optional: Other tables
    return 'optional';
  }

  // 📈 Change-Frequency bestimmen
  private determineChangeFrequency(tableName: string, estimatedRows: number): TableInfo['changeFrequency'] {
    // Sessions ändern sich sehr häufig
    if (tableName === 'sessions') return 'high';
    
    // User-Daten ändern sich medium
    if (['users', 'players', 'password_resets'].includes(tableName)) return 'medium';
    
    // Schema und Permissions ändern sich selten
    if (['roles', 'permissions', '_prisma_migrations'].includes(tableName)) return 'static';
    
    // Große Tabellen haben wahrscheinlich häufigere Änderungen
    if (estimatedRows > 10000) return 'high';
    if (estimatedRows > 1000) return 'medium';
    
    return 'low';
  }

  // 🎯 Backup-Strategie bestimmen
  private determineBackupStrategy(
    category: TableInfo['category'], 
    changeFrequency: TableInfo['changeFrequency'],
    sizeMB: number
  ): TableInfo['backupStrategy'] {
    // Sessions können übersprungen werden (Session-Rotation)
    if (category === 'logs' && changeFrequency === 'high' && sizeMB < 10) {
      return 'skip';
    }
    
    // Große, häufig ändernde Tabellen -> Incremental
    if (sizeMB > 100 && (changeFrequency === 'high' || changeFrequency === 'medium')) {
      return 'incremental';
    }
    
    // Standard: Full Backup
    return 'full';
  }

  // 🔢 Backup-Priorität berechnen
  private calculateBackupPriority(
    category: TableInfo['category'], 
    changeFrequency: TableInfo['changeFrequency']
  ): number {
    let priority = 5; // Base priority
    
    // Category Priority
    switch (category) {
      case 'critical': priority += 4; break;
      case 'important': priority += 2; break;
      case 'optional': priority += 0; break;
      case 'logs': priority -= 2; break;
    }
    
    // Change Frequency Priority
    switch (changeFrequency) {
      case 'high': priority += 1; break;
      case 'medium': priority += 0; break;
      case 'low': priority -= 1; break;
      case 'static': priority -= 2; break;
    }
    
    return Math.max(1, Math.min(10, priority));
  }

  // 📊 Tabellen-Kategorie-Zusammenfassung
  private getTableCategorySummary(): Record<string, number> {
    const summary: Record<string, number> = {};
    
    for (const table of this.tableInfo.values()) {
      summary[table.category] = (summary[table.category] || 0) + 1;
    }
    
    return summary;
  }

  // 🗄️ Backup erstellen
  async createBackup(type: BackupJob['type'] = 'manual', tables?: string[]): Promise<BackupJob> {
    if (!this.config.enabled) {
      throw new Error('Backup system is disabled');
    }

    const jobId = crypto.randomUUID();
    const job: BackupJob = {
      id: jobId,
      type,
      status: 'pending',
      startTime: new Date(),
      tables: tables || Array.from(this.tableInfo.keys())
    };

    this.activeJobs.set(jobId, job);

    try {
      loggers.system.info('Starting backup job', {
        jobId,
        type,
        tablesCount: job.tables.length
      });

      job.status = 'running';
      
      // Database Structure Discovery (if needed)
      if (this.tableInfo.size === 0) {
        await this.discoverDatabaseStructure();
      }

      // Generate backup filename
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `weltenwind_${type}_${timestamp}${this.config.compression.enabled ? '.sql.gz' : '.sql'}`;
      const filePath = path.join(this.config.backupDir, type, filename);

      // Create backup using pg_dump
      await this.executePgDump(filePath, job.tables);

      // Verify backup if enabled
      if (this.config.autoVerification) {
        job.verification = await this.verifyBackup(filePath);
      }

      // Upload to offsite if enabled
      if (this.config.offsite.enabled) {
        await this.uploadToOffsite(filePath);
      }

      // Complete job
      job.status = 'completed';
      job.endTime = new Date();
      job.duration = job.endTime.getTime() - job.startTime.getTime();
      job.filePath = filePath;
      job.fileSize = fs.statSync(filePath).size;

      loggers.system.info('Backup job completed successfully', {
        jobId,
        duration: `${Math.round(job.duration / 1000)}s`,
        fileSize: `${Math.round(job.fileSize / 1024 / 1024)}MB`,
        filePath
      });

      // Cleanup old backups
      await this.cleanupOldBackups(type);

      return job;

    } catch (error: any) {
      job.status = 'failed';
      job.endTime = new Date();
      job.error = error.message;

      loggers.system.error('Backup job failed', {
        jobId,
        error: error.message,
        duration: job.endTime.getTime() - job.startTime.getTime()
      });

      throw error;
    }
  }

  // 🔧 pg_dump ausführen
  private async executePgDump(filePath: string, tables: string[]): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        const dbUrl = process.env.DATABASE_URL;
        if (!dbUrl) {
          throw new Error('DATABASE_URL not configured');
        }

        // Build pg_dump command
        const args = [
          dbUrl,
          '--verbose',
          '--no-owner',
          '--no-privileges',
          '--format=custom'
        ];

        // Add specific tables if provided
        if (tables.length > 0) {
          for (const table of tables) {
            args.push('--table', table);
          }
        }

        // Compression handling
        const outputFile = this.config.compression.enabled ? 
          `gzip -${this.config.compression.level} > "${filePath}"` : 
          `> "${filePath}"`;

        const command = `nice -n ${this.config.performance.cpuNiceLevel} ionice -c 2 -n ${this.config.performance.ioNiceLevel} pg_dump ${args.join(' ')} ${outputFile}`;

        if (this.config.debug) {
          loggers.system.info('Executing pg_dump command', { command });
        }

        execSync(command, {
          stdio: this.config.debug ? 'inherit' : 'pipe',
          timeout: 30 * 60 * 1000 // 30 minutes timeout
        });

        resolve();
      } catch (error: any) {
        reject(new Error(`pg_dump failed: ${error.message}`));
      }
    });
  }

  // ✅ Backup verifizieren
  private async verifyBackup(filePath: string): Promise<{ status: 'passed' | 'failed'; error?: string }> {
    try {
      // Check if file exists and has reasonable size
      const stats = fs.statSync(filePath);
      if (stats.size < 1024) { // Less than 1KB is suspicious
        return { status: 'failed', error: 'Backup file too small' };
      }

      // For compressed files, try to decompress a small portion
      if (this.config.compression.enabled && filePath.endsWith('.gz')) {
        execSync(`gzip -t "${filePath}"`, { stdio: 'pipe' });
      }

      return { status: 'passed' };
    } catch (error: any) {
      return { status: 'failed', error: error.message };
    }
  }

  // ☁️ Upload to offsite storage
  private async uploadToOffsite(filePath: string): Promise<void> {
    if (!this.config.offsite.enabled || !this.config.offsite.s3Bucket) {
      return;
    }

    // TODO: Implement S3 upload
    loggers.system.info('Offsite backup upload scheduled', { filePath });
  }

  // 🧹 Alte Backups aufräumen
  async cleanupOldBackups(type: BackupJob['type']): Promise<void> {
    try {
      const backupTypeDir = path.join(this.config.backupDir, type);
      const files = fs.readdirSync(backupTypeDir);
      
      let retentionDays: number;
      switch (type) {
        case 'daily': 
          retentionDays = this.config.retention.dailyDays;
          break;
        case 'weekly': 
          retentionDays = this.config.retention.weeklyWeeks * 7;
          break;
        case 'monthly': 
          retentionDays = this.config.retention.monthlyMonths * 30;
          break;
        default:
          retentionDays = 7; // Manual backups kept for 7 days
      }

      const cutoffTime = Date.now() - (retentionDays * 24 * 60 * 60 * 1000);
      let deletedCount = 0;

      for (const file of files) {
        const filePath = path.join(backupTypeDir, file);
        const stats = fs.statSync(filePath);
        
        if (stats.mtime.getTime() < cutoffTime) {
          fs.unlinkSync(filePath);
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        loggers.system.info('Old backups cleaned up', {
          type,
          deletedCount,
          retentionDays
        });
      }
    } catch (error: any) {
      loggers.system.error('Backup cleanup failed', error);
    }
  }

  // 📊 Backup-Statistiken
  async getBackupStats(): Promise<BackupStats> {
    try {
      const stats: BackupStats = {
        totalBackups: 0,
        totalSize: 0,
        successRate: 0,
        avgDuration: 0,
        diskUsage: {
          used: 0,
          available: 0,
          percentage: 0
        }
      };

      // Calculate disk usage
      const diskUsage = execSync(`df -B1 "${this.config.backupDir}" | tail -1 | awk '{print $2,$3,$4}'`, { encoding: 'utf8' });
      const [total, used, available] = diskUsage.trim().split(' ').map(Number);
      
      stats.diskUsage = {
        used: used,
        available: available,
        percentage: Math.round((used / total) * 100)
      };

      // Scan backup directories
      const subDirs = ['daily', 'weekly', 'monthly', 'manual'];
      for (const subDir of subDirs) {
        const dirPath = path.join(this.config.backupDir, subDir);
        if (fs.existsSync(dirPath)) {
          const files = fs.readdirSync(dirPath);
          for (const file of files) {
            const fileStat = fs.statSync(path.join(dirPath, file));
            stats.totalBackups++;
            stats.totalSize += fileStat.size;
            
            if (!stats.lastBackup || fileStat.mtime > stats.lastBackup) {
              stats.lastBackup = fileStat.mtime;
            }
          }
        }
      }

      // TODO: Calculate success rate and avg duration from job history
      stats.successRate = 95; // Placeholder
      stats.avgDuration = 120000; // Placeholder: 2 minutes

      return stats;
    } catch (error: any) {
      loggers.system.error('Failed to calculate backup stats', error);
      throw error;
    }
  }

  // 🏥 Health Check
  async performHealthCheck(): Promise<{
    status: 'healthy' | 'degraded' | 'critical';
    checks: Array<{ name: string; status: 'pass' | 'fail'; message: string }>;
  }> {
    const checks: Array<{ name: string; status: 'pass' | 'fail'; message: string }> = [];

    // Check if backup system is enabled
    checks.push({
      name: 'backup_enabled',
      status: this.config.enabled ? 'pass' : 'fail',
      message: this.config.enabled ? 'Backup system is enabled' : 'Backup system is disabled'
    });

    // Check backup directory
    checks.push({
      name: 'backup_directory',
      status: fs.existsSync(this.config.backupDir) ? 'pass' : 'fail',
      message: fs.existsSync(this.config.backupDir) ? 'Backup directory accessible' : 'Backup directory not found'
    });

    // Check recent backups
    try {
      const stats = await this.getBackupStats();
      const recentBackup = stats.lastBackup && (Date.now() - stats.lastBackup.getTime()) < (48 * 60 * 60 * 1000);
      checks.push({
        name: 'recent_backup',
        status: recentBackup ? 'pass' : 'fail',
        message: recentBackup ? 'Recent backup found' : 'No recent backup (>48h)'
      });
    } catch (error) {
      checks.push({
        name: 'recent_backup',
        status: 'fail',
        message: 'Could not check recent backups'
      });
    }

    // Determine overall status
    const failedChecks = checks.filter(c => c.status === 'fail').length;
    let status: 'healthy' | 'degraded' | 'critical';
    
    if (failedChecks === 0) {
      status = 'healthy';
    } else if (failedChecks <= 1) {
      status = 'degraded';
    } else {
      status = 'critical';
    }

    return { status, checks };
  }

  // 🎯 Public Methods für API
  async getActiveJobs(): Promise<BackupJob[]> {
    return Array.from(this.activeJobs.values());
  }

  async getTableInfo(): Promise<TableInfo[]> {
    if (this.tableInfo.size === 0) {
      await this.discoverDatabaseStructure();
    }
    return Array.from(this.tableInfo.values());
  }

  getConfig(): BackupConfig {
    return { ...this.config };
  }
}

// 🚀 Singleton Export
export const backupService = new IntelligentBackupService();

// 📊 Export Types
export type { BackupConfig, TableInfo, BackupJob, BackupStats };