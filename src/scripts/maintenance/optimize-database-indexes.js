#!/usr/bin/env node
// 🗄️ Database Index Optimization Script
// Führt empfohlene Index-Optimierungen auf der PostgreSQL-Datenbank aus

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🗄️ Database Index Optimization Script');
console.log('=====================================\n');

// 📋 Index-Optimierungen basierend auf Query-Performance-Analyse
const indexOptimizations = [
  {
    name: 'sessions_user_expires',
    description: 'Optimiert Session-Lookups für aktive User-Sessions',
    impact: 'HIGH',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_user_expires 
      ON sessions (user_id, expires_at);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_sessions_user_expires;'
  },
  
  {
    name: 'sessions_token_lookup',
    description: 'Beschleunigt Token-basierte Session-Validierung',
    impact: 'HIGH',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_token 
      ON sessions (token);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_sessions_token;'
  },
  
  {
    name: 'sessions_last_accessed',
    description: 'Optimiert Session-Cleanup und Inaktivitäts-Tracking',
    impact: 'MEDIUM',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_last_accessed 
      ON sessions (last_accessed_at);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_sessions_last_accessed;'
  },
  
  {
    name: 'user_roles_scope_optimization',
    description: 'Beschleunigt Permission-Checks mit Scope-Filtering',
    impact: 'HIGH',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_roles_scope 
      ON user_roles (user_id, scope_type, scope_object_id);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_user_roles_scope;'
  },
  
  {
    name: 'role_permissions_scope_optimization',
    description: 'Optimiert Permission-Resolution für spezifische Scopes',
    impact: 'HIGH',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_role_permissions_scope 
      ON role_permissions (role_id, scope_type, scope_object_id);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_role_permissions_scope;'
  },
  
  {
    name: 'invites_email_world_lookup',
    description: 'Verhindert doppelte Invites und optimiert Lookups',
    impact: 'MEDIUM',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_invites_email_world 
      ON invites (email, world_id);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_invites_email_world;'
  },
  
  {
    name: 'invites_expires_cleanup',
    description: 'Beschleunigt Cleanup von abgelaufenen Invites',
    impact: 'MEDIUM',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_invites_expires 
      ON invites (expires_at);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_invites_expires;'
  },
  
  {
    name: 'players_world_active',
    description: 'Optimiert Active-Player-Counts pro World',
    impact: 'MEDIUM',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_players_world_active 
      ON players (world_id, left_at);
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_players_world_active;'
  },
  
  {
    name: 'users_lockout_status',
    description: 'Beschleunigt Account-Lockout-Status-Checks',
    impact: 'LOW',
    query: `
      CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_lockout 
      ON users (is_locked, locked_until) 
      WHERE is_locked = true OR locked_until IS NOT NULL;
    `,
    rollback: 'DROP INDEX CONCURRENTLY IF EXISTS idx_users_lockout;'
  }
];

// 🔍 Funktionen
function getDBConnectionString() {
  // Load .env file
  const envPath = path.join(__dirname, '../../.env');
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    const envLines = envContent.split('\n');
    for (const line of envLines) {
      if (line.startsWith('DATABASE_URL=')) {
        return line.split('=')[1].trim().replace(/"/g, '');
      }
    }
  }
  return process.env.DATABASE_URL;
}

function executeSQL(query, description) {
  const dbUrl = getDBConnectionString();
  if (!dbUrl) {
    throw new Error('DATABASE_URL nicht gefunden. Bitte .env-Datei überprüfen.');
  }

  console.log(`🔧 ${description}...`);
  try {
    execSync(`psql "${dbUrl}" -c "${query.replace(/\n/g, ' ').trim()}"`, { 
      stdio: 'pipe'
    });
    console.log('   ✅ Erfolgreich ausgeführt\n');
    return true;
  } catch (error) {
    // Check if error is just "index already exists"
    if (error.message.includes('already exists')) {
      console.log('   ⚪ Index bereits vorhanden - übersprungen\n');
      return true;
    }
    console.log('   ❌ Fehler aufgetreten:');
    console.log(`   ${error.message}\n`);
    return false;
  }
}

function checkIndexExists(indexName) {
  const dbUrl = getDBConnectionString();
  if (!dbUrl) return false;

  try {
    const result = execSync(`psql "${dbUrl}" -t -c "SELECT 1 FROM pg_indexes WHERE indexname = '${indexName}';"`, { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    return result.trim() === '1';
  } catch (error) {
    return false;
  }
}

function showIndexStatus(indexName) {
  const dbUrl = getDBConnectionString();
  if (!dbUrl) return;

  try {
    const result = execSync(`psql "${dbUrl}" -t -c "SELECT schemaname, tablename, indexname, indexdef FROM pg_indexes WHERE indexname = '${indexName}';"`, { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    if (result.trim()) {
      console.log('   📊 Index-Status: Vorhanden');
    } else {
      console.log('   📊 Index-Status: Nicht vorhanden');
    }
  } catch (error) {
    console.log('   📊 Index-Status: Unbekannt');
  }
}

function analyzeCurrentIndexes() {
  console.log('📊 Aktuelle Index-Analyse...\n');
  
  const dbUrl = getDBConnectionString();
  if (!dbUrl) {
    console.log('❌ DATABASE_URL nicht gefunden!\n');
    return;
  }

  try {
    console.log('🔍 Vorhandene Indizes:');
    const result = execSync(`psql "${dbUrl}" -c "SELECT schemaname, tablename, indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;"`, { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    console.log(result);
  } catch (error) {
    console.log('❌ Fehler beim Abrufen der Index-Informationen:\n', error.message);
  }
}

// 🚀 Hauptfunktion
function main() {
  const args = process.argv.slice(2);
  const command = args[0] || 'help';

  switch (command) {
    case 'analyze':
      analyzeCurrentIndexes();
      break;
      
    case 'apply':
      console.log('🚀 Starte Index-Optimierungen...\n');
      console.log('⚠️  WARNUNG: Führen Sie diese Optimierungen nur während wartungsarmer Zeiten durch!\n');
      
      let successCount = 0;
      let totalCount = indexOptimizations.length;
      
      for (const optimization of indexOptimizations) {
        console.log(`📝 ${optimization.name} (${optimization.impact} Impact)`);
        console.log(`   ${optimization.description}`);
        
        const indexName = `idx_${optimization.name}`;
        if (checkIndexExists(indexName)) {
          console.log('   ⚪ Index bereits vorhanden - übersprungen\n');
          successCount++;
          continue;
        }
        
        if (executeSQL(optimization.query, 'Index erstellen')) {
          successCount++;
        }
      }
      
      console.log(`\n🎯 Zusammenfassung:`);
      console.log(`   ✅ Erfolgreich: ${successCount}/${totalCount} Optimierungen`);
      console.log(`   ${successCount === totalCount ? '🎉 Alle Optimierungen erfolgreich!' : '⚠️  Einige Optimierungen fehlgeschlagen'}\n`);
      
      console.log('💡 Nächste Schritte:');
      console.log('   1. Query-Performance-Dashboard überprüfen: /api/query-performance');
      console.log('   2. Slow-Query-Logs überwachen');
      console.log('   3. Bei Problemen Rollback ausführen: npm run db:optimize -- rollback\n');
      break;
      
    case 'rollback':
      console.log('🔄 Starte Index-Rollback...\n');
      
      let rollbackCount = 0;
      for (const optimization of indexOptimizations.reverse()) {
        console.log(`📝 Rollback: ${optimization.name}`);
        if (executeSQL(optimization.rollback, 'Index entfernen')) {
          rollbackCount++;
        }
      }
      
      console.log(`\n🎯 Rollback abgeschlossen: ${rollbackCount}/${indexOptimizations.length} Indizes entfernt\n`);
      break;
      
    case 'status':
      console.log('📊 Index-Status-Check...\n');
      for (const optimization of indexOptimizations) {
        console.log(`📝 ${optimization.name}:`);
        showIndexStatus(`idx_${optimization.name}`);
        console.log();
      }
      break;
      
    case 'help':
    default:
      console.log('🔧 Verfügbare Kommandos:\n');
      console.log('   analyze   - Zeigt aktuelle Database-Indizes an');
      console.log('   apply     - Führt alle Index-Optimierungen aus');
      console.log('   rollback  - Entfernt alle erstellten Indizes');
      console.log('   status    - Zeigt Status der Optimierungs-Indizes');
      console.log('   help      - Zeigt diese Hilfe an\n');
      
      console.log('📊 Beispiele:');
      console.log('   node optimize-database-indexes.js analyze');
      console.log('   node optimize-database-indexes.js apply');
      console.log('   node optimize-database-indexes.js rollback\n');
      
      console.log('⚠️  Wichtige Hinweise:');
      console.log('   • Führen Sie Optimierungen nur während wartungsarmer Zeiten durch');
      console.log('   • Testen Sie Indizes zuerst in der Staging-Umgebung');
      console.log('   • Überwachen Sie die Performance nach der Anwendung');
      console.log('   • Bei Problemen sofort Rollback durchführen\n');
      break;
  }
}

// 🏃‍♂️ Script ausführen
if (require.main === module) {
  main();
}