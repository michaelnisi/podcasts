// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Podcasts",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(
      name: "Podcasts",
      targets: ["Podcasts"]),
  ],
  dependencies: [
    .package(name: "FeedKit", url: "https://github.com/michaelnisi/feedkit", from: "17.0.0"),
    .package(name: "Playback", url: "https://github.com/michaelnisi/playback", from: "11.0.0"),
    .package(name: "FileProxy", url: "https://github.com/michaelnisi/fileproxy", from: "6.0.0")
  ],
  targets: [
    .target(
      name: "Podcasts",
      dependencies: ["FeedKit", "Playback", "FileProxy"]),
    .testTarget(
      name: "PodcastsTests",
      dependencies: ["Podcasts"]),
  ]
)
