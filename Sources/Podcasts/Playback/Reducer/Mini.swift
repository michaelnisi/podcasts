//
//  Mini.swift
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
  struct Mini {
    let entry: Entry
    let asset: AssetState
    let player: Epic.MiniPlayer
    let factory: PlayerFactory
    
    func reduce(_ action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
      switch action {
      case .inactive(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .paused(_, _, _, _):
        player.configure(item: player.item, playback: .paused)
        
        return Just(.mini(entry, asset, player))
          .eraseToAnyPublisher()
        
      case .preparing(_, _, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .listening(type, entry, asset):
        switch type {
        case .full:
          return factory.transformListening(entry: entry, asset: asset)
              .eraseToAnyPublisher()
          
        case .mini, .none:
          return factory.transformListeningMini(entry: entry, asset: asset, player: player)
              .eraseToAnyPublisher()
        }

      case let .viewing(_, entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
