// swift-tools-version:5.3
//===----------------------------------------------------------------------===//
//
// This source file is part of the Podcasts open source project
//
// Copyright (c) 2021 Michael Nisi and collaborators
// Licensed under MIT License
//
// See https://github.com/michaelnisi/podcasts/blob/main/LICENSE for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "Podcasts",
  defaultLocalization: "en",
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
    .package(name: "FileProxy", url: "https://github.com/michaelnisi/fileproxy", from: "6.0.0"),
    .package(name: "HTMLAttributor", url: "https://github.com/michaelnisi/hattr", from: "6.0.0"),
    .package(name: "Epic", url: "https://github.com/michaelnisi/epic", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "Podcasts",
      dependencies: ["FeedKit", "Playback", "FileProxy", "HTMLAttributor", "Epic"]),
    .testTarget(
      name: "PodcastsTests",
      dependencies: ["Podcasts"],
      resources: [.process("Resources")])
  ]
)
