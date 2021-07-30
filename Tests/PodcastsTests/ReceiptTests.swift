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

import XCTest
import StoreKit
@testable import Podcasts

/// Tests in-app purchase receipts, `PodestReceipt`.
class ReceiptTests: XCTestCase {
  
  func testInvalidReceipts() {
    let past = PodestReceipt(
      productIdentifier: "abc",
      transactionIdentifier: "123",
      transactionDate: Date.distantPast
    )
    
    let future = PodestReceipt(
      productIdentifier: "abc",
      transactionIdentifier: "123",
      transactionDate: Date.distantFuture
    )
    
    let found = [
      StoreFSM.validProductIdentifier([], matching: Set()),
      StoreFSM.validProductIdentifier([past], matching: Set()),
      StoreFSM.validProductIdentifier([past], matching: Set(["def"])),
      StoreFSM.validProductIdentifier([past], matching: Set(["abc"])),
      StoreFSM.validProductIdentifier([future], matching: Set(["def"]))
    ]
    
    for f in found {
      XCTAssertNil(f)
    }
  }
  
  func testValidReceipts() {
    let past = PodestReceipt(
      productIdentifier: "abc",
      transactionIdentifier: "123",
      transactionDate: Date.distantPast
    )
    
    let future = PodestReceipt(
      productIdentifier: "abc",
      transactionIdentifier: "123",
      transactionDate: Date.distantFuture
    )
    
    let recent = PodestReceipt(
      productIdentifier: "def",
      transactionIdentifier: "123",
      transactionDate: Date.init(timeIntervalSinceNow: -3600)
    )
    
    let found = [
      StoreFSM.validProductIdentifier([future], matching: Set(["abc"])),
      StoreFSM.validProductIdentifier([past, future], matching: Set(["abc"])),
      StoreFSM.validProductIdentifier([future, past], matching: Set(["abc"])),
      StoreFSM.validProductIdentifier([past, future, past], matching: Set(["abc"])),
      StoreFSM.validProductIdentifier([recent, past, future], matching: Set(["def"])),
      StoreFSM.validProductIdentifier([past, recent, past], matching: Set(["def"])),
      StoreFSM.validProductIdentifier([future, past, recent], matching: Set(["def"]))
    ]
    
    let wanted = [
      "abc",
      "abc",
      "abc",
      "abc",
      "def",
      "def",
      "def"
    ]
    
    for (n, f) in found.enumerated() {
      let w = wanted[n]
      XCTAssertEqual(f, w)
    }
  }
  
}
