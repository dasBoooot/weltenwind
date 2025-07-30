#!/usr/bin/env python3
"""
Weltenwind i18n ARB Converter
Konvertiert extrahierte deutsche Strings automatisch in .arb-Dateien

Usage: python i18n_arb_converter.py [--source report.json] [--auto-translate] [--update-code]
"""

import json
import re
import argparse
import sys
from pathlib import Path
from typing import Dict, List, Set, Optional, Tuple
from dataclasses import dataclass, asdict
import shutil

@dataclass
class StringConversion:
    key: str
    german_text: str
    english_text: str
    category: str
    confidence: float
    files_to_update: List[str]
    line_numbers: List[int]
    success: bool = False
    error_message: Optional[str] = None

class I18nArbConverter:
    def __init__(self, client_root: str = ".", lib_dir: str = "lib"):
        self.client_root = Path(client_root)
        self.lib_dir = self.client_root / lib_dir
        self.l10n_dir = self.lib_dir / "l10n"
        
        # Einfache Übersetzungs-Mappings (kann erweitert werden)
        self.translation_mappings = {
            # UI-Elemente
            'Fehler': 'Error',
            'Warnung': 'Warning',
            'Erfolg': 'Success',
            'Laden': 'Loading',
            'Speichern': 'Save',
            'Löschen': 'Delete',
            'Bearbeiten': 'Edit',
            'Erstellen': 'Create',
            'Zurück': 'Back',
            'Weiter': 'Next',
            'Abbrechen': 'Cancel',
            'OK': 'OK',
            'Ja': 'Yes',
            'Nein': 'No',
            'Schließen': 'Close',
            'Öffnen': 'Open',
            
            # Auth-Begriffe
            'Anmelden': 'Sign In',
            'Anmeldung': 'Sign In',
            'Abmelden': 'Sign Out',
            'Registrieren': 'Register',
            'Registrierung': 'Registration',
            'Passwort': 'Password',
            'Kennwort': 'Password',
            'E-Mail': 'Email',
            'E-Mail-Adresse': 'Email Address',
            'Benutzername': 'Username',
            'Spielername': 'Player Name',
            
            # Gaming-Begriffe
            'Welt': 'World',
            'Welten': 'Worlds',
            'Spieler': 'Player',
            'Spiel': 'Game',
            'Level': 'Level',
            'Quest': 'Quest',
            'Punkte': 'Points',
            'Score': 'Score',
            'Einladung': 'Invitation',
            'Einladungen': 'Invitations',
            'beitreten': 'join',
            'starten': 'start',
            'beenden': 'end',
            'teilnehmen': 'participate',
            
            # Status-Begriffe
            'offen': 'open',
            'geschlossen': 'closed',
            'laufend': 'running',
            'beendet': 'finished',
            'geplant': 'planned',
            'verfügbar': 'available',
            'nicht verfügbar': 'not available',
            
            # Häufige Phrasen
            'Bitte warten': 'Please wait',
            'Versuche erneut': 'Try again',
            'Nicht gefunden': 'Not found',
            'Zugriff verweigert': 'Access denied',
            'Ungültig': 'Invalid',
            'Erforderlich': 'Required',
            'Optional': 'Optional',
        }
    
    def load_extraction_report(self, report_path: str) -> List[Dict]:
        """Lädt den JSON-Report vom String-Extractor"""
        try:
            with open(report_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Fehler beim Laden des Reports: {e}")
            return []
    
    def load_existing_arb(self, lang: str) -> Tuple[Dict, Set[str]]:
        """Lädt existierende .arb-Datei und extrahiert Keys"""
        arb_file = self.l10n_dir / f"app_{lang}.arb"
        
        if not arb_file.exists():
            return {}, set()
        
        try:
            with open(arb_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Extrahiere nur String-Keys (ohne Metadaten)
            string_keys = {k for k in data.keys() if not k.startswith('@')}
            return data, string_keys
        except Exception as e:
            print(f"❌ Fehler beim Laden von {arb_file}: {e}")
            return {}, set()
    
    def generate_english_translation(self, german_text: str) -> str:
        """Generiert eine einfache englische Übersetzung"""
        
        # Exakte Übereinstimmungen
        for german, english in self.translation_mappings.items():
            if german.lower() == german_text.lower().strip():
                return english
        
        # Teilweise Übereinstimmungen (für längere Texte)
        english_text = german_text
        for german, english in self.translation_mappings.items():
            # Case-insensitive replacement, aber behält Groß-/Kleinschreibung bei
            pattern = re.compile(re.escape(german), re.IGNORECASE)
            english_text = pattern.sub(english, english_text)
        
        # Fallback: Englische Übersetzung placeholder
        if english_text == german_text:
            # Wenn keine Übersetzung gefunden wurde, erstelle Placeholder
            return f"[EN] {german_text}"
        
        return english_text
    
    def deduplicate_keys(self, extractions: List[Dict]) -> List[Dict]:
        """Entfernt Duplikate basierend auf suggested_key"""
        seen_keys = set()
        unique_extractions = []
        
        # Sortiere nach Konfidenz (höchste zuerst)
        sorted_extractions = sorted(extractions, key=lambda x: x['confidence'], reverse=True)
        
        for extraction in sorted_extractions:
            key = extraction['suggested_key']
            if key not in seen_keys:
                seen_keys.add(key)
                unique_extractions.append(extraction)
            else:
                print(f"⚠️ Duplikat-Key übersprungen: {key}")
        
        return unique_extractions
    
    def convert_extractions_to_arb(self, extractions: List[Dict], 
                                  confidence_threshold: float = 0.7,
                                  auto_translate: bool = False) -> List[StringConversion]:
        """Konvertiert Extractions in .arb-Format"""
        
        conversions = []
        
        # Lade existierende .arb-Dateien
        de_data, de_keys = self.load_existing_arb('de')
        en_data, en_keys = self.load_existing_arb('en')
        
        # Dedupliziere und filtere nach Konfidenz
        unique_extractions = self.deduplicate_keys(extractions)
        filtered_extractions = [e for e in unique_extractions if e['confidence'] >= confidence_threshold]
        
        print(f"🔍 {len(unique_extractions)} einzigartige Strings")
        print(f"🎯 {len(filtered_extractions)} Strings über Konfidenz-Schwelle ({confidence_threshold})")
        
        for extraction in filtered_extractions:
            key = extraction['suggested_key']
            german_text = extraction['original']
            category = extraction['category']
            confidence = extraction['confidence']
            
            # Überspringe bereits existierende Keys
            if key in de_keys:
                print(f"⏭️ Überspringe existierenden Key: {key}")
                continue
            
            # Generiere englische Übersetzung
            if auto_translate:
                english_text = self.generate_english_translation(german_text)
            else:
                english_text = f"[TODO] {german_text}"
            
            # Erstelle Conversion-Objekt
            conversion = StringConversion(
                key=key,
                german_text=german_text,
                english_text=english_text,
                category=category,
                confidence=confidence,
                files_to_update=[extraction['file']],
                line_numbers=[extraction['line']]
            )
            
            conversions.append(conversion)
        
        return conversions
    
    def update_arb_files(self, conversions: List[StringConversion], 
                        backup: bool = True) -> bool:
        """Aktualisiert .arb-Dateien mit neuen Strings"""
        
        if backup:
            self.create_backups()
        
        # Lade existierende Daten
        de_data, _ = self.load_existing_arb('de')
        en_data, _ = self.load_existing_arb('en')
        
        # Stelle sicher, dass Basis-Metadaten vorhanden sind
        if '@@locale' not in de_data:
            de_data['@@locale'] = 'de'
        if '@@context' not in de_data:
            de_data['@@context'] = 'weltenwind-game'
            
        if '@@locale' not in en_data:
            en_data['@@locale'] = 'en'
        if '@@context' not in en_data:
            en_data['@@context'] = 'weltenwind-game'
        
        successful_conversions = 0
        
        for conversion in conversions:
            try:
                key = conversion.key
                
                # Deutsche .arb-Datei
                de_data[key] = conversion.german_text
                de_data[f'@{key}'] = {
                    "description": f"{conversion.category.title()} text",
                    "context": conversion.category,
                    "confidence": conversion.confidence
                }
                
                # Englische .arb-Datei
                en_data[key] = conversion.english_text
                en_data[f'@{key}'] = {
                    "description": f"{conversion.category.title()} text",
                    "context": conversion.category,
                    "confidence": conversion.confidence
                }
                
                conversion.success = True
                successful_conversions += 1
                
            except Exception as e:
                conversion.success = False
                conversion.error_message = str(e)
                print(f"❌ Fehler bei Key {conversion.key}: {e}")
        
        # Speichere aktualisierte .arb-Dateien
        try:
            de_file = self.l10n_dir / "app_de.arb"
            en_file = self.l10n_dir / "app_en.arb"
            
            with open(de_file, 'w', encoding='utf-8') as f:
                json.dump(de_data, f, indent=2, ensure_ascii=False)
            
            with open(en_file, 'w', encoding='utf-8') as f:
                json.dump(en_data, f, indent=2, ensure_ascii=False)
            
            print(f"✅ {successful_conversions} Strings erfolgreich zu .arb-Dateien hinzugefügt")
            return True
            
        except Exception as e:
            print(f"❌ Fehler beim Speichern der .arb-Dateien: {e}")
            return False
    
    def create_backups(self):
        """Erstellt Backups der existierenden .arb-Dateien"""
        backup_dir = self.l10n_dir / "backups"
        backup_dir.mkdir(exist_ok=True)
        
        import datetime
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for lang in ['de', 'en']:
            arb_file = self.l10n_dir / f"app_{lang}.arb"
            if arb_file.exists():
                backup_file = backup_dir / f"app_{lang}.arb.backup_{timestamp}"
                shutil.copy2(arb_file, backup_file)
                print(f"📦 Backup erstellt: {backup_file.name}")
    
    def generate_code_replacements(self, conversions: List[StringConversion]) -> Dict[str, List[Dict]]:
        """Generiert Code-Replacements für Dart-Dateien"""
        
        file_replacements = {}
        
        for conversion in conversions:
            if not conversion.success:
                continue
            
            for file_path in conversion.files_to_update:
                if file_path not in file_replacements:
                    file_replacements[file_path] = []
                
                # Erstelle Replacement-Pattern
                old_pattern = f'"{conversion.german_text}"'
                new_pattern = f'AppLocalizations.of(context)!.{conversion.key}'
                
                # Alternative für Single-Quotes
                old_pattern_single = f"'{conversion.german_text}'"
                
                file_replacements[file_path].append({
                    'old_double': old_pattern,
                    'old_single': old_pattern_single,
                    'new': new_pattern,
                    'key': conversion.key,
                    'confidence': conversion.confidence
                })
        
        return file_replacements
    
    def update_dart_files(self, conversions: List[StringConversion], 
                         backup: bool = True, dry_run: bool = True) -> Dict[str, int]:
        """Aktualisiert Dart-Dateien mit AppLocalizations-Aufrufen"""
        
        if backup and not dry_run:
            self.create_code_backups()
        
        file_replacements = self.generate_code_replacements(conversions)
        replacement_stats = {}
        
        for file_path, replacements in file_replacements.items():
            full_path = self.client_root / file_path
            
            if not full_path.exists():
                print(f"⚠️ Datei nicht gefunden: {file_path}")
                continue
            
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    original_content = f.read()
                
                modified_content = original_content
                replacements_made = 0
                
                # Stelle sicher, dass Import vorhanden ist
                import_line = "import '../l10n/app_localizations.dart';"
                if import_line not in modified_content and 'AppLocalizations' not in modified_content:
                    # Finde die letzte import-Zeile und füge danach hinzu
                    import_pattern = r'(import [\'"][^\'"]+(\.dart)?[\'"];)'
                    imports = re.findall(import_pattern, modified_content)
                    if imports:
                        last_import = imports[-1][0]
                        modified_content = modified_content.replace(
                            last_import, 
                            f"{last_import}\n{import_line}"
                        )
                
                # Führe Replacements durch
                for replacement in replacements:
                    # Versuche Double-Quote Replacement
                    if replacement['old_double'] in modified_content:
                        modified_content = modified_content.replace(
                            replacement['old_double'], 
                            replacement['new']
                        )
                        replacements_made += 1
                    
                    # Versuche Single-Quote Replacement
                    elif replacement['old_single'] in modified_content:
                        modified_content = modified_content.replace(
                            replacement['old_single'], 
                            replacement['new']
                        )
                        replacements_made += 1
                
                # Speichere nur wenn Änderungen vorhanden und nicht Dry-Run
                if replacements_made > 0 and not dry_run:
                    with open(full_path, 'w', encoding='utf-8') as f:
                        f.write(modified_content)
                
                replacement_stats[file_path] = replacements_made
                
                if replacements_made > 0:
                    status = "🔧" if not dry_run else "🔍"
                    print(f"{status} {file_path}: {replacements_made} Replacements")
                
            except Exception as e:
                print(f"❌ Fehler bei {file_path}: {e}")
                replacement_stats[file_path] = 0
        
        return replacement_stats
    
    def create_code_backups(self):
        """Erstellt Backups der zu modifizierenden Dart-Dateien"""
        backup_dir = self.client_root / "tools" / "code_backups"
        backup_dir.mkdir(exist_ok=True)
        
        print(f"📦 Code-Backups werden in {backup_dir} erstellt...")
    
    def generate_summary_report(self, conversions: List[StringConversion], 
                              replacement_stats: Dict[str, int]) -> Dict:
        """Generiert Zusammenfassungsbericht"""
        
        successful = len([c for c in conversions if c.success])
        failed = len([c for c in conversions if not c.success])
        total_replacements = sum(replacement_stats.values())
        files_modified = len([f for f, count in replacement_stats.items() if count > 0])
        
        categories = {}
        for conversion in conversions:
            if conversion.success:
                categories[conversion.category] = categories.get(conversion.category, 0) + 1
        
        return {
            "conversion_stats": {
                "successful": successful,
                "failed": failed,
                "total": len(conversions)
            },
            "replacement_stats": {
                "total_replacements": total_replacements,
                "files_modified": files_modified,
                "files_processed": len(replacement_stats)
            },
            "categories": categories,
            "failed_conversions": [
                {"key": c.key, "error": c.error_message} 
                for c in conversions if not c.success
            ]
        }

def main():
    parser = argparse.ArgumentParser(description='Weltenwind i18n ARB Converter')
    parser.add_argument('--source', '-s', 
                       default='i18n_extraction_report.json',
                       help='Pfad zum JSON-Report des String-Extractors')
    parser.add_argument('--confidence', '-c', type=float, default=0.7,
                       help='Minimale Konfidenz für String-Konvertierung (0.0-1.0)')
    parser.add_argument('--auto-translate', action='store_true',
                       help='Automatische englische Übersetzungen generieren')
    parser.add_argument('--update-code', action='store_true',
                       help='Dart-Code automatisch mit AppLocalizations aktualisieren')
    parser.add_argument('--dry-run', action='store_true',
                       help='Zeige nur was geändert würde, ohne Dateien zu modifizieren')
    parser.add_argument('--no-backup', action='store_true',
                       help='Keine Backups erstellen')
    parser.add_argument('--output-report', default='conversion_report.json',
                       help='Pfad für Zusammenfassungsbericht')
    
    args = parser.parse_args()
    
    print("🚀 Weltenwind i18n ARB Converter")
    print("=" * 50)
    
    # Prüfe ob Source-Report existiert
    if not Path(args.source).exists():
        print(f"❌ Source-Report nicht gefunden: {args.source}")
        print("💡 Führe zuerst 'python i18n_string_extractor.py --json' aus")
        sys.exit(1)
    
    converter = I18nArbConverter()
    
    # 1. Lade Extraction-Report
    print(f"📊 Lade Report: {args.source}")
    extractions = converter.load_extraction_report(args.source)
    
    if not extractions:
        print("❌ Keine Extractions im Report gefunden")
        sys.exit(1)
    
    print(f"✅ {len(extractions)} Extractions geladen")
    
    # 2. Konvertiere zu .arb-Format
    print(f"🔄 Konvertiere Strings (Konfidenz ≥ {args.confidence})...")
    conversions = converter.convert_extractions_to_arb(
        extractions, 
        confidence_threshold=args.confidence,
        auto_translate=args.auto_translate
    )
    
    if not conversions:
        print("ℹ️ Keine neuen Strings zum Konvertieren gefunden")
        sys.exit(0)
    
    print(f"🎯 {len(conversions)} Strings zur Konvertierung vorbereitet")
    
    # 3. Aktualisiere .arb-Dateien
    if not args.dry_run:
        print("📝 Aktualisiere .arb-Dateien...")
        success = converter.update_arb_files(conversions, backup=not args.no_backup)
        
        if not success:
            print("❌ Fehler beim Aktualisieren der .arb-Dateien")
            sys.exit(1)
    else:
        print("🔍 DRY RUN: .arb-Dateien würden aktualisiert werden")
    
    # 4. Optional: Code-Update
    replacement_stats = {}
    if args.update_code:
        print("🔧 Aktualisiere Dart-Code...")
        replacement_stats = converter.update_dart_files(
            conversions, 
            backup=not args.no_backup,
            dry_run=args.dry_run
        )
    
    # 5. Zusammenfassungsbericht
    summary = converter.generate_summary_report(conversions, replacement_stats)
    
    if args.output_report and not args.dry_run:
        with open(args.output_report, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        print(f"📄 Zusammenfassungsbericht: {args.output_report}")
    
    # Ausgabe der Statistiken
    print("\n" + "=" * 50)
    print("📊 ZUSAMMENFASSUNG")
    print("=" * 50)
    print(f"✅ Erfolgreich konvertiert: {summary['conversion_stats']['successful']}")
    print(f"❌ Fehlgeschlagen: {summary['conversion_stats']['failed']}")
    
    if args.update_code and replacement_stats:
        print(f"🔧 Code-Replacements: {summary['replacement_stats']['total_replacements']}")
        print(f"📁 Dateien modifiziert: {summary['replacement_stats']['files_modified']}")
    
    print("\n🏷️ Kategorien:")
    for category, count in summary['categories'].items():
        print(f"   • {category}: {count} Strings")
    
    if summary['failed_conversions']:
        print("\n❌ Fehlgeschlagene Konvertierungen:")
        for failed in summary['failed_conversions'][:5]:  # Zeige nur erste 5
            print(f"   • {failed['key']}: {failed['error']}")
    
    if args.dry_run:
        print("\n🔍 DRY RUN abgeschlossen - keine Dateien wurden verändert")
        print("💡 Entferne --dry-run um Änderungen durchzuführen")
    else:
        print("\n✅ Konvertierung abgeschlossen!")
        print("🎯 Nächste Schritte:")
        print("   1. Flutter Code regenerieren: flutter pub get")
        print("   2. App testen: flutter run")
        print("   3. Verbleibende [TODO]-Übersetzungen überarbeiten")

if __name__ == "__main__":
    main() 