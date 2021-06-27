//
//  Images.swift
//  
//
//  Created by Michael Nisi on 05.04.21.
//

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
