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
    @State private var newestFirst:Bool = true
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
    
    var subsystems: [String]
    
    private var searchResults: [FlannelLogEntry] {
        if searchText.isEmpty {
            return logs.filter { logTypeVisibilityStore.logTypes[$0.level] ?? false }
                .sorted { newestFirst ? ($0.date > $1.date) : ($0.date < $1.date)  }
        } else {
            return logs.filter {
                $0.message.lowercased().contains(searchText.lowercased())
                && logTypeVisibilityStore.logTypes[$0.level] ?? false }
            .sorted { $0.date > $1.date }
        }
    }
    
    /// A display of logs captured by OSLog
    /// - Parameter subsystems: An array of bundle indentifiers to filter the OSLogStore by. By default, it will only filter by 'Bundle.main.bundleIdentifier'
    public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
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
        

        self.subsystems = subsystems
        
        
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
                    Menu {
                        Toggle(isOn: $newestFirst) {
                            Text("Newest first")
                        }
                        
                    } label: {
                        Image(systemName:
                                "arrow.up.arrow.down"
                        )
                    }
                    .disabled(logs.isEmpty)
                    .menuActionDismissBehavior(.disabled)
                    
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
                   
                    
                    Button {
                        showExport.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(logs.isEmpty)
                    
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
                format: "subsystem IN %@",
                self.subsystems
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
