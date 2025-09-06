import SwiftUI
import OSLog

public struct LogView: View {
  
  private let subsystems: [String]
  
  @State private var subtitleText: String = "Fetching Logs..."
  @State private var searchText: String = ""
  @State private var logs: [LogEntry] = []
  @State private var error: Error?
  @State private var isLoading: Bool = false
  @State private var isFirstLoad: Bool = true
  @State private var lastFetchTime: Date = .now
  @State private var showExport: Bool = false
  @State private var subtitleUpdateTask: Task<Void, Never>? = nil
  
  @State private var selectedMetadatas: Set<Metadata> = [
    .type,
    .timestamp,
    .subsystem,
    .category
  ]
  @State private var selectedLevels: Set<LogLevel> = [.info, .error]
  @State private var showMetadata: Bool = true
  
  public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
    self.subsystems = subsystems
  }
  
  
  private var searchResults: [LogEntry] {
    let filteredByLevels = logs.filter { selectedLevels.contains($0.level) }
    if searchText.isEmpty { return filteredByLevels }
    return filteredByLevels
      .filter { $0.message.lowercased().contains(searchText.lowercased()) }
  }
  
  public var body: some View {
    logContent
      .task { await fetchLogs(showSpinner: true) }
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
  
  @MainActor
  private func fetchLogs(showSpinner: Bool) async {
    let alreadyLoading = await MainActor.run { isLoading }
    if alreadyLoading { return }
    if showSpinner { await MainActor.run { isLoading = true } }
    defer {
      if showSpinner {
        isLoading = false
        isFirstLoad = false
      }
    }
    do {
      let store = try OSLogStore(scope: .currentProcessIdentifier)
      let predicate = NSPredicate(format: "subsystem IN %@", self.subsystems)
      let newEntries = try store.getEntries(matching: predicate).compactMap { $0 as? OSLogEntryLog }
      
      self.logs = newEntries.map {
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
      self.lastFetchTime = .now
      
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
    } catch {
      self.error = error
      let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
      logger.error("Failed to fetch logs: \(error.localizedDescription)")
    }
  }
}

#Preview {
  NavigationStack { LogView() }
}
