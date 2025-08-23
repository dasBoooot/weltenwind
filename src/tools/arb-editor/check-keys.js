#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 ARB-Dateien Key-Vergleich...\n');

// Load files
const deFile = path.join(__dirname, 'client/lib/l10n/app_de.arb');
const enFile = path.join(__dirname, 'client/lib/l10n/app_en.arb');

const deContent = JSON.parse(fs.readFileSync(deFile, 'utf8'));
const enContent = JSON.parse(fs.readFileSync(enFile, 'utf8'));

// Extract keys (without @-metadata)
const deKeys = Object.keys(deContent).filter(key => !key.startsWith('@'));
const enKeys = Object.keys(enContent).filter(key => !key.startsWith('@'));

console.log(`📊 Deutsche ARB Keys: ${deKeys.length}`);
console.log(`📊 Englische ARB Keys: ${enKeys.length}\n`);

// Find differences
const missingInEnglish = deKeys.filter(key => !enKeys.includes(key));
const extraInEnglish = enKeys.filter(key => !deKeys.includes(key));

console.log(`❌ Fehlende Keys in EN: ${missingInEnglish.length}`);
console.log(`➕ Extra Keys in EN: ${extraInEnglish.length}\n`);

if (extraInEnglish.length > 0) {
    console.log('🔍 Extra Keys in englischer ARB:');
    extraInEnglish.forEach((key, index) => {
        console.log(`  ${index + 1}. "${key}": "${enContent[key]}"`);
    });
}

if (missingInEnglish.length > 0) {
    console.log('\n❌ Fehlende Keys in englischer ARB:');
    missingInEnglish.forEach((key, index) => {
        console.log(`  ${index + 1}. "${key}": "${deContent[key]}"`);
    });
}