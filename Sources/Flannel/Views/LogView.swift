import SwiftUI
import OSLog


public struct LogView: View {
    
    @State private var metadataVisibilityStore: MetadataOptionVisibilityStore = MetadataOptionVisibilityStore()
    @State private var logTypeVisibilityStore: LogTypeVisibilityStore = LogTypeVisibilityStore()
    
    @State private var searchText: String = ""
    @State private var logs: [FlannelLogEntry] = []
    @State private var attemptedLoad: Bool = true
    @State private var errorMessage: String = ""
    @State private var fetchingLogs: Bool = false
    @State private var lastFetchTime: Date = .now
    @State private var showExport: Bool = false
    
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
    
    private var searchResults: [FlannelLogEntry] {
        if searchText.isEmpty {
            return logs.filter { logTypeVisibilityStore.logTypes[$0.level] ?? false }
        } else {
            return logs.filter {
                $0.message.lowercased().contains(searchText.lowercased())
                && logTypeVisibilityStore.logTypes[$0.level] ?? false}
        }
    }
    
    public init() {
        logger.debug("Debug log message")
        logger.info("Info log message")
        logger.notice("Notice log message")
        logger.error("Error log message")
        logger.fault("Fault log")
        logger.debug("Debug log message")
        logger.info("Info log message")
        logger.notice("Notice log message")
        logger.error("Error log message")
        logger.fault("Fault log")
        logger.debug("Debug log message")
        logger.info("Info log message")
        logger.notice("Notice log message")
        logger.error("Error log message")
        logger.fault("Fault log")
        
    }
    public var body: some View {
        Group {
            if !errorMessage.isEmpty {
                ContentUnavailableView("Couldn't load logs", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            }
            if searchResults.isEmpty && !searchText.isEmpty && errorMessage.isEmpty {
                ContentUnavailableView.search(text: searchText)
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
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        showExport.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(logs.isEmpty)
                    
                    
                    Menu {
                        MetadataOptionsView(metadataVisibilityStore: metadataVisibilityStore)
                    } label: {
                        Image(systemName: "switch.2")
                    }
                    .disabled(logs.isEmpty)
                    .menuActionDismissBehavior(.disabled)
                    
                    
                }
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
                        Text("Last updated: \(lastFetchTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
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
                
            }
            .toolbar(.automatic, for: .bottomBar)
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
            case .success(let file):
                print(file)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func fetchLogs() async {
        do {
            fetchingLogs = true
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let predicate = NSPredicate(
                format: "subsystem = %@",
                Bundle.main.bundleIdentifier!
            )
            
            let newEntries = try store.getEntries(matching: predicate)
                .compactMap { $0 as? OSLogEntryLog }
            
            DispatchQueue.main.async {
                self.logs = newEntries.map {
                    fetchingLogs = false
                    return FlannelLogEntry(date: $0.date, category: $0.category, message: $0.formatString, subsytem: $0.subsystem, processId: Int($0.processIdentifier), threadId: ($0.threadIdentifier), library: $0.sender, processName: $0.process, level: FlannelLogLevel(rawLevel: $0.level.rawValue) ?? .unknown)
                }
            }
        } catch {
            print(error.localizedDescription)
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
