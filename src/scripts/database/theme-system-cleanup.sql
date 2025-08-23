-- 🎯 WELTENWIND THEME SYSTEM - CLEAN SLATE
-- Autoritative Bundle-Namen aus bundle-configs.json verwenden

-- =====================================================
-- 1. KOMPLETTE DB-CLEANUP: ALLE AUF AUTORITATIVE NAMEN
-- =====================================================

-- Standard-Welten: Alle auf 'world-preview' (für World-Listen)
UPDATE worlds 
SET theme_bundle = 'world-preview', parent_theme = 'world-preview'
WHERE theme_bundle IN (
    'default_world_bundle', 
    'pre_game_bundle'
) OR id IN (1,2,3,4,5,11,12,13,14,15);

-- Demo-Welten: Alle auf 'full-gaming' (für Gaming Experience)  
UPDATE worlds 
SET theme_bundle = 'full-gaming', parent_theme = 'full-gaming'
WHERE theme_bundle IN (
    'fantasy_world_bundle',
    'sci_fi_world_bundle', 
    'ancient_world_bundle'
) OR id IN (6,7,8,9,10);

-- =====================================================
-- 2. THEME-VARIANTEN: BLEIBEN UNVERÄNDERT (SIND PERFEKT)
-- =====================================================
-- tolkien, cyberpunk, roman, nature, space, default ✅

-- =====================================================
-- 3. VERIFICATION QUERIES
-- =====================================================

-- Zeige alle Bundle-Namen nach Cleanup
SELECT DISTINCT theme_bundle, parent_theme, COUNT(*) as count
FROM worlds 
GROUP BY theme_bundle, parent_theme
ORDER BY theme_bundle, parent_theme;

-- Zeige Demo-Welten Details
SELECT id, name, theme_bundle, parent_theme, theme_variant 
FROM worlds 
WHERE id IN (6,7,8,9,10)
ORDER BY id;

-- =====================================================
-- ERGEBNIS NACH CLEANUP:
-- =====================================================
-- ✅ Standard-Welten: theme_bundle = 'world-preview'
-- ✅ Demo-Welten: theme_bundle = 'full-gaming'  
-- ✅ Theme-Varianten: tolkien, cyberpunk, roman, nature, space, default
-- ✅ KEINE Legacy-Namen mehr!
-- ✅ SINGLE SOURCE OF TRUTH: bundle-configs.json