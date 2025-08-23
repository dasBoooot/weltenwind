#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Finde Extra-Keys in englischer ARB...\n');

// Load files
const deFile = path.join(__dirname, 'client/lib/l10n/app_de.arb');
const enFile = path.join(__dirname, 'client/lib/l10n/app_en.arb');

const deContent = JSON.parse(fs.readFileSync(deFile, 'utf8'));
const enContent = JSON.parse(fs.readFileSync(enFile, 'utf8'));

// Extract keys (without @-metadata)
const deKeys = Object.keys(deContent).filter(key => !key.startsWith('@'));
const enKeys = Object.keys(enContent).filter(key => !key.startsWith('@'));

// Find extra keys in English
const extraInEnglish = enKeys.filter(key => !deKeys.includes(key));

console.log(`❌ ${extraInEnglish.length} Extra Keys in englischer ARB:\n`);

extraInEnglish.forEach((key, index) => {
    console.log(`${index + 1}. "${key}": "${enContent[key]}"`);
});

console.log('\n🔧 Diese Keys sollten aus der englischen ARB entfernt werden.');