#!/bin/bash
set -euo pipefail

cd quartz
npm install
cp ../config/quartz.config.ts .
cp ../config/quartz.layout.ts .
rm -rf ./content
cp -r ../content ./content

echo "→ Serving on http://localhost:8080"
npx quartz build --serve
