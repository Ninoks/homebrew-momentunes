#!/bin/bash
# Momentunes installer.
#
#   curl -fsSL https://momentunes-nine.vercel.app/install | bash
#
# Installs the app through Homebrew, clears the Gatekeeper quarantine the
# unsigned build would otherwise trip on, and schedules background updates
# scoped to Momentunes alone.
set -euo pipefail

TAP="Ninoks/momentunes"
CASK="momentunes"
APP="/Applications/Momentunes.app"
INTERVAL="${MOMENTUNES_UPDATE_INTERVAL:-43200}"
AGENT_LABEL="app.momentunes.updater"
AGENT="$HOME/Library/LaunchAgents/$AGENT_LABEL.plist"
LOG_DIR="$HOME/Library/Logs/Momentunes"
SUPPORT_DIR="$HOME/Library/Application Support/Momentunes"
UPDATER="$SUPPORT_DIR/update.sh"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
info() { printf '  %s\n' "$1"; }
die() { printf '\033[31merror:\033[0m %s\n' "$1" >&2; exit 1; }

bold "Momentunes"

[ "$(uname -s)" = "Darwin" ] || die "Momentunes only runs on macOS."
[ "$(uname -m)" = "arm64" ] || die "Momentunes needs an Apple Silicon Mac."
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 14 ] || die "Momentunes needs macOS 14 (Sonoma) or newer."

BREW="$(command -v brew || true)"
if [ -z "$BREW" ]; then
  die "Homebrew is required. Install it first:
  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
Then run this installer again."
fi

# Homebrew 6 refuses to load casks from third-party taps until they are trusted.
# Older versions have no `trust` subcommand, so a failure here is not fatal.
info "Trusting the Momentunes tap"
brew trust "$TAP" >/dev/null 2>&1 || true

if [ -d "$APP" ] && brew list --cask "$CASK" >/dev/null 2>&1; then
  info "Updating Momentunes"
  brew upgrade --cask "$CASK" || info "Already at the latest version"
else
  info "Installing Momentunes"
  brew install --cask "$TAP/$CASK"
fi

[ -d "$APP" ] || die "Homebrew finished but $APP is missing."

# The build is signed, but ad-hoc rather than notarized, so Gatekeeper blocks
# the downloaded copy until the quarantine attribute is gone.
info "Clearing the download quarantine"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

# A launchd agent of our own rather than `brew autoupdate`: that tap is broken
# on Homebrew 6 ("undefined method 'quiet_system'"), and it would upgrade every
# package on the machine unless carefully scoped.
if [ "${MOMENTUNES_NO_AUTOUPDATE:-}" = "1" ]; then
  info "Skipping background updates (MOMENTUNES_NO_AUTOUPDATE=1)"
else
  info "Scheduling background updates every $((INTERVAL / 3600))h"
  mkdir -p "$(dirname "$AGENT")" "$LOG_DIR" "$SUPPORT_DIR"

  cat > "$UPDATER" <<UPDATE
#!/bin/bash
# Refresh the tap first: \`brew upgrade\` on its own reads a cached copy and
# would never see a new release. Then clear the quarantine Homebrew re-applies
# to every download, without which the app stops launching after an update.
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
fi

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
info "Updates install themselves every $((INTERVAL / 3600))h. Relaunch the app to pick one up."
info "Update log: $LOG_DIR/updater.log"
echo
info "Remove everything with:"
info "  launchctl bootout gui/\$(id -u)/$AGENT_LABEL && rm -f $AGENT"
info "  brew uninstall --cask $CASK"
