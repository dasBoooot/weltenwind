// Test-Script für Passwort-Validierung
const fetch = require('node-fetch');

const API_URL = process.env.API_URL || 'http://192.168.2.168:3000';

async function testPasswordStrength(password, username = 'testuser', email = 'test@example.com') {
  console.log(`\n🔐 Teste Passwort: "${password}"`);
  console.log(`   Mit Username: "${username}", Email: "${email}"`);
  
  try {
    const response = await fetch(`${API_URL}/api/auth/check-password-strength`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password, username, email })
    });

    const result = await response.json();
    
    console.log(`\n📊 Ergebnis:`);
    console.log(`   Gültig: ${result.valid ? '✅' : '❌'}`);
    console.log(`   Stärke: ${result.strengthText} (${result.score}/4)`);
    console.log(`   Crack-Zeit: ${result.estimatedCrackTime}`);
    
    if (result.feedback && result.feedback.length > 0) {
      console.log(`\n   ⚠️  Probleme:`);
      result.feedback.forEach(f => console.log(`      - ${f}`));
    }
    
    if (result.suggestions && result.suggestions.length > 0) {
      console.log(`\n   💡 Vorschläge:`);
      result.suggestions.forEach(s => console.log(`      - ${s}`));
    }
    
    console.log(`\n   📈 Fortschritt: ${'█'.repeat(Math.floor(result.strengthPercentage / 10))}${'░'.repeat(10 - Math.floor(result.strengthPercentage / 10))} ${result.strengthPercentage}%`);
    
  } catch (error) {
    console.error('❌ Fehler:', error.message);
  }
}

async function runTests() {
  console.log('🧪 Passwort-Validierungs-Tests\n');
  console.log('================================');

  // Test verschiedene Passwörter
  const testCases = [
    // Schwache Passwörter
    { password: '123456', desc: 'Nur Zahlen' },
    { password: 'password', desc: 'Häufiges Passwort' },
    { password: 'qwerty', desc: 'Tastaturmuster' },
    { password: 'testuser', desc: 'Enthält Username' },
    { password: 'test@example.com', desc: 'Enthält Email' },
    { password: 'aaaaaaaa', desc: 'Wiederholende Zeichen' },
    { password: 'admin123', desc: 'Häufiges Admin-Passwort' },
    { password: 'weltenwind', desc: 'Projektname' },
    
    // Mittlere Passwörter
    { password: 'Test123!', desc: 'Kurz aber mit Variation' },
    { password: 'MyP@ssw0rd', desc: 'Klassisches Format' },
    { password: 'Sommer2024!', desc: 'Mit Jahreszahl' },
    
    // Starke Passwörter
    { password: 'Korrekt-Pferd-Batterie-Klammer', desc: 'Passphrase' },
    { password: 'xJ9#mK2$vL5!qR8&', desc: 'Zufällig generiert' },
    { password: 'DerSchnelleBrauneFuchsSpringtÜberDenFaulenHund', desc: 'Langer Satz' },
    { password: 'My$up3r$tr0ng!P@ssw0rd2024', desc: 'Komplex mit allem' }
  ];

  for (const testCase of testCases) {
    console.log(`\n🔹 ${testCase.desc}`);
    await testPasswordStrength(testCase.password);
    console.log('\n' + '─'.repeat(60));
  }

  // Test mit verschiedenen Usernames
  console.log('\n\n🔸 Spezialtest: Passwort enthält Username-Variationen');
  const username = 'JohnDoe';
  const passwordsWithUsername = [
    'john123',
    'johndoe2024',
    'MyNameIsJohn',
    'doe123456',
    'J0hnD03!',
    'CompletelyDifferent123!'
  ];

  for (const pwd of passwordsWithUsername) {
    await testPasswordStrength(pwd, username, 'john@example.com');
    console.log('\n' + '─'.repeat(60));
  }
}

// Führe Tests aus
runTests().catch(console.error);