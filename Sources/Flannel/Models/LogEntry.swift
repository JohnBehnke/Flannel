//
//  LogEntry.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation
import SwiftUI

/// Represents a single log entry with associated metadata and visual properties.
struct LogEntry: Identifiable {
  /// Unique identifier for the log entry.
  let id = UUID()
  /// The date and time when the log entry was created.
  let date: Date
  /// The category associated with the log entry.
  let category: String
  /// The main log message content.
  let message: String
  /// The subsystem associated with the log entry.
  let subsystem: String
  /// The process ID (PID) that generated the log entry.
  let processId: Int
  /// The thread ID (TID) that generated the log entry.
  let threadId: UInt64
  /// The originating library of the log entry.
  let library: String
  /// The name of the process that generated the log entry.
  let processName: String
  /// The severity level of the log entry.
  let level: LogLevel
  
  /// The background row color associated with the log level.
  var rowColor: Color {
    switch level {
      case .debug, .notice:
        return .clear
      case .info:
        return .blue
      case .error:
        return .yellow
      case .fault:
        return .red
    }
  }
  
  /// The color of the symbol used to represent the log level.
  var symbolColor: Color {
    switch level {
      case .debug:
        return .gray
      case .info:
        return .blue
      case .notice:
        return .gray
      case .error:
        return .yellow
      case .fault:
        return .red
    }
  }
  
  /// The SF Symbol name representing the log level.
  var symbol: String {
    switch level {
      case .debug:
        return "stethoscope"
      case .info:
        return "info"
      case .notice:
        return "bell.fill"
      case .error:
        return "exclamationmark.2"
      case .fault:
        return "exclamationmark.3"
    }
  }
  
  /// A formatted string description of the log entry including metadata.
  var description: String {
    return "Message: \(message) | Type: \(level) | Timestamp: \(date.ISO8601Format()) | Library: \(library) | Subsystem: \(subsystem) | Category: \(category) | TID: \(threadId.formattedString) | PID: \(processId.formatted(.number.grouping(.never)))"
  }
}

extension LogEntry {
  /// Mock log entries for previews and testing.
  static var mockFlannelEntries: [LogEntry] {
    return [LogEntry(date: .now, category: "Category", message: "Info message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .info),
            LogEntry(date: .now, category: "Category", message: "Debug message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .debug),
            LogEntry(date: .now, category: "Category", message: "Notice message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .notice),
            LogEntry(date: .now, category: "Category", message: "Error message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .error),
            LogEntry(date: .now, category: "Category", message: "Fault message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .fault)
    ]
  }
}
