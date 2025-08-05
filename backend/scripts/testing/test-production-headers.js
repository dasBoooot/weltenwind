const fetch = require('node-fetch');

const API_URL = 'http://localhost:3000';

console.log('🔒 Production Security Headers Test\n');
console.log('=====================================\n');

async function testProductionHeaders() {
  try {
    console.log('📡 Testing Production Headers...');
    
    // Teste mit fetch (wie change-password script)
    const response = await fetch(`${API_URL}/api/auth/me`);
    
    console.log(`📋 Status: ${response.status}`);
    console.log('\n📋 Response Headers:\n');
    
    // Security-relevante Headers
    const securityHeaders = [
      'x-dns-prefetch-control',
      'x-frame-options', 
      'strict-transport-security',
      'x-content-type-options',
      'x-permitted-cross-domain-policies',
      'referrer-policy',
      'x-xss-protection',
      'content-security-policy',
      'cross-origin-embedder-policy',
      'cross-origin-opener-policy',
      'cross-origin-resource-policy',
      'origin-agent-cluster'
    ];

    // Prüfe jeden Header
    securityHeaders.forEach(header => {
      const value = response.headers.get(header);
      if (value) {
        console.log(`✅ ${header}: ${value}`);
      } else {
        console.log(`❌ ${header}: NICHT GESETZT`);
      }
    });

    console.log('\n🌐 CORS Headers:');
    const corsHeaders = [
      'access-control-allow-origin',
      'access-control-allow-credentials', 
      'access-control-allow-methods',
      'access-control-allow-headers'
    ];

    corsHeaders.forEach(header => {
      const value = response.headers.get(header);
      if (value) {
        console.log(`   ✅ ${header}: ${value}`);
      }
    });

    // CSP Details
    const csp = response.headers.get('content-security-policy');
    if (csp) {
      console.log('\n🛡️  Content-Security-Policy aktiv:');
      const directives = csp.split(';').map(d => d.trim());
      directives.forEach(directive => {
        if (directive) console.log(`   - ${directive}`);
      });
    } else {
      console.log('\n⚠️  Content-Security-Policy: DEVELOPMENT MODE (deaktiviert)');
    }

    console.log('\n✨ Test abgeschlossen!');
    
  } catch (error) {
    console.error('❌ Fehler:', error.message);
    console.log('\n💡 Tipp: Stelle sicher, dass der Server läuft!');
  }
}

// Info über Development vs Production
console.log('ℹ️  Hinweis: Diese Anwendung ist so konfiguriert:');
console.log('   - Development: Weniger strikte Headers für lokale Entwicklung');
console.log('   - Production: Vollständige Security Headers aktiv');
console.log('   - Aktueller Modus wird durch NODE_ENV bestimmt\n');

testProductionHeaders();