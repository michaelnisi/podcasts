//
//  Factory.swift
//  Podest
//
//  Created by Michael Nisi on 23.05.21.
//  Copyright © 2021 Michael Nisi. All rights reserved.
//

import UIKit
import Playback
import Epic
import FeedKit
import Combine
import SwiftUI

// MARK: - Images

struct PlayerFactory {
  var fallback: UIImage {
    UIImage()
  }
  
  func loadImage(representing entry: Entry, at size: CGSize) -> AnyPublisher<UIImage, Never> {
    ImageRepository.shared.loadImage(representing: entry, at: size)
      .replaceError(with: fallback)
      .eraseToAnyPublisher()
  }
}

// MARK: - Full

extension PlayerFactory {
  func makePlayerItem(entry: Entry, image: UIImage) -> Epic.Player.Item {
    Epic.Player.Item(
      title: entry.title,
      subtitle: entry.feedTitle ?? "Some Podcast",
      colors: Colors(image: image),
      image: Image(uiImage: image)
    )
  }
  
  func transformListening(entry: Entry, asset: AssetState, player: Epic.Player? = nil) -> AnyPublisher<Playing.State, Never> {
    loadImage(representing: entry, at: CGSize(width: 600, height: 600))
      .map { image in
        let item = self.makePlayerItem(entry: entry, image: image)
        let player = player ?? Epic.Player(
          item: item,
          isPlaying: asset.isPlaying,
          isForwardable: true,
          isBackwardable: true,
          trackTime: asset.time
        )
        
        player.actionHandler = { action in
          switch action {
          case .play:
            Podcasts.player.setItem(matching: EntryLocator(entry: entry))
          
          case .pause:
            Podcasts.player.pause()
            
          case .forward:
            break
            
          case .backward:
            break
            
          case .close:
            break
          }
        }
        
        return .full(entry, asset, player)
      }
      .eraseToAnyPublisher()
  }
}

// MARK: - Mini

private extension AssetState {
  var playback: Epic.PlaybackState {
    isPlaying ? .playing : .paused
  }
}

extension PlayerFactory {
  func makeMiniPlayerItem(entry: Entry, image: UIImage) -> MiniPlayer.Item {
    MiniPlayer.Item(title: entry.title, image: image)
  }
  
  func transformListeningMini(entry: Entry, asset: AssetState, player: MiniPlayer? = nil) -> AnyPublisher<Playing.State, Never> {
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
        
        return .mini(entry, asset, player)
      }
      .eraseToAnyPublisher()
  }
}

// MARK: - Video

extension Playing {

}
