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
import Playback
import TipTop

let conf: Configuration = {
  try! Configuration(url: Bundle.main.url(forResource: "config", withExtension: "json")!)
}()

public let settings: Settings = conf.settings
public let contact: Contact = conf.contact
public let images: Images = try! conf.freshImageRepo()
public let finder: Searching = try! conf.freshSearchRepo()
public let browser: Browsing = conf.browser
public let userCaching: Caching = conf.userCache
public let feedCaching: Caching = conf.feedCache
public let iCloud: UserSyncing = conf.makeUserClient()
public let store: Shopping = try! conf.makeStore()
public let files: Downloading = conf.makeFileRepo()
public var userLibrary: Subscribing = conf.user
public var userQueue: Queueing = conf.user
public let playback = PlaybackSession<Entry>(times: TimeRepository.shared)
public let player = PlaybackController()
