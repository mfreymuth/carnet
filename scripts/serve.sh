#!/bin/bash
set -euo pipefail

export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

cd quartz
npm install
cp ../config/quartz.config.ts .
cp ../config/quartz.layout.ts .
cp ../config/custom.scss ./quartz/styles/custom.scss
rm -rf ./content
cp -r ../content ./content
npx quartz build --serve
