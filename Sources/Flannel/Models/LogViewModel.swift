//
//  LogViewModel.swift
//  Flannel
//
//  Created by John Behnke on 9/6/25.
//

import SwiftUI
import OSLog
import Observation

@MainActor
@Observable
final class LogViewModel {
  // UI state previously in the view
  var subtitleText: String = "Fetching Logs..."
  var searchText: String = ""
  var logs: [FlannelLogEntry] = []
  var error: Error?
  var isLoading: Bool = false           // replaces fetchingLogs
  var isFirstLoad: Bool = true          // only show spinner on the first load
  var lastFetchTime: Date = .now
  var showExport: Bool = false
  
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ViewModel")
  private let subsystems: [String]
  
  init(subsystems: [String]) {
    self.subsystems = subsystems
  }
  
  var searchResults: [FlannelLogEntry] {
    if searchText.isEmpty {
      return logs
    } else {
      return logs.filter {
        $0.message.lowercased().contains(searchText.lowercased())
      }
    }
  }
  
  func fetchLogs(showSpinner: Bool) async {
    if showSpinner { isLoading = true }
    defer {
      if showSpinner {
        isLoading = false
        isFirstLoad = false
      }
    }
    do {
      let store = try OSLogStore(scope: .currentProcessIdentifier)
      let predicate = NSPredicate(format: "subsystem IN %@", self.subsystems)
      let newEntries = try store.getEntries(matching: predicate)
        .compactMap { $0 as? OSLogEntryLog }
      
      self.logs = newEntries.map {
        FlannelLogEntry(
          date: $0.date,
          category: $0.category,
          message: $0.composedMessage,
          subsytem: $0.subsystem,
          processId: Int($0.processIdentifier),
          threadId: $0.threadIdentifier,
          library: $0.sender,
          processName: $0.process,
          level: FlannelLogLevel(rawLevel: $0.level.rawValue) ?? .unknown
        )
      }
      self.lastFetchTime = .now
    } catch {
      self.error = error
      logger.error("Failed to fetch logs: \(error.localizedDescription)")
    }
  }
}
