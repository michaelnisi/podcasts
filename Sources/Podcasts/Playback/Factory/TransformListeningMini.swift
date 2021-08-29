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

private extension AssetState {
  var playback: Epic.PlaybackState {
    isPlaying ? .playing : .paused
  }
}

extension PlayerFactory {
  func makeMiniPlayerItem(entry: Entry, image: UIImage) -> MiniPlayer.Item {
    MiniPlayer.Item(title: entry.title, image: image)
  }
  
  func transformListeningMini(
    entry: Entry,
    asset: AssetState,
    player: MiniPlayer? = nil,
    error: PlaybackError? = nil,
    more: Entry? = nil
  ) -> AnyPublisher<PlaybackController.State, Never> {
    loadImage(representing: entry, at: CGSize(width: 600, height: 600))
      .map { image in
        let player = player ?? Epic.MiniPlayer()
        let item = self.makeMiniPlayerItem(entry: entry, image: image)
        
        player.actionHandler = { action in
          switch action {
          case .play:
            Podcasts.player.setItem(matching: EntryLocator(entry: entry))
          
          case .pause:
            Podcasts.player.pause()
            
          case .showPlayer:
            Podcasts.player.showPlayer()
          }
        }
        
        player.configure(item: item, playback: asset.playback)
        
        return .mini(
          entry,
          asset,
          player,
          MetaFactory(value: more).make() ?? MetaFactory(value: error).make()
        )
      }
      .eraseToAnyPublisher()
  }
}
