import express from 'express';
import cors from 'cors';
import * as dotenv from 'dotenv';
import path from 'path';

import authRoutes from './routes/auth';
import worldRoutes from './routes/worlds';
import { cleanupExpiredSessions } from './services/session.service';
import prisma from './libs/prisma';

dotenv.config();

const app = express();

// === Middleware ===
app.use(cors());
app.use(express.json());

// TODO: Security-Middleware für Produktion
// import helmet from 'helmet';
// app.use(helmet());

// TODO: Rate-Limiting für öffentliche Endpunkte
// import rateLimit from 'express-rate-limit';
// const publicLimiter = rateLimit({
//   windowMs: 15 * 60 * 1000, // 15 Minuten
//   max: 100, // max 100 requests per windowMs
//   message: 'Zu viele Anfragen von dieser IP'
// });
// app.use('/api/worlds/*/invites/public', publicLimiter);
// app.use('/api/worlds/*/pre-register', publicLimiter);

// === API-Routen ===
app.use('/api/auth', authRoutes);
app.use('/api/worlds', worldRoutes);

// === API-Doku (OpenAPI) ===
// === OpenAPI YAML gezielt bereitstellen ===
app.get('/api-combined.yaml', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../docs/api-combined.yaml'));
});

// === Swagger Editor unter /docs ===
// → mit require.resolve (robuster als direkter Pfad)
const swaggerEditorPath = path.dirname(require.resolve('swagger-editor-dist/index.html'));
app.use('/docs', express.static(swaggerEditorPath));

// === Info- und Status-Endpunkte ===
app.get('/', (req, res) => {
  res.send('Willkommen beim Weltenwind-API-Server 🚀');
});

app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV || 'development',
  });
});

// === Session-Cleanup-Job ===
// Alle 5 Minuten abgelaufene Sessions löschen
setInterval(async () => {
  try {
    const result = await cleanupExpiredSessions();
    if (result.count > 0) {
      console.log(`[${new Date().toISOString()}] 🧹 Cleanup: ${result.count} abgelaufene Sessions gelöscht`);
    }
  } catch (error) {
    console.error(`[${new Date().toISOString()}] ❌ Session-Cleanup fehlgeschlagen:`, error);
  }
}, 5 * 60 * 1000); // 5 Minuten

// === Graceful Shutdown ===
process.on('SIGINT', async () => {
  console.log('⏹ Server wird heruntergefahren...');
  try {
    await prisma.$disconnect();
    console.log('✅ Prisma-Verbindung geschlossen');
  } catch (error) {
    console.error('❌ Fehler beim Schließen der Prisma-Verbindung:', error);
  }
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('⏹ Server wird heruntergefahren (SIGTERM)...');
  try {
    await prisma.$disconnect();
    console.log('✅ Prisma-Verbindung geschlossen');
  } catch (error) {
    console.error('❌ Fehler beim Schließen der Prisma-Verbindung:', error);
  }
  process.exit(0);
});

// === Server starten ===
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Weltenwind-API läuft auf Port ${PORT}`);
  console.log(`📘 Swagger Editor verfügbar unter: http://localhost:${PORT}/docs`);
  console.log(`📄 API-Doku YAML erreichbar unter: http://localhost:${PORT}/api-combined.yaml`);
  console.log(`🧹 Session-Cleanup alle 5 Minuten aktiv`);
});
