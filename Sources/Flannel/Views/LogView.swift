import SwiftUI
import OSLog


public struct LogView: View {
  private enum LogsScreenState: Equatable { case error, searching, noSearch, empty, list }
  
  private struct LogsOverlayView: View {
    let state: LogsScreenState
    let errorDescription: String?
    let searchText: String
    let subsystemsCount: Int
    
    var body: some View {
      switch state {
        case .error:
          ContentUnavailableView(
            "Couldn't load logs",
            systemImage: "exclamationmark.triangle",
            description: Text(errorDescription ?? "Unknown error")
          )
          .containerRelativeFrame(.vertical)
          .transition(.opacity.combined(with: .scale(0.98)))
          
        case .searching:
          ContentUnavailableView {
            Label("Searching Logs…", systemImage: "magnifyingglass.circle.fill")
          } description: {
            VStack(spacing: 8) {
              Text("Scanning \(subsystemsCount) subsystem(s)…")
                .foregroundStyle(.secondary)
              ProgressView()
                .controlSize(.large)
            }
          }
          .containerRelativeFrame(.vertical)
          .transition(.opacity.combined(with: .scale(0.98)))
          
        case .noSearch:
          ContentUnavailableView.search(text: searchText)
            .containerRelativeFrame(.vertical)
            .transition(.opacity.combined(with: .scale(0.98)))
          
        case .empty:
          ContentUnavailableView(
            "No Logs",
            systemImage: "doc.text.magnifyingglass",
            description: Text("No log entries were found for the selected subsystems.")
          )
          .containerRelativeFrame(.vertical)
          .transition(.opacity.combined(with: .scale(0.98)))
          
        case .list:
          EmptyView()
      }
    }
  }
  
  @State private var metadataVisibilityStore: MetadataOptionVisibilityStore = MetadataOptionVisibilityStore()
  @State private var logTypeVisibilityStore: LogTypeVisibilityStore = LogTypeVisibilityStore()
  
  @State private var subtitleText: String = "Fetching Logs..."
  
  
  @State private var searchText: String = ""
  @State private var logs: [FlannelLogEntry] = []
  @State private var error: Error?
  @State private var fetchingLogs: Bool = true
  @State private var lastFetchTime: Date = .now
  @State private var showExport: Bool = false
  
  let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
  
  var subsystems: [String]
  
  private var screenState: LogsScreenState {
    if error != nil { return .error }
    if fetchingLogs { return .searching }
    if !searchText.isEmpty && searchResults.isEmpty { return .noSearch }
    if logs.isEmpty { return .empty }
    return .list
  }
  
  var searchResults: [FlannelLogEntry] {
    if searchText.isEmpty {
      return logs.filter { logTypeVisibilityStore.logTypes[$0.level] ?? false }
    } else {
      return logs.filter {
        $0.message.lowercased().contains(searchText.lowercased())
        && logTypeVisibilityStore.logTypes[$0.level] ?? false }
    }
  }
  
  @ViewBuilder
  private var baseContent: some View {
    if screenState == .list {
      List(searchResults) { log in
        LogEntryRowView(
          entry: log,
          metadataVisibility: metadataVisibilityStore
        )
      }
      .listStyle(.plain)
      .refreshable {
        subtitleText = "Fetching Logs..."
        await fetchLogs()
        subtitleText = "Updated Just Now"
        Task {
          try? await Task.sleep(for: .seconds(5))
          subtitleText = "\(self.searchResults.count) logs"
        }
      }
      .transition(.opacity)
    } else {
      // Keep layout height so overlay centers nicely
      Color.clear
        .containerRelativeFrame(.vertical)
    }
  }
  
  /// A display of logs captured by OSLog
  /// - Parameter subsystems: An array of bundle indentifiers to filter the OSLogStore by. By default, it will only filter by 'Bundle.main.bundleIdentifier'
  public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
    self.subsystems = subsystems
  }
  public var body: some View {
    baseContent
      .overlay {
        LogsOverlayView(
          state: screenState,
          errorDescription: error?.localizedDescription,
          searchText: searchText,
          subsystemsCount: subsystems.count
        )
      }
      .animation(.easeInOut, value: screenState)
      .searchable(text: $searchText)
      .toolbar {
        exportButton
        metadataButton
        ToolbarSpacer(.fixed, placement: .bottomBar)
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
        ToolbarSpacer(.fixed, placement: .bottomBar)
        filterButton
      }
      .onAppear {
        subtitleText = "Fetching Logs..."
        Task {
          await fetchLogs()
          subtitleText = "\(self.searchResults.count) logs"
          
        }
      }
      .navigationTitle("Logs")
      .navigationSubtitle(subtitleText)
      .fileExporter(
        isPresented: $showExport,
        document: TextDocument(text: logs.map { $0.message }.joined(separator: "\n")),
        contentType: .plainText,
        defaultFilename: "\(Date.now.formatted(.iso8601.dateSeparator(.dash).timeSeparator(.colon)))-\(Bundle.main.bundleIdentifier!)"
      ) { result in
        switch result {
          case .success(_):
            break
          case .failure(let error):
            self.error = error
        }
      }
  }
  
  @ToolbarContentBuilder
  private var filterButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Filter", systemImage: "line.3.horizontal.decrease") {
      }
    }
  }
  
  @ToolbarContentBuilder
  private var metadataButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Filter", systemImage: "switch.2") {
      }
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
    defer { fetchingLogs = false }
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
