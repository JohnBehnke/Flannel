//
//  LogTypeView.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI

struct LogTypeView: View {
    let entry: FlannelLogEntry
    var body: some View {
        Form {
            Section {
                Text(entry.level.rawValue.capitalized)
                
            } header: {
                Text("Type")
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
        LogTypeView(entry: FlannelLogEntry.mockFlannelEntries.first!)
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
    }
}
