import SwiftUI
import OSLog
import Observation

public struct LogView: View {
  // Immutable input
  private let subsystems: [String]
  
  // View state
  @State private var subtitleText: String = "Fetching Logs..."
  @State private var searchText: String = ""
  @State private var logs: [FlannelLogEntry] = []
  @State private var error: Error?
  @State private var isLoading: Bool = false
  @State private var isFirstLoad: Bool = true
  @State private var lastFetchTime: Date = .now
  @State private var showExport: Bool = false
  @State private var subtitleUpdateTask: Task<Void, Never>? = nil
  
  @State private var selectedMetadatas: Set<FlannelLogMetadata> = [.processName]
  @State private var showMetadata: Bool = true
  
  public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
    self.subsystems = subsystems
  }
  
  // Derived state
  private var searchResults: [FlannelLogEntry] {
    if searchText.isEmpty { return logs }
    return logs.filter { $0.message.lowercased().contains(searchText.lowercased()) }
  }
  
  public var body: some View {
    logContent
      .task { await fetchLogs(showSpinner: true) }
      .searchable(text: $searchText, placement: .automatic, prompt: "Search Logs")
      .refreshable { await fetchLogs(showSpinner: false) }
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
      .onDisappear { subtitleUpdateTask?.cancel() }
  }
  
  @ToolbarContentBuilder
  private var filterButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Filter", systemImage: "line.3.horizontal.decrease") {}
        .disabled(logs.isEmpty)
    }
  }
  
  @ToolbarContentBuilder
  private var metadataButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Menu {
        Toggle("Metadata", isOn: $showMetadata)
        Divider()
        ForEach(FlannelLogMetadata.allCases) { meta in
          Toggle(isOn: binding(for: meta), label: {
            Label(meta.rawValue, systemImage: meta.systemImage ?? "")
          })
          .disabled(!showMetadata)
        }
      } label: {
        Label("Metadata", systemImage: "switch.2")
      }
      .menuActionDismissBehavior(.disabled)
    }
  }
  
  @ToolbarContentBuilder
  private var exportButton: some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      Button { showExport.toggle() } label: { Image(systemName: "square.and.arrow.up") }
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
  
  private func binding(for col: FlannelLogMetadata) -> Binding<Bool> {
    Binding(
      get: { selectedMetadatas.contains(col) },
      set: { newValue in
        if newValue { selectedMetadatas.insert(col) }
        else { selectedMetadatas.remove(col) }
      }
    )
  }
  
  @MainActor
  private func fetchLogs(showSpinner: Bool) async {
    if showSpinner { isLoading = true }
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
        FlannelLogEntry(
          date: $0.date,
          category: $0.category,
          message: $0.composedMessage,
          subsytem: $0.subsystem,
          processId: Int($0.processIdentifier),
          threadId: $0.threadIdentifier,
          library: $0.sender,
          processName: $0.process,
          level: FlannelLogLevel(rawLevel: $0.level.rawValue) ?? .unknown
        )
      }
      self.lastFetchTime = .now
      
      if showSpinner {
        // First load: show final count immediately
        self.subtitleText = "\(self.logs.count) Logs"
      } else {
        // Refresh: briefly show "Updated Just Now", then revert to count after a short delay
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
