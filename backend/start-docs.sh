#!/bin/bash
cd /srv/weltenwind
npx serve -s node_modules/swagger-editor-dist -l 3001 -c ../openapi.yml
