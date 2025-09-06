//
//  LogEntry.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation
import SwiftUI

struct LogEntry: Identifiable {
  let id = UUID()
  let date: Date
  let category: String
  let message: String
  let subsystem: String
  let processId: Int
  let threadId: UInt64
  let library: String
  let processName: String
  let level: LogLevel
  
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
  
  var description: String {
    return "Message: \(message) | Type: \(level) | Timestamp: \(date.ISO8601Format()) | Library: \(library) | Subsystem: \(subsystem) | Category: \(category) | TID: \(threadId.formattedString) | PID: \(processId.formatted(.number.grouping(.never)))"
  }
}

extension LogEntry {
  static var mockFlannelEntries: [LogEntry] {
    return [LogEntry(date: .now, category: "Category", message: "Info message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .info),
            LogEntry(date: .now, category: "Category", message: "Debug message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .debug),
            LogEntry(date: .now, category: "Category", message: "Notice message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .notice),
            LogEntry(date: .now, category: "Category", message: "Error message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .error),
            LogEntry(date: .now, category: "Category", message: "Fault message", subsystem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .fault)
    ]
  }
}


