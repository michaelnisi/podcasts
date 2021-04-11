//
//  Services.swift
//  
//
//  Created by Michael Nisi on 10.04.21.
//

import Foundation

/// Trade representative contact information.
public struct Contact: Decodable {
  public let email: String
  public let github: String
  public let privacy: String
  public let review: String
}

struct Service: Equatable, Decodable {
  let name: String
  let secret: String?
  let url: String
  let version: String

  static func ==(lhs: Service, rhs: Service) -> Bool {
    lhs.name == rhs.name && lhs.version == rhs.version
  }
}

final class Services: Decodable {
  var services: [Service]
  var contact: Contact

  func service(_ name: String, at version: String) -> Service? {
    services.filter { svc in
      svc.name == name && svc.version == version
    }.first
  }
}
