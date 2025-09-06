//
//  Metadata.swift
//
//  Created by John Behnke on 9/6/25.
//

/// Represents different metadata fields that can be displayed for a log entry.
enum Metadata: String, CaseIterable, Identifiable {
  /// The timestamp of the log entry.
  case timestamp = "Timestamp"
  /// The type or level of the log entry.
  case type = "Type"
  /// The originating library of the log entry.
  case library = "Library"
  /// The process ID and thread ID associated with the log entry.
  case pidtid = "PID:TID"
  /// The subsystem identifier associated with the log entry.
  case subsystem = "Subsystem"
  /// The log category.
  case category = "Category"
  /// The name of the process that generated the log.
  case processName = "Process Name"
  
  /// The unique identifier for the metadata case, based on its raw value.
  var id: String { rawValue }
}

extension Metadata {
  /// Returns an optional SF Symbol name representing the metadata case.
  var systemImage: String? {
    switch self {
      case .timestamp, .type:
        return nil
      case .library:
        return "building.columns" // Represents library
      case .pidtid:
        return "tag" // Represents process ID and thread ID
      case .subsystem:
        return "gearshape.2" // Represents subsystem
      case .category:
        return "square.grid.3x3" // Represents category
      case .processName:
        return "apple.terminal" // Represents process name
    }
  }
}
