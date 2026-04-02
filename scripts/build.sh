#!/bin/bash
set -euo pipefail

echo "→ Installing dependencies..."
cd quartz
npm install

echo "→ Copying config and content..."
cp ../config/quartz.config.ts .
cp ../config/quartz.layout.ts .
cp ../config/custom.scss ./quartz/styles/custom.scss
rm -rf ./content
cp -r ../content ./content

echo "→ Building..."
npx quartz build --output ../public
echo "✓ Done → public/"
