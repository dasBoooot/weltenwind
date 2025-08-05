# 🌍 Weltenwind ARB Manager

Professioneller ARB (Application Resource Bundle) Manager für Flutter-Lokalisierung.

## 📁 Dateien

### 🌐 ARB Manager Core
- **`index.html`** - ARB Manager Web-Interface
- **`arb.css`** - Styling für den ARB Manager  
- **`arb.js`** - JavaScript-Funktionalität

### 🔧 Maintenance-Tools
- **`check-keys.js`** - Vergleicht deutsche und englische ARB-Keys
- **`find-extra-keys.js`** - Findet überflüssige Keys in englischer ARB
- **`cleanup-english-arb.js`** - Bereinigt englische ARB basierend auf deutscher Master-ARB

## 🚀 Verwendung

### ARB Manager öffnen
```
http://localhost:3000/arb-manager/
```

### Maintenance-Tools verwenden
```bash
# Key-Synchronisation prüfen
node check-keys.js

# Überflüssige Keys finden  
node find-extra-keys.js

# Englische ARB bereinigen (erstellt automatisch Backup)
node cleanup-english-arb.js
```

## 🎯 Features

- ✅ **Multi-Sprachen-Support** - Wechsle zwischen verfügbaren Sprachen
- ✅ **Alle Sprachen editierbar** - Deutsche Master-ARB und alle anderen Sprachen
- ✅ **Sicherheits-Dialoge** - Klare Erklärungen beim Speichern
- ✅ **Export/Import** - .arb und .json Formate unterstützt  
- ✅ **Live-Validierung** - XSS-Schutz und Input-Sanitization
- ✅ **Multi-Language Vergleichsansicht** - Master vs. Zielsprache Vergleich
- ✅ **Professionelle Übersetzungen** - Gaming-optimierte manuelle Übersetzungen

## 🛡️ Sicherheit

- **Input-Sanitization** - Alle Eingaben werden bereinigt
- **XSS-Protection** - 15+ gefährliche Patterns werden blockiert  
- **Berechtigungen** - `localization.manage` erforderlich
- **Backup-System** - Automatische Backups vor Änderungen

## 📋 Workflow

1. **Login** → ARB Manager öffnet sich
2. **Sprache wählen** → Dropdown mit verfügbaren Sprachen
3. **Bearbeiten** → Alle Sprachen sind vollständig editierbar
4. **Speichern** → Sicherheitsabfrage mit nächsten Schritten
5. **Vergleichen** → Multi-Language Vergleichsansicht nutzen
6. **Export** → Download als .arb oder .json Format

## 📊 Vergleichsansicht

Die Multi-Language Vergleichsansicht bietet:
- **Master vs. Zielsprache** - Übersichtlicher 2-Spalten Vergleich
- **Statistiken** - Vollständigkeit, fehlende Keys, etc.
- **Filter-Optionen** - Nur fehlende, vollständige oder alle Keys
- **Suchfunktion** - Durchsuche Keys und Werte
- **Sprachkarten** - Übersicht über alle verfügbaren Sprachen
- **Dark Theme** - Konsistent mit ARB Manager Design

## 💼 Übersetzungsstrategie

**Manuelle Übersetzung bevorzugt:**
- ✅ Gaming-optimierte Terminologie
- ✅ Kontext-bewusste Übersetzungen  
- ✅ Konsistente UI-Begriffe
- ✅ Hochwertige Qualität ohne API-Dependencies
- ✅ Vollständige Kontrolle über alle Texte

**Beispiele professioneller Gaming-Übersetzungen:**
- "Anmelden" → "Sign In" (Gaming-Standard)
- "Spielwelten" → "Game Worlds" (Kontext-klar)
- "Vorregistrieren" → "Pre-Register" (Gaming-Terminologie)
- "Bereit für dein Abenteuer?" → "Ready for your adventure?" (Adventure-Sprache)

## 🔧 Maintenance-Tools Details

### 📊 `check-keys.js`
- **Zweck**: Vollständiger Vergleich zwischen deutscher Master-ARB und englischer ARB
- **Output**: Zeigt fehlende Keys, Extra-Keys und Vollständigkeits-Prozentsatz
- **Verwende wenn**: Du vermutest, dass die ARB-Dateien nicht synchron sind

### 🔍 `find-extra-keys.js`  
- **Zweck**: Findet Keys die nur in der englischen ARB existieren
- **Output**: Liste aller überflüssigen Keys mit ihren Werten
- **Verwende wenn**: Du willst gezielt überflüssige Keys identifizieren

> **💡 Tipp**: Diese Tools nutzen die gleiche Logik wie die Multi-Language Vergleichsansicht im ARB Manager!

## 💡 Tipps

- **ESC-Taste** schließt alle Dialoge und Vergleichsansicht
- **Click außerhalb** schließt Dialoge
- **Auto-Sanitization** warnt bei gefährlichen Eingaben
- **Import-Vorschau** zeigt alle Änderungen vor Import
- **Vergleichsansicht** nutzen um Übersetzungsqualität zu prüfen
- **Master-Sprache** (Deutsch) als Referenz für alle Übersetzungen
- **Maintenance-Tools** regelmäßig ausführen um ARB-Synchronisation zu gewährleisten