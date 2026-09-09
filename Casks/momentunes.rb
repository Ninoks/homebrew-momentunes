cask "momentunes" do
  version "0.1.1"
  sha256 "2ed1efe9186b03ba64dd46fa2e83a7d68f3d8bc2bc0b73ac610e0c6e6d020ff9"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.1.1/Momentunes-darwin-arm64-0.1.1.zip"
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
