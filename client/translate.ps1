# ARB Translation Script
# Übersetzt die deutsche Master-ARB-Datei ins Englische

Write-Host "🌍 Starting ARB Translation..." -ForegroundColor Green

# Teste ob Translator verfügbar ist
$translatorTest = flutter pub run flutter_arb_translator:main --help 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter ARB Translator not found. Run 'flutter pub get' first." -ForegroundColor Red
    exit 1
}

# Übersetze DE -> EN
Write-Host "📝 Translating German (DE) to English (EN)..." -ForegroundColor Yellow
flutter pub run flutter_arb_translator:main --from de --to en --service deepl --override

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Translation completed successfully!" -ForegroundColor Green
    Write-Host "📄 Updated: lib/l10n/app_en.arb" -ForegroundColor Cyan
} else {
    Write-Host "❌ Translation failed. Check your DeepL API key in dev_assets/flutter_arb_translator_config.json" -ForegroundColor Red
}

Write-Host "🎯 Next: Test translations with 'flutter build web --base-href /game/'" -ForegroundColor Blue