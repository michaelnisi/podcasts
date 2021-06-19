//
//  Files.swift
//  
//
//  Created by Michael Nisi on 19.06.21.
//

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
