# 🌍 Weltenwind i18n Git-Workflow

## 📋 Überblick

Dieser Workflow stellt sicher, dass Übersetzungen strukturiert, überprüft und sicher in das Projekt integriert werden.

## 🌿 Branch-Strategie

### Haupt-Branches
- `main` - Produktionscode (nur Maintainer)
- `develop` - Entwicklungsbranch (Entwickler)

### i18n-Branches
- `i18n/de-DE` - Deutsche Übersetzungen
- `i18n/en-US` - Englische Übersetzungen
- `i18n/fr-FR` - Französische Übersetzungen (zukünftig)
- `i18n/es-ES` - Spanische Übersetzungen (zukünftig)

### Feature-Branches für Übersetzer
```bash
# Namenskonvention: i18n/{lang}/feature-beschreibung
i18n/de-DE/auth-strings-update
i18n/de-DE/world-dialogs-new
i18n/en-US/ui-consistency-fix
```

## 👥 Rollen & Berechtigungen

### Übersetzer-Rolle
**Berechtigt zu:**
- ✅ .arb-Dateien bearbeiten (`client/lib/l10n/`)
- ✅ Feature-Branches erstellen
- ✅ Pull Requests erstellen

**NICHT berechtigt zu:**
- ❌ Direkte Pushes auf `main` oder `develop`
- ❌ .dart-Code-Änderungen
- ❌ Lokalisierungs-Konfiguration (pubspec.yaml, l10n.yaml)

### Reviewer-Rolle
**Berechtigt zu:**
- ✅ Pull Requests reviewen & mergen
- ✅ .arb-Validierung vor Merge
- ✅ Qualitätskontrolle

## 🔄 Workflow-Schritte

### 1. Übersetzer startet neue Arbeit

```bash
# 1. Repository aktualisieren
git checkout develop
git pull origin develop

# 2. Neuen Feature-Branch erstellen
git checkout -b i18n/de-DE/auth-improvements

# 3. Änderungen machen (nur .arb-Dateien!)
# Bearbeite: client/lib/l10n/app_de.arb

# 4. Validierung vor Commit
cd client
python tools/arb_validator.py lib/l10n/app_de.arb

# 5. Commit & Push
git add client/lib/l10n/app_de.arb
git commit -m "i18n(de): Verbesserte Auth-Strings

- Klarere Fehlermeldungen
- Konsistente Button-Texte  
- Behebt #123"

git push origin i18n/de-DE/auth-improvements
```

### 2. Pull Request erstellen

**PR-Template für Übersetzer:**
```markdown
## 🌍 i18n Update: Deutsche Übersetzungen

### 📝 Änderungen
- [ ] Neue Strings hinzugefügt
- [ ] Bestehende Strings verbessert
- [ ] Konsistenz-Fixes
- [ ] Bug-Fixes

### 🎯 Betroffene Bereiche
- [ ] Authentication
- [ ] World Management
- [ ] Invite System
- [ ] UI Elements
- [ ] Error Messages

### ✅ Checkliste
- [ ] .arb-Syntax validiert
- [ ] Alle Platzhalter korrekt
- [ ] Konsistent mit bestehenden Strings
- [ ] Getestet in der App

### 📊 String-Statistiken
- Hinzugefügt: X Strings
- Geändert: Y Strings
- Entfernt: Z Strings
```

### 3. Code Review Process

**Automatische Checks:**
- ✅ .arb-Syntax-Validierung
- ✅ Platzhalter-Konsistenz
- ✅ Keine Code-Änderungen außerhalb i18n
- ✅ Branch-Naming-Convention

**Manueller Review:**
- 📝 Sprachliche Qualität
- 🎯 Konsistenz mit bestehenden Strings
- 🎮 Gaming-Kontext angemessen
- 🔍 Vollständigkeit

### 4. Merge & Deployment

```bash
# Nach erfolgreicher Review (nur Maintainer)
git checkout develop
git merge --no-ff i18n/de-DE/auth-improvements
git push origin develop

# Feature-Branch löschen
git branch -d i18n/de-DE/auth-improvements
git push origin --delete i18n/de-DE/auth-improvements
```

## 🔧 Git-Hooks

### Pre-Commit Hook
Automatische .arb-Validierung vor jedem Commit:

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Prüfe nur .arb-Dateien
arb_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.arb$')

if [ -n "$arb_files" ]; then
    echo "🌍 Validiere .arb-Dateien..."
    
    for file in $arb_files; do
        if [ -f "$file" ]; then
            python client/tools/arb_validator.py "$file"
            if [ $? -ne 0 ]; then
                echo "❌ Validierung fehlgeschlagen: $file"
                exit 1
            fi
        fi
    done
    
    echo "✅ Alle .arb-Dateien sind valid!"
fi
```

### Pre-Push Hook
Verhindert versehentliche Pushes auf geschützte Branches:

```bash
#!/bin/sh
# .git/hooks/pre-push

protected_branches="main master"
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

for branch in $protected_branches; do
    if [ "$current_branch" = "$branch" ]; then
        echo "❌ Direkte Pushes auf '$branch' sind nicht erlaubt!"
        echo "💡 Verwende Pull Requests für Änderungen."
        exit 1
    fi
done
```

## 📊 Monitoring & Statistiken

### Translation Progress Tracking
```bash
# Progress-Report generieren
python client/tools/translation_stats.py

# Output:
# 🌍 Weltenwind Translation Progress
# ================================
# 
# 🇩🇪 Deutsch (DE):    187/200 (93.5%) ✅
# 🇺🇸 Englisch (EN):   200/200 (100%) ✅
# 🇫🇷 Französisch (FR):  45/200 (22.5%) 🟡
# 🇪🇸 Spanisch (ES):     12/200 (6.0%)  🔴
```

### Quality Metrics
- **Consistency Score**: Ähnliche Begriffe einheitlich übersetzt
- **Completeness**: Prozentsatz übersetzter Strings
- **Freshness**: Wie aktuell sind die Übersetzungen
- **Context Accuracy**: Korrekte Verwendung von Gaming-Begriffen

## 🚨 Troubleshooting

### Häufige Probleme

**1. .arb-Syntax-Fehler**
```bash
# Problem: Invalide JSON in .arb-Datei
# Lösung: Validator verwenden
python client/tools/arb_validator.py lib/l10n/app_de.arb --fix
```

**2. Merge-Konflikte in .arb-Dateien**
```bash
# Problem: Zwei Übersetzer haben gleichzeitig gearbeitet
# Lösung: Strukturierter Merge
git checkout develop
git pull origin develop
git checkout i18n/de-DE/my-feature
git rebase develop
# Konflikte manuell lösen, dann:
git add .
git rebase --continue
```

**3. Fehlende Platzhalter**
```bash
# Problem: {userName} in DE fehlt, aber in EN vorhanden
# Lösung: Automatic Sync Tool
python client/tools/sync_placeholders.py --source en --target de
```

## 📚 Best Practices

### ✅ Do's
- Kleine, fokussierte PRs (max. 20-30 Strings)
- Beschreibende Commit-Messages
- Kontext in PR-Beschreibung erklären
- Gaming-Terminologie beibehalten
- Konsistenz mit bestehenden Strings

### ❌ Don'ts
- Keine Code-Änderungen in i18n-PRs
- Keine direkten Pushes auf main/develop
- Keine Übersetzungs-Tools ohne Review
- Keine Änderungen an Template-.arb-Datei ohne Abstimmung

## 🔐 Security Considerations

### Branch Protection Rules
```yaml
# GitHub Branch Protection für main
protection_rules:
  required_reviews: 2
  dismiss_stale_reviews: true
  require_code_owner_reviews: true
  allowed_push_users: []  # Nur via PR
  
# Für i18n-Branches
i18n_protection:
  required_reviews: 1
  auto_merge_enabled: true  # Nach Review
```

### Sensitive Strings
- **API-Keys**: Niemals in .arb-Dateien
- **URLs**: Nur öffentliche URLs
- **Persönliche Daten**: Nur Platzhalter verwenden

---

**🎮 Happy Translating!**

*Dieser Workflow wird kontinuierlich verbessert basierend auf Team-Feedback.* 