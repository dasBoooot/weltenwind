const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

console.log('🔍 Debug Backend Startup\n');

// 1. Prüfe Working Directory
console.log('1️⃣ Working Directory:');
console.log('   CWD:', process.cwd());
console.log('   __dirname:', __dirname);

// 2. Prüfe .env Datei
console.log('\n2️⃣ .env Datei:');
const envPath = path.join(process.cwd(), '.env');
const envExists = fs.existsSync(envPath);
console.log('   Pfad:', envPath);
console.log('   Existiert:', envExists ? '✅ Ja' : '❌ Nein');

if (envExists) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  const lines = envContent.split('\n');
  console.log('   Zeilen:', lines.length);
  
  // Prüfe JWT_SECRET (ohne Wert anzuzeigen)
  const hasJwtSecret = lines.some(line => line.trim().startsWith('JWT_SECRET='));
  console.log('   JWT_SECRET vorhanden:', hasJwtSecret ? '✅ Ja' : '❌ Nein');
  
  if (hasJwtSecret) {
    const jwtLine = lines.find(line => line.trim().startsWith('JWT_SECRET='));
    const jwtValue = jwtLine.split('=')[1].trim().replace(/["']/g, '');
    console.log('   JWT_SECRET Länge:', jwtValue.length, 'Zeichen');
  }
}

// 3. Lade dotenv
console.log('\n3️⃣ Lade dotenv:');
const result = dotenv.config();
if (result.error) {
  console.log('   ❌ Fehler:', result.error.message);
} else {
  console.log('   ✅ Erfolgreich geladen');
  console.log('   Geladene Variablen:', Object.keys(result.parsed || {}).join(', '));
}

// 4. Prüfe Environment Variablen
console.log('\n4️⃣ Environment Variablen:');
console.log('   NODE_ENV:', process.env.NODE_ENV || '(nicht gesetzt)');
console.log('   PORT:', process.env.PORT || '(nicht gesetzt)');
console.log('   JWT_SECRET:', process.env.JWT_SECRET ? `✅ Gesetzt (${process.env.JWT_SECRET.length} Zeichen)` : '❌ NICHT GESETZT');
console.log('   DATABASE_URL:', process.env.DATABASE_URL ? '✅ Gesetzt' : '❌ Nicht gesetzt');

// 5. Teste JWT Config Import
console.log('\n5️⃣ Teste JWT Config Import:');
try {
  // Kompiliere TypeScript zur Laufzeit
  require('ts-node').register({
    transpileOnly: true,
    compilerOptions: {
      module: 'commonjs'
    }
  });
  
  const { jwtConfig } = require('./src/config/jwt.config');
  console.log('   ✅ JWT Config erfolgreich geladen');
  console.log('   Secret vorhanden:', jwtConfig.getSecret() ? 'Ja' : 'Nein');
} catch (error) {
  console.log('   ❌ Fehler beim Laden:', error.message);
  if (error.stack) {
    console.log('   Stack:', error.stack.split('\n')[1]);
  }
}

// 6. Prüfe TypeScript Compilation
console.log('\n6️⃣ TypeScript Compilation Test:');
try {
  const ts = require('typescript');
  console.log('   TypeScript Version:', ts.version);
  
  // Teste rateLimiter compilation
  const source = fs.readFileSync(path.join(__dirname, 'src/middleware/rateLimiter.ts'), 'utf8');
  const result = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS }
  });
  
  if (result.diagnostics && result.diagnostics.length > 0) {
    console.log('   ❌ Compilation Fehler in rateLimiter.ts');
  } else {
    console.log('   ✅ rateLimiter.ts kompiliert ohne Fehler');
  }
} catch (error) {
  console.log('   ❌ TypeScript Test fehlgeschlagen:', error.message);
}

console.log('\n✅ Debug abgeschlossen\n');