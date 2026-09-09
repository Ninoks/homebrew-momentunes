cask "momentunes" do
  version "0.2.0"
  sha256 "c7e23ff0ca8f1d83bb0b3ec9cda968cb5847562a33e385cb89cadb085fa68bd8"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.2.0/Momentunes-darwin-arm64-0.2.0.zip"
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
