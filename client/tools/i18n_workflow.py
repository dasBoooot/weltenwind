#!/usr/bin/env python3
"""
Weltenwind i18n Master Workflow
Automatisierter End-to-End Workflow für Internationalisierung

Usage: 
  python i18n_workflow.py --mode scan           # Nur Strings scannen
  python i18n_workflow.py --mode convert        # Vollständige Konvertierung  
  python i18n_workflow.py --mode update         # Aktualisierung bestehender
  python i18n_workflow.py --mode ci             # CI/CD Pipeline Modus
"""

import os
import sys
import json
import argparse
import subprocess
import shutil
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
import datetime

@dataclass
class WorkflowConfig:
    """Konfiguration für den i18n-Workflow"""
    client_root: str = "."
    confidence_threshold: float = 0.8
    auto_translate: bool = True
    update_code: bool = False
    create_backups: bool = True
    run_flutter_commands: bool = True
    fail_on_warnings: bool = False
    output_dir: str = "tools/workflow_reports"

@dataclass
class WorkflowResult:
    """Ergebnis eines Workflow-Durchlaufs"""
    success: bool
    mode: str
    timestamp: str
    extraction_stats: Dict
    conversion_stats: Dict
    validation_stats: Dict
    errors: List[str]
    warnings: List[str]
    reports_generated: List[str]

class I18nWorkflow:
    def __init__(self, config: WorkflowConfig):
        self.config = config
        self.client_root = Path(config.client_root)
        self.tools_dir = self.client_root / "tools"
        self.output_dir = self.client_root / config.output_dir
        self.output_dir.mkdir(exist_ok=True)
        
        # Workflow-State
        self.errors = []
        self.warnings = []
        self.reports = []
        
    def log(self, message: str, level: str = "INFO"):
        """Einheitliches Logging"""
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        icon = {"INFO": "📋", "SUCCESS": "✅", "WARNING": "⚠️", "ERROR": "❌"}.get(level, "📋")
        print(f"{icon} [{timestamp}] {message}")
        
        if level == "ERROR":
            self.errors.append(message)
        elif level == "WARNING":
            self.warnings.append(message)
    
    def run_command(self, command: List[str], description: str, 
                   capture_output: bool = False, cwd: Optional[Path] = None) -> subprocess.CompletedProcess:
        """Führt einen Befehl aus"""
        
        self.log(f"Führe aus: {description}")
        self.log(f"Befehl: {' '.join(command)}", "INFO")
        
        try:
            result = subprocess.run(
                command,
                cwd=cwd or self.client_root,
                capture_output=capture_output,
                text=True,
                check=False
            )
            
            if result.returncode == 0:
                self.log(f"✅ {description} erfolgreich", "SUCCESS")
            else:
                error_msg = f"❌ {description} fehlgeschlagen (Exit Code: {result.returncode})"
                if result.stderr:
                    error_msg += f"\nFehler: {result.stderr.strip()}"
                self.log(error_msg, "ERROR")
            
            return result
            
        except Exception as e:
            self.log(f"❌ Fehler bei {description}: {e}", "ERROR")
            raise
    
    def check_prerequisites(self) -> bool:
        """Prüft ob alle erforderlichen Tools verfügbar sind"""
        self.log("🔍 Prüfe Voraussetzungen...")
        
        required_files = [
            self.tools_dir / "i18n_string_extractor.py",
            self.tools_dir / "i18n_arb_converter.py", 
            self.tools_dir / "arb_validator.py"
        ]
        
        missing_files = [f for f in required_files if not f.exists()]
        if missing_files:
            for file in missing_files:
                self.log(f"❌ Erforderliche Datei fehlt: {file}", "ERROR")
            return False
        
        # Prüfe Flutter-Installation
        try:
            result = self.run_command(["flutter", "--version"], "Flutter Version prüfen", capture_output=True)
            if result.returncode != 0:
                self.log("❌ Flutter nicht gefunden oder nicht funktionsfähig", "ERROR")
                return False
        except FileNotFoundError:
            self.log("❌ Flutter nicht im PATH gefunden", "ERROR")
            return False
        
        self.log("✅ Alle Voraussetzungen erfüllt", "SUCCESS")
        return True
    
    def extract_strings(self) -> Dict:
        """Extrahiert deutsche Strings"""
        self.log("🔍 Extrahiere deutsche Strings...")
        
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.output_dir / f"extraction_report_{timestamp}.md"
        json_file = self.output_dir / f"extraction_report_{timestamp}.json"
        problems_file = self.output_dir / f"extraction_problems_{timestamp}.json"
        
        command = [
            "python", str(self.tools_dir / "i18n_string_extractor.py"),
            "--output", str(report_file),
            "--json",
            "--problems"
        ]
        
        if self.config.fail_on_warnings:
            command.append("--fail-on-find")
        
        result = self.run_command(command, "String-Extraktion")
        
        # Lade Statistiken aus JSON
        stats = {"total_strings": 0, "high_confidence": 0, "files_scanned": 0}
        if json_file.exists():
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    stats["total_strings"] = len(data)
                    stats["high_confidence"] = len([s for s in data if s.get('confidence', 0) >= 0.8])
                    stats["files_scanned"] = len(set(s.get('file', '') for s in data))
                    
                    # Merke JSON-Datei für nächste Schritte
                    self.latest_extraction_json = json_file
                    
            except Exception as e:
                self.log(f"⚠️ Konnte Statistiken nicht laden: {e}", "WARNING")
        
        self.reports.extend([str(report_file), str(json_file), str(problems_file)])
        
        self.log(f"📊 Strings gefunden: {stats['total_strings']}", "SUCCESS")
        self.log(f"🔥 Hochkonfident (≥80%): {stats['high_confidence']}", "SUCCESS")
        
        return stats
    
    def convert_strings(self, extraction_json: Path) -> Dict:
        """Konvertiert Strings zu .arb-Format"""
        self.log("🔄 Konvertiere Strings zu .arb-Format...")
        
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.output_dir / f"conversion_report_{timestamp}.json"
        
        command = [
            "python", str(self.tools_dir / "i18n_arb_converter.py"),
            "--source", str(extraction_json),
            "--confidence", str(self.config.confidence_threshold),
            "--output-report", str(report_file)
        ]
        
        if self.config.auto_translate:
            command.append("--auto-translate")
        
        if self.config.update_code:
            command.append("--update-code")
        
        if not self.config.create_backups:
            command.append("--no-backup")
        
        result = self.run_command(command, "String-Konvertierung")
        
        # Lade Konvertierungs-Statistiken
        stats = {"converted": 0, "failed": 0, "code_replacements": 0}
        if report_file.exists():
            try:
                with open(report_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    stats.update(data.get('conversion_stats', {}))
                    stats.update(data.get('replacement_stats', {}))
            except Exception as e:
                self.log(f"⚠️ Konnte Konvertierungs-Statistiken nicht laden: {e}", "WARNING")
        
        self.reports.append(str(report_file))
        
        self.log(f"✅ Konvertiert: {stats.get('successful', 0)}", "SUCCESS")
        self.log(f"❌ Fehlgeschlagen: {stats.get('failed', 0)}", "SUCCESS")
        
        return stats
    
    def validate_arb_files(self) -> Dict:
        """Validiert .arb-Dateien"""
        self.log("🔍 Validiere .arb-Dateien...")
        
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        validation_dir = self.output_dir / f"validation_{timestamp}"
        validation_dir.mkdir(exist_ok=True)
        
        arb_files = list((self.client_root / "lib" / "l10n").glob("*.arb"))
        stats = {"files_validated": 0, "errors": 0, "warnings": 0}
        
        for arb_file in arb_files:
            self.log(f"Validiere {arb_file.name}...")
            
            report_file = validation_dir / f"{arb_file.stem}_validation.json"
            
            command = [
                "python", str(self.tools_dir / "arb_validator.py"),
                str(arb_file),
                "--json-report", str(report_file),
                "--quiet"
            ]
            
            # Referenz-Vergleich für deutsche Datei
            if arb_file.name == "app_de.arb":
                en_file = arb_file.parent / "app_en.arb"
                if en_file.exists():
                    command.extend(["--compare-to", str(en_file)])
            
            if self.config.fail_on_warnings:
                command.append("--fail-on-warning")
            
            result = self.run_command(command, f"Validierung {arb_file.name}")
            
            # Statistiken sammeln
            if report_file.exists():
                try:
                    with open(report_file, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        summary = data.get('summary', {})
                        stats["errors"] += summary.get('errors', 0)
                        stats["warnings"] += summary.get('warnings', 0)
                        
                except Exception as e:
                    self.log(f"⚠️ Validierungsbericht nicht lesbar: {e}", "WARNING")
            
            stats["files_validated"] += 1
            self.reports.append(str(report_file))
        
        self.log(f"📊 Dateien validiert: {stats['files_validated']}", "SUCCESS")
        if stats["errors"] > 0:
            self.log(f"❌ Fehler gefunden: {stats['errors']}", "ERROR")
        if stats["warnings"] > 0:
            self.log(f"⚠️ Warnungen: {stats['warnings']}", "WARNING")
        
        return stats
    
    def run_flutter_commands(self) -> Dict:
        """Führt Flutter-Befehle aus"""
        self.log("🦋 Führe Flutter-Befehle aus...")
        
        stats = {"pub_get": False, "gen_l10n": False, "analyze": False}
        
        # flutter pub get
        result = self.run_command(["flutter", "pub", "get"], "flutter pub get")
        stats["pub_get"] = result.returncode == 0
        
        # flutter gen-l10n
        result = self.run_command(["flutter", "gen-l10n"], "flutter gen-l10n")
        stats["gen_l10n"] = result.returncode == 0
        
        # flutter analyze (optional)
        result = self.run_command(["flutter", "analyze", "--no-fatal-infos"], "flutter analyze")
        stats["analyze"] = result.returncode == 0
        
        return stats
    
    def generate_workflow_report(self, result: WorkflowResult) -> Path:
        """Generiert einen zusammenfassenden Workflow-Report"""
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.output_dir / f"workflow_report_{result.mode}_{timestamp}.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(asdict(result), f, indent=2, ensure_ascii=False)
        
        # Markdown-Summary
        md_file = report_file.with_suffix('.md')
        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(f"# 🌍 Weltenwind i18n Workflow Report\n\n")
            f.write(f"**Modus:** {result.mode}\n")
            f.write(f"**Zeitstempel:** {result.timestamp}\n")
            f.write(f"**Status:** {'✅ Erfolgreich' if result.success else '❌ Fehlgeschlagen'}\n\n")
            
            f.write("## 📊 Statistiken\n\n")
            f.write("### String-Extraktion\n")
            for key, value in result.extraction_stats.items():
                f.write(f"- **{key}**: {value}\n")
            
            f.write("\n### Konvertierung\n")
            for key, value in result.conversion_stats.items():
                f.write(f"- **{key}**: {value}\n")
            
            f.write("\n### Validierung\n")
            for key, value in result.validation_stats.items():
                f.write(f"- **{key}**: {value}\n")
            
            if result.errors:
                f.write("\n## ❌ Fehler\n\n")
                for error in result.errors:
                    f.write(f"- {error}\n")
            
            if result.warnings:
                f.write("\n## ⚠️ Warnungen\n\n")
                for warning in result.warnings:
                    f.write(f"- {warning}\n")
            
            f.write(f"\n## 📁 Generierte Reports\n\n")
            for report in result.reports_generated:
                f.write(f"- `{report}`\n")
        
        self.log(f"📄 Workflow-Report: {report_file.name}", "SUCCESS")
        return report_file
    
    def run_scan_mode(self) -> WorkflowResult:
        """Modus: Nur String-Scanning"""
        self.log("🚀 Starte SCAN-Modus", "SUCCESS")
        
        extraction_stats = self.extract_strings()
        
        return WorkflowResult(
            success=len(self.errors) == 0,
            mode="scan",
            timestamp=datetime.datetime.now().isoformat(),
            extraction_stats=extraction_stats,
            conversion_stats={},
            validation_stats={},
            errors=self.errors.copy(),
            warnings=self.warnings.copy(),
            reports_generated=self.reports.copy()
        )
    
    def run_convert_mode(self) -> WorkflowResult:
        """Modus: Vollständige Konvertierung"""
        self.log("🚀 Starte CONVERT-Modus", "SUCCESS")
        
        # 1. String-Extraktion
        extraction_stats = self.extract_strings()
        if not hasattr(self, 'latest_extraction_json'):
            self.log("❌ Keine Extraktions-JSON gefunden", "ERROR")
            return self._create_failed_result("convert")
        
        # 2. Konvertierung
        conversion_stats = self.convert_strings(self.latest_extraction_json)
        
        # 3. Validierung
        validation_stats = self.validate_arb_files()
        
        # 4. Flutter-Befehle
        flutter_stats = {}
        if self.config.run_flutter_commands:
            flutter_stats = self.run_flutter_commands()
        
        return WorkflowResult(
            success=len(self.errors) == 0,
            mode="convert",
            timestamp=datetime.datetime.now().isoformat(),
            extraction_stats=extraction_stats,
            conversion_stats={**conversion_stats, **flutter_stats},
            validation_stats=validation_stats,
            errors=self.errors.copy(),
            warnings=self.warnings.copy(),
            reports_generated=self.reports.copy()
        )
    
    def run_update_mode(self) -> WorkflowResult:
        """Modus: Update bestehender Übersetzungen"""
        self.log("🚀 Starte UPDATE-Modus", "SUCCESS")
        
        # Niedrigere Konfidenz-Schwelle für Updates
        original_threshold = self.config.confidence_threshold
        self.config.confidence_threshold = max(0.6, original_threshold - 0.1)
        self.log(f"📊 Konfidenz-Schwelle für Update: {self.config.confidence_threshold}")
        
        result = self.run_convert_mode()
        result.mode = "update"
        
        # Ursprüngliche Schwelle wiederherstellen
        self.config.confidence_threshold = original_threshold
        
        return result
    
    def run_ci_mode(self) -> WorkflowResult:
        """Modus: CI/CD Pipeline"""
        self.log("🚀 Starte CI-Modus", "SUCCESS")
        
        # CI-spezifische Konfiguration
        self.config.fail_on_warnings = True
        self.config.create_backups = False
        self.config.update_code = False  # Sicherheit in CI
        
        # Nur Scanning + Validierung
        extraction_stats = self.extract_strings()
        validation_stats = self.validate_arb_files()
        
        return WorkflowResult(
            success=len(self.errors) == 0,
            mode="ci",
            timestamp=datetime.datetime.now().isoformat(),
            extraction_stats=extraction_stats,
            conversion_stats={},
            validation_stats=validation_stats,
            errors=self.errors.copy(),
            warnings=self.warnings.copy(),
            reports_generated=self.reports.copy()
        )
    
    def _create_failed_result(self, mode: str) -> WorkflowResult:
        """Erstellt ein fehlgeschlagenes Ergebnis"""
        return WorkflowResult(
            success=False,
            mode=mode,
            timestamp=datetime.datetime.now().isoformat(),
            extraction_stats={},
            conversion_stats={},
            validation_stats={},
            errors=self.errors.copy(),
            warnings=self.warnings.copy(),
            reports_generated=self.reports.copy()
        )

def main():
    parser = argparse.ArgumentParser(description='Weltenwind i18n Master Workflow')
    parser.add_argument('--mode', required=True,
                       choices=['scan', 'convert', 'update', 'ci'],
                       help='Workflow-Modus')
    parser.add_argument('--confidence', type=float, default=0.8,
                       help='Konfidenz-Schwelle für String-Konvertierung')
    parser.add_argument('--auto-translate', action='store_true', default=True,
                       help='Automatische englische Übersetzungen')
    parser.add_argument('--update-code', action='store_true',
                       help='Dart-Code automatisch aktualisieren')
    parser.add_argument('--no-backups', action='store_true',
                       help='Keine Backups erstellen')
    parser.add_argument('--no-flutter', action='store_true',
                       help='Flutter-Befehle überspringen')
    parser.add_argument('--fail-on-warnings', action='store_true',
                       help='Bei Warnungen fehlschlagen (CI-Modus)')
    parser.add_argument('--output-dir', default='tools/workflow_reports',
                       help='Ausgabe-Verzeichnis für Reports')
    
    args = parser.parse_args()
    
    # Konfiguration erstellen
    config = WorkflowConfig(
        confidence_threshold=args.confidence,
        auto_translate=args.auto_translate,
        update_code=args.update_code,
        create_backups=not args.no_backups,
        run_flutter_commands=not args.no_flutter,
        fail_on_warnings=args.fail_on_warnings,
        output_dir=args.output_dir
    )
    
    # Workflow starten
    workflow = I18nWorkflow(config)
    
    print("🌍 Weltenwind i18n Master Workflow")
    print("=" * 60)
    
    # Voraussetzungen prüfen
    if not workflow.check_prerequisites():
        sys.exit(1)
    
    # Je nach Modus ausführen
    if args.mode == 'scan':
        result = workflow.run_scan_mode()
    elif args.mode == 'convert':
        result = workflow.run_convert_mode()
    elif args.mode == 'update':
        result = workflow.run_update_mode()
    elif args.mode == 'ci':
        result = workflow.run_ci_mode()
    
    # Abschlussbericht
    report_file = workflow.generate_workflow_report(result)
    
    print("\n" + "=" * 60)
    print("📊 WORKFLOW ABGESCHLOSSEN")
    print("=" * 60)
    print(f"🎯 Modus: {result.mode.upper()}")
    print(f"✅ Status: {'Erfolgreich' if result.success else 'Fehlgeschlagen'}")
    print(f"📄 Report: {report_file.name}")
    
    if result.errors:
        print(f"❌ Fehler: {len(result.errors)}")
    if result.warnings:
        print(f"⚠️ Warnungen: {len(result.warnings)}")
    
    # Exit-Code setzen
    sys.exit(0 if result.success else 1)

if __name__ == "__main__":
    main() 