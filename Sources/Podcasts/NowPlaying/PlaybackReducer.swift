//
//  PlaybackStateTransformer.swift
//  Podest
//
//  Created by Michael Nisi on 24.05.21.
//  Copyright © 2021 Michael Nisi. All rights reserved.
//

import Foundation
import Playback
import Combine
import FeedKit

struct PlaybackReducer {
  let factory: PlayerFactory
  
  func reducer(state: Playing.State, action: PlaybackState<Entry>) -> AnyPublisher<Playing.State, Never> {
    switch state {
    case .full:
      switch action {
      case .inactive(_):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .paused(_, _, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .preparing(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .listening(entry, asset):
        return factory.transformListening(entry: entry, asset: asset)
          .eraseToAnyPublisher()
        
      case let .viewing(entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    case let .mini(entry, player):
      switch action {
      case .inactive(_):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .paused(_, _, _):
        player.configure(item: player.item, isPlaying: false)
        
        return Just(.mini(entry, player))
          .eraseToAnyPublisher()
        
      case .preparing(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .listening(entry, asset):
        return factory.transformListeningMini(entry: entry, asset: asset, player: player)
          .eraseToAnyPublisher()
        
      case let .viewing(entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    case .video(_, _):
      switch action {
      case .inactive(_):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .paused(_, _, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .preparing(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .listening(entry, asset):
        return factory.transformListening(entry: entry, asset: asset)
          .eraseToAnyPublisher()
        
      case let .viewing(entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    case .none:
      switch action {
      case .inactive(_):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .paused(_, _, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .preparing(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .listening(entry, asset):
        return factory.transformListeningMini(entry: entry, asset: asset)
          .eraseToAnyPublisher()
        
      case let .viewing(entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
