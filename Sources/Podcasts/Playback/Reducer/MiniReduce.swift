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
  struct Mini {
    let player: Epic.MiniPlayer
    let factory: PlayerFactory
    let oldState: PlaybackController.State
    
    func reduce(_ action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
      switch action {
      case .inactive(_, _):
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case let .paused(type, entry, asset, error):
        guard let asset = asset else {
          fatalError("unhandled problem: missing asset")
        }
            
        switch type {
        case .full:
          return factory.transformListening(entry: entry, asset: asset, player: nil)
              
        case .mini, .none:
          return factory.transformListeningMini(entry: entry, asset: asset, player: player, error: error)
        }
        
      case .preparing:
        return Just(oldState).eraseToAnyPublisher()
        
      case let .listening(type, entry, asset):
        switch type {
        case .full:
          return factory.transformListening(entry: entry, asset: Podcasts.playback.assetState ?? asset)
          
        case .mini, .none:
          return factory.transformListeningMini(entry: entry, asset: asset, player: player)
        }

      case let .viewing(_, entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
