import SwiftUI

public struct LogView: View {
    
    @State private var searchText: String = ""
    @State private var logs: [FlannelLogEntry] = []
    @State private var attemptedLoad: Bool = true
    @State private var errorMessage: String = ""
    private var searchResults: [FlannelLogEntry] {
        if searchText.isEmpty {
            return logs
        } else {
            return logs.filter { $0.message.lowercased().contains(searchText) }
        }
    }

    public init() {}
    public var body: some View {
        if !errorMessage.isEmpty {
            ContentUnavailableView("Couldn't load logs", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
        }
        if searchResults.isEmpty && !searchText.isEmpty && errorMessage.isEmpty {
            ContentUnavailableView.search(text: searchText)
        }
        List (searchResults) { log in
            Text("Hello World")
        }
        .searchable(text: $searchText)
        .refreshable {
            print("Hello World")
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
        }
    }
}

#Preview {
    NavigationStack {
        LogView()
            .navigationTitle("Logs")
    }
}
