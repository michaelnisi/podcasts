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

import Foundation
import Combine
import Epic
import Playback
import FeedKit

extension PlaybackReducer {
  struct Full {
    let entry: Entry
    let asset: AssetState
    let player: Epic.Player
    let factory: PlayerFactory
    
    func reduce(_ action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
      switch action {
      case .inactive(_, _):
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case let .paused(type, entry, asset, error):
        switch type {
        case .full:
          return factory.transformListening(entry: entry, asset: asset!, player: player, error: error)
              .eraseToAnyPublisher()
          
        case let .mini(item):
          return factory.transformListeningMini(entry: entry, asset: asset!, more: item)
              .eraseToAnyPublisher()
          
        case .none:
          return factory.transformListeningMini(entry: entry, asset: asset!)
              .eraseToAnyPublisher()
        }
        
      case let .preparing(_, entry, _):
        return factory.transformListening(entry: entry, asset: asset, player: player)
          .eraseToAnyPublisher()
        
      case let .listening(type, entry, asset):
        switch type {
        case .full:
          return factory.transformListening(entry: entry, asset: asset, player: player)
              .eraseToAnyPublisher()
          
        case let .mini(item):
          return factory.transformListeningMini(entry: entry, asset: asset, more: item)
              .eraseToAnyPublisher()
          
        case .none:
          return factory.transformListeningMini(entry: entry, asset: asset)
              .eraseToAnyPublisher()
        }
        
      case let .viewing(_, entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
