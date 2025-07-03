#!/bin/bash
npm install --prefix Safari\ Extension/Resources/Angular
npm run build:safari --prefix Safari\ Extension/Resources/Angular
rm -f -R Safari\ Extension/Resources/src
mv Safari\ Extension/Resources/Angular/dist/email-alias/browser Safari\ Extension/Resources/src
cp -r Safari\ Extension/Resources/extension/shared/* Safari\ Extension/Resources