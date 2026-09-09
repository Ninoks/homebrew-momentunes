cask "momentunes" do
  version "0.2.1"
  sha256 "3ba67108ad7f94011c71c89ef2dfd4a4cf95266c14a4f3d0d74de4e44a348221"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.2.1/Momentunes-darwin-arm64-0.2.1.zip"
  name "Momentunes"
  desc "Menu-bar app for sharing Spotify listening with approved friends"
  homepage "https://github.com/Ninoks/homebrew-momentunes"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Momentunes.app"

  zap trash: [
    "~/Library/Application Support/Momentunes",
    "~/Library/Preferences/com.momentunes.app.plist",
    "~/Library/Saved Application State/com.momentunes.app.savedState",
  ]
end
