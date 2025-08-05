# Session-Konfiguration

## Umgebungsvariablen

Die folgenden Umgebungsvariablen können in der `.env` Datei gesetzt werden:

### `ALLOW_MULTI_DEVICE_LOGIN`
- **Typ**: Boolean (true/false)
- **Standard**: false
- **Beschreibung**: Erlaubt es Usern, sich von mehreren Geräten gleichzeitig einzuloggen

### `MAX_SESSIONS_PER_USER`
- **Typ**: Zahl
- **Standard**: 1
- **Beschreibung**: Maximale Anzahl aktiver Sessions pro User (nur relevant wenn `ALLOW_MULTI_DEVICE_LOGIN=true`)

## Beispiele

### Single-Device-Login (Standard)
```env
# User kann nur von einem Gerät gleichzeitig eingeloggt sein
ALLOW_MULTI_DEVICE_LOGIN=false
```

### Multi-Device-Login mit Limit
```env
# User kann von max. 3 Geräten gleichzeitig eingeloggt sein
ALLOW_MULTI_DEVICE_LOGIN=true
MAX_SESSIONS_PER_USER=3
```

### Unbegrenztes Multi-Device-Login
```env
# User kann von beliebig vielen Geräten eingeloggt sein
ALLOW_MULTI_DEVICE_LOGIN=true
MAX_SESSIONS_PER_USER=999
```

## Verhalten

- **Single-Device-Login**: Bei jedem neuen Login werden alle bestehenden Sessions des Users invalidiert
- **Multi-Device-Login mit Limit**: Wenn das Limit erreicht wird, werden die ältesten Sessions automatisch gelöscht
- **Session-Bereinigung**: Das Script `cleanup-duplicate-sessions.js` kann verwendet werden, um bestehende Duplikate zu bereinigen

## Cleanup-Script

Um bestehende Duplikat-Sessions zu bereinigen:

```bash
cd backend
node cleanup-duplicate-sessions.js
```

Das Script:
- Findet alle User mit mehreren aktiven Sessions
- Behält nur die neueste Session pro User
- Löscht zusätzlich alle abgelaufenen Sessions
- Zeigt eine detaillierte Statistik