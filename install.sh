#!/bin/bash
# Momentunes installer.
#
#   curl -fsSL https://momentunes-nine.vercel.app/install | bash
#
# Downloads the latest release straight into /Applications. Builds are
# Developer ID signed and notarized, so Gatekeeper opens them and the app
# installs its own updates. Homebrew is only used for copies it installed
# before signing existed: those keep the background updater that got them
# here, which carries them onto the first signed build.
set -euo pipefail

TAP="Ninoks/momentunes"
TAP_REPO="Ninoks/homebrew-momentunes"
CASK="momentunes"
# The cask is the release manifest: it names the current ZIP and its checksum.
CASK_URL="https://raw.githubusercontent.com/$TAP_REPO/HEAD/Casks/$CASK.rb"
APP="/Applications/Momentunes.app"
INTERVAL="${MOMENTUNES_UPDATE_INTERVAL:-43200}"
AGENT_LABEL="app.momentunes.updater"
AGENT="$HOME/Library/LaunchAgents/$AGENT_LABEL.plist"
LOG_DIR="$HOME/Library/Logs/Momentunes"
SUPPORT_DIR="$HOME/Library/Application Support/Momentunes"
UPDATER="$SUPPORT_DIR/update.sh"
WORK=""

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
info() { printf '  %s\n' "$1"; }
die() { printf '\033[31merror:\033[0m %s\n' "$1" >&2; exit 1; }
cleanup() { [ -z "$WORK" ] || rm -rf "$WORK"; }
trap cleanup EXIT

bold "Momentunes"

[ "$(uname -s)" = "Darwin" ] || die "Momentunes only runs on macOS."
[ "$(uname -m)" = "arm64" ] || die "Momentunes needs an Apple Silicon Mac."
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 14 ] || die "Momentunes needs macOS 14 (Sonoma) or newer."

BREW="$(command -v brew || true)"
if [ -n "$BREW" ] && "$BREW" list --cask "$CASK" >/dev/null 2>&1; then
  METHOD="homebrew"
else
  METHOD="direct"
fi

install_direct() {
  local manifest url sha
  manifest="$(curl -fsSL "$CASK_URL")" || die "Could not reach GitHub to find the latest release."
  url="$(printf '%s\n' "$manifest" | sed -n 's/^ *url "\(.*\)"$/\1/p' | head -n 1)"
  sha="$(printf '%s\n' "$manifest" | sed -n 's/^ *sha256 "\(.*\)"$/\1/p' | head -n 1)"
  [ -n "$url" ] && [ -n "$sha" ] || die "Could not read the latest release from $CASK_URL."

  WORK="$(mktemp -d)"
  info "Downloading $(basename "$url")"
  curl -fsSL "$url" -o "$WORK/Momentunes.zip" || die "The download failed."
  [ "$(shasum -a 256 "$WORK/Momentunes.zip" | cut -d' ' -f1)" = "$sha" ] \
    || die "The download does not match its published checksum."
  # ditto, not unzip: it keeps the symlinks and extended attributes the code
  # signature covers.
  ditto -x -k "$WORK/Momentunes.zip" "$WORK"
  [ -d "$WORK/Momentunes.app" ] || die "The download does not contain Momentunes.app."
  [ -w "$(dirname "$APP")" ] || die "$(dirname "$APP") is not writable by this account. Use an administrator account."

  if pgrep -x Momentunes >/dev/null 2>&1; then
    info "Quitting the running copy"
    osascript -e 'tell application "Momentunes" to quit' >/dev/null 2>&1 || pkill -x Momentunes || true
    sleep 2
  fi
  info "Installing into $(dirname "$APP")"
  rm -rf "$APP"
  ditto "$WORK/Momentunes.app" "$APP"
}

install_homebrew() {
  # Homebrew 6 refuses to load casks from third-party taps until they are
  # trusted. Older versions have no `trust` subcommand, so this is not fatal.
  "$BREW" trust "$TAP" >/dev/null 2>&1 || true
  info "Updating the Homebrew copy"
  "$BREW" upgrade --cask "$CASK" || info "Already at the latest version"
  [ -d "$APP" ] || die "Homebrew finished but $APP is missing."

  # Pre-signing builds are ad-hoc signed, and Homebrew quarantines every
  # download, so Gatekeeper blocks them until the attribute is gone.
  xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

  # A launchd agent of our own rather than `brew autoupdate`: that tap is broken
  # on Homebrew 6 ("undefined method 'quiet_system'"), and it would upgrade every
  # package on the machine unless carefully scoped.
  if [ "${MOMENTUNES_NO_AUTOUPDATE:-}" = "1" ]; then
    info "Skipping background updates (MOMENTUNES_NO_AUTOUPDATE=1)"
    return
  fi
  info "Scheduling background updates every $((INTERVAL / 3600))h"
  mkdir -p "$(dirname "$AGENT")" "$LOG_DIR" "$SUPPORT_DIR"

  cat > "$UPDATER" <<UPDATE
#!/bin/bash
# Refresh the tap first: \`brew upgrade\` on its own reads a cached copy and
# would never see a new release. Naming the cask upgrades it even once it
# declares \`auto_updates\`. Then clear the quarantine Homebrew re-applies to
# every download, without which an ad-hoc build stops launching after an update.
set -uo pipefail
"$BREW" update --quiet || exit 0
"$BREW" upgrade --cask "$CASK" || exit 0
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
UPDATE
  chmod +x "$UPDATER"

  cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key><string>$AGENT_LABEL</string>
    <key>ProgramArguments</key>
    <array>
      <string>/bin/bash</string>
      <string>$UPDATER</string>
    </array>
    <key>StartInterval</key><integer>$INTERVAL</integer>
    <key>RunAtLoad</key><false/>
    <key>StandardOutPath</key><string>$LOG_DIR/updater.log</string>
    <key>StandardErrorPath</key><string>$LOG_DIR/updater.log</string>
  </dict>
</plist>
PLIST

  launchctl bootout "gui/$(id -u)/$AGENT_LABEL" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "$AGENT" >/dev/null 2>&1 \
    || info "Could not schedule updates. Run 'brew upgrade --cask $CASK' when a fix ships."
}

if [ "$METHOD" = "homebrew" ]; then install_homebrew; else install_direct; fi

open -a "$APP" || true

echo
bold "Installed."
info "Momentunes lives in your menu bar, next to the clock."
info "Click it and sign in with your email."
echo
info "Two things must already be true for it to work:"
info "  1. Nino invited your email to Momentunes."
info "  2. The Spotify app is installed. Momentunes asks once for permission"
info "     to read what it is playing."
echo
if [ "$METHOD" = "homebrew" ]; then
  info "Updates install themselves every $((INTERVAL / 3600))h. Relaunch the app to pick one up."
  info "Update log: $LOG_DIR/updater.log"
  echo
  info "Remove everything with:"
  info "  launchctl bootout gui/\$(id -u)/$AGENT_LABEL && rm -f $AGENT"
  info "  brew uninstall --cask $CASK"
else
  info "Momentunes updates itself and tells you when a restart will apply it."
  echo
  info "Remove it with:"
  info "  rm -rf $APP \"$SUPPORT_DIR\""
fi
