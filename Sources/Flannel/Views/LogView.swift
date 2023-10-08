import SwiftUI
import OSLog


public struct LogView: View {
    
    @State private var metadataVisibilityStore: MetadataOptionVisibilityStore = MetadataOptionVisibilityStore()
    @State private var logTypeVisibilityStore: LogTypeVisibilityStore = LogTypeVisibilityStore()
    
    
    @State private var searchText: String = ""
    @State private var logs: [FlannelLogEntry] = []
    @State private var attemptedLoad: Bool = true
    @State private var error: Error?
    @State private var fetchingLogs: Bool = false
    @State private var lastFetchTime: Date = .now
    @State private var showExport: Bool = false
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
    
    var subsystems: [String]
    
    private var searchResults: [FlannelLogEntry] {
        if searchText.isEmpty {
            return logs.filter { logTypeVisibilityStore.logTypes[$0.level] ?? false }
        } else {
            return logs.filter {
                $0.message.lowercased().contains(searchText.lowercased())
                && logTypeVisibilityStore.logTypes[$0.level] ?? false }
        }
    }
    
    private var relativeDateFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }
    
    /// A display of logs captured by OSLog
    /// - Parameter subsystems: An array of bundle indentifiers to filter the OSLogStore by. By default, it will only filter by 'Bundle.main.bundleIdentifier'
    public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
        logger.info("Info")
        self.subsystems = subsystems
    }
    public var body: some View {
        Group {
            if let error {
                ContentUnavailableView("Couldn't load logs", systemImage: "exclamationmark.triangle", description: Text(error.localizedDescription))
                    .containerRelativeFrame(.vertical)
            }
            if searchResults.isEmpty && !searchText.isEmpty && error == nil {
                ContentUnavailableView.search(text: searchText)
                    .containerRelativeFrame(.vertical)
            }
            
            if searchResults.isEmpty && searchText.isEmpty && attemptedLoad && error == nil {
                ContentUnavailableView("No Logs Found", systemImage: "magnifyingglass", description: Text("Check that the provided subsystems are correct"))
                    .containerRelativeFrame(.vertical)
                
                
            }
            
            List (searchResults) { log in
                LogEntryRowView(
                    entry: log,
                    metadataVisibility: metadataVisibilityStore
                )
                
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .refreshable {
                await fetchLogs()
            }
            .toolbar {
#if os(iOS)
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    Menu {
                        MetadataOptionsView(metadataVisibilityStore: metadataVisibilityStore)
                    } label: {
                        Image(systemName: "switch.2")
                    }
                    .disabled(logs.isEmpty)
                    .menuActionDismissBehavior(.disabled)
                    
                    Menu {
                        FilterOptionsView(logTypeVisibilityStore: logTypeVisibilityStore)
                    } label: {
                        Image(systemName:
                                logTypeVisibilityStore.logTypes.values.contains(false)
                              ? "line.3.horizontal.decrease.circle.fill"
                              :"line.3.horizontal.decrease.circle"
                        )
                    }
                    .disabled(logs.isEmpty)
                    .menuActionDismissBehavior(.disabled)
                    
                    
                    
                }
#endif
                ToolbarItemGroup(placement: .status) {
                    if fetchingLogs {
                        HStack {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.blue)
                                .symbolEffect(.pulse.wholeSymbol)
                            
                            HStack(alignment: .bottom,spacing: 0) {
                                Text("Fetching Logs")
                                Image(systemName: "ellipsis")
                                    .symbolEffect(
                                        .variableColor
                                            .iterative
                                            .dimInactiveLayers
                                            .nonReversing
                                    )
                                    .font(.caption2)
                                    .padding(.bottom, 1)
                            }
                            
                            
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        
                        
                    }
                    else {
                        
                        TimelineView(.periodic(from: .now, by: 60)) { context in
                            
                            // Use a custom method because RelativeDateFormatter doesn't output a "Just Now"
                            Text("Updated \(lastFetchTime.relativeTimestamp())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                        }
                    }
                }
#if os(iOS)
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showExport.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(logs.isEmpty)
                } #endif
            }
        }
        .onAppear {
            Task {
                await fetchLogs()
            }
        }
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
    
    
    func fetchLogs() async {
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
                fetchingLogs = false
                self.logs = newEntries.map {
                    return FlannelLogEntry(date: $0.date, category: $0.category, message: $0.formatString, subsytem: $0.subsystem, processId: Int($0.processIdentifier), threadId: ($0.threadIdentifier), library: $0.sender, processName: $0.process, level: FlannelLogLevel(rawLevel: $0.level.rawValue) ?? .unknown)
                }
            }
        } catch {
            self.error = error
            fetchingLogs = false
        }
    }
}

#Preview {
    NavigationStack {
        LogView()
            .navigationTitle("Logs")
    }
}




