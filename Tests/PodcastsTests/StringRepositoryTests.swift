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
import FeedKit

@testable import Podcasts

class StringRepositoryTests: XCTestCase {

  struct EntrySubtitles: Codable {
    let entries: [Entry]
    let subtitles: [String]
  }

  struct TestData: Codable {
    let entrySubtitles: EntrySubtitles
  }

  lazy var entrySubtitles: EntrySubtitles = {
    let url = Bundle.module.url(forResource: "strings", withExtension: "json")!
    let json = try! Data(contentsOf: url)
    let decoder = JSONDecoder()

    let data = try! decoder.decode(TestData.self, from: json)

    return data.entrySubtitles
  }()

  func testEpisodeCellSubtitle() {
    let entries = entrySubtitles.entries
    let subtitles = entrySubtitles.subtitles

    for (i, entry) in entries.enumerated() {
      let found = StringRepository.episodeCellSubtitle(for: entry)
      let wanted = subtitles[i]
      
      XCTAssertEqual(found, wanted)
    }
  }

}
