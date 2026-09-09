# Momentunes tap

Homebrew tap for [Momentunes](https://github.com/Ninoks/momentunes), a private
macOS menu-bar app for sharing Spotify listening with approved friends.

This repository holds the cask and the release builds. The application source
lives in a separate private repository.

## Install

```sh
brew install --cask --no-quarantine Ninoks/momentunes/momentunes
```

`--no-quarantine` is required while the build is unsigned. Without it macOS
blocks the first launch and you have to allow the app under System Settings →
Privacy & Security.

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
