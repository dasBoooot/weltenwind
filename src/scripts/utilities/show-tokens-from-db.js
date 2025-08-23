const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function showTokensFromDatabase() {
  console.log('🔍 Tokens aus der Datenbank anzeigen...\n');

  try {
    // Zeige letzte Invites
    console.log('📋 INVITE-TOKENS (letzte 10):');
    const invites = await prisma.invite.findMany({
      take: 10,
      orderBy: { createdAt: 'desc' },
      include: {
        world: {
          select: { name: true }
        },
        invitedBy: {
          select: { username: true }
        }
      }
    });

    if (invites.length === 0) {
      console.log('   📭 Keine Invites gefunden');
      console.log('   💡 Erstelle einen Invite im Client um zu testen\n');
    } else {
      invites.forEach((invite, index) => {
        const inviteUrl = `http://192.168.2.168:3000/game/#/go/world-join/${invite.token}`;
        console.log(`   ${index + 1}. ${invite.world.name} (${invite.email})`);
        console.log(`      🌍 Token: ${invite.token}`);
        console.log(`      🔗 Link:  ${inviteUrl}`);
        console.log(`      👤 Von:   ${invite.invitedBy?.username || 'System'}`);
        console.log(`      ⏰ Zeit:  ${invite.createdAt.toLocaleString('de-DE')}`);
        console.log('');
      });
    }

    // Zeige letzte Password-Resets
    console.log('🔑 PASSWORD-RESET-TOKENS (letzte 10):');
    const resets = await prisma.passwordReset.findMany({
      take: 10,
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: { username: true, email: true }
        }
      }
    });

    if (resets.length === 0) {
      console.log('   📭 Keine Password-Resets gefunden');
      console.log('   💡 Fordere einen Reset über Login-Seite an\n');
    } else {
      resets.forEach((reset, index) => {
        const resetUrl = `http://192.168.2.168:3000/game/#/go/auth/reset-password?token=${reset.token}`;
        const isExpired = reset.expiresAt < new Date();
        const isUsed = !!reset.usedAt;
        
        console.log(`   ${index + 1}. ${reset.user.username} (${reset.user.email})`);
        console.log(`      🔑 Token: ${reset.token}`);
        console.log(`      🔗 Link:  ${resetUrl}`);
        console.log(`      ⏰ Zeit:  ${reset.createdAt.toLocaleString('de-DE')}`);
        console.log(`      📅 Läuft ab: ${reset.expiresAt.toLocaleString('de-DE')}`);
        console.log(`      📊 Status: ${isUsed ? '✅ Verwendet' : isExpired ? '❌ Abgelaufen' : '🟢 Aktiv'}`);
        console.log('');
      });
    }

    console.log('🧪 USAGE:');
    console.log('• Kopiere die Links und teste sie direkt im Browser');
    console.log('• Invite-Links führen zur World-Join-Page');
    console.log('• Reset-Links führen zur Password-Reset-Page');
    console.log('• Alle Tokens werden automatisch validiert\n');

    console.log('🔄 LIVE-MONITORING:');
    console.log('• Führe dieses Script nach jeder Aktion aus');
    console.log('• Oder schaue im Log-Viewer: http://192.168.2.168:3000/log-viewer/');
    console.log('• Logs zeigen auch Mail-Versand-Versuche (falls konfiguriert)');

  } catch (error) {
    console.error('❌ Fehler beim Lesen der Datenbank:', error.message);
    console.log('\n💡 Mögliche Lösungen:');
    console.log('• Stelle sicher, dass die Datenbank läuft');
    console.log('• Prüfe DATABASE_URL in der .env');
    console.log('• Führe "npx prisma migrate dev" aus');
  } finally {
    await prisma.$disconnect();
  }
}

showTokensFromDatabase().catch(console.error);