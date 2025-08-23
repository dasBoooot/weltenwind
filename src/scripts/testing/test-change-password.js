const fetch = require('node-fetch');

const API_URL = 'http://192.168.2.168:3000';
let accessToken = '';
let csrfToken = '';

console.log('🔐 Teste Passwort-Änderung mit Session-Rotation\n');
console.log('==============================================\n');

async function login() {
  console.log('1️⃣  Login als testuser1...');
  
  const response = await fetch(`${API_URL}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: 'testuser1',
      password: 'AAbb1234!!'
    })
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Login fehlgeschlagen: ${response.status} - ${error}`);
  }

  const data = await response.json();
  accessToken = data.accessToken;
  
  console.log('✅ Login erfolgreich!');
  console.log(`   Access Token: ${accessToken.substring(0, 20)}...`);
  console.log('');
}

async function getCsrfToken() {
  console.log('2️⃣  CSRF-Token abrufen...');
  
  const response = await fetch(`${API_URL}/api/auth/csrf-token`, {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`CSRF-Token Abruf fehlgeschlagen: ${response.status} - ${error}`);
  }

  const data = await response.json();
  csrfToken = data.csrfToken;
  
  console.log('✅ CSRF-Token erhalten!');
  console.log(`   Token: ${csrfToken.substring(0, 20)}...`);
  console.log('');
}

async function testChangePassword(currentPassword, newPassword, shouldSucceed = true) {
  console.log(`3️⃣  Teste Passwort-Änderung...`);
  console.log(`   Aktuelles Passwort: ${currentPassword}`);
  console.log(`   Neues Passwort: ${newPassword}`);
  
  // Neuen CSRF-Token holen für jeden Test
  await getCsrfTokenSilent();
  
  const response = await fetch(`${API_URL}/api/auth/change-password`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'X-CSRF-Token': csrfToken,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      currentPassword,
      newPassword
    })
  });

  // Prüfe Content-Type
  const contentType = response.headers.get('content-type');
  console.log(`   Status: ${response.status}`);
  console.log(`   Content-Type: ${contentType}`);

  let data;
  try {
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      // Falls HTML zurückkommt (z.B. Error-Seite)
      const text = await response.text();
      console.log(`   Response Text: ${text.substring(0, 200)}...`);
      throw new Error(`Server returned non-JSON response: ${response.status}`);
    }
  } catch (parseError) {
    const text = await response.text();
    console.log(`   Raw Response: ${text.substring(0, 300)}...`);
    throw new Error(`JSON Parse Error: ${parseError.message}`);
  }

  if (response.ok && shouldSucceed) {
    console.log('✅ Passwort erfolgreich geändert!');
    console.log(`   Message: ${data.message}`);
    console.log(`   Session rotiert: ${data.sessionRotated}`);
    console.log(`   Neuer Access Token: ${data.accessToken?.substring(0, 20)}...`);
    console.log(`   Neuer Refresh Token: ${data.refreshToken?.substring(0, 20)}...`);
    
    // Neue Tokens speichern
    if (data.accessToken) {
      accessToken = data.accessToken;
    }
    
    return true;
  } else if (!response.ok && !shouldSucceed) {
    console.log(`❌ Erwarteter Fehler: ${data.error}`);
    if (data.details) {
      console.log(`   Score: ${data.details.score}/4`);
      console.log(`   Feedback:`, data.details.feedback);
      console.log(`   Vorschläge:`, data.details.suggestions);
    }
    return false;
  } else {
    console.error(`❌ Unerwarteter Fehler: ${response.status}`);
    console.error(`   Response:`, data);
    return false;
  }
}

async function getCsrfTokenSilent() {
  const response = await fetch(`${API_URL}/api/auth/csrf-token`, {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`CSRF-Token Abruf fehlgeschlagen: ${response.status} - ${error}`);
  }

  const data = await response.json();
  csrfToken = data.csrfToken;
}

async function testOldTokenInvalid(oldToken) {
  console.log('\n4️⃣  Teste ob alter Token ungültig ist...');
  
  const response = await fetch(`${API_URL}/api/auth/me`, {
    headers: {
      'Authorization': `Bearer ${oldToken}`
    }
  });

  if (response.status === 401) {
    console.log('✅ Alter Token ist ungültig (wie erwartet)!');
  } else {
    console.log('❌ Alter Token ist noch gültig (sollte ungültig sein)!');
  }
}

async function runTests() {
  try {
    // Login
    await login();
    
    // CSRF-Token holen
    await getCsrfToken();
    
    // Speichere alten Token
    const oldToken = accessToken;
    
    console.log('\n🔹 Test 1: Falsches aktuelles Passwort');
    console.log('----------------------------------------');
    await testChangePassword('WrongPassword', 'NewTest456!', false);
    
    console.log('\n🔹 Test 2: Schwaches neues Passwort');
    console.log('----------------------------------------');
    await testChangePassword('AAbb1234!!', 'weak', false);
    
    console.log('\n🔹 Test 3: Gleiches Passwort');
    console.log('----------------------------------------');
    await testChangePassword('AAbb1234!!', 'AAbb1234!!', false);
    
    console.log('\n🔹 Test 4: Erfolgreiches Passwort ändern');
    console.log('----------------------------------------');
    const success = await testChangePassword('AAbb1234!!', 'NewSecurePass456!', true);
    
    if (success) {
      // Teste ob alter Token ungültig ist
      await testOldTokenInvalid(oldToken);
      
      console.log('\n\n✨ Alle Tests abgeschlossen!');
      console.log('\n⚠️  WICHTIG: Passwort wurde geändert!');
      console.log('   Altes Passwort: AAbb1234!!');
      console.log('   Neues Passwort: NewSecurePass456!');
      console.log('   Bitte manuell zurücksetzen falls nötig.');
    } else {
      console.log('\n❌ Passwort-Änderung fehlgeschlagen - alter Token Test übersprungen');
    }
    
  } catch (error) {
    console.error('\n❌ Fehler:', error.message);
  }
}

// Start
runTests();