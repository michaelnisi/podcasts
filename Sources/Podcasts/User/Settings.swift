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
