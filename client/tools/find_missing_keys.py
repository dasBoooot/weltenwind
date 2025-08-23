#!/usr/bin/env python3
"""
Findet alle AppLocalizations.of(context)!.xyz Keys im Code,
die noch nicht in den .arb-Dateien existieren.

Das ist der richtige Ansatz statt Regex-Pattern auf Strings!
"""

import json
import re
from pathlib import Path
from typing import Set, Dict, List

def extract_applocalization_keys(dart_files: List[Path]) -> Set[str]:
    """Extrahiert alle AppLocalizations.of(context)!.xyz Keys aus Dart-Dateien"""
    keys = set()
    pattern = r'AppLocalizations\.of\(context\)!\.([\w]+)'
    
    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(pattern, content)
                for match in matches:
                    keys.add(match)
                    print(f"📝 {file_path.name}: .{match}")
        except Exception as e:
            print(f"⚠️ Fehler beim Lesen {file_path}: {e}")
    
    return keys

def load_arb_keys(arb_file: Path) -> Set[str]:
    """Lädt alle Keys aus einer .arb-Datei"""
    try:
        with open(arb_file, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
            # Filtere Metadaten-Keys (die mit @ beginnen) und @@locale aus
            keys = {k for k in arb_data.keys() if not k.startswith('@')}
            return keys
    except Exception as e:
        print(f"⚠️ Fehler beim Lesen {arb_file}: {e}")
        return set()

def main():
    client_root = Path(".")
    lib_dir = client_root / "lib"
    l10n_dir = lib_dir / "l10n"
    
    print("🔍 Suche alle .dart-Dateien...")
    dart_files = list(lib_dir.rglob("*.dart"))
    print(f"📂 {len(dart_files)} Dart-Dateien gefunden")
    
    print("\n🎯 Extrahiere AppLocalizations-Keys aus Code...")
    used_keys = extract_applocalization_keys(dart_files)
    print(f"\n✅ {len(used_keys)} einzigartige Keys im Code gefunden")
    
    print("\n📋 Lade existierende .arb-Keys...")
    arb_de = l10n_dir / "app_de.arb"
    arb_en = l10n_dir / "app_en.arb"
    
    existing_keys_de = load_arb_keys(arb_de) if arb_de.exists() else set()
    existing_keys_en = load_arb_keys(arb_en) if arb_en.exists() else set()
    
    print(f"📝 app_de.arb: {len(existing_keys_de)} Keys")
    print(f"📝 app_en.arb: {len(existing_keys_en)} Keys")
    
    print("\n🔍 Analysiere fehlende Keys...")
    missing_in_de = used_keys - existing_keys_de
    missing_in_en = used_keys - existing_keys_en
    
    print(f"\n❌ Fehlende Keys in app_de.arb: {len(missing_in_de)}")
    print(f"❌ Fehlende Keys in app_en.arb: {len(missing_in_en)}")
    
    print("\n🎯 FEHLENDE KEYS (benötigt für .arb-Dateien):")
    print("=" * 60)
    
    all_missing = missing_in_de | missing_in_en
    for key in sorted(all_missing):
        de_status = "❌" if key in missing_in_de else "✅"
        en_status = "❌" if key in missing_in_en else "✅"
        print(f"{de_status} DE | {en_status} EN | {key}")
    
    print(f"\n📊 ZUSAMMENFASSUNG:")
    print(f"🔍 Keys im Code verwendet: {len(used_keys)}")
    print(f"✅ Keys in app_de.arb: {len(existing_keys_de)}")
    print(f"✅ Keys in app_en.arb: {len(existing_keys_en)}")
    print(f"❌ Fehlende Keys gesamt: {len(all_missing)}")
    
    # Speichere fehlende Keys als JSON
    missing_data = {
        "used_keys": sorted(list(used_keys)),
        "existing_de": sorted(list(existing_keys_de)),
        "existing_en": sorted(list(existing_keys_en)),
        "missing_in_de": sorted(list(missing_in_de)),
        "missing_in_en": sorted(list(missing_in_en)),
        "all_missing": sorted(list(all_missing))
    }
    
    output_file = Path("tools") / "missing_keys_analysis.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(missing_data, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 Detaillierte Analyse gespeichert: {output_file}")

if __name__ == "__main__":
    main()