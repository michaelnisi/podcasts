//
//  Player.swift
//  
//
//  Created by Michael Nisi on 05.04.21.
//

import Combine
import FeedKit
import Playback
import os.log

private let log = OSLog(subsystem: "ink.codes.podcasts", category: "player")

public class Player {
  public enum State {
    case none
    case failure(Entry)
    case listening(Entry, Bool, Double, Double)
    case watching(Entry, Bool)
  }
    
  @Published public private(set) var state: State = .none
  
  private let playback = PlaybackSession<Entry>(times: TimeRepository.shared)
  private let userQueue: Queueing
  
  init(userQueue: Queueing) {
    self.userQueue = userQueue
  }
}

public extension Player {
  func play(_ entry: Entry) {
    os_log("playing: %@", log: log, type: .info, entry.title)

    userQueue.enqueue(entries: [entry], belonging: .user) { enqueued, er in
      if let error = er {
        os_log("enqueue error: %{public}@", log: log, type: .error, error as CVarArg)
      }

      if !enqueued.isEmpty {
        os_log("enqueued to play: %@", log: log, type: .info, enqueued)
      }

      do {
        try self.userQueue.skip(to: entry)
      } catch {
        os_log("skip error: %{public}@", log: log, type: .error, error as CVarArg)
      }

      self.playback.resume(entry, from: nil)
    }
  }

  func pause() {
    guard playback.currentItem != nil else {
      return
    }

    playback.pause(nil, at: nil)
  }
}

extension Entry: Playable {
  public func makePlaybackItem() -> PlaybackItem {
    guard let enclosure = enclosure else {
      fatalError("missing enclosure")
    }
    
    return PlaybackItem(
      id: guid,
      url: enclosure.url,
      title: title,
      subtitle: feedTitle ?? "",
      imageURLs: makeURLs(),
      proclaimedMediaType: enclosure.type.isVideo ? .video : .audio
    )
  }
}
