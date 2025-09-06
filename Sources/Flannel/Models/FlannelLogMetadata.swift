//
//  FlannelLogMetadata.swift
//  Flannel
//
//  Created by John Behnke on 9/6/25.
//

/// Represents the available metadata fields for a Flannel log entry.
/// Provides identifiers, display names, and optional system images.
enum FlannelLogMetadata: String, CaseIterable, Identifiable {
  case timestamp = "Timestamp"
  case type = "Type"
  case library = "Library"
  case pidtid = "PID:TID"
  case subsystem = "Subsystem"
  case category = "Category"
  case processName = "Process Name"
  
  var id: String { rawValue }
}

extension FlannelLogMetadata {
  /// An optional SF Symbol name that represents the metadata field.
  var systemImage: String? {
    switch self {
      case .timestamp, .type:
        return nil
      case .library:
        return "building.columns"
      case .pidtid:
        return "tag"
      case .subsystem:
        return "gearshape.2"
      case .category:
        return "square.grid.3x3"
      case .processName:
        return "apple.terminal"
    }
  }
}
