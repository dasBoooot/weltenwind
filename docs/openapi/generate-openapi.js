const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const baseFile = path.join(__dirname, 'specs', 'openapi.yaml');
const authFile = path.join(__dirname, 'specs', 'auth.yaml');
const worldsFile = path.join(__dirname, 'specs', 'worlds.yaml');
const invitesFile = path.join(__dirname, 'specs', 'invite.yaml');
const arbFile = path.join(__dirname, 'specs', 'arb.yaml');
const themesFile = path.join(__dirname, 'specs', 'themes.yaml');
const logsFile = path.join(__dirname, 'specs', 'logs.yaml');
const healthFile = path.join(__dirname, 'specs', 'health.yaml');
const combinedPath = path.join(__dirname, 'generated', 'api-combined.yaml');

// Hilfsfunktion zum Deep-Merge von Objekten
function deepMerge(target, source) {
  for (const key of Object.keys(source)) {
    if (
      source[key] &&
      typeof source[key] === 'object' &&
      !Array.isArray(source[key])
    ) {
      if (!target[key]) target[key] = {};
      deepMerge(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
}

// YAML-Dateien einlesen
const base = yaml.load(fs.readFileSync(baseFile, 'utf8'));
const auth = yaml.load(fs.readFileSync(authFile, 'utf8'));
const worlds = yaml.load(fs.readFileSync(worldsFile, 'utf8'));
const invites = yaml.load(fs.readFileSync(invitesFile, 'utf8'));
const arb = yaml.load(fs.readFileSync(arbFile, 'utf8'));
const themes = yaml.load(fs.readFileSync(themesFile, 'utf8'));
const logs = yaml.load(fs.readFileSync(logsFile, 'utf8'));
const health = yaml.load(fs.readFileSync(healthFile, 'utf8'));

// Kombinieren
const combined = {
  openapi: base.openapi,
  info: base.info,
  servers: base.servers,
  components: {},
  paths: {},
};

// paths zusammenführen
Object.assign(combined.paths, auth.paths || {});
Object.assign(combined.paths, worlds.paths || {});
Object.assign(combined.paths, invites.paths || {});
Object.assign(combined.paths, arb.paths || {});
Object.assign(combined.paths, themes.paths || {});
Object.assign(combined.paths, logs.paths || {});
Object.assign(combined.paths, health.paths || {});

// components zusammenführen (z.B. securitySchemes, schemas)
if (base.components) deepMerge(combined.components, base.components);
if (auth.components) deepMerge(combined.components, auth.components);
if (worlds.components) deepMerge(combined.components, worlds.components);
if (invites.components) deepMerge(combined.components, invites.components);
if (arb.components) deepMerge(combined.components, arb.components);
if (themes.components) deepMerge(combined.components, themes.components);
if (logs.components) deepMerge(combined.components, logs.components);
if (health.components) deepMerge(combined.components, health.components);

// In YAML schreiben
fs.writeFileSync(combinedPath, yaml.dump(combined, { lineWidth: 120 }));
console.log('✅ api-combined.yaml erfolgreich generiert.');
console.log('📦 Einbezogene API-Module: auth.yaml, worlds.yaml, invite.yaml, arb.yaml, themes.yaml, logs.yaml, health.yaml');
