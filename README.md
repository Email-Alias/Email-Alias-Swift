# Email Alias

An app to create alias for a self-hosted mailcow server. It supports iOS 17,
iPadOS 17, watchOS 10, macOS 14 and visionOS 1. The app does also include an
extension for Safari, which also syncs with the main app and does highlight
the email(s) with the current domain.

## Add code for Safari extension

Compile the angular app from
[the angular repository](https://github.com/Email-Alias/Email-Alias-Angular) and
move (or copy) the aritifacts from dist/one-percent/browser (angular repo) to
Web Extension/Resources/src (this repository).

## Compile the app

You should copy add the code for Safari extension before compiling the app.
After that, you just replace the development team with your own and use xCode
to run the app on your desired device.
