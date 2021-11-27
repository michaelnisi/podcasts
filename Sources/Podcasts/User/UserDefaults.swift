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

extension UserDefaults {
  static var automaticDownloadsKey = "automaticDownloads"
  static var discretionaryDownloads = "discretionaryDownloads"
  static var mobileDataStreamingKey = "mobileDataStreaming"
  static var mobileDataDownloadsKey = "mobileDataDownloads"
  static var lastUpdateTimeKey = "ink.codes.podest.last-update"
}

public extension UserDefaults {
  var automaticDownloads: Bool {
    bool(forKey: UserDefaults.automaticDownloadsKey)
  }

  var discretionaryDownloads: Bool {
    ProcessInfo.processInfo.isLowPowerModeEnabled ||
      bool(forKey: UserDefaults.discretionaryDownloads)
  }

  var mobileDataStreaming: Bool {
    bool(forKey: UserDefaults.mobileDataStreamingKey)
  }

  var mobileDataDownloads: Bool {
    bool(forKey: UserDefaults.mobileDataDownloadsKey)
  }

  var lastUpdateTime: Double {
    get { double(forKey: UserDefaults.lastUpdateTimeKey) }
    set { set(newValue, forKey: UserDefaults.lastUpdateTimeKey) }
  }
  
  func isLastUpdate(outside deadline: TimeInterval = 3600) -> (Double, Bool) {
    let now = Date().timeIntervalSince1970
    
    return (now, true)
    
    return (now, now - lastUpdateTime > deadline)
  }

  static func registerPodcastsDefaults(_ user: UserDefaults = UserDefaults.standard) {
    user.register(defaults: [
      mobileDataDownloadsKey: false,
      mobileDataStreamingKey: false,
      automaticDownloadsKey: !Podcasts.settings.noDownloading,
      lastUpdateTimeKey: 0,
    ])
  }
}
