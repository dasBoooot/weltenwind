#!/usr/bin/env python3
"""
Weltenwind i18n String Extractor
Automatische Erkennung von hardcoded deutschen Strings im Flutter Code

Usage: python i18n_string_extractor.py [--fix] [--fail-on-find] [--strict]
"""

import os
import re
import json
import argparse
from pathlib import Path
from typing import List, Dict, Set, Tuple
from dataclasses import dataclass, asdict

@dataclass
class StringMatch:
    file: str
    line: int
    column: int
    original: str
    suggested_key: str
    context: str
    category: str
    confidence: float
    widget_context: str = ""
    quote_type: str = ""

class I18nStringExtractor:
    def __init__(self, client_root: str = ".", lib_dir: str = "lib"):
        self.client_root = Path(client_root)
        self.lib_dir = self.client_root / lib_dir
        self.l10n_dir = self.client_root / lib_dir / "l10n"
        
        # ✅ 1. ULTRA-RESTRIKTIVE deutsche String-Patterns - NUR echte UI-Strings!
        self.german_patterns = [
            # 🎯 NUR EINZEILIGE, KURZE UI-STRINGS (verhindert Code-Erfassung)
            # Gaming-spezifische deutsche Begriffe (nur kurze, saubere Strings)
            (r'"([^"\n\r\\]{5,50}(?:Welt|Welten|Spieler|Spiel|Level|Quest|Punkte|Score|Einladung|beitreten|starten|beenden)[^"\n\r\\]{0,20})"', 0.95),
            (r"'([^'\n\r\\]{5,50}(?:Welt|Welten|Spieler|Spiel|Level|Quest|Punkte|Score|Einladung|beitreten|starten|beenden)[^'\n\r\\]{0,20})'", 0.9),
            
            # UI-Button und Aktion-Texte (nur saubere, kurze Strings)
            (r'"([^"\n\r\\]{3,30}(?:Bitte|Fehler|Warnung|Erfolg|Laden|Speichern|Löschen|Bearbeiten|Erstellen|Zurück|Weiter|Abbrechen|OK|Ja|Nein)[^"\n\r\\]{0,15})"', 0.9),
            (r"'([^'\n\r\\]{3,30}(?:Bitte|Fehler|Warnung|Erfolg|Laden|Speichern|Löschen|Bearbeiten|Erstellen|Zurück|Weiter|Abbrechen|OK|Ja|Nein)[^'\n\r\\]{0,15})'", 0.85),
            
            # Deutsche Anrede und Höflichkeitsformen (nur kurze UI-Texte)
            (r'"([^"\n\r\\]{5,40}(?:Sie|Ihnen|Ihr|Ihre|bitte|danke|willkommen)[^"\n\r\\]{0,20})"', 0.85),
            (r"'([^'\n\r\\]{5,40}(?:Sie|Ihnen|Ihr|Ihre|bitte|danke|willkommen)[^'\n\r\\]{0,20})'", 0.8),
            
            # Deutsche Umlaute in kurzen UI-Strings (sehr restriktiv)
            (r'"([^"\n\r\\]{3,25}[äöüÄÖÜß][^"\n\r\\]{3,25})"', 0.8),
            (r"'([^'\n\r\\]{3,25}[äöüÄÖÜß][^'\n\r\\]{3,25})'", 0.75),
            
            # Deutsche Artikel + Substantiv (nur typische UI-Länge)
            (r'"((?:der|die|das|ein|eine|einen)\s+[A-ZÄÖÜ][a-zäöüß]{3,15}[^"\n\r\\]{0,10})"', 0.8),
            (r"'((?:der|die|das|ein|eine|einen)\s+[A-ZÄÖÜ][a-zäöüß]{3,15}[^'\n\r\\]{0,10})'", 0.75),
            
            # Deutsche Fragewörter (typisch für UI)
            (r'"([^"\n\r\\]{5,35}(?:Was|Wie|Wer|Wo|Wann|Warum|Welche)[^"\n\r\\]{5,25}[?])"', 0.85),
            (r"'([^'\n\r\\]{5,35}(?:Was|Wie|Wer|Wo|Wann|Warum|Welche)[^'\n\r\\]{5,25}[?])'", 0.8),
            
            # Deutsche Sätze mit Satzzeichen (sehr restriktive Länge)
            (r'"([^"\n\r\\]{8,50}[.!?])"', 0.7),
            (r"'([^'\n\r\\]{8,50}[.!?])'", 0.65),
            
            # Deutsche häufige Wörter (nur als vollständige, kurze Strings)
            (r'"([^"\n\r\\]{3,25}(?:können|müssen|sollen|möchten|haben|sind|wird)[^"\n\r\\]{3,25})"', 0.7),
            (r"'([^'\n\r\\]{3,25}(?:können|müssen|sollen|möchten|haben|sind|wird)[^'\n\r\\]{3,25})'", 0.65),
        ]
        
        # Kategorien basierend auf Kontext mit Gewichtung
        self.category_patterns = {
            'error': (r'(?:error|fehler|exception|throw)', 0.1),
            'button': (r'(?:button|onPressed|elevated|text.*button)', 0.1),
            'dialog': (r'(?:dialog|alert|show.*dialog)', 0.1),
            'navigation': (r'(?:route|go_router|navigation|appbar)', 0.05),
            'form': (r'(?:form|field|input|validator|controller)', 0.05),
            'auth': (r'(?:auth|login|register|password|email)', 0.1),
            'world': (r'(?:world|welt|game|spieler)', 0.1),
            'invite': (r'(?:invite|einladung|token)', 0.1),
            'ui': (r'(?:widget|build|text|title|label)', 0.0)
        }
        
        # ✅ 2. Sprachumschalter-Schutz (Whitelisting)
        self.whitelist_strings = {
            # Sprachnamen
            "Deutsch", "Englisch", "Français", "Español", "Italiano",
            "DE", "EN", "FR", "ES", "IT",
            # Technische Begriffe
            "UTF-8", "HTTP", "HTTPS", "JSON", "XML", "API",
            # Konstanten
            "DEBUG", "RELEASE", "PROD", "DEV", "TEST",
            # Marken/Namen (case-sensitive)
            "Flutter", "Dart", "Android", "iOS",
        }
        
        # ⚠️ MASSIV ERWEITERTE Ausschlussmuster - Verhindert Code-Detection
        self.exclude_patterns = [
            # Basis-Ausschlüsse
            r'^[A-Z_]+$',  # Konstanten (DEBUG, API_KEY)
            r'^[a-z][a-zA-Z]*\.[a-z][a-zA-Z]*$',  # Klassen/Methoden (User.fromJson)
            r'^\d+$',  # Nur Zahlen
            r'^[a-zA-Z0-9\-_]+\.(json|yaml|dart|png|jpg|svg)$',  # Dateinamen
            r'^https?://',  # URLs
            r'^[a-zA-Z0-9\-_]+@[a-zA-Z0-9\-_]+\.[a-zA-Z]{2,}$',  # E-Mails
            r'^\s*$',  # Leerstrings
            r'^[a-zA-Z0-9_]+$',  # Einzelne Wörter ohne Leerzeichen
            
            # 🚨 CODE-PATTERN AUSSCHLÜSSE
            r'.*class\s+[A-Z][a-zA-Z]*.*',  # Dart Klassen-Definitionen
            r'.*static\s+(final|const).*',  # Static-Deklarationen  
            r'.*factory\s+[A-Z][a-zA-Z]*.*',  # Factory-Konstruktoren
            r'.*extends\s+[A-Z][a-zA-Z]*.*',  # Extends-Klauseln
            r'.*implements\s+[A-Z][a-zA-Z]*.*',  # Implements-Klauseln
            r'.*package:[a-z][a-z_/]*\.dart.*',  # Dart Package-Imports
            r'.*import\s+[\'"][^\'\"]*[\'"].*',  # Import-Statements
            r'.*\{[^}]*\}.*',  # Code-Blöcke mit geschweiften Klammern
            r'.*[a-zA-Z]+\([^)]*\).*',  # Funktionsaufrufe
            r'.*[a-zA-Z_]+\.[a-zA-Z_]+\(.*',  # Methoden-Aufrufe
            r'.*\w+\s*:\s*\w+.*',  # Key-Value Zuweisungen
            r'.*final\s+[a-zA-Z_]+.*',  # Variable-Deklarationen
            r'.*const\s+[a-zA-Z_]+.*',  # Konstante-Deklarationen
            r'.*return\s+.*',  # Return-Statements
            r'.*override\s+.*',  # Override-Annotations
            r'.*async\s+.*',  # Async-Funktionen
            r'.*await\s+.*',  # Await-Expressions
            r'.*Future<.*>.*',  # Future-Types
            r'.*List<.*>.*',  # List-Types
            r'.*Map<.*>.*',  # Map-Types
            r'.*Widget\s+.*',  # Flutter Widget-Code
            r'.*BuildContext.*',  # Flutter BuildContext
            r'.*State<.*>.*',  # Flutter State-Classes
            r'.*StatefulWidget.*',  # Flutter StatefulWidget
            r'.*StatelessWidget.*',  # Flutter StatelessWidget
            r'.*\.setState\(.*',  # setState-Aufrufe
            r'.*Navigator\..*',  # Navigator-Aufrufe
            r'.*Scaffold\..*',  # Scaffold-Aufrufe
            r'.*Theme\.of\(.*',  # Theme-Aufrufe
            r'.*MediaQuery\..*',  # MediaQuery-Aufrufe
            r'.*\$\{[^}]+\}.*',  # String-Interpolation
            r'.*\w+\[\w+\].*',  # Array/Map-Zugriffe
            r'.*if\s*\(.*\).*',  # If-Statements  
            r'.*else\s+.*',  # Else-Statements
            r'.*switch\s*\(.*',  # Switch-Statements
            r'.*case\s+.*:.*',  # Case-Labels
            r'.*catch\s*\(.*',  # Catch-Blocks
            r'.*try\s*\{.*',  # Try-Blocks
            r'.*throw\s+.*',  # Throw-Statements
            r'.*\w+\s*\?\s*\w+\s*:.*',  # Ternary-Operatoren
            r'.*\?\?.*',  # Null-aware Operatoren
            r'.*\w+\?\.\w+.*',  # Null-aware Member-Access
            r'.*\d+\.\d+.*',  # Floating-Point-Zahlen
            r'.*0x[0-9a-fA-F]+.*',  # Hex-Zahlen
            r'.*[<>]=?.*',  # Vergleichsoperatoren
            r'.*[+\-*/].*',  # Mathematische Operatoren
            r'.*&&|\|\|.*',  # Logische Operatoren
            r'.*\w+\+\+|\+\+\w+.*',  # Increment-Operatoren
            r'.*\w+--|\-\-\w+.*',  # Decrement-Operatoren
            
            # 🚨 SPEZIELLE DART/FLUTTER PATTERN
            r'.*\.toList\(\).*',  # Collection-Methoden
            r'.*\.toString\(\).*',  # toString-Aufrufe
            r'.*\.isEmpty.*',  # Collection-Eigenschaften
            r'.*\.isNotEmpty.*',  # Collection-Eigenschaften
            r'.*\.length.*',  # Length-Eigenschaften
            r'.*\.map\(.*',  # Map-Funktionen
            r'.*\.where\(.*',  # Where-Funktionen
            r'.*\.forEach\(.*',  # ForEach-Funktionen
            r'.*\.firstWhere\(.*',  # FirstWhere-Funktionen
            r'.*\.any\(.*',  # Any-Funktionen
            r'.*\.every\(.*',  # Every-Funktionen
            r'.*\.fold\(.*',  # Fold-Funktionen
            r'.*\.reduce\(.*',  # Reduce-Funktionen
            r'.*MaterialApp.*',  # Flutter MaterialApp
            r'.*Scaffold.*',  # Flutter Scaffold
            r'.*AppBar.*',  # Flutter AppBar
            r'.*Container.*',  # Flutter Container
            r'.*Column.*',  # Flutter Column
            r'.*Row.*',  # Flutter Row
            r'.*Padding.*',  # Flutter Padding
            r'.*Margin.*',  # Flutter Margin
            r'.*Expanded.*',  # Flutter Expanded
            r'.*Flexible.*',  # Flutter Flexible
            r'.*SizedBox.*',  # Flutter SizedBox
            r'.*Text\(.*',  # Flutter Text-Widget (außer Plain-Text)
            r'.*ElevatedButton.*',  # Flutter ElevatedButton
            r'.*TextButton.*',  # Flutter TextButton
            r'.*OutlinedButton.*',  # Flutter OutlinedButton
            r'.*TextField.*',  # Flutter TextField
            r'.*TextFormField.*',  # Flutter TextFormField
            r'.*style:\s*.*',  # Style-Definitionen
            r'.*decoration:\s*.*',  # Decoration-Definitionen
            r'.*onPressed:\s*.*',  # OnPressed-Handler
            r'.*onTap:\s*.*',  # OnTap-Handler
            r'.*child:\s*.*',  # Child-Definitionen (nur wenn erkennbar Code)
            r'.*children:\s*.*',  # Children-Listen
            
            # 🚨 LOGGING & DEBUG PATTERN
            r'.*print\(.*',  # Print-Statements
            r'.*debugPrint\(.*',  # DebugPrint-Statements
            r'.*log\(.*',  # Log-Statements
            r'.*Logger.*',  # Logger-Instanzen
            r'.*console\..*',  # Console-Aufrufe
            r'.*AppLogger\..*',  # Custom Logger-Aufrufe
            r'.*\[DEBUG\].*',  # Debug-Messages
            r'.*\[INFO\].*',  # Info-Messages
            r'.*\[ERROR\].*',  # Error-Messages
            r'.*\[WARNING\].*',  # Warning-Messages
            
            # 🚨 VARIABLE & METHODEN PATTERN
            r'^[a-z][a-zA-Z0-9_]*$',  # camelCase-Variablen (einzeln)
            r'^[A-Z][a-zA-Z0-9]*$',  # PascalCase-Klassen (einzeln)
            r'^_[a-zA-Z][a-zA-Z0-9_]*$',  # Private-Variablen
            r'.*\w+\s*=\s*.*',  # Zuweisungen
            r'.*var\s+\w+.*',  # Var-Deklarationen
            r'.*int\s+\w+.*',  # Int-Deklarationen
            r'.*double\s+\w+.*',  # Double-Deklarationen
            r'.*String\s+\w+.*',  # String-Deklarationen
            r'.*bool\s+\w+.*',  # Bool-Deklarationen
            
            # 🚨 SONSTIGE CODE-PATTERN
            r'.*\.\w+\s*=.*',  # Property-Zuweisungen
            r'.*;\s*$',  # Statements mit Semikolon am Ende
            r'.*\{\s*$',  # Öffnende geschweifte Klammer am Ende
            r'.*\}\s*$',  # Schließende geschweifte Klammer am Ende
            r'.*\(\s*$',  # Öffnende runde Klammer am Ende
            r'.*\)\s*$',  # Schließende runde Klammer am Ende
            r'.*\[\s*$',  # Öffnende eckige Klammer am Ende
            r'.*\]\s*$',  # Schließende eckige Klammer am Ende
        ]

    def should_exclude(self, text: str) -> bool:
        """✅ 2. Erweiterte Ausschlussprüfung mit Whitelisting"""
        clean_text = text.strip()
        
        # Whitelist check
        if clean_text in self.whitelist_strings:
            return True
        
        # Pattern-basierte Ausschlüsse
        for pattern in self.exclude_patterns:
            if re.match(pattern, clean_text):
                return True
        return False

    def detect_widget_context(self, lines: List[str], line_idx: int) -> str:
        """✅ 3. Erweiterte Widget-Kontext-Erkennung"""
        
        # Suche rückwärts nach Widget-Definitionen
        widget_patterns = [
            r'(ElevatedButton|TextButton|OutlinedButton)',
            r'(Text|RichText)',
            r'(AppBar|Scaffold)',
            r'(AlertDialog|SimpleDialog)',
            r'(TextField|TextFormField)',
            r'(ListTile|Card)',
            r'(SnackBar|Tooltip)',
        ]
        
        context_lines = []
        search_range = min(10, line_idx)  # Suche max. 10 Zeilen zurück
        
        for i in range(line_idx - search_range, line_idx + 1):
            if 0 <= i < len(lines):
                line = lines[i].strip()
                context_lines.append(line)
                
                # Prüfe Widget-Pattern
                for pattern in widget_patterns:
                    if re.search(pattern, line):
                        return f"Widget: {re.search(pattern, line).group(1)}"
        
        # Fallback: Suche nach häufigen Flutter-Patterns
        context_text = '\n'.join(context_lines)
        if 'child:' in context_text:
            return "Widget: child property"
        elif 'title:' in context_text:
            return "Widget: title property"
        elif 'content:' in context_text:
            return "Widget: content property"
        
        return "Widget: unknown"

    def detect_category(self, context: str, file_path: str, widget_context: str = "") -> Tuple[str, float]:
        """✅ 6. Kategorien gezielt gewichtbar gemacht"""
        context_lower = context.lower()
        file_lower = file_path.lower()
        
        base_confidence = 0.0
        detected_category = 'ui'
        
        # Dateipfad-basierte Kategorisierung
        if 'auth' in file_lower:
            detected_category = 'auth'
            base_confidence += 0.1
        elif 'world' in file_lower:
            detected_category = 'world'
            base_confidence += 0.1
        elif 'invite' in file_lower:
            detected_category = 'invite'
            base_confidence += 0.1
        elif 'dialog' in file_lower:
            detected_category = 'dialog'
            base_confidence += 0.1
        
        # Kontext-basierte Kategorisierung mit Gewichtung
        for category, (pattern, confidence_boost) in self.category_patterns.items():
            if re.search(pattern, context_lower):
                detected_category = category
                base_confidence += confidence_boost
                break
        
        # Widget-Kontext-spezifische Gewichtung
        if 'dialog' in widget_context.lower():
            base_confidence += 0.1
        elif 'form' in widget_context.lower() and 'validator' in context_lower:
            base_confidence += 0.05
        elif 'button' in widget_context.lower():
            base_confidence += 0.05
        
        return detected_category, base_confidence

    def generate_key(self, text: str, category: str) -> str:
        """Generiert einen .arb-Key basierend auf Text und Kategorie"""
        # Text säubern und normalisieren
        clean_text = re.sub(r'[^\w\s]', '', text)
        clean_text = re.sub(r'\s+', ' ', clean_text).strip()
        
        # Erste 2-3 Wörter nehmen
        words = clean_text.lower().split()[:3]
        key_base = ''.join(word.capitalize() for word in words if word)
        
        # Fallback wenn kein sinnvoller Key
        if not key_base or len(key_base) < 3:
            key_base = f"Text{abs(hash(text)) % 1000:03d}"
        
        return f"{category}{key_base}"

    def get_context(self, lines: List[str], line_idx: int, context_size: int = 3) -> str:
        """Extrahiert erweiterten Kontext um eine Zeile"""
        start = max(0, line_idx - context_size)
        end = min(len(lines), line_idx + context_size + 1)
        return '\n'.join(lines[start:end])

    def scan_file(self, file_path: Path) -> List[StringMatch]:
        """Scannt eine Dart-Datei nach deutschen Strings"""
        matches = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
        except Exception as e:
            print(f"⚠️ Fehler beim Lesen von {file_path}: {e}")
            return matches

        # Relative Pfad für bessere Lesbarkeit
        rel_path = str(file_path.relative_to(self.client_root))
        
        for pattern, base_confidence in self.german_patterns:
            for match in re.finditer(pattern, content, re.IGNORECASE | re.MULTILINE):
                text = match.group(1)
                
                # Bestimme Quote-Type
                quote_type = '"' if pattern.startswith(r'"') else "'"
                
                # Ausschlusskriterien prüfen
                if self.should_exclude(text) or len(text.strip()) < 3:
                    continue
                
                # Position bestimmen
                line_start = content.rfind('\n', 0, match.start()) + 1
                line_num = content.count('\n', 0, match.start()) + 1
                column = match.start() - line_start + 1
                
                # Erweiterten Kontext extrahieren
                context = self.get_context(lines, line_num - 1)
                widget_context = self.detect_widget_context(lines, line_num - 1)
                
                # Kategorie mit Gewichtung bestimmen
                category, confidence_boost = self.detect_category(context, rel_path, widget_context)
                final_confidence = min(1.0, base_confidence + confidence_boost)
                
                suggested_key = self.generate_key(text, category)
                
                matches.append(StringMatch(
                    file=rel_path,
                    line=line_num,
                    column=column,
                    original=text,
                    suggested_key=suggested_key,
                    context=context.strip(),
                    category=category,
                    confidence=final_confidence,
                    widget_context=widget_context,
                    quote_type=quote_type
                ))
        
        return matches

    def scan_all_files(self) -> List[StringMatch]:
        """Scannt alle Dart-Dateien im lib-Verzeichnis"""
        all_matches = []
        
        if not self.lib_dir.exists():
            print(f"❌ lib-Verzeichnis nicht gefunden: {self.lib_dir}")
            return all_matches
        
        dart_files = list(self.lib_dir.rglob("*.dart"))
        total_files = len(dart_files)
        print(f"🔍 Scanne {total_files} Dart-Dateien...")
        
        scanned_files = 0
        files_with_matches = 0
        
        for dart_file in dart_files:
            # l10n-generierte Dateien überspringen
            if 'l10n' in str(dart_file) and 'app_localizations' in str(dart_file):
                continue
                
            matches = self.scan_file(dart_file)
            all_matches.extend(matches)
            scanned_files += 1
            
            if matches:
                files_with_matches += 1
                print(f"  📝 {len(matches)} Strings in {dart_file.name}")
        
        print(f"📊 Scan-Statistik: {scanned_files} Dateien durchsucht, {files_with_matches} mit Treffern")
        return all_matches

    def load_existing_arb(self, lang: str = 'de') -> Set[str]:
        """Lädt existierende .arb-Keys"""
        arb_file = self.l10n_dir / f"app_{lang}.arb"
        existing_keys = set()
        
        if arb_file.exists():
            try:
                with open(arb_file, 'r', encoding='utf-8') as f:
                    arb_data = json.load(f)
                    existing_keys = {k for k in arb_data.keys() if not k.startswith('@@') and not k.startswith('@')}
                print(f"📋 {len(existing_keys)} existierende Keys in {arb_file.name}")
            except Exception as e:
                print(f"⚠️ Fehler beim Lesen von {arb_file}: {e}")
        
        return existing_keys

    def generate_problems_json(self, matches: List[StringMatch], output_file: str = "problems.json"):
        """✅ 7. Editor-Integration: VS Code Problems Format"""
        problems = []
        
        for match in matches:
            problems.append({
                "file": match.file,
                "line": match.line,
                "column": match.column,
                "message": f"Hardcoded deutscher Text gefunden: \"{match.original[:50]}{'...' if len(match.original) > 50 else ''}\"",
                "severity": "warning" if match.confidence > 0.7 else "info",
                "code": "i18n-hardcoded-string",
                "source": "weltenwind-i18n-extractor",
                "details": {
                    "suggested_key": match.suggested_key,
                    "category": match.category,
                    "confidence": match.confidence,
                    "widget_context": match.widget_context,
                    "quote_type": match.quote_type
                }
            })
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(problems, f, indent=2, ensure_ascii=False)
        
        print(f"🔧 Editor-Integration: {output_file}")

    def generate_report(self, matches: List[StringMatch], output_file: str = "i18n_extraction_report.md"):
        """Generiert einen erweiterten Markdown-Report"""
        existing_keys = self.load_existing_arb()
        
        # Matches filtern und sortieren
        new_matches = [m for m in matches if m.suggested_key not in existing_keys]
        new_matches.sort(key=lambda x: (-x.confidence, x.category, x.file))
        
        # Statistiken
        total_matches = len(matches)
        new_strings = len(new_matches)
        categories = {}
        confidence_distribution = {'high': 0, 'medium': 0, 'low': 0}
        quote_types = {}
        
        for match in new_matches:
            categories[match.category] = categories.get(match.category, 0) + 1
            quote_types[match.quote_type] = quote_types.get(match.quote_type, 0) + 1
            
            if match.confidence >= 0.8:
                confidence_distribution['high'] += 1
            elif match.confidence >= 0.6:
                confidence_distribution['medium'] += 1
            else:
                confidence_distribution['low'] += 1
        
        # Report schreiben
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# 🌍 Weltenwind i18n String Extraction Report\n\n")
            f.write(f"**Gesamt gefunden:** {total_matches} Strings\n")
            f.write(f"**Neue Strings:** {new_strings} (noch nicht in .arb)\n")
            f.write(f"**Bereits vorhanden:** {total_matches - new_strings}\n\n")
            
            f.write("## 📊 Kategorien\n\n")
            for category, count in sorted(categories.items()):
                f.write(f"- **{category}**: {count} Strings\n")
            f.write("\n")
            
            f.write("## 🎯 Konfidenz-Verteilung\n\n")
            f.write(f"- **Hoch (≥80%)**: {confidence_distribution['high']} Strings ✅\n")
            f.write(f"- **Mittel (60-79%)**: {confidence_distribution['medium']} Strings ⚠️\n")
            f.write(f"- **Niedrig (<60%)**: {confidence_distribution['low']} Strings ❓\n\n")
            
            f.write("## 📝 Quote-Types\n\n")
            for quote_type, count in quote_types.items():
                f.write(f"- **{quote_type}-Quotes**: {count} Strings\n")
            f.write("\n")
            
            f.write("## 🔍 Neue Strings (Priorität: Hoch → Niedrig)\n\n")
            
            current_category = None
            for match in new_matches:
                if match.category != current_category:
                    current_category = match.category
                    f.write(f"### 🏷️ {current_category.upper()}\n\n")
                
                confidence_emoji = "🔥" if match.confidence >= 0.8 else "⚠️" if match.confidence >= 0.6 else "❓"
                f.write(f"**{match.suggested_key}** {confidence_emoji} (Confidence: {match.confidence:.1f})\n")
                f.write(f"- 📁 `{match.file}:{match.line}:{match.column}`\n")
                f.write(f"- 📝 Original: `{match.quote_type}{match.original}{match.quote_type}`\n")
                f.write(f"- 🎯 Widget: {match.widget_context}\n")
                f.write(f"- 🔧 Context:\n```dart\n{match.context}\n```\n\n")
        
        print(f"📄 Report gespeichert: {output_file}")
        return new_matches

def main():
    parser = argparse.ArgumentParser(description='Weltenwind i18n String Extractor (Enhanced)')
    parser.add_argument('--output', '-o', default='i18n_extraction_report.md', 
                       help='Output-Datei für den Report')
    parser.add_argument('--json', action='store_true', 
                       help='Zusätzliche JSON-Ausgabe')
    parser.add_argument('--problems', action='store_true',
                       help='Generiere problems.json für Editor-Integration')
    parser.add_argument('--client-root', default='.', 
                       help='Pfad zum Client-Root-Verzeichnis')
    parser.add_argument('--fail-on-find', action='store_true',
                       help='✅ 4. Gibt Fehlercode zurück, wenn Strings gefunden wurden (CI/CD)')
    parser.add_argument('--strict', action='store_true',
                       help='Strenge Validierung mit niedrigerer Konfidenz-Schwelle')
    
    args = parser.parse_args()
    
    # ✅ 8. CLI-Summary-Header
    print("🚀 Weltenwind i18n String Extractor (Enhanced)")
    print("=" * 60)
    
    extractor = I18nStringExtractor(args.client_root)
    matches = extractor.scan_all_files()
    
    if not matches:
        print("✅ Keine hardcoded deutschen Strings gefunden!")
        return
    
    # Report generieren
    new_matches = extractor.generate_report(matches, args.output)
    
    # Optional: JSON-Output
    if args.json:
        json_file = args.output.replace('.md', '.json')
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump([asdict(match) for match in new_matches], f, 
                     indent=2, ensure_ascii=False)
        print(f"📊 JSON-Daten gespeichert: {json_file}")
    
    # Optional: Problems JSON für Editor
    if args.problems:
        problems_file = args.output.replace('.md', '_problems.json')
        extractor.generate_problems_json(new_matches, problems_file)
    
    # ✅ 8. CLI-Summary-Output am Ende
    print()
    print("=" * 60)
    print("📋 ZUSAMMENFASSUNG")
    print("=" * 60)
    total_files = len(list(extractor.lib_dir.rglob("*.dart")))
    print(f"✅ Scan abgeschlossen: {total_files} Dateien durchsucht")
    print(f"🔍 {len(new_matches)} neue deutsche Strings gefunden")
    print(f"📄 Report gespeichert als: {args.output}")
    
    if args.json:
        print(f"📊 JSON-Daten unter: {json_file}")
    if args.problems:
        print(f"🔧 Editor-Integration: {problems_file}")
    
    high_confidence = len([m for m in new_matches if m.confidence >= 0.8])
    if high_confidence > 0:
        print(f"🔥 {high_confidence} Strings mit hoher Konfidenz (≥80%) - Priorität!")
    
    # ✅ 4. --fail-on-find Modus für CI/CD
    if args.fail_on_find and new_matches:
        print(f"❌ CI/CD: {len(new_matches)} hardcoded Strings gefunden - Build fehlgeschlagen!")
        exit(1)
    
    print("🎯 Nächste Schritte: Prüfe den Report und aktualisiere .arb-Dateien")

if __name__ == "__main__":
    main() 