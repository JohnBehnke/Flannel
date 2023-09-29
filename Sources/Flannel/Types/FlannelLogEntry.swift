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
    var color: Color {
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
}
