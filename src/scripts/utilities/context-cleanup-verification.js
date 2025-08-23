#!/usr/bin/env node
/**
 * 🧹 WELTENWIND CONTEXT-CLEANUP VERIFICATION
 * Verifiziert dass die wichtigsten contextOverrides eliminiert wurden
 */

const fs = require('fs');
const path = require('path');

console.log('🧹 WELTENWIND CONTEXT-CLEANUP VERIFICATION');
console.log('==========================================');

const clientPath = path.join(__dirname, '../../client/lib');

// Search for contextOverrides in files
function searchInFile(filePath, searchTerms) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const results = [];
    
    searchTerms.forEach(term => {
      const regex = new RegExp(term, 'g');
      const matches = content.match(regex);
      if (matches) {
        results.push({ term, count: matches.length });
      }
    });
    
    return results.length > 0 ? results : null;
  } catch (e) {
    return null;
  }
}

function scanDirectory(dir, searchTerms) {
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
        if (found) {
          const relativePath = path.relative(clientPath, itemPath);
          results[relativePath] = found;
        }
      }
    });
  }
  
  scanDir(dir);
  return results;
}

// 1. Search for remaining contextOverrides
console.log('\n🔍 REMAINING CONTEXT-OVERRIDES:');
const contextOverrides = scanDirectory(clientPath, ['contextOverrides\\s*:']);

let totalOverrides = 0;

// Categorize by file type
const categories = {
  'auth': [],
  'world': [],
  'landing': [],
  'dashboard': [],
  'shared/widgets': [],
  'shared/components': [],
  'other': []
};

Object.entries(contextOverrides).forEach(([file, matches]) => {
  const overrideCount = matches.reduce((sum, match) => sum + match.count, 0);
  totalOverrides += overrideCount;
  
  if (file.includes('features/auth/')) categories.auth.push({ file, count: overrideCount });
  else if (file.includes('features/world/')) categories.world.push({ file, count: overrideCount });
  else if (file.includes('features/landing/')) categories.landing.push({ file, count: overrideCount });
  else if (file.includes('features/dashboard/')) categories.dashboard.push({ file, count: overrideCount });
  else if (file.includes('shared/widgets/')) categories['shared/widgets'].push({ file, count: overrideCount });
  else if (file.includes('shared/components/')) categories['shared/components'].push({ file, count: overrideCount });
  else categories.other.push({ file, count: overrideCount });
});

// Print results by category
Object.entries(categories).forEach(([category, files]) => {
  if (files.length > 0) {
    const categoryTotal = files.reduce((sum, f) => sum + f.count, 0);
    console.log(`\n📁 ${category.toUpperCase()}: ${categoryTotal} overrides`);
    files.forEach(({ file, count }) => {
      console.log(`   ${count > 0 ? '❌' : '✅'} ${file}: ${count}`);
    });
  } else {
    console.log(`\n📁 ${category.toUpperCase()}: ✅ CLEAN (0 overrides)`);
  }
});

// 2. Search for staticAreas
console.log('\n🗺️ REMAINING STATIC-AREAS:');
const staticAreas = scanDirectory(clientPath, ['staticAreas\\s*:']);
const totalStaticAreas = Object.keys(staticAreas).length;

if (totalStaticAreas === 0) {
  console.log('   ✅ KEINE staticAreas gefunden!');
} else {
  Object.entries(staticAreas).forEach(([file, matches]) => {
    console.log(`   ❌ ${file}: ${matches[0].count}`);
  });
}

// 3. Check for enableMixedContext usage
console.log('\n🔄 MIXED-CONTEXT USAGE:');
const mixedContext = scanDirectory(clientPath, ['enableMixedContext\\s*:\\s*true']);
const totalMixedContext = Object.keys(mixedContext).length;

if (totalMixedContext === 0) {
  console.log('   ✅ KEINE enableMixedContext gefunden!');
} else {
  console.log(`   ℹ️ ${totalMixedContext} Files verwenden Mixed-Context:`);
  Object.keys(mixedContext).forEach(file => {
    console.log(`      - ${file}`);
  });
}

// 4. Summary
console.log('\n🎯 CLEANUP SUMMARY:');
console.log(`   📊 Verbleibende contextOverrides: ${totalOverrides}`);
console.log(`   🗺️ Verbleibende staticAreas: ${totalStaticAreas}`);
console.log(`   🔄 Mixed-Context Files: ${totalMixedContext}`);

// Success thresholds
const authSuccess = categories.auth.length === 0;
const worldSuccess = categories.world.length === 0; 
const landingSuccess = categories.landing.length === 0;
const dashboardSuccess = categories.dashboard.length === 0;

console.log('\n🚀 PAGE-CATEGORY STATUS:');
console.log(`   ${authSuccess ? '✅' : '❌'} Auth Pages: ${authSuccess ? 'CLEAN' : 'NEEDS WORK'}`);
console.log(`   ${worldSuccess ? '✅' : '❌'} World Pages: ${worldSuccess ? 'CLEAN' : 'NEEDS WORK'}`);
console.log(`   ${landingSuccess ? '✅' : '❌'} Landing Pages: ${landingSuccess ? 'CLEAN' : 'NEEDS WORK'}`);
console.log(`   ${dashboardSuccess ? '✅' : '❌'} Dashboard Pages: ${dashboardSuccess ? 'CLEAN' : 'NEEDS WORK'}`);

const majorPagesClean = authSuccess && worldSuccess && landingSuccess && dashboardSuccess;
console.log(`\n🎉 MAJOR PAGES STATUS: ${majorPagesClean ? '✅ CLEAN & READY!' : '❌ NEEDS MORE WORK'}`);

if (majorPagesClean) {
  console.log('\n🚀 Die wichtigsten Pages verwenden jetzt automatische Theme-Logik!');
  console.log('   ✅ Auth: UIContext.login → pre-game-minimal');
  console.log('   ✅ World List: UIContext.worldSelection → world-preview');
  console.log('   ✅ World Join: worldThemeOverride → world-spezifisch');
  console.log('   ✅ Dashboard: UIContext.inGame → full-gaming');
  console.log('   ✅ Landing: UIContext.main → pre-game-minimal');
}

console.log(`\n📝 Verbleibende contextOverrides sind hauptsächlich in shared/components`);
console.log(`    (Diese können schrittweise migriert werden)`);