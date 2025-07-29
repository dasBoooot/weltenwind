require('dotenv').config();
const nodemailer = require('nodemailer');

async function testGmailConfiguration() {
  console.log('📧 Teste Gmail-Konfiguration als Alternative...\n');

  console.log('🔧 Schritt-für-Schritt Gmail Setup:');
  console.log('1. Gehe zu: https://myaccount.google.com/security');
  console.log('2. Aktiviere 2-Schritt-Bestätigung');
  console.log('3. Gehe zu: App-Passwörter');
  console.log('4. Wähle "E-Mail" → Generiere Passwort');
  console.log('5. Kopiere das 16-stellige Passwort\n');

  console.log('📝 Füge in deine .env ein:');
  console.log('MAIL_HOST="smtp.gmail.com"');
  console.log('MAIL_PORT="587"');
  console.log('MAIL_SECURE="false"');
  console.log('MAIL_USER="deine-email@gmail.com"');
  console.log('MAIL_PASS="dein-gmail-app-passwort"');
  console.log('MAIL_FROM="deine-email@gmail.com"');
  console.log('MAIL_FROM_NAME="Weltenwind"\n');

  // Teste aktuelle Gmail-Konfiguration falls vorhanden
  const {
    MAIL_HOST,
    MAIL_USER,
    MAIL_PASS
  } = process.env;

  if (MAIL_HOST === 'smtp.gmail.com' && MAIL_USER && MAIL_PASS) {
    console.log('🧪 Teste aktuelle Gmail-Konfiguration...');
    
    try {
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: MAIL_USER,
          pass: MAIL_PASS
        }
      });

      await transporter.verify();
      console.log('✅ Gmail SMTP-Verbindung erfolgreich!');
      
      // Sende Test-Mail
      const result = await transporter.sendMail({
        from: `Weltenwind <${MAIL_USER}>`,
        to: MAIL_USER,
        subject: '🎉 Gmail Test erfolgreich!',
        html: `
          <h2>🎉 Gmail funktioniert perfekt!</h2>
          <p>Deine Weltenwind Mail-Konfiguration mit Gmail ist bereit.</p>
          <p><strong>Nächste Schritte:</strong></p>
          <ul>
            <li>✅ Invite-Mails funktionieren automatisch</li>
            <li>✅ Password-Reset-Mails sind aktiv</li>
            <li>✅ Alle Mail-Features verfügbar</li>
          </ul>
          <p style="color: #666; font-size: 12px;">
            Test-Zeit: ${new Date().toLocaleString('de-DE')}
          </p>
        `
      });

      console.log('📧 Test-Mail erfolgreich versendet!');
      console.log(`📨 Message ID: ${result.messageId}`);
      console.log('🎯 GMAIL FUNKTIONIERT PERFEKT! 🚀');

    } catch (error) {
      console.log(`❌ Gmail-Test fehlgeschlagen: ${error.message}`);
      console.log('\n🔧 Mögliche Probleme:');
      console.log('• App-Passwort falsch oder abgelaufen');
      console.log('• 2FA nicht aktiviert');
      console.log('• Konto temporär gesperrt');
    }
  } else {
    console.log('ℹ️ Noch keine Gmail-Konfiguration gefunden.');
    console.log('💡 Ändere deine .env auf Gmail und führe dieses Script erneut aus.');
  }
}

testGmailConfiguration().catch(console.error);