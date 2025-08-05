#!/usr/bin/env node

/**
 * 🗑️ User komplett aus Datenbank löschen
 * 
 * Dieses Skript löscht einen User und ALLE abhängigen Daten sauber aus der Datenbank.
 * 
 * ⚠️  WARNUNG: Diese Aktion ist IRREVERSIBEL!
 * 
 * Usage:
 *   node delete-user.js <username>
 *   node delete-user.js <email>
 *   node delete-user.js --id <userId>
 */

require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Konfiguration
const DRY_RUN = process.env.DRY_RUN === 'true'; // Für Tests - nichts wirklich löschen

async function findUser(identifier) {
  console.log(`🔍 Suche User: ${identifier}`);
  
  let user = null;
  
  // Prüfe verschiedene Suchmöglichkeiten
  if (identifier.includes('@')) {
    // E-Mail
    user = await prisma.user.findUnique({
      where: { email: identifier },
      include: {
        roles: true,
        sessions: true,
        players: { include: { world: { select: { name: true } } } },
        preRegistrations: { include: { world: { select: { name: true } } } },
        passwordResets: true,
        invites: { include: { world: { select: { name: true } } } }
      }
    });
  } else if (!isNaN(identifier)) {
    // User ID
    user = await prisma.user.findUnique({
      where: { id: parseInt(identifier) },
      include: {
        roles: true,
        sessions: true,
        players: { include: { world: { select: { name: true } } } },
        preRegistrations: { include: { world: { select: { name: true } } } },
        passwordResets: true,
        invites: { include: { world: { select: { name: true } } } }
      }
    });
  } else {
    // Username
    user = await prisma.user.findUnique({
      where: { username: identifier },
      include: {
        roles: true,
        sessions: true,
        players: { include: { world: { select: { name: true } } } },
        preRegistrations: { include: { world: { select: { name: true } } } },
        passwordResets: true,
        invites: { include: { world: { select: { name: true } } } }
      }
    });
  }
  
  return user;
}

async function showUserInfo(user) {
  console.log('\n📊 USER-INFORMATIONEN:');
  console.log('========================');
  console.log(`👤 ID: ${user.id}`);
  console.log(`📧 E-Mail: ${user.email}`);
  console.log(`🏷️  Username: ${user.username}`);
  console.log(`🔒 Gesperrt: ${user.isLocked ? 'Ja' : 'Nein'}`);
  console.log(`❌ Fehlversuche: ${user.failedLoginAttempts}`);
  
  // Empfangene Invites abfragen
  const receivedInvites = await prisma.invite.findMany({
    where: { email: user.email },
    include: { world: { select: { name: true } } }
  });
  
  console.log('\n🔗 ABHÄNGIGE DATEN:');
  console.log('===================');
  console.log(`👑 Rollen: ${user.roles.length}`);
  console.log(`🔑 Sessions: ${user.sessions.length}`);
  console.log(`🎮 Welt-Mitgliedschaften: ${user.players.length}`);
  console.log(`📝 Vorregistrierungen: ${user.preRegistrations.length}`);
  console.log(`🔐 Password-Resets: ${user.passwordResets.length}`);
  console.log(`📬 Versendete Invites: ${user.invites.length}`);
  console.log(`📥 Empfangene Invites: ${receivedInvites.length}`);
  
  if (user.players.length > 0) {
    console.log('\n🌍 Mitglied in Welten:');
    user.players.forEach(player => {
      console.log(`   • ${player.world.name} (seit ${player.joinedAt?.toLocaleDateString('de-DE')})`);
    });
  }
  
  if (user.preRegistrations.length > 0) {
    console.log('\n📋 Vorregistriert für Welten:');
    user.preRegistrations.forEach(preReg => {
      console.log(`   • ${preReg.world.name} (${preReg.createdAt.toLocaleDateString('de-DE')})`);
    });
  }
  
  if (user.invites.length > 0) {
    console.log('\n📨 Versendete Invites:');
    user.invites.forEach(invite => {
      console.log(`   • ${invite.world.name} → ${invite.email} (${invite.createdAt.toLocaleDateString('de-DE')})`);
    });
  }
  
  if (receivedInvites.length > 0) {
    console.log('\n📥 Empfangene Invites:');
    receivedInvites.forEach(invite => {
      const status = invite.acceptedAt ? '✅ akzeptiert' : '⏳ offen';
      console.log(`   • ${invite.world.name} (${invite.createdAt.toLocaleDateString('de-DE')}) - ${status}`);
    });
  }
}

async function deleteUserData(user) {
  console.log('\n🗑️  LÖSCHVORGANG:');
  console.log('=================');
  
  const deletionPlan = [];
  let totalOperations = 0;
  
  // 1. UserRole-Einträge
  if (user.roles.length > 0) {
    deletionPlan.push({
      step: 1,
      table: 'UserRole', 
      count: user.roles.length,
      description: 'Rollen-Zuweisungen löschen'
    });
    totalOperations += user.roles.length;
  }
  
  // 2. Session-Einträge
  if (user.sessions.length > 0) {
    deletionPlan.push({
      step: 2,
      table: 'Session',
      count: user.sessions.length, 
      description: 'Aktive Sessions löschen'
    });
    totalOperations += user.sessions.length;
  }
  
  // 3. Player-Einträge  
  if (user.players.length > 0) {
    deletionPlan.push({
      step: 3,
      table: 'Player',
      count: user.players.length,
      description: 'Welt-Mitgliedschaften löschen'
    });
    totalOperations += user.players.length;
  }
  
  // 4. PreRegistration-Einträge
  if (user.preRegistrations.length > 0) {
    deletionPlan.push({
      step: 4,
      table: 'PreRegistration',
      count: user.preRegistrations.length,
      description: 'Vorregistrierungen löschen'
    });
    totalOperations += user.preRegistrations.length;
  }
  
  // 5. PasswordReset-Einträge
  if (user.passwordResets.length > 0) {
    deletionPlan.push({
      step: 5,
      table: 'PasswordReset',
      count: user.passwordResets.length,
      description: 'Password-Reset-Tokens löschen'
    });
    totalOperations += user.passwordResets.length;
  }
  
  // 6. Invites - sowohl versendete (invitedById) als auch empfangene (email)
  const invitedByUser = await prisma.invite.count({
    where: { invitedById: user.id }
  });
  
  const invitesToUser = await prisma.invite.count({
    where: { email: user.email }
  });
  
  let inviteOperations = 0;
  const inviteTasks = [];
  
  if (invitedByUser > 0) {
    inviteTasks.push(`${invitedByUser} versendete Invites (invitedById → NULL)`);
    inviteOperations += invitedByUser;
  }
  
  if (invitesToUser > 0) {
    inviteTasks.push(`${invitesToUser} empfangene Invites löschen`);
    inviteOperations += invitesToUser;
  }
  
  if (inviteOperations > 0) {
    deletionPlan.push({
      step: 6,
      table: 'Invite',
      count: inviteOperations,
      description: inviteTasks.join(' + ')
    });
    totalOperations += inviteOperations;
  }
  
  // 8. User selbst
  deletionPlan.push({
    step: 8,
    table: 'User',
    count: 1,
    description: 'User-Account löschen'
  });
  totalOperations += 1;
  
  console.log('📋 Löschplan:');
  deletionPlan.forEach(plan => {
    console.log(`   ${plan.step}. ${plan.description}: ${plan.count} Einträge`);
  });
  console.log(`\n📊 Gesamt: ${totalOperations} Operationen`);
  
  if (DRY_RUN) {
    console.log('\n🧪 DRY RUN - Keine Daten werden tatsächlich gelöscht!');
    return;
  }
  
  // Bestätigung einholen
  console.log('\n⚠️  WARNUNG: Diese Aktion ist IRREVERSIBEL!');
  console.log('Möchten Sie fortfahren? Geben Sie "DELETE" ein:');
  
  return new Promise((resolve) => {
    process.stdin.resume();
    process.stdin.setEncoding('utf8');
    
    process.stdin.on('data', async (text) => {
      const input = text.trim();
      
      if (input === 'DELETE') {
        console.log('\n🚀 Löschvorgang gestartet...');
        
        try {
          // Transaktion für atomare Löschung
          await prisma.$transaction(async (tx) => {
            // 1. UserRole löschen
            if (user.roles.length > 0) {
              const deleteRoles = await tx.userRole.deleteMany({
                where: { userId: user.id }
              });
              console.log(`✅ ${deleteRoles.count} Rollen-Zuweisungen gelöscht`);
            }
            
            // 2. Sessions löschen
            if (user.sessions.length > 0) {
              const deleteSessions = await tx.session.deleteMany({
                where: { userId: user.id }
              });
              console.log(`✅ ${deleteSessions.count} Sessions gelöscht`);
            }
            
            // 3. Player-Einträge löschen
            if (user.players.length > 0) {
              const deletePlayers = await tx.player.deleteMany({
                where: { userId: user.id }
              });
              console.log(`✅ ${deletePlayers.count} Welt-Mitgliedschaften gelöscht`);
            }
            
            // 4. PreRegistrations löschen
            if (user.preRegistrations.length > 0) {
              const deletePreRegs = await tx.preRegistration.deleteMany({
                where: { userId: user.id }
              });
              console.log(`✅ ${deletePreRegs.count} Vorregistrierungen gelöscht`);
            }
            
            // 5. PasswordResets löschen
            if (user.passwordResets.length > 0) {
              const deleteResets = await tx.passwordReset.deleteMany({
                where: { userId: user.id }
              });
              console.log(`✅ ${deleteResets.count} Password-Reset-Tokens gelöscht`);
            }
            
            // 6. Invite-Referenzen auf NULL setzen
            if (invitedByUser > 0) {
              const updateInvites = await tx.invite.updateMany({
                where: { invitedById: user.id },
                data: { invitedById: null }
              });
              console.log(`✅ ${updateInvites.count} Invite-Referenzen auf NULL gesetzt`);
            }

            // 7. Empfangene Invites löschen
            if (invitesToUser > 0) {
              const deleteInvitesToUser = await tx.invite.deleteMany({
                where: { email: user.email }
              });
              console.log(`✅ ${deleteInvitesToUser.count} empfangene Invites gelöscht`);
            }
            
            // 8. User löschen
            await tx.user.delete({
              where: { id: user.id }
            });
            console.log(`✅ User-Account gelöscht`);
          });
          
          console.log('\n🎉 USER ERFOLGREICH GELÖSCHT!');
          console.log(`👤 ${user.username} (${user.email}) wurde komplett aus der Datenbank entfernt.`);
          
        } catch (error) {
          console.error('\n❌ FEHLER beim Löschen:', error.message);
          console.error(error);
        }
        
      } else if (input.toUpperCase() === 'ABBRUCH' || input.toUpperCase() === 'ABORT') {
        console.log('\n🚫 Löschvorgang abgebrochen.');
      } else {
        console.log('\n❌ Ungültige Eingabe. Löschvorgang abgebrochen.');
      }
      
      process.stdin.pause();
      resolve();
    });
  });
}

async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.error('❌ Fehler: Bitte geben Sie einen Username, E-Mail oder User-ID an.');
    console.log('\nUsage:');
    console.log('  node delete-user.js <username>');
    console.log('  node delete-user.js <email>');
    console.log('  node delete-user.js --id <userId>');
    console.log('\nOptionen:');
    console.log('  DRY_RUN=true    Testlauf ohne tatsächliches Löschen');
    process.exit(1);
  }
  
  let identifier;
  if (args[0] === '--id' && args[1]) {
    identifier = args[1];
  } else {
    identifier = args[0];
  }
  
  try {
    console.log('🗑️  WELTENWIND USER DELETE TOOL');
    console.log('==================================');
    
    if (DRY_RUN) {
      console.log('🧪 DRY RUN MODE - Keine Daten werden gelöscht!');
    }
    
    const user = await findUser(identifier);
    
    if (!user) {
      console.error(`❌ User nicht gefunden: ${identifier}`);
      process.exit(1);
    }
    
    await showUserInfo(user);
    await deleteUserData(user);
    
  } catch (error) {
    console.error('❌ Unerwarteter Fehler:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

// Graceful Shutdown
process.on('SIGINT', async () => {
  console.log('\n🚫 Abbruch durch Benutzer');
  await prisma.$disconnect();
  process.exit(0);
});

main().catch(console.error);