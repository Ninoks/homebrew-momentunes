cask "momentunes" do
  version "0.3.0"
  sha256 "b1ef5e9aadfb775236535f2050ab658aea599d2906cf0e535b2719b913f5cfc0"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.3.0/Momentunes-darwin-arm64-0.3.0.zip"
  name "Momentunes"
  desc "Menu-bar app for sharing Spotify listening with approved friends"
  homepage "https://github.com/Ninoks/homebrew-momentunes"

  auto_updates true

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Momentunes.app"

  zap trash: [
    "~/Library/Application Support/Momentunes",
    "~/Library/Preferences/com.momentunes.app.plist",
    "~/Library/Saved Application State/com.momentunes.app.savedState",
  ]
end
