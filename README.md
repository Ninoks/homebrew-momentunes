# Momentunes tap

Homebrew tap and release builds for Momentunes, a private macOS menu-bar app
for sharing Spotify listening with approved friends. The application source
lives in a separate private repository.

## Install

```sh
curl -fsSL https://momentunes-nine.vercel.app/install | bash
```

That installs the app, clears the Gatekeeper quarantine an un-notarized build
would otherwise trip on, and schedules updates every 12 hours. Run it again any
time to upgrade.

If the API is unreachable, `install.sh` in this repository is the same script:

```sh
curl -fsSL https://raw.githubusercontent.com/Ninoks/homebrew-momentunes/main/install.sh | bash
```

Momentunes needs an invitation and a Spotify account on the app's allowlist.
Installing it without both does nothing.

## By hand

```sh
brew trust Ninoks/momentunes
brew install --cask Ninoks/momentunes/momentunes
xattr -dr com.apple.quarantine /Applications/Momentunes.app
```

Homebrew 6 refuses to load casks from untrusted third-party taps, and it removed
`--no-quarantine`, so both extra steps are required. Repeat the `xattr` line
after every `brew upgrade --cask momentunes` — Homebrew re-applies the attribute
to each download, and the app will not launch with it set.

## Uninstall

```sh
launchctl bootout gui/$(id -u)/app.momentunes.updater
rm -f ~/Library/LaunchAgents/app.momentunes.updater.plist
brew uninstall --cask momentunes
```
