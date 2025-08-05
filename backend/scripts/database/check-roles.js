// Einfaches Script zum Prüfen der Rollen-Konfiguration
// Falls node-fetch nicht installiert ist, nutze: npm install node-fetch@2
// Oder öffne im Browser: http://192.168.2.168:3000/api/auth/roles-check

let fetch;
try {
  fetch = require('node-fetch');
} catch (e) {
  console.error('node-fetch nicht installiert. Bitte ausführen: npm install node-fetch@2');
  console.log('Oder öffne im Browser: http://192.168.2.168:3000/api/auth/roles-check');
  process.exit(1);
}

async function checkRoles() {
  try {
    console.log('Prüfe Rollen-Konfiguration...\n');
    
    const response = await fetch('http://192.168.2.168:3000/api/auth/roles-check');
    const data = await response.json();
    
    console.log(`Status: ${data.status}`);
    console.log(`Anzahl Rollen: ${data.roleCount}`);
    console.log(`Anzahl User: ${data.userCount}`);
    console.log(`Anzahl UserRole-Einträge: ${data.userRoleCount}`);
    console.log(`Seeds ausgeführt: ${data.seedsExecuted ? 'JA' : 'NEIN'}`);
    
    if (data.roles && data.roles.length > 0) {
      console.log('\nVerfügbare Rollen:');
      data.roles.forEach(role => {
        console.log(`  - ${role.name} (ID: ${role.id}, Permissions: ${role.permissionCount})`);
      });
    } else {
      console.log('\n❌ KEINE ROLLEN GEFUNDEN!');
      console.log('Bitte führe "npm run seed" aus!');
    }
    
    // Prüfe ob "user" Rolle existiert
    const userRole = data.roles?.find(r => r.name === 'user');
    if (!userRole) {
      console.log('\n⚠️  WARNUNG: Standard-User-Rolle fehlt!');
    } else {
      console.log('\n✅ Standard-User-Rolle gefunden');
    }
    
  } catch (error) {
    console.error('Fehler beim Prüfen:', error.message);
    console.log('\nStelle sicher, dass der Backend-Server läuft (Port 3000)');
    console.log('Und dass die Änderungen deployed wurden (Server neu gestartet)');
  }
}

checkRoles(); 