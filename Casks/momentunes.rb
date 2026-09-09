cask "momentunes" do
  version "0.1.3"
  sha256 "379c836afa7faafd282d955e916d2f5ab80873cac8bff91a2e54a05b8537ce7b"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.1.3/Momentunes-darwin-arm64-0.1.3.zip"
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
