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
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case let .paused(_, _, _, error):
        return Just(.none(MetaFactory(value: error).make()))
          .eraseToAnyPublisher()
        
      case .preparing(_, _, _):
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case let .listening(_, entry, asset):
        return factory.transformListeningMini(entry: entry, asset: asset, player: nil)
        
      case let .viewing(_, entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
