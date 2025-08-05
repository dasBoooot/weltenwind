# 🚫 Entwicklungsregeln - Weltenwind

**Unsere absoluten Do's und Don'ts für die gemeinsame Entwicklung**

---

## 🚨 **ABSOLUTE NO-GOS**

### **1. 🚫 NIEMALS UI-Elemente hardcoden!**

**✅ Logger/Console: Englisch OK**  
**❌ UI-Elemente: IMMER AppLocalizations verwenden!**

```dart
// ❌ NIEMALS SO:
Text('Fehler beim Laden der Daten')
AlertDialog(title: Text('Bestätigung'))
ElevatedButton(child: Text('Speichern'))

// ✅ IMMER SO:
Text(AppLocalizations.of(context).dataLoadError)
AlertDialog(title: Text(l10n.confirmationTitle))
ElevatedButton(child: Text(l10n.buttonSave))
```

**Wenn ARB-Keys fehlen → Keys zur ARB-Datei hinzufügen, NICHT durch hardcoded Texte ersetzen!**

### **2. 🚫 Hardcoding von Werten, Mappings, oder Logik ist zu 99% ein Fehler**

**Stattdessen immer nach konfigurierbaren, dynamischen Lösungen suchen.**

```dart
// ❌ NIEMALS SO: Switch-Case Mappings für Themes/Bundles
switch(theme) {
  case 'medieval': return 'castle-bundle';
  case 'sci-fi': return 'space-bundle';
}

// ❌ NIEMALS SO: Hardcoded Listen von Werten
final availableThemes = ['medieval', 'sci-fi', 'fantasy'];

// ❌ NIEMALS SO: Fest verdrahtete IDs
if (worldId == 123) { /* special logic */ }

// ✅ IMMER SO: Konfiguration/DB-basiert
final themeMapping = await configService.getThemeMapping();
final availableThemes = await themeService.getAvailableThemes();
final specialWorlds = await worldService.getWorldsWithSpecialLogic();
```

**Grund**: "Morgen haben wir andere Welten" - der Code muss das automatisch unterstützen, ohne Code-Änderungen!

### **3. 🚫 NIEMALS komplette Dateien/Funktionen ohne Erlaubnis neu schreiben**

**Der User verbietet explizit, jemals wieder komplette Dateien oder Funktionen ohne ausdrückliche Erlaubnis zu überschreiben.**

- ✅ **IMMER fragen** bevor etwas komplett neu gebaut wird
- ✅ **Gründliche, sorgfältige Arbeit** hat Vorrang vor Geschwindigkeit  
- ✅ **Minimale, präzise Änderungen** sind besser als komplette Neuschreibungen
- ✅ **Ein Widget/Feature nach dem anderen** implementieren und warten auf Review

### **4. 🚫 NIEMALS Linux-Befehle in PowerShell**

**Der User arbeitet in einer PowerShell-Umgebung (Windows).**

```bash
# ❌ NIEMALS diese Linux-Befehle verwenden:
ls, mkdir, cp, cat, grep, find, rm, mv

# ✅ IMMER PowerShell-Befehle verwenden:
Get-ChildItem, New-Item, Copy-Item, Get-Content, Select-String, Remove-Item, Move-Item
```

---

## ✅ **PFLICHT-REGELN**

### **1. ✅ Vor jedem Build: flutter analyze**

**Der User bevorzugt, dass flutter analyze vor flutter build ausgeführt wird.**

```bash
# ✅ Immer in dieser Reihenfolge:
flutter analyze
flutter build web --base-href /game/ 
```

### **2. ✅ Zentrale Utilities statt Widget-interne Funktionen**

**Der User bevorzugt, dass Utility-Funktionen NICHT direkt in Page-Widget-Klassen platziert werden.**

```dart
// ❌ NICHT SO: Utility-Funktion in Page-Widget
class MyPage extends StatefulWidget {
  String formatDate(DateTime date) { /* ... */ }  // ❌ Duplicated across pages
}

// ✅ SO: Zentralisierte Helper-Klassen
class DateHelper {
  static String formatDate(DateTime date) { /* ... */ }  // ✅ Reusable
}
```

**Grund**: Vermeidung von Duplikation über mehrere Pages hinweg.

### **3. ✅ Robuste, proper implementierte Lösungen**

**Der User bevorzugt robuste, richtig implementierte Lösungen statt quick-and-dirty Hacks.**

- ✅ **Proper Error Handling** mit try-catch und User-feedback
- ✅ **Input Validation** sowohl Client- als auch Server-side  
- ✅ **Cross-Platform Compatibility** - iOS und Android gleichwertig
- ✅ **Performance Considerations** - efficient algorithms und memory usage

### **4. ✅ Schrittweise Verifikation statt "should"**

**Der User bevorzugt, dass Änderungen Schritt für Schritt verifiziert werden.**

- ❌ "Das sollte funktionieren"
- ❌ "Das müsste jetzt klappen"  
- ✅ **Testen und bestätigen** dass Änderungen tatsächlich funktionieren
- ✅ **Alle Change-Requests implementieren** bevor abschließen

---

## 🏗️ **ARCHITEKTUR-REGELN**

### **1. 🎨 Theme-System richtig verwenden**

**Projekt verwendet ein Theme für konsistente Styling.**

```dart
// ✅ Neue UI-Komponenten folgen dem Design von login_page.dart
// ✅ AppScaffold für globale Theme-Anwendung verwenden
// ✅ Definitionen aus dynamic_components importieren, nicht direkt schreiben
```

### **2. 🧭 Cross-Platform Lösungen bevorzugen**

**Routing und andere Lösungen müssen cross-platform und stabil auf iOS und Android laufen.**

- ❌ Web-spezifische Lösungen vermeiden
- ✅ Flutter-native Patterns verwenden
- ✅ Platform-agnostic Code schreiben

### **3. 📡 API-Endpunkte immer mit Swagger updaten**

**Wenn ein neuer API-Endpunkt gebaut wird, werden die entsprechenden Swagger-Files gleichzeitig aktualisiert.**

- ✅ Neue Endpunkte in entsprechende `specs/*.yaml` Datei
- ✅ Request/Response-Schemas definieren
- ✅ `generate-openapi.js` ausführen
- ✅ Combined YAML testen

### **4. 🗃️ Prisma-Schema und Swagger synchron halten**

**Swagger-Dokumentation und Prisma-Schema-Files müssen immer synchron gehalten werden.**

---

## 🐛 **DEBUGGING-REGELN**

### **1. 🔍 Code-Analyse vor Spekulation**

**User erwartet, dass Bugs durch direktes Lesen und Interpretieren des Codes gefunden werden, ohne Debugging-Logs zu verlangen.**

- ✅ **Code systematic analysieren** 
- ✅ **Logisch durchdenken** was passieren könnte
- ❌ **Nicht spekulieren oder raten**

### **2. 🧹 Kein Debug-Code in Production**

**User bevorzugt, dass kein Debugging-Code eingefügt wird, der den Code "verschmutzt".**

- ❌ `print()` Statements für Production-Code  
- ❌ Temporary Debug-Widgets
- ✅ `AppLogger` für strukturiertes Logging
- ✅ Sauberer, production-ready Code

---

## ⚡ **WORKFLOW-REGELN**

### **1. 📊 Systematische Projekterweiterungen**

**Das Projekt erfordert systematische Migration aller Pages zum neuen Theme-System.**

- ✅ **Alle Pages migrieren** statt case-by-case fixes
- ✅ **Konsistente Patterns** über die gesamte Codebase
- ✅ **Vollständige Implementierung** vor Abschluss

### **2. 🔐 Permission-Format befolgen**

**Permission-Namen im Format `<scope>.<action>` verwenden.**

```typescript
// ✅ Korrekte Permission-Namen:
'player.join', 'world.edit', 'admin.access', 'user.manage'

// ❌ Falsche Formate:
'joinPlayer', 'world_edit', 'AdminAccess'
```

### **3. 🌐 Server-IP für API-Requests**

**Bei API-Requests zum dev server, die Server-IP statt localhost verwenden.**

```javascript
// ✅ Korrekt: 
const apiUrl = 'http://192.168.2.168:3000/api';

// ❌ Falsch:
const apiUrl = 'http://localhost:3000/api';
```

---

**Letztes Update**: Januar 2025  
**Status**: 🚀 Aktiv - Diese Regeln sind verpflichtend für alle Code-Änderungen!