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

/// Extending user defaults with our settings.
///
/// For preventing key collisions, all user defaults keys should be listed here,
/// which they aren’t at the moment, I’m looking at you, sync.
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
    double(forKey: UserDefaults.lastUpdateTimeKey)
  }

  var lastVersionPromptedForReview: String? {
    string(forKey: UserDefaults.lastVersionPromptedForReviewKey)
  }

  static func registerPodestDefaults(_ user: UserDefaults = UserDefaults.standard) {
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

/// Additional **development** settings may override user defaults.
public struct Settings {

  /// Despite disabling iCloud in Settings.app makes the better, more realistic,
  /// environment, this argument can be used during development. Passing `true`
  /// produces a NOP iCloud client at initialization time.
  ///
  /// Disabling sync also disables preloading media files.
  public let noSync: Bool

  /// Removes local caches for starting over.
  public let flush: Bool

  /// Prevents automatic downloading of media files. Good for quick sessions in
  /// simulators, where background downloads may be pointless.
  public let noDownloading: Bool

  /// Overrides allowed interface orientations, allowing all but upside down.
  public let allButUpsideDown: Bool

  /// Removes IAP receipts.
  public let removeReceipts: Bool

  /// Creates new settings from process info arguments.
  init (arguments: [String]) {
    noSync = arguments.contains("-ink.codes.podest.noSync")
    flush = arguments.contains("-ink.codes.podest.flush")
    noDownloading = arguments.contains("-ink.codes.podest.noDownloading")
      || arguments.contains("-ink.codes.podest.noSync")
    allButUpsideDown = arguments.contains("-ink.codes.podest.allButUpsideDown")
    removeReceipts = arguments.contains("-ink.codes.podest.removeReceipts")
  }
}
