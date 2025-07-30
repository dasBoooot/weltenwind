#!/usr/bin/env python3
"""
Weltenwind .arb Validator (Enhanced)
Validiert .arb-Dateien für Syntax, Konsistenz und Best Practices

Usage: python arb_validator.py [file.arb] [--fix] [--strict] [--compare-to ref.arb]
"""

import json
import re
import argparse
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional, Union
from dataclasses import dataclass

# ✅ 3. YAML-Unterstützung (optional)
try:
    import yaml
    YAML_SUPPORT = True
except ImportError:
    YAML_SUPPORT = False

@dataclass
class ValidationError:
    severity: str  # 'error', 'warning', 'info'
    code: str
    message: str
    line: Optional[int] = None
    suggestion: Optional[str] = None
    file_path: Optional[str] = None

class ArbValidator:
    def __init__(self, strict_mode: bool = False):
        self.strict_mode = strict_mode
        self.errors: List[ValidationError] = []
        
        # Erlaubte Platzhalter-Patterns
        self.placeholder_patterns = [
            r'\{[a-zA-Z][a-zA-Z0-9_]*\}',  # {userName}
            r'\$\{[a-zA-Z][a-zA-Z0-9_]*\}',  # ${worldName}
            r'\{[a-zA-Z][a-zA-Z0-9_]*,[^}]+\}',  # {count, plural, =0{keine} =1{eine} other{#}}
        ]
        
        # Verbotene Zeichen/Patterns
        self.forbidden_patterns = [
            (r'<script', 'XSS-Risiko: <script> Tags sind verboten'),
            (r'javascript:', 'XSS-Risiko: javascript: URLs sind verboten'),
            (r'[^\x00-\x7F\u00C0-\u017F\u2000-\u206F\u2070-\u209F\u20A0-\u20CF\u2100-\u214F\u2190-\u21FF]', 'Unerlaubte Unicode-Zeichen'),
        ]
        
        # Gaming-spezifische Begriffe (Konsistenz)
        self.gaming_terms = {
            'player': ['Spieler', 'Player'],
            'world': ['Welt', 'World'], 
            'game': ['Spiel', 'Game'],
            'level': ['Level', 'Stufe'],
            'quest': ['Quest', 'Aufgabe'],
            'guild': ['Gilde', 'Guild'],
            'invite': ['Einladung', 'Invite']
        }
        
        # ✅ 5. Empfehlungssystem: Kontextuelle Vorschläge
        self.term_suggestions = {
            # Inkonsistente Begriffe
            'Weltkarte': 'Verwende konsistent "Karte" oder "Map"',
            'Spielstart': 'Nutze einheitlich "Spielbeginn"',
            'Benutzer': 'Verwende "Spieler" für Gaming-Kontext',
            'User': 'Verwende "Spieler" für Gaming-Kontext',
            'Passwort': 'Nutze "Kennwort" für Konsistenz',
            'E-Mail': 'Verwende "E-Mail-Adresse" vollständig',
            'Email': 'Schreibe "E-Mail" mit Bindestrich',
            'Okay': 'Verwende "OK" für Buttons',
            'ok': 'Verwende "OK" in Großbuchstaben',
            'Abbrechen': 'Nutze "Abbrechen" statt "Cancel"',
            'Cancel': 'Verwende "Abbrechen" auf Deutsch',
            # Gaming-spezifische Begriffe
            'Gamemaster': 'Verwende "Spielleiter"',
            'Admin': 'Nutze "Administrator" vollständig',
            'Lobby': 'Verwende "Wartebereich" oder behalten als "Lobby"',
            'Server': 'Nutze "Server" oder "Spielserver" je nach Kontext',
            # UI-Begriffe
            'Button': 'Verwende "Schaltfläche" oder "Taste"',
            'Click': 'Nutze "Klicken" oder "Antippen"',
            'Login': 'Verwende "Anmeldung"',
            'Logout': 'Nutze "Abmeldung"',
            'Settings': 'Verwende "Einstellungen"',
            'Options': 'Nutze "Optionen" oder "Einstellungen"',
        }

    def add_error(self, severity: str, code: str, message: str, 
                  line: Optional[int] = None, suggestion: Optional[str] = None,
                  file_path: Optional[str] = None):
        """Fügt einen Validierungsfehler hinzu"""
        self.errors.append(ValidationError(severity, code, message, line, suggestion, file_path))

    def load_file(self, filepath: str, yaml_mode: bool = False) -> Optional[Dict]:
        """Lädt .arb- oder .yaml-Datei"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                if yaml_mode and YAML_SUPPORT:
                    return yaml.safe_load(f)
                else:
                    return json.load(f)
        except json.JSONDecodeError as e:
            self.add_error('error', 'JSON_SYNTAX', 
                          f'JSON-Syntax-Fehler: {e.msg}', 
                          e.lineno,
                          'Überprüfe Kommata, Anführungszeichen und Klammern',
                          filepath)
            return None
        except yaml.YAMLError as e:
            self.add_error('error', 'YAML_SYNTAX',
                          f'YAML-Syntax-Fehler: {e}',
                          suggestion='Überprüfe Einrückung und Syntax',
                          file_path=filepath)
            return None
        except Exception as e:
            self.add_error('error', 'FILE_READ', 
                          f'Datei kann nicht gelesen werden: {e}',
                          file_path=filepath)
            return None

    def validate_json_syntax(self, content: str, filename: str) -> Optional[Dict]:
        """Validiert JSON-Syntax (Legacy-Support)"""
        return self.load_file(filename)

    def validate_arb_structure(self, data: Dict, filename: str):
        """Validiert ARB-spezifische Struktur"""
        
        # Locale-Check
        if '@@locale' not in data:
            self.add_error('error', 'MISSING_LOCALE', 
                          'Fehlende @@locale-Angabe',
                          suggestion='Füge "@@locale": "de" hinzu',
                          file_path=filename)
        
        # Context-Check
        if '@@context' not in data:
            self.add_error('warning', 'MISSING_CONTEXT',
                          'Fehlende @@context-Angabe',
                          suggestion='Füge "@@context": "weltenwind-game" hinzu',
                          file_path=filename)
        
        # String-Keys validieren
        string_keys = {k for k in data.keys() if not k.startswith('@')}
        metadata_keys = {k for k in data.keys() if k.startswith('@') and not k.startswith('@@')}
        
        # Prüfe ob jeder String-Key Metadaten hat
        for key in string_keys:
            meta_key = f'@{key}'
            if meta_key not in metadata_keys:
                self.add_error('warning', 'MISSING_METADATA',
                              f'Fehlende Metadaten für "{key}"',
                              suggestion=f'Füge "@{key}": {{"description": "...", "context": "..."}} hinzu',
                              file_path=filename)

    def validate_key_naming(self, data: Dict, filename: str):
        """Validiert Key-Naming-Conventions"""
        
        # Erlaubtes Pattern: camelCase mit Kategorie-Prefix
        valid_pattern = re.compile(r'^[a-z]+[A-Z][a-zA-Z0-9]*$')
        
        # Bekannte Kategorien
        known_categories = {
            'app', 'auth', 'world', 'invite', 'error', 'button', 'dialog', 
            'form', 'navigation', 'ui', 'common'
        }
        
        string_keys = [k for k in data.keys() if not k.startswith('@')]
        
        for key in string_keys:
            # Pattern-Check
            if not valid_pattern.match(key):
                self.add_error('warning', 'KEY_NAMING',
                              f'Key "{key}" folgt nicht camelCase-Convention',
                              suggestion='Verwende camelCase: z.B. "authLoginButton"',
                              file_path=filename)
            
            # Kategorie-Check
            category_found = False
            for category in known_categories:
                if key.lower().startswith(category):
                    category_found = True
                    break
            
            if not category_found and self.strict_mode:
                self.add_error('info', 'UNKNOWN_CATEGORY',
                              f'Key "{key}" hat keine erkennbare Kategorie',
                              suggestion=f'Beginne mit: {", ".join(sorted(known_categories))}',
                              file_path=filename)

    def validate_placeholders(self, data: Dict, filename: str):
        """✅ 2. Erweiterte Platzhalter-Validierung mit Metadaten-Abgleich"""
        
        string_entries = {k: v for k, v in data.items() if not k.startswith('@')}
        
        for key, value in string_entries.items():
            if not isinstance(value, str):
                continue
                
            # Finde alle Platzhalter im String
            found_placeholders = set()
            for pattern in self.placeholder_patterns:
                matches = re.findall(pattern, value)
                for match in matches:
                    # Extrahiere Platzhalter-Namen
                    if match.startswith('{') and '}' in match:
                        placeholder_name = match.split(',')[0].strip('{}').strip('$')
                        found_placeholders.add(placeholder_name)
            
            # Validiere jeden Platzhalter
            for placeholder in found_placeholders:
                # Prüfe auf leere Platzhalter
                if not placeholder:
                    self.add_error('error', 'EMPTY_PLACEHOLDER',
                                  f'Leerer Platzhalter in "{key}"',
                                  suggestion='Gib dem Platzhalter einen Namen: {userName}',
                                  file_path=filename)
            
            # ✅ 2. Platzhalter-Abgleich mit Metadaten
            meta_key = f'@{key}'
            if meta_key in data and isinstance(data[meta_key], dict):
                metadata = data[meta_key]
                if 'placeholders' in metadata:
                    defined_placeholders = set(metadata['placeholders'].keys())
                    
                    # Prüfe fehlende Definitionen
                    missing_definitions = found_placeholders - defined_placeholders
                    for missing in missing_definitions:
                        self.add_error('warning', 'PLACEHOLDER_NOT_DEFINED',
                                      f'Platzhalter "{missing}" in "{key}" nicht in Metadaten definiert',
                                      suggestion=f'Füge "{missing}": {{"type": "String"}} zu placeholders hinzu',
                                      file_path=filename)
                    
                    # Prüfe überflüssige Definitionen
                    extra_definitions = defined_placeholders - found_placeholders
                    for extra in extra_definitions:
                        self.add_error('warning', 'UNUSED_PLACEHOLDER_DEFINITION',
                                      f'Platzhalter "{extra}" in Metadaten definiert, aber nicht in "{key}" verwendet',
                                      suggestion=f'Entferne "{extra}" aus placeholders oder verwende ihn im String',
                                      file_path=filename)

    def validate_consistency(self, data: Dict, filename: str):
        """Prüft Konsistenz zwischen ähnlichen Strings"""
        
        string_entries = {k: v for k, v in data.items() if not k.startswith('@')}
        
        # Gruppiere ähnliche Keys
        key_groups = {}
        for key in string_entries.keys():
            # Extrahiere Basis (ohne Suffix wie Button, Title, etc.)
            base = re.sub(r'(Button|Title|Label|Text|Message|Error)$', '', key)
            if base not in key_groups:
                key_groups[base] = []
            key_groups[base].append(key)
        
        # Prüfe Gaming-Term-Konsistenz
        for english_term, german_variants in self.gaming_terms.items():
            found_variants = set()
            
            for key, value in string_entries.items():
                for variant in german_variants:
                    if variant.lower() in value.lower():
                        found_variants.add(variant)
            
            # Warnung bei mehreren Varianten
            if len(found_variants) > 1:
                self.add_error('warning', 'INCONSISTENT_TERMS',
                              f'Inkonsistente Übersetzung für "{english_term}": {", ".join(found_variants)}',
                              suggestion=f'Einheitlich verwenden: {german_variants[0]}',
                              file_path=filename)

    def validate_term_suggestions(self, data: Dict, filename: str):
        """✅ 5. Empfehlungssystem für bessere Terminologie"""
        
        string_entries = {k: v for k, v in data.items() if not k.startswith('@')}
        
        for key, value in string_entries.items():
            if not isinstance(value, str):
                continue
            
            # Prüfe auf verbesserungswürdige Begriffe
            for term, suggestion in self.term_suggestions.items():
                if term.lower() in value.lower():
                    self.add_error('info', 'TERM_SUGGESTION',
                                  f'Verbesserungsvorschlag für "{key}": Gefunden "{term}"',
                                  suggestion=suggestion,
                                  file_path=filename)

    def validate_security(self, data: Dict, filename: str):
        """Prüft auf Sicherheitsrisiken"""
        
        string_entries = {k: v for k, v in data.items() if not k.startswith('@')}
        
        for key, value in string_entries.items():
            if not isinstance(value, str):
                continue
                
            # Prüfe verbotene Patterns
            for pattern, message in self.forbidden_patterns:
                if re.search(pattern, value, re.IGNORECASE):
                    self.add_error('error', 'SECURITY_RISK',
                                  f'Sicherheitsrisiko in "{key}": {message}',
                                  suggestion='Entferne den problematischen Inhalt',
                                  file_path=filename)
            
            # Prüfe auf potentielle Code-Injection
            suspicious_patterns = ['eval(', 'function(', '=>', 'import ', 'require(']
            for pattern in suspicious_patterns:
                if pattern in value:
                    self.add_error('warning', 'SUSPICIOUS_CONTENT',
                                  f'Verdächtiger Inhalt in "{key}": {pattern}',
                                  suggestion='Überprüfe ob das wirklich Übersetzungstext ist',
                                  file_path=filename)

    def validate_length_limits(self, data: Dict, filename: str):
        """Prüft String-Längen für UI-Kompatibilität"""
        
        # UI-Element-spezifische Längengrenzen
        length_limits = {
            'button': 25,
            'title': 50,
            'label': 30,
            'error': 200,
            'message': 300
        }
        
        string_entries = {k: v for k, v in data.items() if not k.startswith('@')}
        
        for key, value in string_entries.items():
            if not isinstance(value, str):
                continue
                
            # Bestimme erwartete Maximallänge
            max_length = 100  # Default
            for ui_type, limit in length_limits.items():
                if ui_type.lower() in key.lower():
                    max_length = limit
                    break
            
            # Prüfe Länge (ohne Platzhalter)
            text_without_placeholders = re.sub(r'\{[^}]+\}', 'XX', value)
            if len(text_without_placeholders) > max_length:
                self.add_error('warning', 'TEXT_TOO_LONG',
                              f'Text zu lang für "{key}": {len(text_without_placeholders)} > {max_length} Zeichen',
                              suggestion='Kürze den Text für bessere UI-Darstellung',
                              file_path=filename)

    def compare_with_reference(self, file_path: str, reference_path: str, yaml_mode: bool = False):
        """✅ 1. Sprachvergleich mit Referenzdatei"""
        
        # Lade beide Dateien
        data = self.load_file(file_path, yaml_mode)
        reference = self.load_file(reference_path, yaml_mode)
        
        if data is None or reference is None:
            return
        
        # Extrahiere String-Keys (ohne Metadaten)
        keys = {k for k in data.keys() if not k.startswith('@')}
        ref_keys = {k for k in reference.keys() if not k.startswith('@')}
        
        # Finde Unterschiede
        missing_keys = ref_keys - keys
        extra_keys = keys - ref_keys
        
        # Fehlende Keys (Fehler)
        for key in missing_keys:
            self.add_error('error', 'MISSING_KEY',
                          f'Schlüssel fehlt: "{key}" (verglichen mit {Path(reference_path).name})',
                          suggestion=f'Füge Übersetzung für "{key}" hinzu',
                          file_path=file_path)
        
        # Zusätzliche Keys (Warnung)
        for key in extra_keys:
            self.add_error('warning', 'EXTRA_KEY',
                          f'Schlüssel nicht in Referenz: "{key}" (verglichen mit {Path(reference_path).name})',
                          suggestion=f'Entferne "{key}" oder füge ihn zur Referenzdatei hinzu',
                          file_path=file_path)
        
        # Statistiken
        total_ref_keys = len(ref_keys)
        total_keys = len(keys)
        common_keys = len(keys & ref_keys)
        
        if total_ref_keys > 0:
            completeness = (common_keys / total_ref_keys) * 100
            self.add_error('info', 'COMPLETENESS_STATS',
                          f'Vollständigkeit: {completeness:.1f}% ({common_keys}/{total_ref_keys} Keys)',
                          suggestion=f'Ziel: 100% Vollständigkeit erreichen',
                          file_path=file_path)

    def validate_file(self, filepath: str, yaml_mode: bool = False) -> bool:
        """Validiert eine .arb- oder .yaml-Datei"""
        
        # Datei laden
        data = self.load_file(filepath, yaml_mode)
        if data is None:
            return False
        
        # ARB-spezifische Validierungen
        self.validate_arb_structure(data, filepath)
        self.validate_key_naming(data, filepath)
        self.validate_placeholders(data, filepath)
        self.validate_consistency(data, filepath)
        self.validate_term_suggestions(data, filepath)
        self.validate_security(data, filepath)
        self.validate_length_limits(data, filepath)
        
        return len([e for e in self.errors if e.severity == 'error']) == 0

    def fix_common_issues(self, filepath: str, yaml_mode: bool = False) -> bool:
        """Behebt häufige .arb-Probleme automatisch"""
        
        data = self.load_file(filepath, yaml_mode)
        if data is None:
            return False
        
        changes_made = False
        
        # Füge fehlende @@locale hinzu
        if '@@locale' not in data:
            # Bestimme Locale aus Dateiname
            path = Path(filepath)
            if 'app_de.arb' in path.name or '_de.' in path.name:
                data['@@locale'] = 'de'
                changes_made = True
            elif 'app_en.arb' in path.name or '_en.' in path.name:
                data['@@locale'] = 'en'
                changes_made = True
        
        # Füge fehlende @@context hinzu
        if '@@context' not in data:
            data['@@context'] = 'weltenwind-game'
            changes_made = True
        
        # Speichere Änderungen
        if changes_made:
            try:
                with open(filepath, 'w', encoding='utf-8') as f:
                    if yaml_mode and YAML_SUPPORT:
                        yaml.dump(data, f, default_flow_style=False, allow_unicode=True)
                    else:
                        json.dump(data, f, indent=2, ensure_ascii=False)
                print(f"✅ Auto-Fix angewendet: {filepath}")
                return True
            except Exception as e:
                print(f"❌ Fehler beim Speichern: {e}")
                return False
        
        return True

    def print_report(self, quiet: bool = False) -> bool:
        """Gibt Validierungsbericht aus"""
        
        if not self.errors:
            if not quiet:
                print("✅ Alle Validierungen bestanden!")
            return True
        
        # Gruppiere nach Severity
        errors = [e for e in self.errors if e.severity == 'error']
        warnings = [e for e in self.errors if e.severity == 'warning']
        infos = [e for e in self.errors if e.severity == 'info']
        
        if not quiet:
            print(f"📊 Validierungsergebnis:")
            print(f"   ❌ Fehler: {len(errors)}")
            print(f"   ⚠️ Warnungen: {len(warnings)}")
            print(f"   ℹ️ Hinweise: {len(infos)}")
            print()
            
            # Errors
            if errors:
                print("❌ FEHLER (müssen behoben werden):")
                for error in errors:
                    line_info = f" (Zeile {error.line})" if error.line else ""
                    file_info = f" [{Path(error.file_path).name}]" if error.file_path else ""
                    print(f"   • [{error.code}] {error.message}{line_info}{file_info}")
                    if error.suggestion:
                        print(f"     💡 {error.suggestion}")
                print()
            
            # Warnings
            if warnings:
                print("⚠️ WARNUNGEN (sollten behoben werden):")
                for warning in warnings:
                    line_info = f" (Zeile {warning.line})" if warning.line else ""
                    file_info = f" [{Path(warning.file_path).name}]" if warning.file_path else ""
                    print(f"   • [{warning.code}] {warning.message}{line_info}{file_info}")
                    if warning.suggestion:
                        print(f"     💡 {warning.suggestion}")
                print()
            
            # Infos (nur im strict mode oder bei Empfehlungen)
            if infos and (self.strict_mode or any(e.code in ['TERM_SUGGESTION', 'COMPLETENESS_STATS'] for e in infos)):
                print("ℹ️ HINWEISE:")
                for info in infos:
                    line_info = f" (Zeile {info.line})" if info.line else ""
                    file_info = f" [{Path(info.file_path).name}]" if info.file_path else ""
                    print(f"   • [{info.code}] {info.message}{line_info}{file_info}")
                    if info.suggestion:
                        print(f"     💡 {info.suggestion}")
                print()
        
        return len(errors) == 0

    def generate_json_report(self) -> Dict:
        """✅ 4. JSON-Report für CI-Integration"""
        
        report = {
            "summary": {
                "total_issues": len(self.errors),
                "errors": len([e for e in self.errors if e.severity == 'error']),
                "warnings": len([e for e in self.errors if e.severity == 'warning']),
                "infos": len([e for e in self.errors if e.severity == 'info'])
            },
            "issues": []
        }
        
        for error in self.errors:
            report["issues"].append({
                "severity": error.severity,
                "code": error.code,
                "message": error.message,
                "line": error.line,
                "suggestion": error.suggestion,
                "file": error.file_path
            })
        
        return report

def main():
    parser = argparse.ArgumentParser(description='Weltenwind .arb Validator (Enhanced)')
    parser.add_argument('file', help='.arb- oder .yaml-Datei zum Validieren')
    parser.add_argument('--fix', action='store_true', 
                       help='Behebt häufige Probleme automatisch')
    parser.add_argument('--strict', action='store_true',
                       help='Strenge Validierung mit zusätzlichen Checks')
    parser.add_argument('--compare-to', 
                       help='✅ 1. Vergleiche mit Referenzdatei (z.B. app_en.arb)')
    parser.add_argument('--yaml', action='store_true',
                       help='✅ 3. Behandle Datei als YAML statt JSON')
    parser.add_argument('--json-report', 
                       help='✅ 4. Speichere JSON-Report für CI-Integration')
    parser.add_argument('--quiet', action='store_true',
                       help='✅ 4. Unterdrücke Konsolenausgabe, nur Exit-Code')
    parser.add_argument('--fail-on-warning', action='store_true',
                       help='✅ 4. Bricht auch bei Warnungen mit Exit 1 ab')
    
    args = parser.parse_args()
    
    if not Path(args.file).exists():
        if not args.quiet:
            print(f"❌ Datei nicht gefunden: {args.file}")
        sys.exit(1)
    
    # ✅ 3. YAML-Support prüfen
    if args.yaml and not YAML_SUPPORT:
        if not args.quiet:
            print("❌ YAML-Support nicht verfügbar. Installiere: pip install pyyaml")
        sys.exit(1)
    
    validator = ArbValidator(strict_mode=args.strict)
    
    # Auto-Fix anwenden falls gewünscht
    if args.fix:
        if not args.quiet:
            print("🔧 Wende Auto-Fix an...")
        validator.fix_common_issues(args.file, args.yaml)
    
    # ✅ 1. Referenzdatei-Vergleich
    if args.compare_to:
        if not Path(args.compare_to).exists():
            if not args.quiet:
                print(f"❌ Referenzdatei nicht gefunden: {args.compare_to}")
            sys.exit(1)
        
        if not args.quiet:
            print(f"🔍 Vergleiche mit Referenz: {args.compare_to}")
        validator.compare_with_reference(args.file, args.compare_to, args.yaml)
    
    # Validierung durchführen
    if not args.quiet:
        print(f"🌍 Validiere {args.file}...")
    success = validator.validate_file(args.file, args.yaml)
    
    # ✅ 4. JSON-Report generieren
    if args.json_report:
        report = validator.generate_json_report()
        try:
            with open(args.json_report, 'w', encoding='utf-8') as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
            if not args.quiet:
                print(f"📊 JSON-Report gespeichert: {args.json_report}")
        except Exception as e:
            if not args.quiet:
                print(f"❌ Fehler beim Speichern des JSON-Reports: {e}")
    
    # Bericht ausgeben
    report_success = validator.print_report(args.quiet)
    
    # ✅ 4. Exit-Code-Logik
    has_errors = len([e for e in validator.errors if e.severity == 'error']) > 0
    has_warnings = len([e for e in validator.errors if e.severity == 'warning']) > 0
    
    if has_errors:
        sys.exit(1)
    elif args.fail_on_warning and has_warnings:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main() 