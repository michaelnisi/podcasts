//===----------------------------------------------------------------------===//
//
// This source file is part of the Podcasts open source project
//
// Copyright (c) 2021 Michael Nisi and collaborators
// Licensed under MIT License
//
// See https://github.com/michaelnisi/podest/blob/main/LICENSE for license information
//
//===----------------------------------------------------------------------===//

import UIKit
import Playback
import Epic
import FeedKit
import Combine
import SwiftUI

extension PlayerFactory {
  func makePlayerItem(entry: Entry, image: UIImage) -> Epic.Player.Item {
    Epic.Player.Item(
      title: entry.title,
      subtitle: entry.feedTitle ?? "Some Podcast",
      colors: Colors(image: image),
      image: Image(uiImage: image)
    )
  }
  
  func transformListening(
    entry: Entry,
    asset: AssetState,
    player: Epic.Player? = nil,
    error: PlaybackError? = nil
  ) -> AnyPublisher<PlaybackController.State, Never> {
    loadImage(representing: entry, at: CGSize(width: 600, height: 600))
      .map { image in
        let item = self.makePlayerItem(entry: entry, image: image)
        
        let player = player ?? Epic.Player()
        
        player.configure(
          item: item,
          isPlaying: asset.isPlaying,
          isForwardable: true,
          isBackwardable: true,
          trackTime: asset.time,
          trackDuration: asset.duration
        )
        
        player.actionHandler = { action in
          switch action {
          case .play:
            Podcasts.player.setItem(matching: EntryLocator(entry: entry))
          
          case .pause:
            Podcasts.player.pause()
            
          case .forward:
            Podcasts.player.forward()
            
          case .backward:
            Podcasts.player.backward()
            
          case .close:
            Podcasts.player.hidePlayer()
            
          case let .scrub(time):
            Podcasts.player.scrub(time: time)
            
          case .skipForward:
            Podcasts.player.skipForward()
            
          case .skipBackward:
            Podcasts.player.skipBackward()
            
          case .more:
            Podcasts.player.more()
          }
        }
        
        return .full(entry, asset, player)
      }
      .eraseToAnyPublisher()
  }
}

