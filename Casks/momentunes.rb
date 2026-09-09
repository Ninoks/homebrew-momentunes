cask "momentunes" do
  version "0.1.2"
  sha256 "d618b6627d36d03427862452b1cbdc0e780e4b6c9b960781faca6c2ae013c5e9"

  url "https://github.com/Ninoks/homebrew-momentunes/releases/download/v0.1.2/Momentunes-darwin-arm64-0.1.2.zip"
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
