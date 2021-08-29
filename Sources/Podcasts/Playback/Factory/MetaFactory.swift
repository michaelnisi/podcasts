//===----------------------------------------------------------------------===//
//
// This source file is part of the Podcasts open source project
//
// Copyright (c) 2021 Michael Nisi and collaborators
// Licensed under MIT License
//
// See https://github.com/michaelnisi/podest/blob/main/LICENSE for license information
//
//===----------------------------------------------------------------------===//

import Playback
import FeedKit

struct MetaFactory<T> {
  let value: T?
  
  func make() -> PlaybackController.Meta where T == PlaybackError {
    guard let value = value else {
      return .none
    }
    
    switch value {
    case .unreachable:
      return .error(
        LocalizedStringKey.error_offline_title.string,
        LocalizedStringKey.error_offline_message.string
      )
    
    default:
      return .error(
        LocalizedStringKey.error_unknown_title.string,
        LocalizedStringKey.error_unknown_message.string
      )
    }
  }
  
  func make() -> PlaybackController.Meta? where T == Entry {
    guard let value = value else {
      return nil
    }
    
    return .more(value)
  }
}
