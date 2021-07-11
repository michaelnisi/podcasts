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
      switch action {
      case .inactive(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .paused(_, entry, asset, error):
        player.isPlaying = false
        
        return factory.transformListening(entry: entry, asset: asset!, player: player)
          .eraseToAnyPublisher()
        
      case let .preparing(_, entry, _):
        return factory.transformListening(entry: entry, asset: asset, player: player)
          .eraseToAnyPublisher()
        
      case let .listening(type, entry, asset):
        switch type {
        case .full:
          return factory.transformListening(entry: entry, asset: asset, player: player)
              .eraseToAnyPublisher()
          
        case .mini, .none:
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
