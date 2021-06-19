//
//  File.swift
//  
//
//  Created by Michael Nisi on 17.06.21.
//

import Foundation
import Combine
import FeedKit
import AVKit

extension PlaybackReducer {
  struct Video {
    let entry: Entry
    let player: AVPlayer
    let factory: PlayerFactory
    
    func reduce(_ action: Playing.Action) -> AnyPublisher<Playing.State, Never> {
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
        return factory.transformListening(entry: entry, asset: asset)
          .eraseToAnyPublisher()
        
      case let .viewing(entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
