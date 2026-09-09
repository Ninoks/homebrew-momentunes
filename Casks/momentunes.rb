cask "momentunes" do
  version "0.1.0"
  sha256 "bf4d2d6eef5badc7c5a693e65df030b4483266bf54a1306eeca20d9d1f6c3c15"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.1.0/Momentunes-darwin-arm64-0.1.0.zip"
  name "Momentunes"
  desc "Menu-bar app for sharing Spotify listening with approved friends"
  homepage "https://github.com/Ninoks/homebrew-momentunes"

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "Momentunes.app"

  zap trash: [
    "~/Library/Application Support/Momentunes",
    "~/Library/Preferences/com.momentunes.app.plist",
    "~/Library/Saved Application State/com.momentunes.app.savedState",
  ]
end
