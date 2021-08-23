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
  struct Video {
    let entry: Entry
    let player: AVPlayer
    let factory: PlayerFactory
    
    func reduce(_ action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
      switch action {
      case .inactive(_, _):
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case .paused(_, _, _, _):
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case .preparing(_, _, _):
        return Just(.none(.none))
          .eraseToAnyPublisher()
        
      case let .listening(_, entry, asset):
        return factory.transformListening(entry: entry, asset: asset)
          .eraseToAnyPublisher()
        
      case let .viewing(_, entry, player):
        return Just(.video(entry, player))
          .eraseToAnyPublisher()
      }
    }
  }
}
