//
//  Full.swift
//  
//
//  Created by Michael Nisi on 17.06.21.
//

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
      switch action.event {
      case .inactive(_):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .paused(entry, asset, error):
        player.isPlaying = false
        
        return factory.transformListening(entry: entry, asset: asset!, player: player)
          .eraseToAnyPublisher()
        
      case let .preparing(entry, _):
        return factory.transformListening(entry: entry, asset: asset, player: player)
          .eraseToAnyPublisher()
        
      case let .listening(entry, asset):
        return transformListeningFor(action.playerType, entry: entry, asset: asset)
        
      case let .viewing(entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}

private extension PlaybackReducer.Full {
  func transformListeningFor(
    _ playerType: PlaybackController.PlayerType,
    entry: Entry,
    asset: AssetState
  ) -> AnyPublisher<PlaybackController.State, Never>  {
    switch playerType {
    case .full:
      return factory.transformListening(entry: entry, asset: asset)
        .eraseToAnyPublisher()
      
    case .mini:
      return factory.transformListeningMini(entry: entry, asset: asset)
        .eraseToAnyPublisher()
      
    case .video:
      return Just(.none)
        .eraseToAnyPublisher()
      
    case .none:
      return Just(.none)
        .eraseToAnyPublisher()
    }
  }
}


