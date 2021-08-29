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

import UIKit
import Playback
import Epic
import FeedKit
import Combine
import SwiftUI

struct PlayerFactory {
  var fallback: UIImage {
    UIImage()
  }
  
  func loadImage(representing entry: Entry, at size: CGSize) -> AnyPublisher<UIImage, Never> {
    ImageRepository.shared.loadImage(representing: entry, at: size)
      .replaceError(with: fallback)
      .eraseToAnyPublisher()
  }
}
