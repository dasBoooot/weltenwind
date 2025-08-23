-- AlterTable
ALTER TABLE "worlds" ADD COLUMN     "parent_theme" TEXT,
ADD COLUMN     "theme_bundle" TEXT NOT NULL DEFAULT 'default_world_bundle',
ADD COLUMN     "theme_overrides" JSONB,
ADD COLUMN     "theme_variant" TEXT DEFAULT 'standard';

-- Slug support (idempotent)
DO $$ BEGIN
  ALTER TABLE "worlds" ADD COLUMN IF NOT EXISTS "slug" TEXT;
EXCEPTION WHEN duplicate_column THEN NULL; END $$;

DO $$ BEGIN
  CREATE UNIQUE INDEX IF NOT EXISTS "worlds_slug_key" ON "worlds"("slug");
EXCEPTION WHEN duplicate_table THEN NULL; END $$;

-- Slug history table (idempotent)
CREATE TABLE IF NOT EXISTS "world_slug_history" (
  "id" SERIAL PRIMARY KEY,
  "worldId" INTEGER NOT NULL REFERENCES "worlds"("id") ON DELETE CASCADE,
  "oldSlug" TEXT UNIQUE NOT NULL,
  "changedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);