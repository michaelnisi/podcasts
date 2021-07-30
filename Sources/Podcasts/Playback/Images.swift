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

import FeedKit
import Playback

extension Entry: Imaginable {
  public func makeURLs() -> ImageURLs {
    guard let iTunes = iTunes else {
      return ImageURLs(
        id: feed.hash,
        title: title,
        small: feedImage!,
        medium: feedImage!,
        large: feedImage!
      )
    }
    
    return ImageURLs(
      id: iTunes.iTunesID,
      title: title,
      small: iTunes.img60,
      medium: iTunes.img100,
      large: iTunes.img600
    )
  }
}

extension Feed: Imaginable {
  public func makeURLs() -> ImageURLs {
    guard let iTunes = iTunes else {
      fatalError("missing iTunes")
    }
    
    return ImageURLs(
      id: iTunes.iTunesID,
      title: title,
      small: iTunes.img60,
      medium: iTunes.img100,
      large: iTunes.img600
    )
  }
}
