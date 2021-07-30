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
import FeedKit
import AVKit

extension PlaybackReducer {
  struct None {
    let factory: PlayerFactory
    
    func reduce(_ action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
      switch action {
      case .inactive(_, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .paused(_, _, _, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case .preparing(_, _, _):
        return Just(.none)
          .eraseToAnyPublisher()
        
      case let .listening(type, entry, asset):
        precondition(type == .none)
        
        return factory.transformListeningMini(entry: entry, asset: asset, player: nil)
        
      case let .viewing(_, entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
