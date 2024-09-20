//
//  MetadataOptionsView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI

struct MetadataOptionsView: View {
    @State var metadataVisibilityStore: MetadataOptionVisibilityStore
    var body: some View {
        Menu {
            Toggle(isOn: $metadataVisibilityStore.showMetadata, label: {
                Text("Metadata")
            })
            if metadataVisibilityStore.showMetadata {
                Divider()
                Toggle(isOn: $metadataVisibilityStore.showTimestamp, label: {
                    Text("Timestamp")
                })
                Toggle(isOn: $metadataVisibilityStore.showType, label: {
                    Text("Type")
                })
                Toggle(isOn: $metadataVisibilityStore.showProcessName, label: {
                    Label("Process Name", systemImage: "apple.terminal")
                })
                Toggle(isOn: $metadataVisibilityStore.showLibrary, label: {
                    Label("Library", systemImage: "building.columns")
                })
                Toggle(isOn: $metadataVisibilityStore.showPIDTID, label: {
                    Label("PID:TID", systemImage: "tag")
                })
                Toggle(isOn: $metadataVisibilityStore.showSubsystem, label: {
                    Label("Subsystem", systemImage: "gearshape.2")
                })
                Toggle(isOn: $metadataVisibilityStore.showCategory, label: {
                    Label("Category", systemImage: "square.grid.3x3")
                })
            }
        } label: {
            Image(systemName: "switch.2")
        }
    }
}

#Preview{
    MetadataOptionsView(metadataVisibilityStore: MetadataOptionVisibilityStore())
}

