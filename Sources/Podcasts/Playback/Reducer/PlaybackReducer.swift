import Foundation
import Playback
import Combine
import FeedKit
import os.log
import Epic

private let log = OSLog(subsystem: "ink.codes.podest", category: "PlaybackReducer")

struct PlaybackReducer {
  let factory: PlayerFactory
  
  func reducer(state: PlaybackController.State, action: PlaybackController.Action) -> AnyPublisher<PlaybackController.State, Never> {
    switch state {
    case let .full(entry, asset, player):
      return Full(entry: entry, asset: asset, player: player, factory: factory)
        .reduce(action)
      
    case let .mini(entry, asset, player):
      return Mini(entry: entry, asset: asset, player: player, factory: factory)
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
