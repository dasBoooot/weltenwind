# Spielregeln – Einheitliche Arbeitsweise (Global)
---
title: "Spielregeln – Einheitliche Arbeitsweise"
description: "Globale Arbeitsweise und Qualitätsregeln für alle Agents im Projekt."
scope: "global"
version: "1.0.0"
docs_path: "docs/cursor/rules/spielregeln.md"
---

Diese Regeln gelten für alle Agents in diesem Projekt. Sie sichern eine strukturierte, nachvollziehbare und vollständige Umsetzung.

Hinweis: Architektur- und Security-Regeln sind ausgelagert und werden in separaten Dokumenten gepflegt.

---

## 1. Kommunikation

- Deutsch als Standardsprache; keine Annahmen bei Unklarheiten – nachfragen.
- Keine Erfolgsmeldung, solange Punkte der ToDo-Liste offen sind.
- Blocker (fehlende API/Assets/Config) sofort transparent melden.
- Keine unangeforderten Code-Änderungen oder Features.
- Rückfragepflicht bei Widersprüchen: Kollidieren Prompt, bestehender Code oder Architekturregeln, sofort stoppen und klären, bevor Änderungen beginnen.

---

## 2. Startphase: Verständnis & Planung

1. Aufgabe in eigenen Worten wiederholen.
2. Konkrete ToDo-Liste erstellen (max. 10–15 prägnante Punkte).
3. Relevante Regeln (AI-Reminder/Spielregeln) kurz checken.
4. Bestehenden Code lesen, betroffene Stellen skizzieren.
5. Offene Fragen klären – erst danach starten.
6. Kontext-Beständigkeit: Bei mehrschrittigen Tasks bisherigen Kontext (ToDo-Liste + Zwischenergebnisse) vor jedem neuen Schritt kurz wiederholen.
7. Keine „frischen“ Lösungsansätze starten, ohne den bisherigen Plan zu berücksichtigen.
8. Prompt-Echo & Kontextbindung: Vor jedem Schritt kurz die aktuell relevanten Regeln und den unmittelbaren Task-Kontext benennen.

---

## 3. Implementierungsprinzipien

- Schrittweise, minimalinvasiv arbeiten; funktionierenden Code nicht ohne Not ändern.
- Änderungen vollständig und konsistent in allen betroffenen Dateien umsetzen.
- Keine neuen Dependencies ohne vorherige Rückfrage.
- Keine kompletten Dateien/Funktionen ohne explizite Freigabe neu schreiben.
- Keine hardcodierten UI-Texte – AppLocalizations/ARB-Keys verwenden.
- Utility-/Helper-Funktionen zentralisieren statt in Widgets duplizieren.
- Defensive Programmierung: valides Error-Handling, Input-Validierung.
- Kein `print()` im Production-Code – AppLogger/strukturierte Logs nutzen.
- PowerShell-Umgebung respektieren: keine Linux-Shell-Befehle verwenden.
- Änderungsauswirkungen prüfen: Vor dem Commit einschätzen, welche Module, Tests oder Doku betroffen sind; bei Unklarheit Rückfrage statt Anpassung „auf Verdacht“.
- API- und Schnittstellen-Respekt: Nie Methoden/Parameter entfernen oder umbenennen ohne vorherige Abstimmung, wenn extern genutzt.
- Nicht in fremden Branches arbeiten: Nur im vorgegebenen Branch, keine spontanen Branch-Wechsel oder Commits auf main.
- Config-Integrität: Vor Commit sicherstellen, dass keine Secrets (Keys/Tokens/Passwörter) in Code/Configs landen.

---

## 4. Nach jedem Change: Verifikation

1. Code-Analyse: `flutter analyze`
2. Build-Test (falls relevant): `flutter build web --base-href /game/`
3. Manuelle Tests: Funktionalität, Edge Cases, Cross-Platform-Verhalten prüfen (Flutter Web/Android/iOS); Unterschiede dokumentieren.
4. Bei Änderungen an Logik: Betroffene Unit-/Widget-/Integrationstests ausführen. Neue Logik ohne Tests nur nach expliziter Freigabe.
5. Ergebnisse im Chat knapp zusammenfassen (Was geändert? Was getestet? Ergebnis?) inkl. Diff-Zusammenfassung (Dateien, Kernänderungen, betroffene Features).
6. Falls API-/Schema-Änderungen: OpenAPI/Swagger aktualisieren, Migrationsskripte + Kompatibilitätstests erstellen; prüfen, ob bestehende Daten migriert/validiert werden müssen.
7. Lauffähigkeit garantieren: Kein Merge bei `flutter analyze`- oder Build-Fehlern. Warnings nur mit dokumentiertem Grund akzeptieren.
8. Merge-Sauberkeit: Keine ungetesteten Quickfixes im letzten Commit vor Merge; Analyse/Build/Tests erneut ausführen.

Fehler/Warnungen klassifizieren:
- Kritisch (Build bricht/Crash)
- Mittel (funktioniert, aber inkorrekt/unsauber)
- Niedrig (Styling/Lint)

---

## 5. Debugging-Regeln

- Code zuerst lesen und logisch analysieren – nicht raten.
- Systematisch vorgehen, Hypothesen gegen Code/Runtime verifizieren.
- Kein temporärer Debug-/Test-Code in dauerhaften Commits.

---

## 6. Code-Review & Qualität

- Kleine, klar umrissene Edits; keine Vermischung unzusammenhängender Themen.
- Selbst-Check vor dem Review:
  - Lints fehlerfrei? (`flutter analyze`)
  - Keine hardcodierten UI-Texte?
  - Sauberes Error-Handling?
  - Manuelle Tests durchgeführt und dokumentiert?
  - Ergebnis-Vollständigkeit: Keine Codefragmente bei Aufträgen, die vollständige Implementierung verlangen; bei Multi-File-Änderungen gesamten Diff zeigen.
  - Branch & CI: Richtiger Branch verwendet; CI/Checks grün.

---

## 7. Dokumentation & Commits

- Nur wo nötig kommentieren; Verständlichkeit durch klaren Code bevorzugen.
- Prägnante Commit-Messages mit Kontext und Motivation.
- Bei größeren Änderungen: kurzen Changelog-Eintrag ergänzen.

---

## 8. Abbruch & Wiederaufnahme

- Bei Blockern/Komplexität stoppen, Zwischenstand dokumentieren, im Chat beschreiben.
- Nach Freigabe exakt an der dokumentierten Stelle fortsetzen.

---

## 9. Umgebung & Requests

- Bei lokalen API-Tests die Server-IP der VM nutzen (nicht `localhost`).
- Environment-spezifische Einstellungen konsistent halten.

---

## 10. Was ausdrücklich zu vermeiden ist

- Blindes Refactoring ohne Auftrag.
- Änderungen „aus Stilgründen“, die Verhalten unnötig riskieren.
- Teilimplementierungen ohne Tests/Verifikation.
- „Hier ist dein Code“-Abschluss ohne vollständige Bearbeitung.
- Vermischen mehrerer unzusammenhängender Änderungen in einem Edit.

---

## 11. Ergänzende Qualitätsregeln

- Definition of Done: analyze clean, Build ok (falls relevant), manuelle Tests dokumentiert, Changelog/Docs aktualisiert, Rollback-Plan klar.
- Kleine, fokussierte PRs: Max. 300–400 Zeilen Diff; ein Thema pro PR; klare Beschreibung inkl. „Warum“.
- Commit-Konvention: Conventional Commits mit Scope (z. B. feat/world, fix/auth, docs/rules); präzise Messages.
- Modulgrenzen durchsetzen:
  - Feature-Module mit klaren öffentlichen Schnittstellen
  - Keine Querverweise auf interne Details anderer Module
  - Barrel-Exports für wohldefinierte Public APIs
- Kein zyklischer Import: Abhängigkeiten nur „nach unten“ (Utilities → Features → App); Zyklen sofort auflösen.
- Public API je Modul: Nur Nötiges exponieren; Interna verborgen halten.
- Deprecation-Policy: Altes API markieren, Ersatz nennen, Entfernungstermin setzen; kein „Hard Cut“ ohne Übergang.
- Lint-Warnungen als Fehler behandeln: Neue Warnungen blockieren den Merge bis behoben.
- A11y-Basisregeln: Fokus-Reihenfolge, ausreichender Kontrast, semantische Widgets; Tastaturbedienbarkeit prüfen.
- Performance-Budgets: Bundle-Größe beobachten; große Assets lazy laden; unnötige Rebuilds vermeiden.
- Feature-Toggles: Inkrementell liefern; unfertige Teile hinter Schaltern statt totem/auskommentiertem Code.
- Fehlerkultur: Bugs reproduzierbar dokumentieren (Schritte, Erwartung, Ergebnis); kurze Ursachenanalyse festhalten.
- Wissenspflege: Lessons learned zeitnah in Regeln/Notizen aufnehmen; wiederkehrende Stolpersteine sichtbar machen.
- Review-Disziplin: Kein Merge ohne Selbst-Checkliste; keine unaufgeforderten großen Rewrites.
- Dependency-Hygiene: Vor neuer Lib Health/Lizenz/Wartung prüfen; Versionen pinnen; klare Removal-Strategie.
- Rollback-Strategie verpflichtend bei tiefgreifenden Änderungen: Welche Commits revertierbar, welche Configs zu sichern.
- Time-Box für lange Tasks: Große Aufgaben in Teilsprints schneiden, Zwischenergebnisse zur Freigabe liefern.
