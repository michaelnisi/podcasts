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

private let logger = Logger(subsystem: "ink.codes.podcasts", category: "Playback")

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

public class PlaybackController {
  public enum State: CustomStringConvertible {
    public var description: String {
      switch self {
      case let .full(entry, asset, _):
        return "full: \((entry.description, asset.isPlaying))"
        
      case let .mini(entry, asset, _):
        return "mini: \((entry.description, asset.isPlaying))"
        
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
    case full, mini, none
  }
  
  enum Action {
    case inactive(PlayerType, PlaybackError?)
    case paused(PlayerType, Entry, AssetState?, PlaybackError?)
    case preparing(PlayerType, Entry, Bool)
    case listening(PlayerType, Entry, AssetState)
    case viewing(PlayerType, Entry, AVPlayer)
  }
  
  @Published public private (set) var state: State = .none 
  @Published public private (set) var message: Message = .none
  @Published private var playerType: PlayerType = .none
  
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
      promise(.success(entry))
    }
  }
  
  private func enqueue(_ entry: Entry?) -> Future<Entry, Never> {
    Future { promise in
      Podcasts.userQueue.enqueue(entries: [entry!], belonging: .user) { enqueued, error in
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
  func scrub() {
    // TODO
  }
}

// MARK: - Showing and hiding the audio player

extension PlaybackController {
  func showPlayer() {
    playerType = .full
  }
  
  func hidePlayer() {
    playerType = .mini
  }
}
