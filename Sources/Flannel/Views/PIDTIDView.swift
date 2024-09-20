//
//  PIDTIDView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI

struct PIDTIDView: View {
    let entry: FlannelLogEntry
    var body: some View {
        Form {
            Section {
                Text("\(entry.processId.formatted(.number.grouping(.never)))")
            } header: {
                Text("Process ID")
                    .foregroundStyle(.tertiary)
                    .font(.footnote)
            }
            Section {
                Text(entry.threadId.formattedString)
                
            } header: {
                Text("Thread ID")
                    .foregroundStyle(.tertiary)
                    .font(.footnote)
            }
        }
    }
}


#Preview {
    HStack {
        Text("Hello!")
    }
    .popover(isPresented: .constant(true)){
        PIDTIDView(entry: FlannelLogEntry.mockFlannelEntries.first!)
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
    }
}
