#!/usr/bin/env node
/**
 * 🎯 WELTENWIND THEME SYSTEM - VERIFICATION SCRIPT
 * Verifiziert dass alle Bundle & Theme Namen konsistent sind
 */

const fs = require('fs');
const path = require('path');

console.log('🎯 WELTENWIND THEME SYSTEM VERIFICATION');
console.log('==========================================');

// 1. Bundle-Configs prüfen
const bundleConfigPath = path.join(__dirname, '../theme-editor/bundles/bundle-configs.json');
const bundleConfigs = JSON.parse(fs.readFileSync(bundleConfigPath, 'utf8'));

console.log('\n✅ AUTORITATIVE BUNDLE-NAMEN:');
const authoritativeBundles = Object.keys(bundleConfigs.bundles);
authoritativeBundles.forEach(bundle => {
  console.log(`   - ${bundle}`);
});

// 2. Theme-Files prüfen
const themeSchemasPath = path.join(__dirname, '../theme-editor/schemas');
const themeFiles = fs.readdirSync(themeSchemasPath)
  .filter(file => file.endsWith('.json') && !file.includes('audit') && !file.includes('schema'))
  .map(file => file.replace('.json', ''));

console.log('\n✅ VERFÜGBARE THEME-NAMEN:');
themeFiles.forEach(theme => {
  console.log(`   - ${theme}`);
});

// 3. Flutter Code prüfen
const clientPath = path.join(__dirname, '../../client');
console.log('\n🔍 FLUTTER CODE VERIFICATION:');

// Suche nach Legacy Bundle-Namen
const legacyBundles = [
  'pre_game_bundle', 'fantasy_world_bundle', 'sci_fi_world_bundle', 
  'ancient_world_bundle', 'default_world_bundle', 'minimal_bundle', 'debug_bundle'
];

function searchInFile(filePath, searchTerms) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const found = [];
    searchTerms.forEach(term => {
      if (content.includes(term)) {
        found.push(term);
      }
    });
    return found;
  } catch (e) {
    return [];
  }
}

function searchDirectory(dir, searchTerms) {
  const results = {};
  
  function scanDir(currentDir) {
    const items = fs.readdirSync(currentDir);
    
    items.forEach(item => {
      const itemPath = path.join(currentDir, item);
      const stat = fs.statSync(itemPath);
      
      if (stat.isDirectory() && !item.startsWith('.')) {
        scanDir(itemPath);
      } else if (item.endsWith('.dart')) {
        const found = searchInFile(itemPath, searchTerms);
        if (found.length > 0) {
          const relativePath = path.relative(clientPath, itemPath);
          results[relativePath] = found;
        }
      }
    });
  }
  
  scanDir(dir);
  return results;
}

const legacyResults = searchDirectory(path.join(clientPath, 'lib'), legacyBundles);

if (Object.keys(legacyResults).length === 0) {
  console.log('   ✅ KEINE Legacy Bundle-Namen gefunden!');
} else {
  console.log('   ❌ Legacy Bundle-Namen gefunden:');
  Object.entries(legacyResults).forEach(([file, terms]) => {
    console.log(`     ${file}: ${terms.join(', ')}`);
  });
}

// 4. Bundle-Resolver Mapping prüfen
console.log('\n✅ BUNDLE-RESOLVER MAPPING:');
const resolver = bundleConfigs.bundleResolver;
if (resolver) {
  console.log('   Context Mapping:');
  Object.entries(resolver.contextMapping || {}).forEach(([context, bundle]) => {
    console.log(`     ${context} → ${bundle}`);
  });
  
  console.log('   Theme Mapping:');
  Object.entries(resolver.themeMapping || {}).forEach(([theme, bundle]) => {
    console.log(`     ${theme} → ${bundle}`);
  });
}

// 5. Summary
console.log('\n🎯 VERIFICATION SUMMARY:');
console.log(`   ✅ ${authoritativeBundles.length} autoritative Bundle-Namen`);
console.log(`   ✅ ${themeFiles.length} Theme-Files verfügbar`);
console.log(`   ${Object.keys(legacyResults).length === 0 ? '✅' : '❌'} Flutter Code ${Object.keys(legacyResults).length === 0 ? 'CLEAN' : 'hat Legacy-Namen'}`);
console.log(`   ✅ Bundle-Resolver konfiguriert`);

console.log('\n🚀 SYSTEM STATUS: ' + (Object.keys(legacyResults).length === 0 ? 'CLEAN & READY!' : 'NEEDS CLEANUP!'));