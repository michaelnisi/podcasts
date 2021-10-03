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

import Combine
import UIKit

extension Publishers {
  var appState: AnyPublisher<UIApplication.State, Never> {
    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
      .merge(with: NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification))
      .compactMap { notification in
        switch notification.name {
        case UIApplication.willResignActiveNotification:
            return .inactive
          
        case UIApplication.willEnterForegroundNotification:
            return .active
          
        default:
            return nil
        }
    }
    .eraseToAnyPublisher()
  }
}
