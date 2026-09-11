cask "momentunes" do
  version "0.3.1"
  sha256 "7d7ff90748e758ffa9fe13242a4c2db81026a28ee668a23a03186fa46710a9ca"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.3.1/Momentunes-darwin-arm64-0.3.1.zip"
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
