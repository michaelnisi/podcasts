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

public extension UserDefaults {
  static var automaticDownloadsKey = "automaticDownloads"
  static var discretionaryDownloads = "discretionaryDownloads"
  static var mobileDataStreamingKey = "mobileDataStreaming"
  static var mobileDataDownloadsKey = "mobileDataDownloads"

  static var lastUpdateTimeKey = "ink.codes.podest.last-update"
  static var lastVersionPromptedForReviewKey = "ink.codes.podest.lastVersionPromptedForReview"

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
    
    return (now, now - lastUpdateTime > deadline)
  }

  var lastVersionPromptedForReview: String? {
    get { string(forKey: UserDefaults.lastVersionPromptedForReviewKey) }
    set { set(newValue, forKey: UserDefaults.lastVersionPromptedForReviewKey) }
  }

  static func registerDefaults(_ user: UserDefaults = UserDefaults.standard) {
    user.register(defaults: [
      mobileDataDownloadsKey: false,
      mobileDataStreamingKey: false,
      automaticDownloadsKey: !Podcasts.settings.noDownloading,
      lastUpdateTimeKey: 0,
      lastVersionPromptedForReviewKey: "0"
    ])
  }
}

extension UserDefaults {
  static var statusKey = "ink.codes.podest.status"
  static var expirationKey = "ink.codes.podest.expiration"
}
