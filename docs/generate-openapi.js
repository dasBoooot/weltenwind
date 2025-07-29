const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const baseFile = path.join(__dirname, 'openapi.yaml');
const authFile = path.join(__dirname, 'auth.yaml');
const worldsFile = path.join(__dirname, 'worlds.yaml');
const invitesFile = path.join(__dirname, 'invites.yaml');
const combinedPath = path.join(__dirname, 'api-combined.yaml');

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

// components zusammenführen (z.B. securitySchemes, schemas)
if (base.components) deepMerge(combined.components, base.components);
if (auth.components) deepMerge(combined.components, auth.components);
if (worlds.components) deepMerge(combined.components, worlds.components);
if (invites.components) deepMerge(combined.components, invites.components);

// In YAML schreiben
fs.writeFileSync(combinedPath, yaml.dump(combined, { lineWidth: 120 }));
console.log('✅ api-combined.yaml erfolgreich generiert.');
console.log('📦 Einbezogene API-Module: auth.yaml, worlds.yaml, invites.yaml');
