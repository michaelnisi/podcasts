//
//  NowPlaying.swift
//  Podest
//
//  Created by Michael Nisi on 22.05.21.
//  Copyright © 2021 Michael Nisi. All rights reserved.
//

import Foundation
import FeedKit
import Playback
import os.log
import Epic
import Combine
import AVFoundation

private let logger = Logger(subsystem: "ink.codes.podcasts", category: "Playing")

extension Entry: Playable {
  public func makePlaybackItem() -> PlaybackItem {
    PlaybackItem(
      id: guid,
      url: enclosure!.url,
      title: title,
      subtitle: feedTitle ?? "",
      imageURLs: makeURLs(),
      proclaimedMediaType: enclosure!.type.isVideo ? .video : .audio
    )
  }
}

/// NowPlaying publishes the player state.
public class Playing {
  public enum State: CustomStringConvertible {
    public var description: String {
      switch self {
      case let .full(entry, _):
        return "full: \(entry.description)"
        
      case let .mini(entry, _):
        return "mini: \(entry.description)"
        
      case let .video(entry, _):
        return "video: \(entry.description)"
        
      case .none:
        return "none"
      }
    }
    
    case full(Entry, Epic.Player)
    case mini(Entry, MiniPlayer)
    case video(Entry, AVPlayer)
    case none
  }
  
  public enum Message {
    case error(String, String)
    case none
  }
  
  @Published public private (set) var state: State = .none
  @Published public private (set) var message: Message = .none
  
  private let playbackReducer = PlaybackReducer(factory: PlayerFactory())
  private var settingItem: AnyCancellable?
  
  init() {
    Podcasts.playback.$state
      .receive(on: DispatchQueue.main)
      .map { (self.state, $0) }
      .flatMap(playbackReducer.reducer)
      .assign(to: &$state)
  }
}

// MARK: - Setting the current item

extension Playing {
  func skipTo(_ entry: Entry) -> Future<Entry, Never> {
    Future { promise in
      promise(.success(entry))
    }
  }
  
  func enqueue(_ entry: Entry?) -> Future<Entry, Never> {
    Future { promise in
      Podcasts.userQueue.enqueue(entries: [entry!]) { enqueued, error in
        if let er = error {
          logger.error("enqueue warning: \(String(describing: er))")
        }
        
        promise(.success(entry!))
      }
    }
  }
  
  func findEntry(matching locator: EntryLocator) -> Future<[Entry], Never> {
    Future { promise in
      var acc = [Entry]()
      
      Podcasts.browser.entries([locator], entriesBlock: { error, entries in
        acc += entries
      }, entriesCompletionBlock: { error in
        promise(.success(acc))
      })
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

public extension Playing {  
  func pause() {
    guard Podcasts.playback.currentItem != nil else {
      return
    }

    Podcasts.playback.pause(nil, at: nil)
  }
}

// MARK: - Skipping

extension Playing {
  func forward() {
    
  }
  
  func backward() {
    
  }
  
  func scrub() {
    
  }
}

