/*
  Warnings:

  - A unique constraint covering the columns `[worldId,email]` on the table `invites` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "invites_worldId_email_key" ON "invites"("worldId", "email");
