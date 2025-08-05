-- 🎨 Theme Bundle Cleanup für Weltenwind DB
-- Ersetzt alte Bundle-Namen durch korrekte Theme-System Namen

-- =====================================================
-- 1. PARENT THEME UPDATES
-- =====================================================

-- Standard-Welten: default_world_bundle → world-preview
UPDATE worlds 
SET parent_theme = 'world-preview'
WHERE parent_theme = 'default_world_bundle';

-- Fantasy-Welten: fantasy_world_bundle → full-gaming  
UPDATE worlds 
SET parent_theme = 'full-gaming'
WHERE parent_theme = 'fantasy_world_bundle';

-- Sci-Fi-Welten: sci_fi_world_bundle → full-gaming
UPDATE worlds 
SET parent_theme = 'full-gaming'
WHERE parent_theme = 'sci_fi_world_bundle';

-- Ancient-Welten: ancient_world_bundle → full-gaming
UPDATE worlds 
SET parent_theme = 'full-gaming'
WHERE parent_theme = 'ancient_world_bundle';

-- =====================================================
-- 2. THEME BUNDLE UPDATES  
-- =====================================================

-- Fantasy Demo-Welten: fantasy_world_bundle → full-gaming
UPDATE worlds 
SET theme_bundle = 'full-gaming'
WHERE theme_bundle = 'fantasy_world_bundle';

-- Sci-Fi Demo-Welten: sci_fi_world_bundle → full-gaming
UPDATE worlds 
SET theme_bundle = 'full-gaming'
WHERE theme_bundle = 'sci_fi_world_bundle';

-- Ancient Demo-Welten: ancient_world_bundle → full-gaming
UPDATE worlds 
SET theme_bundle = 'full-gaming'
WHERE theme_bundle = 'ancient_world_bundle';

-- Standard-Welten: Sollten schon world-preview haben (Sicherheitsupdate)
UPDATE worlds 
SET theme_bundle = 'world-preview'
WHERE theme_bundle = 'default_world_bundle';

-- =====================================================
-- 3. VERIFICATION QUERIES (optional zum Testen)
-- =====================================================

-- Zeige alle Theme-Bundle-Kombinationen nach dem Update
-- SELECT DISTINCT theme_bundle, parent_theme, theme_variant 
-- FROM worlds 
-- ORDER BY theme_bundle, parent_theme;

-- Zeige spezifische Demo-Welten nach Update
-- SELECT id, name, parent_theme, theme_bundle, theme_variant 
-- FROM worlds 
-- WHERE id IN (6,7,8,9,10);

-- =====================================================
-- ERGEBNIS NACH UPDATE:
-- =====================================================
-- ✅ Basis-Welten (1-5, 11-15): theme_bundle = 'world-preview'
-- ✅ Demo-Welten (6-10): theme_bundle = 'full-gaming'  
-- ✅ Parent-Themes: Alle korrekt auf world-preview/full-gaming
-- ✅ Theme-Varianten: Bleiben unverändert (tolkien, cyberpunk, etc.)