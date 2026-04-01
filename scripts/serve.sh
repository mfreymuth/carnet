#!/bin/bash
set -euo pipefail

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

cd quartz
npm install
cp ../config/quartz.config.ts .
cp ../config/quartz.layout.ts .
rm -rf ./content
cp -r ../content ./content
echo "→ Serving on http://localhost:8080"
npx quartz build --serve
