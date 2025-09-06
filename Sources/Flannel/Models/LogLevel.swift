//
//  LogLevel.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

/// Represents the severity level of a log entry.
enum LogLevel: String, CaseIterable, Identifiable {
  /// Debug-level log messages, used for detailed troubleshooting.
  case debug = "Debug"
  /// Informational log messages, highlighting general runtime events.
  case info = "Info"
  /// Notice-level log messages, indicating noteworthy but not error conditions.
  case notice = "Notice"
  /// Error-level log messages, representing recoverable issues.
  case error = "Error"
  /// Fault-level log messages, representing serious system errors or failures.
  case fault = "Fault"
  
  /// Unique identifier for the log level, based on its raw string value.
  var id: String { rawValue }
}

extension LogLevel {
  /// Creates a log level from a raw integer value.
  /// - Parameter rawLevel: The integer representing a log level (1 = Debug, 2 = Info, 3 = Notice, 4 = Error, 5 = Fault).
  /// - Returns: A `LogLevel` matching the raw value, or `.info` by default if the value is unrecognized.
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
