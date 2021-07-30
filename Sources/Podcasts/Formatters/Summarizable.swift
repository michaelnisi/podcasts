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
import FeedKit

/// Types that conform to the `Summarizable` protocol are typically entities
/// that can be displayed as a single text paragraph.
public protocol Summarizable: Hashable {
  var summary: String? { get }
  var title: String { get }
  var author: String? { get }
  var guid: String { get }
}

// MARK: - Extending Core Types

extension Entry: Summarizable {}

extension Feed: Summarizable {
  public var guid: String {
    self.url // Anything unique for NSCache.
  }
}

