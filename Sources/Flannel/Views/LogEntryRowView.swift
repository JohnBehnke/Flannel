//
//  LogEntryRowView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI
import UniformTypeIdentifiers

/// A SwiftUI view that displays a single log entry row with message and optional metadata.
struct LogEntryRowView: View {
  @Environment(\.colorScheme) private var colorScheme
  
  /// The set of metadata fields to display for this log entry.
  let visibleMetadata: Set<Metadata>
  /// The log entry data to be displayed.
  let entry: LogEntry
  /// A Boolean value indicating whether to show metadata beneath the log message.
  let showMetadata: Bool
  
  /// Date formatter used to display log timestamps in HH:mm:ss.SSSS format.
  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  /// A view modifier that applies consistent styling for metadata items.
  private struct MetaStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(.caption2)
        .bold()
        .foregroundStyle(.tertiary)
    }
  }
  
  /// A small colored badge that represents the log level.
  private struct LevelBadge: View {
    /// The SF Symbol name to display inside the badge.
    let symbol: String
    /// The background color for the badge.
    let color: Color
    
    var body: some View {
      Image(systemName: symbol)
        .resizable()
        .scaledToFit()
        .frame(width: 8, height: 8)
        .padding(3)
        .font(.caption2)
        .foregroundStyle(.white)
        .background(color)
        .clipShape(.rect(cornerRadius: 2))
        .accessibilityHidden(true)
    }
  }
  
  /// A view that displays a metadata field with optional icon and text.
  private struct MetaItem: View {
    var systemName: String?
    var text: String
    
    var body: some View {
      HStack(spacing: 2) {
        if let systemName { Image(systemName: systemName) }
        Text(text)
      }
      .modifier(MetaStyle())
    }
  }
  
  /// The main content of the row, including the log message and optional metadata.
  var body: some View {
    
    VStack(alignment: .leading, spacing: 12) {
      Text(entry.message)
        .fontWeight(.bold)
        .foregroundStyle(colorScheme == .light ? .gray : .white)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      if showMetadata { metadataRow }
    }
    
    .listRowBackground(showMetadata ? entry.rowColor.opacity(0.2) : nil)
    .contextMenu { copyContextMenu }
  }
  
  /// A horizontal row of metadata items for the log entry, shown if enabled.
  @ViewBuilder
  var metadataRow: some View {
    HStack(alignment: .center, spacing: 8) {
      if visibleMetadata.contains(.type) {
        LevelBadge(symbol: entry.symbol, color: entry.symbolColor)
      }
      
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 12) {
          if visibleMetadata.contains(.timestamp) {
            MetaItem(systemName: nil, text: Self.timeFormatter.string(from: entry.date))
          }
          
          if visibleMetadata.contains(.processName) {
            MetaItem(systemName: "apple.terminal", text: entry.processName)
          }
          
          if visibleMetadata.contains(.library) {
            MetaItem(systemName: "building.columns", text: entry.library)
          }
          
          if visibleMetadata.contains(.pidtid) {
            
            MetaItem(
              systemName: "tag",
              text: "\(entry.processId.formatted(.number.grouping(.never))):0x\(String(entry.threadId, radix: 16))"
            )
          }
          
          if visibleMetadata.contains(.subsystem) {
            MetaItem(systemName: "gearshape.2", text: entry.subsystem)
          }
          
          if visibleMetadata.contains(.category) {
            MetaItem(systemName: "square.grid.3x3", text: entry.category)
          }
        }
      }
    }
  }
  
  /// A context menu that allows copying the log entry description to the clipboard.
  var copyContextMenu: some View {
    Button {
      UIPasteboard.general.setValue(entry.description, forPasteboardType: UTType.plainText.identifier)
    } label: {
      Label("Copy", systemImage: "doc.on.doc")
    }
  }
}

/// A preview showing multiple log entry rows with all metadata visible.
#Preview {
  List(LogEntry.mockFlannelEntries) { entry in
    LogEntryRowView(
      visibleMetadata: Set(Metadata.allCases),
      entry: entry,
      showMetadata: true
    )
  }
  .listStyle(.plain)
}
