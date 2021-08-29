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
import os.log
import Epic
import Combine
import AVFoundation
import FileProxy

private let logger: Logger? = nil // Logger(subsystem: "ink.codes.podcasts", category: "Playback")

extension Entry: Playable {
  public func makePlaybackItem() -> PlaybackItem {
    PlaybackItem(
      id: guid,
      url: enclosure!.url,
      title: title,
      subtitle: feedTitle ?? "",
      imageURLs: makeImageURLs(),
      proclaimedMediaType: enclosure!.type.isVideo ? .video : .audio
    )
  }
}

public class PlaybackController {
  public enum Meta {
      case none
      case error(String, String)
      case more(Entry)
  }
  
  public enum State: CustomStringConvertible {
    public var description: String {
      switch self {
      case let .full(entry, asset, _):
        return "full: \((entry.description, asset.isPlaying))"
        
      case let .mini(entry, asset, _, _):
        return "mini: \((entry.description, asset.isPlaying))"
        
      case let .video(entry, _):
        return "video: \(entry.description)"
        
      case .none:
        return "none"
      }
    }
    
    case full(Entry, AssetState, Epic.Player)
    case mini(Entry, AssetState, MiniPlayer, Meta)
    case video(Entry, AVPlayer)
    case none(Meta)
  }
  
  enum Mode {
    case full, mini(Entry?), none
  }
  
  enum Action {
    case inactive(Mode, PlaybackError?)
    case paused(Mode, Entry, AssetState?, PlaybackError?)
    case preparing(Mode, Entry, Bool)
    case listening(Mode, Entry, AssetState)
    case viewing(Mode, Entry, AVPlayer)
  }
  
  @Published public private (set) var state: State = .none(.none)
  @Published private var playerType: Mode = .none
  
  private let playbackReducer = PlaybackReducer(factory: PlayerFactory())
  private var settingItem: AnyCancellable?

  init() {
    Files.install()
    
    Podcasts.playback.nextItem = Podcasts.userQueue.next
    Podcasts.playback.previousItem = Podcasts.userQueue.previous
    
    Podcasts.playback.$state
      .combineLatest($playerType)
      .receive(on: DispatchQueue.main)
      .map { (self.state, .init(playback: $0, type: $1)) }
      .flatMap(playbackReducer.reducer)
      .assign(to: &$state)
  }
}


// MARK: - Setting the current item

extension PlaybackController {
  private func skipTo(_ entry: Entry) -> Future<Entry, Never> {
    Future { promise in
      do {
        try Podcasts.userQueue.skip(to: entry)
      } catch {
        logger?.error("could not skip to: \(error.localizedDescription)")
      }
      
      promise(.success(entry))
    }
  }
  
  private func enqueue(_ entry: Entry?) -> Future<Entry, Never> {
    Future { promise in
      guard let entry = entry else {
        fatalError("unhandled missing entry error")
      }
      
      Podcasts.userQueue.enqueue(entries: [entry], belonging: .user) { enqueued, error in
        if let error = error {
          logger?.error("enqueue warning: \(error.localizedDescription)")
        }
        
        promise(.success(entry))
      }
    }
  }
  
  private func findEntry(matching locator: EntryLocator) -> Future<[Entry], Never> {
    Future { promise in
      var acc = [Entry]()
      
      Podcasts.browser.entries([locator], entriesBlock: { error, entries in
        acc += entries
      }) { error in
        if let error = error {
          logger?.error("missing entry: \(error.localizedDescription)")
        }
        
        promise(.success(acc))
      }
    }
  }
  
  public func setItem(matching locator: EntryLocator, paused: Bool = false) {
    settingItem = findEntry(matching: locator)
      .map { $0.first }
      .flatMap(enqueue)
      .flatMap(skipTo)
      .sink { [unowned self] entry in
        Podcasts.playback.resume(entry, from: nil)
        
        self.settingItem = nil
      }
  }
}

// MARK: - Pausing

public extension PlaybackController {
  func pause() {
    guard Podcasts.playback.currentItem != nil else {
      return
    }

    Podcasts.playback.pause(nil, at: nil)
  }
}

// MARK: - Skipping

extension PlaybackController {
  func forward() {
    Podcasts.playback.forward()
  }
  
  func backward() {
    Podcasts.playback.backward()
  }
}

// MARK: - Scrubbing

extension PlaybackController {
  func scrub(time: TimeInterval) {
    Podcasts.playback.scrub(time)
  }
  
  func skipForward() {
    switch Podcasts.playback.state {
    case let .listening(_, asset):
      Podcasts.playback.scrub(min(asset.duration, asset.time + 15))
      
    case .inactive, .paused, .preparing, .viewing:
      break
    }
  }
  
  func skipBackward() {
    switch Podcasts.playback.state {
    case let .listening(_, asset):
      Podcasts.playback.scrub(max(0, asset.time - 15))
      
    case .inactive, .paused, .preparing, .viewing:
      break
    }
  }
}

// MARK: - Navigating

extension PlaybackController {
  func showPlayer() {
    playerType = .full
  }
  
  func hidePlayer() {
    playerType = .mini(.none)
  }
  
  func more() {
    switch state {
    case let .full(entry, _, _):
      playerType = .mini(entry)
      
    case .mini, .video, .none:
      break
    }
  }
}
