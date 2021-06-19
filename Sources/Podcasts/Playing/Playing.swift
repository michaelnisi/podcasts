//
//  Playing.swift
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
import FileProxy

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

public class Playing {
  public enum State: CustomStringConvertible {
    public var description: String {
      switch self {
      case let .full(entry, _, _):
        return "full: \(entry.description)"
        
      case let .mini(entry, _, _):
        return "mini: \(entry.description)"
        
      case let .video(entry, _):
        return "video: \(entry.description)"
        
      case .none:
        return "none"
      }
    }
    
    case full(Entry, AssetState, Epic.Player)
    case mini(Entry, AssetState, MiniPlayer)
    case video(Entry, AVPlayer)
    case none
  }
  
  public enum Message {
    case error(String, String)
    case none
  }
  
  enum PlayerType {
    case full, video, mini, none
  }
  
  struct Action {
    let event: Playback.PlaybackState<Entry>
    let playerType: PlayerType
  }
  
  @Published public private (set) var state: State = .none
  @Published public private (set) var message: Message = .none
  @Published private var playerType: PlayerType = .none
  
  private let playbackReducer = PlaybackReducer(factory: PlayerFactory())
  private var settingItem: AnyCancellable?
  
  init() {
    Files.install()
    
    Podcasts.playback.$state
      .combineLatest($playerType)
      .receive(on: DispatchQueue.main)
      .map { (self.state, .init(event: $0, playerType: $1)) }
      .flatMap(playbackReducer.reducer)
      .assign(to: &$state)
  }
}


// MARK: - Setting the current item

extension Playing {
  private func skipTo(_ entry: Entry) -> Future<Entry, Never> {
    Future { promise in
      promise(.success(entry))
    }
  }
  
  private func enqueue(_ entry: Entry?) -> Future<Entry, Never> {
    Future { promise in
      Podcasts.userQueue.enqueue(entries: [entry!]) { enqueued, error in
        if let er = error {
          logger.error("enqueue warning: \(String(describing: er))")
        }
        
        promise(.success(entry!))
      }
    }
  }
  
  private func findEntry(matching locator: EntryLocator) -> Future<[Entry], Never> {
    Future { promise in
      var acc = [Entry]()
      
      Podcasts.browser.entries([locator], entriesBlock: { error, entries in
        acc += entries
      }) { error in
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
    // TODO
  }
  
  func backward() {
    // TODO
  }
}

// MARK: - Scrubbing

extension Playing {
  func scrub() {
    // TODO
  }
}

// MARK: - Showing and hiding the audio player

extension Playing {
  func showPlayer() {
    playerType = .full
  }
  
  func hidePlayer() {
    playerType = .mini
  }
}
