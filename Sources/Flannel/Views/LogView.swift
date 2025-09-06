import SwiftUI
import OSLog

/// A SwiftUI view that displays logs retrieved from the OSLogStore with filtering, searching, and metadata display controls.
public struct LogView: View {
  
  /// The list of subsystems whose logs will be displayed.
  private let subsystems: [String]
  
  /// The subtitle text shown below the navigation title, reflecting log status.
  @State private var subtitleText: String = "Fetching Logs..."
  /// The current text input used to filter logs by message content.
  @State private var searchText: String = ""
  /// The array of fetched log entries.
  @State private var logs: [LogEntry] = []
  /// Any error encountered during log fetching.
  @State private var error: Error?
  /// Tracks whether the view is currently loading logs.
  @State private var isLoading: Bool = false
  /// Tracks whether the view is performing its first log fetch.
  @State private var isFirstLoad: Bool = true
  /// The timestamp of the last successful log fetch.
  @State private var lastFetchTime: Date = .now
  /// Controls whether the export UI is shown.
  @State private var showExport: Bool = false
  /// Task that updates the subtitle text asynchronously.
  @State private var subtitleUpdateTask: Task<Void, Never>? = nil
  
  /// The set of metadata fields selected for display in each log entry.
  @State private var selectedMetadatas: Set<Metadata> = [
    .type,
    .timestamp,
    .subsystem,
    .category,
    .library,
    .pidtid,
    .category,
    .processName
  ]
  /// The set of log levels selected for filtering displayed logs.
  @State private var selectedLevels: Set<LogLevel> = [
    .info,
    .error,
    .debug,
    .fault,
    .notice
  ]
  /// Controls whether metadata columns are shown in the log list.
  @State private var showMetadata: Bool = true
  
  /// Initializes a new LogView with the given subsystems.
  /// - Parameter subsystems: An array of subsystem identifiers to filter logs by. Defaults to the main bundle identifier.
  public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
    self.subsystems = subsystems
  }
  
  
  /// Computed property that filters logs by selected levels and search text.
  private var searchResults: [LogEntry] {
    let filteredByLevels = logs.filter { selectedLevels.contains($0.level) }
    if searchText.isEmpty { return filteredByLevels }
    return filteredByLevels
      .filter { $0.message.lowercased().contains(searchText.lowercased()) }
  }
  
  /// The main view body showing log content, search, toolbar, and navigation configuration.
  public var body: some View {
    logContent
      .task(id: subsystems) { await fetchLogs(showSpinner: true) }
      .searchable(text: $searchText, placement: .automatic, prompt: "Search Logs")
      .refreshable { await fetchLogs(showSpinner: false) }
      .toolbar {
        deleteButton
        metadataButton
        ToolbarSpacer(.fixed, placement: .bottomBar)
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
        ToolbarSpacer(.fixed, placement: .bottomBar)
        filterButton
      }
      .navigationTitle("Logs")
      .navigationSubtitle(subtitleText)
      .onDisappear { subtitleUpdateTask?.cancel() }
  }
  
  /// A toolbar menu that allows filtering logs by their log level.
  @ToolbarContentBuilder
  private var filterButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Menu {
        ForEach(LogLevel.allCases) { level in
          Toggle(level.rawValue, isOn: membershipBinding(for: level, in: $selectedLevels))
        }
      } label: {
        Label("Filter", systemImage: "line.3.horizontal.decrease")
      }
      .menuActionDismissBehavior(.disabled)
      .disabled(logs.isEmpty)
    }
  }
  
  /// A toolbar menu that toggles metadata display and selects which metadata fields to show.
  @ToolbarContentBuilder
  private var metadataButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Menu {
        Toggle("Metadata", isOn: $showMetadata)
        Divider()
        ForEach(Metadata.allCases) { meta in
          Toggle(isOn: membershipBinding(for: meta, in: $selectedMetadatas), label: {
            if let systemImage = meta.systemImage {
              Label(meta.rawValue, systemImage: systemImage)
            } else {
              Text(meta.rawValue)
            }
          })
          .disabled(!showMetadata)
        }
      } label: {
        Label("Metadata", systemImage: "switch.2")
      }
      .menuActionDismissBehavior(.disabled)
      .disabled(logs.isEmpty)
    }
  }
  
  /// A toolbar button that deletes all currently loaded logs.
  @ToolbarContentBuilder
  private var deleteButton: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(role: .destructive) {
        self.logs.removeAll()
        subtitleText = "0 Logs"
      }
      .disabled(logs.isEmpty)
    }
  }
  
  /// Displays the main content area of the log view, including fetch, empty states, or a list of logs.
  @ViewBuilder
  private var logContent: some View {
    if isFirstLoad && searchText.isEmpty {
      ContentUnavailableView {
        Label {
          HStack(alignment: .bottom, spacing: 0) {
            Text("Fetching Logs")
            Image(systemName: "ellipsis")
              .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
              .padding(.bottom, 3)
          }
        } icon: {
          Image(systemName: "text.page.badge.magnifyingglass").symbolEffect(.pulse)
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
    } else {
      List(searchResults) { entry in
        LogEntryRowView(
          visibleMetadata: selectedMetadatas,
          entry: entry,
          showMetadata: showMetadata
        )
      }
      .listStyle(.plain)
    }
  }
  
  /// Creates a binding that toggles membership of an item in a set.
  /// - Parameters:
  ///   - item: The item to toggle membership for.
  ///   - set: A binding to the set of items.
  /// - Returns: A binding to a Boolean indicating whether the item is in the set.
  private func membershipBinding<T: Hashable>(for item: T, in set: Binding<Set<T>>) -> Binding<Bool> {
    Binding(
      get: { set.wrappedValue.contains(item) },
      set: { newValue in
        var copy = set.wrappedValue
        if newValue { copy.insert(item) } else { copy.remove(item) }
        set.wrappedValue = copy
      }
    )
  }
  
  /// Fetches logs from the OSLogStore asynchronously, updating state and subtitle text.
  /// - Parameter showSpinner: A Boolean indicating whether to show a loading spinner during fetch.
  private func fetchLogs(showSpinner: Bool) async {
    // Flip/loading flags strictly on the main actor
    let alreadyLoading: Bool = await MainActor.run {
      if isLoading { return true }
      if showSpinner { isLoading = true }
      return false
    }
    if alreadyLoading { return }
    
    // Ensure flags reset when we exit
    defer {
      Task { @MainActor in
        if showSpinner {
          isLoading = false
          isFirstLoad = false
        }
      }
    }
    
    do {
      let subsystemsCopy = self.subsystems
      let lastSeen = await MainActor.run { self.lastFetchTime }
      
      let (fetchedLogs, fetchedAt): ([LogEntry], Date) = try await Task.detached(priority: .utility) {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let predicate = NSPredicate(format: "subsystem IN %@", subsystemsCopy)
        
        let rawEntries: [OSLogEntryLog]
        if showSpinner {
          rawEntries = try store.getEntries(matching: predicate).compactMap { $0 as? OSLogEntryLog }
        } else {
          let pos = store.position(date: lastSeen.addingTimeInterval(-2))
          rawEntries = try store.getEntries(at: pos, matching: predicate).compactMap { $0 as? OSLogEntryLog }
        }
        
        let mapped = rawEntries.map {
          LogEntry(
            date: $0.date,
            category: $0.category,
            message: $0.composedMessage,
            subsystem: $0.subsystem,
            processId: Int($0.processIdentifier),
            threadId: $0.threadIdentifier,
            library: $0.sender,
            processName: $0.process,
            level: LogLevel(rawLevel: $0.level.rawValue) ?? .info
          )
        }
        return (mapped, Date())
      }.value
      
      await MainActor.run {
        self.logs = fetchedLogs
        self.lastFetchTime = fetchedAt
        
        if showSpinner {
          self.subtitleText = "\(self.logs.count) Logs"
        } else {
          self.subtitleText = "Updated Just Now"
          subtitleUpdateTask?.cancel()
          subtitleUpdateTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            self.subtitleText = "\(self.searchResults.count) Logs"
          }
        }
      }
    } catch {
      await MainActor.run {
        self.error = error
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
        logger.error("Failed to fetch logs: \(error.localizedDescription)")
      }
    }
  }
}

#Preview {
  NavigationStack { LogView() }
}
