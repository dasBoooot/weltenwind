const fs = require('fs');
const path = require('path');

const combinedPath = path.join(__dirname, 'api-combined.yaml');

const content = `openapi: 3.0.3
info:
  title: Weltenwind API
  description: Auth, Session & Weltenverwaltung
  version: 1.0.0

servers:
  - url: http://localhost:3000/api

paths:
  /auth/login:
    $ref: './auth.yaml#/paths/~1auth~1login/post'
  /auth/logout:
    $ref: './auth.yaml#/paths/~1auth~1logout/post'
  /worlds:
    $ref: './worlds.yaml#/paths/~1worlds/get'
  /worlds/{id}/edit:
    $ref: './worlds.yaml#/paths/~1worlds~1{id}~1edit/post'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  schemas:
    World:
      $ref: './worlds.yaml#/components/schemas/World'
`;

fs.writeFileSync(combinedPath, content);
console.log('✅ api-combined.yaml erfolgreich generiert.');
