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

struct PlaybackReducer {
  let factory: PlayerFactory
  
  func reducer(
    state: PlaybackController.State,
    action: PlaybackController.Action
  ) -> AnyPublisher<PlaybackController.State, Never> {
    switch state {
    case let .full(entry, asset, player):
      return Full(entry: entry, asset: asset, player: player, factory: factory)
        .reduce(action)
      
    case let .mini(_, _, player, _):
      return Mini(player: player, factory: factory, oldState: state)
        .reduce(action)
      
    case let .video(entry, player):
      return Video(entry: entry, player: player, factory: factory)
        .reduce(action)
      
    case .none:
      return None(factory: factory)
        .reduce(action)
    }
  }
}
