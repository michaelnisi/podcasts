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
import os.log
import FileProxy

private let logger = Logger(subsystem: "ink.codes.podcasts", category: "Files")

enum Files {
  static func install() {
    Podcasts.playback.makeURL = makeURL
  }
  
  static func makeURL(url: URL) -> URL? {
    do {
      return try Podcasts.files.url(for: url)
    } catch {
      switch error {
      case FileProxyError.fileSizeRequired:
        logger.warning("missing file size")
        
        return url
      default:
        return nil
      }
    }
  }
}
