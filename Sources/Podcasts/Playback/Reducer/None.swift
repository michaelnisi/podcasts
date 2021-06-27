//
//  File.swift
//  
//
//  Created by Michael Nisi on 19.06.21.
//

import Foundation
import Combine
import FeedKit
import AVKit

extension PlaybackReducer {
  struct None {
    let factory: PlayerFactory
    
    func reduce(_ action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
      switch action.event {
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
