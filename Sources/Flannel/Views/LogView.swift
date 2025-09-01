import SwiftUI
import OSLog


public struct LogView: View {
  
  
  @State private var subtitleText: String = "Fetching Logs..."
  
  @State private var searchText: String = ""
  @State private var logs: [FlannelLogEntry] = []
  @State private var error: Error?
  @State private var fetchingLogs: Bool = false
  @State private var lastFetchTime: Date = .now
  @State private var showExport: Bool = false
  
  let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
  
  var subsystems: [String]
  
  private var searchResults: [FlannelLogEntry] {
    if searchText.isEmpty {
      return logs
    } else {
      return logs.filter {
        $0.message.lowercased().contains(searchText.lowercased())
      }
    }
  }
  
  /// A display of logs captured by OSLog
  /// - Parameter subsystems: An array of bundle indentifiers to filter the OSLogStore by. By default, it will only filter by 'Bundle.main.bundleIdentifier'
  public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
    self.subsystems = subsystems
  }
  public var body: some View {
    List(searchResults) { entry in
      Text(entry.id.uuidString)
    }
    .onAppear {
      Task {
        await fetchLogs()
        subtitleText = "\(logs.count) Logs"
      }
    }
    .overlay {
      if fetchingLogs && searchText.isEmpty {
        ContentUnavailableView {
          Label {
            HStack(alignment: .bottom,spacing: 0) {
              Text("Fetching Logs")
              Image(systemName: "ellipsis")
                .symbolEffect(
                  .variableColor
                    .iterative
                    .dimInactiveLayers
                    .nonReversing
                )
                .padding(.bottom, 3)
            }
          } icon: {
            Image(systemName: "text.page.badge.magnifyingglass")
              .symbolEffect(.pulse)
          }
        }
        
      } else if searchResults.isEmpty && !searchText.isEmpty {
        ContentUnavailableView.search(text: searchText)
      } else if searchResults.isEmpty {
        ContentUnavailableView(
          "No Logs",
          systemImage: "doc.text.magnifyingglass",
          description: Text("No log entries were found for the selected subsystems.")
        )
      }
    }
    .searchable(
      text: $searchText,
      placement: .automatic,
      prompt: "Search Logs"
    )
    .refreshable {
      Task {
        await fetchLogs()
        subtitleText = "Updated Just Now"
        Task {
          try? await Task.sleep(for: .seconds(5))
          subtitleText = "\(self.searchResults.count) Logs"
        }
      }
    }
    .toolbar {
      exportButton
      metadataButton
      ToolbarSpacer(.fixed, placement: .bottomBar)
      DefaultToolbarItem(kind: .search, placement: .bottomBar)
      ToolbarSpacer(.fixed, placement: .bottomBar)
      filterButton
      
    }
    .navigationTitle("Logs")
    .navigationSubtitle(subtitleText)
    
  }
  
  @ToolbarContentBuilder
  private var filterButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Filter", systemImage: "line.3.horizontal.decrease") {
      }
      .disabled(logs.isEmpty)
    }
  }
  
  @ToolbarContentBuilder
  private var metadataButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Filter", systemImage: "switch.2") {
      }
      .disabled(logs.isEmpty)
    }
  }
  
  @ToolbarContentBuilder
  private var exportButton: some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      Button {
        showExport.toggle()
      } label: {
        Image(systemName: "square.and.arrow.up")
      }
      .disabled(logs.isEmpty)
    }
  }
  
  func fetchLogs() async {
    defer {
      fetchingLogs = false
    }
    do {
      fetchingLogs = true
      let store = try OSLogStore(scope: .currentProcessIdentifier)
      let predicate = NSPredicate(
        format: "subsystem IN %@",
        self.subsystems
      )
      
      let newEntries = try store.getEntries(matching: predicate)
        .compactMap { $0 as? OSLogEntryLog }
      
      DispatchQueue.main.async {
        self.logs = newEntries.map {
          return FlannelLogEntry(
            date: $0.date,
            category: $0.category,
            message: $0.composedMessage,
            subsytem: $0.subsystem,
            processId: Int(
              $0.processIdentifier
            ),
            threadId: $0.threadIdentifier,
            library: $0.sender,
            processName: $0.process,
            level: FlannelLogLevel(
              rawLevel: $0.level.rawValue
            ) ?? .unknown
          )
        }
      }
    } catch {
      self.error = error
    }
  }
}

#Preview {
  NavigationStack {
    LogView()
  }
}
