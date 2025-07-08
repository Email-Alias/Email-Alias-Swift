#!/bin/bash
npm install --prefix Safari\ Extension/Resources/extension/Angular
npm run build:safari --prefix Safari\ Extension/Resources/extension/Angular
rm -f -R Safari\ Extension/Resources/extension/src
mv Safari\ Extension/Resources/extension/Angular/dist/email-alias/browser Safari\ Extension/Resources/src
cp -r Safari\ Extension/Resources/extension/shared/content.js Safari\ Extension/Resources