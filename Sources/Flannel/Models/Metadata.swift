//
//  Metadata.swift
//
//  Created by John Behnke on 9/6/25.
//


enum Metadata: String, CaseIterable, Identifiable {
  case timestamp = "Timestamp"
  case type = "Type"
  case library = "Library"
  case pidtid = "PID:TID"
  case subsystem = "Subsystem"
  case category = "Category"
  case processName = "Process Name"
  
  var id: String { rawValue }
}

extension Metadata {
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
