//
//  Podcasts.swift
//  Podest
//
//  Podcast App Core
//
//  Created by Michael Nisi on 24/04/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import Foundation
import FeedKit
import Playback

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
public let player = NowPlaying(playback: playback, userQueue: userQueue)
