#!/bin/bash
# Weltenwind i18n Quick Commands
# Convenience-Skript für häufige i18n-Workflows

set -e  # Exit bei Fehlern

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen
print_usage() {
    echo "🌍 Weltenwind i18n Quick Commands"
    echo "================================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "📋 Verfügbare Commands:"
    echo "  scan                    - Nur deutsche Strings scannen"
    echo "  convert                 - Vollständige Konvertierung (empfohlen)"
    echo "  convert-safe            - Konvertierung ohne Code-Updates"
    echo "  convert-all             - Alles: Konvertierung + Code-Updates"
    echo "  update                  - Update bestehender Übersetzungen"
    echo "  validate                - Nur .arb-Dateien validieren"
    echo "  check                   - Schnelle Prüfung für CI/CD"
    echo "  clean                   - Aufräumen von Reports/Backups"
    echo ""
    echo "🎯 Beispiele:"
    echo "  $0 scan                 # Schneller String-Scan"
    echo "  $0 convert              # Standard-Konvertierung"
    echo "  $0 convert-all          # Mit Code-Updates"
    echo "  $0 update               # Niedrigere Konfidenz für Updates"
    echo ""
}

print_header() {
    echo -e "${BLUE}🌍 Weltenwind i18n: $1${NC}"
    echo "================================="
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_prerequisites() {
    print_header "Prüfe Voraussetzungen"
    
    # Prüfe ob wir im client-Verzeichnis sind
    if [[ ! -f "pubspec.yaml" ]]; then
        print_error "Nicht im Flutter client-Verzeichnis! Wechsle ins client-Verzeichnis."
        exit 1
    fi
    
    # Prüfe Python
    if ! command -v python &> /dev/null; then
        print_error "Python nicht gefunden!"
        exit 1
    fi
    
    # Prüfe Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter nicht gefunden!"
        exit 1
    fi
    
    # Prüfe Tools
    if [[ ! -f "tools/i18n_workflow.py" ]]; then
        print_error "i18n_workflow.py nicht gefunden!"
        exit 1
    fi
    
    print_success "Alle Voraussetzungen erfüllt"
}

run_workflow() {
    local mode=$1
    shift
    local extra_args="$@"
    
    print_header "Starte i18n-Workflow: $mode"
    
    # Führe Workflow aus
    python tools/i18n_workflow.py --mode "$mode" $extra_args
    
    if [[ $? -eq 0 ]]; then
        print_success "Workflow '$mode' erfolgreich abgeschlossen"
        
        # Zeige Report-Verzeichnis
        if [[ -d "tools/workflow_reports" ]]; then
            echo ""
            echo "📁 Reports verfügbar in: tools/workflow_reports/"
            ls -la tools/workflow_reports/ | tail -5
        fi
    else
        print_error "Workflow '$mode' fehlgeschlagen"
        exit 1
    fi
}

# Hauptlogik
case "$1" in
    "scan")
        check_prerequisites
        run_workflow "scan"
        ;;
    
    "convert")
        check_prerequisites
        print_warning "Starte Standard-Konvertierung (ohne Code-Updates)"
        run_workflow "convert" "--confidence 0.8 --auto-translate"
        print_success "Führe 'flutter pub get' aus um die neuen Lokalisierungen zu laden"
        ;;
    
    "convert-safe")
        check_prerequisites
        print_warning "Sichere Konvertierung: Nur .arb-Dateien, kein Code-Update"
        run_workflow "convert" "--confidence 0.8 --auto-translate"
        ;;
    
    "convert-all")
        check_prerequisites
        print_warning "⚠️ VOLLSTÄNDIGE Konvertierung: .arb-Dateien + Code-Updates"
        echo "Das wird Dart-Code automatisch ändern!"
        read -p "Fortfahren? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            run_workflow "convert" "--confidence 0.8 --auto-translate --update-code"
        else
            print_warning "Abgebrochen"
            exit 0
        fi
        ;;
    
    "update")
        check_prerequisites
        print_warning "Update-Modus: Niedrigere Konfidenz für mehr Strings"
        run_workflow "update" "--confidence 0.7 --auto-translate"
        ;;
    
    "validate")
        check_prerequisites
        print_header "Validiere .arb-Dateien"
        
        # Direkt Validator aufrufen
        python tools/arb_validator.py lib/l10n/app_de.arb --compare-to lib/l10n/app_en.arb
        python tools/arb_validator.py lib/l10n/app_en.arb
        
        print_success "Validierung abgeschlossen"
        ;;
    
    "check")
        check_prerequisites
        print_header "CI/CD-Modus: Schnelle Prüfung"
        run_workflow "ci" "--fail-on-warnings"
        ;;
    
    "clean")
        print_header "Aufräumen"
        
        # Backup-Verzeichnisse
        if [[ -d "lib/l10n/backups" ]]; then
            echo "🗑️ Lösche .arb-Backups..."
            rm -rf lib/l10n/backups/
        fi
        
        # Alte Reports (älter als 7 Tage)
        if [[ -d "tools/workflow_reports" ]]; then
            echo "🗑️ Lösche alte Reports (>7 Tage)..."
            find tools/workflow_reports/ -name "*.json" -mtime +7 -delete 2>/dev/null || true
            find tools/workflow_reports/ -name "*.md" -mtime +7 -delete 2>/dev/null || true
        fi
        
        # Code-Backups
        if [[ -d "tools/code_backups" ]]; then
            echo "🗑️ Lösche Code-Backups..."
            rm -rf tools/code_backups/
        fi
        
        print_success "Aufräumen abgeschlossen"
        ;;
    
    "help"|"-h"|"--help"|"")
        print_usage
        ;;
    
    *)
        print_error "Unbekannter Befehl: $1"
        echo ""
        print_usage
        exit 1
        ;;
esac 