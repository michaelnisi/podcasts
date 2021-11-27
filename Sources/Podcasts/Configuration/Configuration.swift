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

import FanboyKit
import FeedKit
import Foundation
import MangerKit
import Ola
import Patron
import Skull
import os.log
import Playback
import TipTop

private let log = OSLog.disabled

// MARK: - Search Repository

/// Returns additional HTTP headers for `service`.
private func httpAdditionalHeaders(service: Service) -> [AnyHashable : Any]? {
  guard
    let userPasswordString = service.secret,
    let userPasswordData = userPasswordString.data(using: .utf8) else {
    return nil
  }
  
  let base64EncodedCredential = userPasswordData.base64EncodedString()
  let auth = "Basic \(base64EncodedCredential)"
  
  return ["Authorization" : auth]
}

private func makeFanboySession(service: Service) -> URLSession {
  let conf = URLSessionConfiguration.default
  
  conf.httpShouldUsePipelining = false
  conf.requestCachePolicy = .useProtocolCachePolicy
  conf.httpAdditionalHeaders = httpAdditionalHeaders(service: service)
  
  return URLSession(configuration: conf)
}

private func makeFanboyService(options: Service) -> FanboyService {
  let url = URL(string: options.url)!
  let session = makeFanboySession(service: options)
  let log = OSLog.disabled
  let client = Patron(URL: url as URL, session: session, log: log)
  
  return Fanboy(client: client)
}

private func makeSearchRepo(_ conf: Configuration) throws -> SearchRepository {
  let c = conf.feedCache
  let opts = conf.service("production", at: "*")!
  let svc = makeFanboyService(options: opts)
  
  let queue = OperationQueue()
  queue.maxConcurrentOperationCount = 1
  queue.qualityOfService = .userInitiated
  
  return SearchRepository(
    cache: c,
    svc: svc,
    browser: conf.browser,
    queue: queue
  )
}

// MARK: - Feed Repository

/// Returns a new URL session for the Manger service.
///
/// Adjusting timeout to fit into the 30 seconds time window allowed for
/// background fetching, leaving some space for other tasks. It would probably
/// be advisable to use two different timeout intervals, the default and a
/// shorter one for background fetching. Try this if 0x8badf00d appears in the
/// crash logs. On the other hand, 10 seconds seems long enough.
private func makeMangerSession(service: Service) -> URLSession {
  let conf = URLSessionConfiguration.default
  
  conf.httpShouldUsePipelining = false
  conf.requestCachePolicy = .useProtocolCachePolicy
  conf.httpAdditionalHeaders = httpAdditionalHeaders(service: service)
  conf.timeoutIntervalForResource = 20
  
  return URLSession(configuration: conf)
}

private func makeMangerService(options: Service) -> MangerService {
  let url = URL(string: options.url)!
  let session = makeMangerSession(service: options)
  let log = OSLog.disabled
  let client = Patron(URL: url, session: session, log: log)
  
  return Manger(client: client)
}

private func makeFeedRepo(_ conf: Configuration) throws -> FeedRepository {
  let c = conf.feedCache
  let opts = conf.service("production", at: "*")!
  let svc = makeMangerService(options: opts)
  let queue = OperationQueue()
  queue.qualityOfService = .userInitiated
  
  return FeedRepository(cache: c, svc: svc, queue: queue)
}

// MARK: - Caches

private func createDirectory(_ dir: URL) {
  do {
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
  } catch {
    let er = error as NSError
    
    switch (er.domain, er.code) {
    case (NSCocoaErrorDomain, 516): // file exists
      break
    default:
      fatalError(String(describing: error))
    }
  }
}

private func removeFile(at url: URL) {
  do {
    os_log("removing file: %@",
           log: log, type: .info, url.path)
    try FileManager.default.removeItem(at: url)
  } catch {
    os_log("failed to remove file: %@",
           log: log, type: .error, error as CVarArg)
  }
}

private func makeCache(_ conf: Configuration) -> FeedCache {
  dispatchPrecondition(condition: .onQueue(.main))
  
  let name = Bundle.main.bundleIdentifier!
  
  let dir = try! FileManager.default.url(
    for: .cachesDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: true
  ).appendingPathComponent(name, isDirectory: true)
  
  // Not naming it Cache.db to avoid conflicts with URLCache.
  let url = URL(string: "Feeds.db", relativeTo: dir)!
  
  if conf.settings.flush {
    removeFile(at: url)
  }
  
  createDirectory(dir)
  
  os_log("cache database at: %@",
         log: log, type: .info, url.path)
  
  return try! FeedCache(schema: cacheURL.path, url: url)
}

private func makeUserCache(_ conf: Configuration) -> UserCache {
  dispatchPrecondition(condition: .onQueue(.main))
  
  let name = Bundle.main.bundleIdentifier!
  
  let dir = try! FileManager.default.url(
    for: .applicationSupportDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: true
  ).appendingPathComponent(name, isDirectory: true)
  
  // All content in the .applicationSupportDirectory should be placed in a
  // custom subdirectory whose name is that of your app’s bundle identifier or
  // your company. In iOS, the contents of this directory are backed up by
  // iTunes and iCloud.
  
  let url = URL(string: "User.db", relativeTo: dir)!
  
  if conf.settings.flush {
    removeFile(at: url)
  }
  
  createDirectory(dir)
  os_log("user database at: %@", log: log, type: .info, url.path)
  let cache = try! UserCache(schema: userURL.path, url: url)
  
  return cache
}

// MARK: - Configuration

/// The default to boot the app with. Eventual differences between
/// development and production should be configured in the JSON file.
class Configuration {
  lazy var feedCache = makeCache(self)
  lazy var browser: Browsing = try! makeFeedRepo(self)
  
  let settings: Settings
  
  private let svcs: Services
  
  func service(_ name: String, at version: String) -> Service? {
    svcs.service(name, at: version)
  }
  
  var contact: Contact {
    svcs.contact
  }
  
  /// Initializes a new setup object with a provided URL of a local JSON
  /// configuration file.
  ///
  /// - Parameter url: The URL of the a local configuration file.
  init(url: URL) throws {
    settings = Settings(arguments: ProcessInfo.processInfo.arguments)
    
    os_log("settings: %{public}@",
           log: log, type: .info, String(describing: settings))
    
    let json = try! Data(contentsOf: url)
    svcs = try! JSONDecoder().decode(Services.self, from: json)
    
    os_log("services: %@", log: log, type: .info, svcs.services)
    
    if settings.flush {
      let keys = [
        UserDefaults.lastUpdateTimeKey
      ]
      
      for key in keys {
        UserDefaults.standard.removeObject(forKey: key)
        os_log("flushing: %{key}@", log: log, key)
      }
    }
  }
  
  func freshSearchRepo() throws -> Searching {
    try makeSearchRepo(self)
  }
  
  func freshImageRepo() throws -> Images {
    ImageRepository.shared
  }
  
  lazy var userCache = makeUserCache(self)
  
  private lazy var synchronizedQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.qualityOfService = .utility
    queue.name = "ink.codes.podcasts.Configuration.Sync"
    
    return queue
  }()
  
  func freshUserLibrary() throws -> UserLibrary {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.qualityOfService = .userInitiated
    queue.name = "ink.codes.podcasts.UserLibrary.Sync"
    
    return UserLibrary(cache: userCache, browser: browser, queue: queue)
  }
  
  lazy var user: UserLibrary = try! self.freshUserLibrary()
  
  func makeUserClient() -> UserSyncing {
    guard !settings.noSync else {
      return NoUserClient()
    }
    
    let host = service("cloudkit", at: "*")!.url
    guard let probe = Ola(host: host) else {
      fatalError("could not init probe: \(host)")
    }
    
    let client = UserClient(cache: userCache, probe: probe, queue: synchronizedQueue)
    
    if self.settings.flush {
      client.flush()
    }
    
    return client
  }
  
  func makeStore() throws -> Shopping {
    dispatchPrecondition(condition: .onQueue(.main))
    
    let url = Bundle.main.url(forResource: "products", withExtension: "json")!
    let store = Store(url: url)
    
    store.formatDate = { date in
      return StringRepository.string(from: date)
    }
    
    if settings.removeReceipts {
      precondition(store.removeReceipts())
    }
    
    return store
  }
  
  func makeFileRepo() -> FileRepository {
    FileRepository(userQueue: user)
  }
}
