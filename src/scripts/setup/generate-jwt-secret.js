const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

console.log('🔐 JWT Secret Generator\n');

// Generiere ein sicheres Secret (64 Bytes = 512 Bit)
const secret = crypto.randomBytes(64).toString('base64');

console.log('Generiertes JWT Secret:');
console.log('========================');
console.log(secret);
console.log('========================\n');

// Prüfe ob .env existiert
const envPath = path.join(__dirname, '.env');
const envExists = fs.existsSync(envPath);

if (envExists) {
  // Lese bestehende .env
  let envContent = fs.readFileSync(envPath, 'utf8');
  
  // Prüfe ob JWT_SECRET bereits existiert
  if (envContent.includes('JWT_SECRET=')) {
    console.log('⚠️  WARNUNG: JWT_SECRET existiert bereits in .env');
    console.log('   Möchtest du es überschreiben? Dies kann bestehende Sessions ungültig machen!');
    console.log('\n   Um fortzufahren, füge das Secret manuell zur .env hinzu:');
    console.log(`   JWT_SECRET="${secret}"`);
  } else {
    // Füge JWT_SECRET hinzu
    envContent += `\n\n# JWT Secret (generiert am ${new Date().toISOString()})\nJWT_SECRET="${secret}"\n`;
    fs.writeFileSync(envPath, envContent);
    console.log('✅ JWT_SECRET wurde zur .env Datei hinzugefügt');
  }
} else {
  // Erstelle neue .env mit Beispiel-Konfiguration
  const envTemplate = `# Datenbank
DATABASE_URL="postgresql://user:password@localhost:5432/weltenwind"

# JWT Secret (generiert am ${new Date().toISOString()})
JWT_SECRET="${secret}"

# Session-Konfiguration
ALLOW_MULTI_DEVICE_LOGIN=false
MAX_SESSIONS_PER_USER=1

# Server
PORT=3000
NODE_ENV=development
`;
  
  fs.writeFileSync(envPath, envTemplate);
  console.log('✅ Neue .env Datei wurde erstellt mit JWT_SECRET');
}

console.log('\n📝 Wichtige Hinweise:');
console.log('   - Bewahre das JWT_SECRET sicher auf');
console.log('   - Teile es niemals öffentlich (Git, etc.)');
console.log('   - Verwende unterschiedliche Secrets für Dev/Staging/Prod');
console.log('   - Bei Secret-Änderung werden alle bestehenden Sessions ungültig');
console.log('\n💡 Tipp: Sichere das Secret in einem Passwort-Manager!');