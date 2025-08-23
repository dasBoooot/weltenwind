@echo off
REM Weltenwind i18n Quick Commands - Windows Version
REM Convenience-Skript für häufige i18n-Workflows

setlocal enabledelayedexpansion

REM Farben für Output (Windows PowerShell unterstützt ANSI codes)
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "BLUE=[34m"
set "NC=[0m"

goto :main

:print_usage
echo 🌍 Weltenwind i18n Quick Commands
echo =================================
echo.
echo Usage: %~nx0 ^<command^> [options]
echo.
echo 📋 Verfügbare Commands:
echo   scan                    - Nur deutsche Strings scannen
echo   convert                 - Vollständige Konvertierung (empfohlen)
echo   convert-safe            - Konvertierung ohne Code-Updates
echo   convert-all             - Alles: Konvertierung + Code-Updates
echo   update                  - Update bestehender Übersetzungen
echo   validate                - Nur .arb-Dateien validieren
echo   check                   - Schnelle Prüfung für CI/CD
echo   clean                   - Aufräumen von Reports/Backups
echo.
echo 🎯 Beispiele:
echo   %~nx0 scan                 # Schneller String-Scan
echo   %~nx0 convert              # Standard-Konvertierung
echo   %~nx0 convert-all          # Mit Code-Updates
echo   %~nx0 update               # Niedrigere Konfidenz für Updates
echo.
goto :eof

:print_header
echo %BLUE%🌍 Weltenwind i18n: %~1%NC%
echo =================================
goto :eof

:print_success
echo %GREEN%✅ %~1%NC%
goto :eof

:print_warning
echo %YELLOW%⚠️ %~1%NC%
goto :eof

:print_error
echo %RED%❌ %~1%NC%
goto :eof

:check_prerequisites
call :print_header "Prüfe Voraussetzungen"

REM Prüfe ob wir im client-Verzeichnis sind
if not exist "pubspec.yaml" (
    call :print_error "Nicht im Flutter client-Verzeichnis! Wechsle ins client-Verzeichnis."
    exit /b 1
)

REM Prüfe Python
python --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Python nicht gefunden!"
    exit /b 1
)

REM Prüfe Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Flutter nicht gefunden!"
    exit /b 1
)

REM Prüfe Tools
if not exist "tools\i18n_workflow.py" (
    call :print_error "i18n_workflow.py nicht gefunden!"
    exit /b 1
)

call :print_success "Alle Voraussetzungen erfüllt"
goto :eof

:run_workflow
set "mode=%~1"
set "extra_args=%~2 %~3 %~4 %~5 %~6"

call :print_header "Starte i18n-Workflow: %mode%"

REM Führe Workflow aus
python tools\i18n_workflow.py --mode %mode% %extra_args%

if errorlevel 1 (
    call :print_error "Workflow '%mode%' fehlgeschlagen"
    exit /b 1
) else (
    call :print_success "Workflow '%mode%' erfolgreich abgeschlossen"
    
    REM Zeige Report-Verzeichnis
    if exist "tools\workflow_reports" (
        echo.
        echo 📁 Reports verfügbar in: tools\workflow_reports\
        dir /b /o-d "tools\workflow_reports" | findstr /v "^$" | head -5
    )
)
goto :eof

:main
if "%~1"=="scan" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :run_workflow "scan"
    
) else if "%~1"=="convert" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :print_warning "Starte Standard-Konvertierung (ohne Code-Updates)"
    call :run_workflow "convert" "--confidence 0.8 --auto-translate"
    call :print_success "Führe 'flutter pub get' aus um die neuen Lokalisierungen zu laden"
    
) else if "%~1"=="convert-safe" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :print_warning "Sichere Konvertierung: Nur .arb-Dateien, kein Code-Update"
    call :run_workflow "convert" "--confidence 0.8 --auto-translate"
    
) else if "%~1"=="convert-all" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :print_warning "⚠️ VOLLSTÄNDIGE Konvertierung: .arb-Dateien + Code-Updates"
    echo Das wird Dart-Code automatisch ändern!
    set /p "confirm=Fortfahren? (y/N): "
    if /i "!confirm!"=="y" (
        call :run_workflow "convert" "--confidence 0.8 --auto-translate --update-code"
    ) else (
        call :print_warning "Abgebrochen"
        exit /b 0
    )
    
) else if "%~1"=="update" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :print_warning "Update-Modus: Niedrigere Konfidenz für mehr Strings"
    call :run_workflow "update" "--confidence 0.7 --auto-translate"
    
) else if "%~1"=="validate" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :print_header "Validiere .arb-Dateien"
    
    REM Direkt Validator aufrufen
    python tools\arb_validator.py lib\l10n\app_de.arb --compare-to lib\l10n\app_en.arb
    python tools\arb_validator.py lib\l10n\app_en.arb
    
    call :print_success "Validierung abgeschlossen"
    
) else if "%~1"=="check" (
    call :check_prerequisites
    if errorlevel 1 exit /b 1
    call :print_header "CI/CD-Modus: Schnelle Prüfung"
    call :run_workflow "ci" "--fail-on-warnings"
    
) else if "%~1"=="clean" (
    call :print_header "Aufräumen"
    
    REM Backup-Verzeichnisse
    if exist "lib\l10n\backups" (
        echo 🗑️ Lösche .arb-Backups...
        rmdir /s /q "lib\l10n\backups"
    )
    
    REM Alte Reports (einfache Lösung - alle löschen)
    if exist "tools\workflow_reports" (
        echo 🗑️ Lösche Reports...
        del /q "tools\workflow_reports\*.json" 2>nul
        del /q "tools\workflow_reports\*.md" 2>nul
    )
    
    REM Code-Backups
    if exist "tools\code_backups" (
        echo 🗑️ Lösche Code-Backups...
        rmdir /s /q "tools\code_backups"
    )
    
    call :print_success "Aufräumen abgeschlossen"
    
) else if "%~1"=="help" (
    call :print_usage
) else if "%~1"=="-h" (
    call :print_usage
) else if "%~1"=="--help" (
    call :print_usage
) else if "%~1"=="" (
    call :print_usage
) else (
    call :print_error "Unbekannter Befehl: %~1"
    echo.
    call :print_usage
    exit /b 1
) 