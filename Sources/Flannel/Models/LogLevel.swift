//
//  LogLevel.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

enum LogLevel: String, CaseIterable, Identifiable {
    case debug = "Debug"
    case info = "Info"
    case notice = "Notice"
    case error = "Error"
    case fault = "Fault"
  
  var id: String { rawValue }
}

extension LogLevel {
    init?(rawLevel: Int) {
        switch rawLevel {
        case 1:
            self = .debug
        case 2:
            self = .info
        case 3:
            self = .notice
        case 4:
            self = .error
        case 5:
            self = .fault
          default:
            self = .info
        }
    }
}
