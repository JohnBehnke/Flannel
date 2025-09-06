import SwiftUI
import OSLog
import Observation



public struct LogView: View {
  
  @State private var model: LogViewModel
  
  public init(subsystems: [String] = [Bundle.main.bundleIdentifier!]) {
    _model = State(initialValue: LogViewModel(subsystems: subsystems))
  }
  public var body: some View {
    logContent
      .task {
        await model.fetchLogs(showSpinner: true)
        model.subtitleText = "\(model.logs.count) Logs"
      }
    
    
      .searchable(
        text: $model.searchText,
        placement: .automatic,
        prompt: "Search Logs"
      )
      .refreshable {
        await model.fetchLogs(showSpinner: false)
        model.subtitleText = "Updated Just Now"
        Task {
          try? await Task.sleep(for: .seconds(5))
          model.subtitleText = "\(model.searchResults.count) Logs"
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
      .navigationSubtitle(model.subtitleText)
    
  }
  
  @ToolbarContentBuilder
  private var filterButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Filter", systemImage: "line.3.horizontal.decrease") {
      }
      .disabled(model.logs.isEmpty)
    }
  }
  
  @ToolbarContentBuilder
  private var metadataButton: some ToolbarContent {
    ToolbarItem(placement: .bottomBar) {
      Button("Metadata", systemImage: "switch.2") {
      }
      .disabled(model.logs.isEmpty)
    }
  }
  
  @ToolbarContentBuilder
  private var exportButton: some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      Button {
        model.showExport.toggle()
      } label: {
        Image(systemName: "square.and.arrow.up")
      }
      .disabled(model.logs.isEmpty)
    }
  }
  
  @ViewBuilder
  private var logContent: some View {
    if model.isFirstLoad && model.searchText.isEmpty {
      ContentUnavailableView {
        Label {
          HStack(alignment: .bottom, spacing: 0) {
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
    } else if model.searchResults.isEmpty && !model.searchText.isEmpty {
      ContentUnavailableView.search(text: model.searchText)
    } else if model.searchResults.isEmpty {
      ContentUnavailableView(
        "No Logs",
        systemImage: "doc.text.magnifyingglass",
        description: Text("No log entries were found for the selected subsystems.")
      )
    } else {
      List(model.searchResults) { entry in
        Text(entry.id.uuidString)
        // put your real row UI here
      }
      // any list-specific modifiers go here
    }
  }
}

#Preview {
  NavigationStack {
    LogView()
  }
}
