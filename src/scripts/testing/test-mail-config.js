require('dotenv').config();
const nodemailer = require('nodemailer');

async function testMailConfiguration() {
  console.log('📧 Teste Mail-Konfiguration...\n');

  const {
    MAIL_HOST,
    MAIL_PORT,
    MAIL_SECURE,
    MAIL_USER,
    MAIL_PASS,
    MAIL_FROM,
    MAIL_FROM_NAME
  } = process.env;

  // Prüfe Konfiguration
  console.log('🔍 Konfiguration:');
  console.log(`   Host: ${MAIL_HOST || '❌ NICHT GESETZT'}`);
  console.log(`   Port: ${MAIL_PORT || '❌ NICHT GESETZT'}`);
  console.log(`   Secure: ${MAIL_SECURE || 'false'}`);
  console.log(`   User: ${MAIL_USER || '❌ NICHT GESETZT'}`);
  console.log(`   Pass: ${MAIL_PASS ? '✅ GESETZT' : '❌ NICHT GESETZT'}`);
  console.log(`   From: ${MAIL_FROM_NAME || 'Weltenwind'} <${MAIL_FROM || MAIL_USER || '❌ NICHT GESETZT'}>\n`);

  if (!MAIL_HOST || !MAIL_USER || !MAIL_PASS) {
    console.error('❌ Unvollständige Mail-Konfiguration!');
    console.log('\n📝 Nächste Schritte:');
    console.log('1. Kopiere mail-config-template.env in deine .env Datei');
    console.log('2. Erstelle ein App-Passwort für dein Microsoft-Konto');
    console.log('3. Führe dieses Script erneut aus');
    return;
  }

  try {
    // Erstelle Transporter
    console.log('🔧 Erstelle Mail-Transporter...');
    const transporter = nodemailer.createTransport({
      host: MAIL_HOST,
      port: parseInt(MAIL_PORT || '587'),
      secure: MAIL_SECURE === 'true',
      auth: {
        user: MAIL_USER,
        pass: MAIL_PASS,
      },
      // Microsoft/Outlook spezifische Konfiguration
      ...(MAIL_HOST.includes('outlook') && {
        service: 'Outlook365',
        tls: {
          ciphers: 'SSLv3',
          rejectUnauthorized: false
        }
      })
    });

    // Teste Verbindung
    console.log('🔌 Teste SMTP-Verbindung...');
    await transporter.verify();
    console.log('✅ SMTP-Verbindung erfolgreich!\n');

    // Sende Test-E-Mail
    console.log('📤 Sende Test-E-Mail...');
    const testEmail = MAIL_USER; // Sende an sich selbst

    const mailOptions = {
      from: `${MAIL_FROM_NAME || 'Weltenwind'} <${MAIL_FROM || MAIL_USER}>`,
      to: testEmail,
      subject: '🧪 Weltenwind Mail-Test',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); color: white; padding: 20px; text-align: center;">
            <h1>🎉 Mail-Konfiguration erfolgreich!</h1>
          </div>
          <div style="padding: 20px; background: #f9f9f9;">
            <h2>Glückwunsch!</h2>
            <p>Deine Weltenwind Mail-Konfiguration funktioniert einwandfrei.</p>
            
            <h3>📊 Konfiguration:</h3>
            <ul>
              <li><strong>Host:</strong> ${MAIL_HOST}</li>
              <li><strong>Port:</strong> ${MAIL_PORT}</li>
              <li><strong>User:</strong> ${MAIL_USER}</li>
              <li><strong>From:</strong> ${MAIL_FROM_NAME} &lt;${MAIL_FROM || MAIL_USER}&gt;</li>
            </ul>
            
            <h3>🚀 Nächste Schritte:</h3>
            <ul>
              <li>✅ Invite-Mails werden automatisch versendet</li>
              <li>✅ Password-Reset-Mails funktionieren</li>
              <li>✅ Alle E-Mail-Features sind aktiv</li>
            </ul>
            
            <p style="color: #666; font-size: 12px; margin-top: 20px;">
              Diese Test-E-Mail wurde von deinem Weltenwind Backend versendet.<br>
              Zeitstempel: ${new Date().toLocaleString('de-DE')}
            </p>
          </div>
        </div>
      `
    };

    const result = await transporter.sendMail(mailOptions);
    
    console.log('✅ Test-E-Mail erfolgreich versendet!');
    console.log(`   📧 An: ${testEmail}`);
    console.log(`   📨 Message ID: ${result.messageId}`);
    console.log(`   📬 Prüfe dein Postfach!\n`);

    console.log('🎯 ERFOLGREICH! Deine Mail-Konfiguration funktioniert!');
    console.log('💡 Jetzt kannst du Invites und Password-Resets testen.');

  } catch (error) {
    console.error('❌ Mail-Test fehlgeschlagen:');
    console.error(`   Fehler: ${error.message}\n`);
    
    console.log('🔧 Lösungsvorschläge:');
    
    if (error.message.includes('Invalid login')) {
      console.log('• Prüfe deine E-Mail-Adresse und das App-Passwort');
      console.log('• Stelle sicher, dass du ein App-Passwort verwendest (nicht dein normales Passwort)');
      console.log('• App-Passwort erstellen: https://account.microsoft.com/security');
    }
    
    if (error.message.includes('connection')) {
      console.log('• Prüfe deine Internetverbindung');
      console.log('• Firewall-Einstellungen prüfen (Port 587)');
    }
    
    if (error.message.includes('authentication')) {
      console.log('• 2FA aktiviert? Verwende App-Passwort statt normalem Passwort');
      console.log('• Konto gesperrt? Prüfe dein Microsoft-Konto');
    }
    
    console.log('\n📝 Weitere Hilfe:');
    console.log('• Schaue in mail-config-template.env für Beispiel-Konfiguration');
    console.log('• Microsoft Outlook SMTP Dokumentation: https://support.microsoft.com/en-us/office/pop-imap-and-smtp-settings-for-outlook-com-d088b986-291d-42b8-9564-9c414e2aa040');
  }
}

testMailConfiguration().catch(console.error);