import express from 'express';
import cors from 'cors';
import * as dotenv from 'dotenv';
import path from 'path';

import authRoutes from './routes/auth';
import worldRoutes from './routes/worlds';

dotenv.config();

const app = express();

// === Middleware ===
app.use(cors());
app.use(express.json());

// === API-Routen ===
app.use('/api/auth', authRoutes);
app.use('/api/worlds', worldRoutes);

// === API-Doku (OpenAPI) ===
// === OpenAPI YAML gezielt bereitstellen ===
app.get('/api-combined.yaml', (req, res) => {
  res.sendFile('/srv/weltenwind/docs/api-combined.yaml');
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

// === Server starten ===
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Weltenwind-API läuft auf Port ${PORT}`);
  console.log(`📘 Swagger Editor verfügbar unter: http://localhost:${PORT}/docs`);
  console.log(`📄 API-Doku YAML erreichbar unter: http://localhost:${PORT}/api-combined.yaml`);
});
