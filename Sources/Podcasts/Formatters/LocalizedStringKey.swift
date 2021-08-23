//===----------------------------------------------------------------------===//
//
// This source file is part of the Podest open source project
//
// Copyright (c) 2021 Michael Nisi and collaborators
// Licensed under MIT License
//
// See https://github.com/michaelnisi/podest/blob/main/LICENSE for license information
//
//===----------------------------------------------------------------------===//

import Foundation

enum LocalizedStringKey: String {
  case no_summary
  case error_offline_title
  case error_offline_message
  case error_unknown_title
  case error_unknown_message
  case invalid_feed
}

extension LocalizedStringKey {
  var string: String {
    NSLocalizedString(rawValue, bundle: .module, comment: "")
  }
}
