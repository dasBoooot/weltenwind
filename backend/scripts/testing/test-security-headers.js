const http = require('http');

console.log('🔒 Security Headers Test\n');
console.log('========================\n');

// Test-Request
const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/me',
  method: 'GET'
};

const req = http.request(options, (res) => {
  console.log('📋 Response Headers:\n');
  
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
    const value = res.headers[header];
    if (value) {
      console.log(`✅ ${header}: ${value}`);
    } else {
      console.log(`❌ ${header}: NICHT GESETZT`);
    }
  });

  console.log('\n📊 Zusammenfassung:');
  console.log('==================\n');

  // CSP Details
  const csp = res.headers['content-security-policy'];
  if (csp) {
    console.log('🛡️  Content-Security-Policy aktiv:');
    const directives = csp.split(';').map(d => d.trim());
    directives.forEach(directive => {
      if (directive) console.log(`   - ${directive}`);
    });
  }

  // CORS Headers
  console.log('\n🌐 CORS Headers:');
  const corsHeaders = [
    'access-control-allow-origin',
    'access-control-allow-credentials',
    'access-control-allow-methods',
    'access-control-allow-headers'
  ];

  corsHeaders.forEach(header => {
    const value = res.headers[header];
    if (value) {
      console.log(`   ✅ ${header}: ${value}`);
    }
  });

  console.log('\n✨ Test abgeschlossen!');
});

req.on('error', (e) => {
  console.error(`❌ Fehler: ${e.message}`);
  console.log('\nStelle sicher, dass der Backend-Server läuft!');
});

req.end();