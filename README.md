# Momentunes tap

Homebrew tap for [Momentunes](https://github.com/Ninoks/momentunes), a private
macOS menu-bar app for sharing Spotify listening with approved friends.

This repository holds the cask and the release builds. The application source
lives in a separate private repository.

## Install

```sh
brew trust Ninoks/momentunes
brew install --cask Ninoks/momentunes/momentunes
xattr -dr com.apple.quarantine /Applications/Momentunes.app
```

Homebrew 6 will not load a cask from a third-party tap until you trust it. The
last line is needed because the build is not notarized yet: it is signed, but
Gatekeeper still blocks a quarantined download. Opening the app once from
System Settings → Privacy & Security → **Open Anyway** works too.

Momentunes needs an invitation and a Spotify account that has been added to the
app's allowlist. Installing it without both does nothing.

## Staying up to date

```sh
brew upgrade --cask momentunes
```

To let that happen on its own, every 12 hours:

```sh
brew tap domt4/autoupdate
brew autoupdate start 43200 --upgrade --cleanup
```

Relaunch Momentunes from the menu bar after an upgrade to pick up the new build.
