# Session-Rotation

## Übersicht

Session-Rotation ist ein wichtiger Sicherheitsmechanismus, der bei kritischen Aktionen automatisch neue Tokens generiert und alte Sessions invalidiert. Dies verhindert Session-Hijacking und erhöht die Sicherheit bei sensiblen Operationen.

## Funktionsweise

1. **Automatische Aktivierung** bei kritischen Aktionen:
   - Passwort-Änderung
   - Email-Änderung
   - Berechtigungen-Änderung
   - 2FA aktivieren/deaktivieren
   - Account-Wiederherstellung

2. **Ablauf:**
   - Alle bestehenden Sessions des Benutzers werden invalidiert
   - Neue Access & Refresh Tokens werden generiert
   - Audit-Log wird erstellt
   - Client erhält neue Tokens im Response

## Implementierte Endpoints

### POST /api/auth/change-password
```javascript
// Request
{
  "currentPassword": "AltesSicheresPW123!",
  "newPassword": "NeuesSicheresPW456!"
}

// Response (mit Session-Rotation)
{
  "message": "Passwort erfolgreich geändert",
  "accessToken": "eyJhbGci...",
  "refreshToken": "a1b2c3d4...",
  "expiresIn": 900,
  "refreshExpiresIn": 604800,
  "sessionRotated": true
}
```

## Client-Implementation

### Flutter/Dart Beispiel
```dart
Future<void> changePassword(String currentPassword, String newPassword) async {
  // 1. CSRF-Token abrufen
  final csrfToken = await getCsrfToken();
  
  // 2. Passwort ändern
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/change-password'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'X-CSRF-Token': csrfToken,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    // 3. WICHTIG: Neue Tokens speichern!
    await tokenStorage.saveTokens(
      data['accessToken'],
      data['refreshToken']
    );
    
    // 4. Optional: Benutzer informieren
    showMessage('Passwort geändert. Aus Sicherheitsgründen wurden alle anderen Geräte abgemeldet.');
  }
}
```

### JavaScript/TypeScript Beispiel
```typescript
async function changePassword(currentPassword: string, newPassword: string) {
  // 1. CSRF-Token abrufen
  const csrfToken = await getCsrfToken();
  
  // 2. Passwort ändern
  const response = await fetch('/api/auth/change-password', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'X-CSRF-Token': csrfToken,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      currentPassword,
      newPassword
    })
  });
  
  if (response.ok) {
    const data = await response.json();
    
    // 3. WICHTIG: Neue Tokens speichern!
    localStorage.setItem('accessToken', data.accessToken);
    localStorage.setItem('refreshToken', data.refreshToken);
    
    // 4. Optional: Auth-State aktualisieren
    authState.updateTokens(data.accessToken, data.refreshToken);
  }
}
```

## Sicherheitsvorteile

1. **Session-Hijacking Prevention**
   - Alte Tokens werden sofort ungültig
   - Angreifer verlieren Zugriff

2. **Compliance**
   - Erfüllt PCI-DSS Anforderungen
   - OWASP Best Practices

3. **Audit Trail**
   - Alle Rotationen werden geloggt
   - Nachvollziehbarkeit gewährleistet

## Best Practices

1. **Client-Implementierung**
   - IMMER neue Tokens speichern
   - Alte Tokens sofort löschen
   - Benutzer über Logout auf anderen Geräten informieren

2. **Error Handling**
   - Bei Rotation-Fehler: Benutzer komplett ausloggen
   - Klare Fehlermeldungen anzeigen

3. **Testing**
   ```bash
   # 1. Login
   curl -X POST http://localhost:3000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser","password":"Test123!"}'
   
   # 2. CSRF-Token abrufen
   curl http://localhost:3000/api/auth/csrf-token \
     -H "Authorization: Bearer <access-token>"
   
   # 3. Passwort ändern (mit Session-Rotation)
   curl -X POST http://localhost:3000/api/auth/change-password \
     -H "Authorization: Bearer <access-token>" \
     -H "X-CSRF-Token: <csrf-token>" \
     -H "Content-Type: application/json" \
     -d '{"currentPassword":"Test123!","newPassword":"NewTest456!"}'
   ```

## Zukünftige Erweiterungen

1. **Weitere kritische Aktionen**
   - Email-Änderung
   - 2FA-Konfiguration
   - Berechtigungen-Änderung

2. **Konfigurierbare Rotation**
   - Admin kann festlegen welche Aktionen Rotation erfordern
   - Zeitbasierte Rotation (z.B. alle 30 Tage)

3. **Erweiterte Features**
   - Device-Trust (vertrauenswürdige Geräte ausschließen)
   - Geo-Location basierte Rotation
   - Risk-Based Authentication