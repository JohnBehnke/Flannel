import SwiftUI
import OSLog

public struct LogView: View {
    
    @State private var searchText: String = ""
    @State private var logs: [FlannelLogEntry] = []
    @State private var attemptedLoad: Bool = true
    @State private var errorMessage: String = ""
    @State private var fetchingLogs: Bool = false
    @State private var lastFetchTime: Date = .now
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "View")
    
    private var searchResults: [FlannelLogEntry] {
        if searchText.isEmpty {
            return logs
        } else {
            return logs.filter { $0.message.lowercased().contains(searchText) }
        }
    }
    
    public init() {
        logger.error("My Error Message")

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
                Text("Hello World")
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .refreshable {
                
                await fetchLogs()
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Spacer()
                    Menu {
                        Text("Filter item 1")
                        Text("Filter item 2")
                        Text("Filter item 3")
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .menuActionDismissBehavior(.disabled)
                    Menu {
                        Text("Metadata option 1")
                        Text("Metadata option 2")
                        Text("Metadata option 3")
                    } label: {
                        Image(systemName: "switch.2")
                    }
                    .menuActionDismissBehavior(.disabled)
                    
                }
                ToolbarItemGroup(placement: .status) {
                    if fetchingLogs {
                        Text("Fetching Logs...")
                            .font(.caption)
                    }
                    else {
                        Text("Last updated: \(lastFetchTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                    }
                    
                }
            }
            .toolbar(.automatic, for: .bottomBar)
        }
        .onAppear {
            Task {
                fetchingLogs = true
                await fetchLogs()
                fetchingLogs = false
            }
        }
        
    }
    
    
    func fetchLogs() async {
        do {
            
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let predicate = NSPredicate(
                format: "subsystem = %@",
                Bundle.main.bundleIdentifier!
            )
            
            let newEntries = try store.getEntries(matching: predicate)
                .compactMap { $0 as? OSLogEntryLog }
            
            DispatchQueue.main.async {
                self.logs = newEntries.map {
                    return FlannelLogEntry(date: $0.date, category: $0.category, message: $0.formatString, subsytem: $0.subsystem, processId: Int($0.processIdentifier), threadId: ($0.threadIdentifier), library: $0.sender, processName: $0.process, level: FlannelLogLevel(rawLevel: $0.level.rawValue) ?? .unknown)
                }
            }
            
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        LogView()
            .navigationTitle("Logs")
    }
}
