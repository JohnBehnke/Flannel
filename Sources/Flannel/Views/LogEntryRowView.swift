//
//  LogEntryRowView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct LogEntryRowView: View {
  @Environment(\.colorScheme) private var colorScheme
  
  let visibleMetadata: Set<Metadata>
  let entry: LogEntry
  let showMetadata: Bool
  
  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  // MARK: - Nested UI helpers
  // Small, reusable style for metadata text
  private struct MetaStyle: ViewModifier {
    func body(content: Content) -> some View {
      content
        .font(.caption2)
        .bold()
        .foregroundStyle(.tertiary)
    }
  }
  
  /// Tiny badge for the log level / type symbol with a colored background
  private struct LevelBadge: View {
    let symbol: String
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
  
  /// Generic metadata pill with an optional SF Symbol and a text value
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
  
  var body: some View {
    HStack(alignment: .top) {
      VStack(spacing: 12) {
        Text(entry.message)
          .fontWeight(.bold)
          .foregroundStyle(colorScheme == .light ? .gray : .white)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .lineLimit(3)
        
        if showMetadata { metadataRow }
      }
    }
    .listRowBackground(showMetadata ? entry.rowColor.opacity(0.2) : nil)
    .contextMenu { copyContextMenu }
  }
  
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
  
  var copyContextMenu: some View {
    Button {
      UIPasteboard.general.setValue(entry.description, forPasteboardType: UTType.plainText.identifier)
    } label: {
      Label("Copy", systemImage: "doc.on.doc")
    }
  }
}

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
