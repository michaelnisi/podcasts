//
//  Action.swift
//  
//
//  Created by Michael Nisi on 11.07.21.
//

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
