-- AlterTable
ALTER TABLE "worlds" ADD COLUMN     "parent_theme" TEXT,
ADD COLUMN     "theme_bundle" TEXT NOT NULL DEFAULT 'default_world_bundle',
ADD COLUMN     "theme_overrides" JSONB,
ADD COLUMN     "theme_variant" TEXT DEFAULT 'standard';
