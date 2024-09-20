//
//  FlannelLogEntry.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation
import SwiftUI

struct FlannelLogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let message: String
    let subsytem: String
    let processId: Int
    let threadId: UInt64
    let library: String
    let processName: String
    let level: FlannelLogLevel

    var rowColor: Color {
        switch level {
        case .unknown, .debug, .notice:
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
        case .unknown:
            return .gray
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
        case .unknown:
            return "questionmark"
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
        return "Message: \(message) | Type: \(level) | Timestamp: \(date.ISO8601Format()) | Library: \(library) | Subsystem: \(subsytem) | Category: \(category) | TID: \(threadId.formattedString) | PID: \(processId.formatted(.number.grouping(.never)))"
    }
}

extension FlannelLogEntry {
    static var mockFlannelEntries: [FlannelLogEntry] {
        return [FlannelLogEntry(date: .now, category: "Category", message: "Info message", subsytem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .info),
                FlannelLogEntry(date: .now, category: "Category", message: "Debug message", subsytem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .debug),
                FlannelLogEntry(date: .now, category: "Category", message: "Notice message", subsytem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .notice),
                FlannelLogEntry(date: .now, category: "Category", message: "Error message", subsytem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .error),
                FlannelLogEntry(date: .now, category: "Category", message: "Fault message", subsytem: "Subsystem", processId: 69420, threadId: 0xdeadb33f, library: "Library", processName: "Process Name", level: .fault)
        ]
    }
}


