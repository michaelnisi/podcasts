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
import Playback
import FeedKit

extension PlaybackController.Action {
  init(playback: PlaybackState<Entry>, type: PlaybackController.PlayerType) {
    switch playback {
    case let .inactive(error):
      self = .inactive(type, error)
      
    case let .paused(entry, asset, error):
      self = .paused(type, entry, asset, error)
      
    case let .preparing(entry, resuming):
      self = .preparing(type, entry, resuming)
      
    case let .listening(entry, asset):
      self = .listening(type, entry, asset)
      
    case let .viewing(entry, player):
      self = .viewing(type, entry, player)
    }
  }
}
