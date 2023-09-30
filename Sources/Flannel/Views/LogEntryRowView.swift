//
//  LogEntryRowView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI

struct LogEntryRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @State private var showPIDTIDPopover: Bool = false
    @State private var showTypePopover: Bool = false

    let entry: FlannelLogEntry
    let metadataVisibility: MetadataOptionVisibilityStore
    
    var body: some View {
        HStack {
            VStack(spacing: 12) {
                
                #warning("Not sure on this color yet...")
                Text(entry.message)
                    .fontWeight(.bold)
               
                    .foregroundStyle(colorScheme == .light ? .gray : .white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                
                if metadataVisibility.showMetadata {
                    HStack {
                        if metadataVisibility.showType {
                            Button {
                                showTypePopover.toggle()
                            } label: {
                                Image(systemName: entry.symbol)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 8, height: 8)
                                    .padding(3)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .background(entry.symbolColor)
                                    .clipShape(.rect(cornerRadius: 2))
                            }
                            
                            .popover(isPresented: $showTypePopover){
                                
                                if sizeClass == .compact {
                                    LogTypeView(entry: entry)
                                        .presentationDetents([.fraction(0.2)])
                                        .presentationDragIndicator(.visible)
                                } else {
                                    LogTypeView(entry: entry)
                                        .frame(width: 300, height: 100)
                                }
                                
                            }
                            
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack {
                                if metadataVisibility.showTimestamp {
                                    
                                    Text(dateFormatter.string(from: entry.date))
                                        .fontWeight(.bold)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                if metadataVisibility.showProcessName {
                                    HStack(spacing: 2) {
                                        Image(systemName: "apple.terminal")
                                        Text(entry.processName)
                                    }
                                    .fontWeight(.bold)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                }
                                if metadataVisibility.showLibrary {
                                    HStack(spacing: 2) {
                                        Image(systemName: "building.columns")
                                        Text(entry.library)
                                    }
                                    .fontWeight(.bold)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                }
                                
                                if metadataVisibility.showPIDTID {
                                    Button {
                                        showPIDTIDPopover.toggle()
                                    } label: {
                                        HStack(spacing: 2) {
                                            Image(systemName: "tag")
                                            Text("\(entry.processId.formatted(.number.grouping(.never))):0x\(String(entry.threadId, radix: 16))")
                                        }
                                        
                                    }
                                    .fontWeight(.bold)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                    .popover(isPresented: $showPIDTIDPopover){
                                        
                                        if sizeClass == .compact {
                                            PIDTIDView(entry: entry)
                                                .presentationDetents([.fraction(0.3)])
                                                .presentationDragIndicator(.visible)
                                        } else {
                                            PIDTIDView(entry: entry)
                                                .frame(width: 300, height: 200)
                                        }
                                        
                                    }
                                    
                                }
                                
                                if metadataVisibility.showSubsystem {
                                    HStack(spacing: 2) {
                                        Image(systemName: "gearshape.2")
                                        Text(entry.subsytem)
                                    }
                                    .fontWeight(.bold)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                }
                                
                                if metadataVisibility.showCategory {
                                    HStack(spacing: 2) {
                                        Image(systemName: "square.grid.3x3")
                                        Text(entry.category)
                                    }
                                    .fontWeight(.bold)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                }
                            }
                        }

                    }
                    
                }
            }
        }
        .listRowBackground(
            metadataVisibility.showMetadata
            ? entry.rowColor.opacity(0.2)
            : nil
        )
        .contextMenu {
            Button("Copy with Visible Metadata", action: {})
            Button("Copy with All Metadata", action: {})
            Button("Copy without Metadata", action: {})
            Divider()
            Menu("Hide Similar Items") {
                Button("Type '\(entry.level.rawValue.capitalized)'", action: {})
                Button("PID '\((entry.processId.formatted(.number.grouping(.never))))'", action: {})
                Button("Library '\(entry.library)'", action: {})
                Button("Subsystem '\(entry.subsytem)'", action: {})
                Button("Category '\(entry.category)'", action: {})
                Button("TID '\(entry.threadId.formattedString)'", action: {})
            }
            Menu("Show Similar Items") {
               
            }
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

#Preview {
    List(FlannelLogEntry.mockFlannelEntries) { entry in
        LogEntryRowView(
            entry: entry,
            metadataVisibility: MetadataOptionVisibilityStore()
        )
        
    }
    .listStyle(.plain)
}




/*
 
 LOGS!
 Type: Fault | Timestamp: 2023-09-29 23:03:58.430022-04:00 | Library: Stellae | Subsystem: xyz.behnke.Stellae | Category: StellaeApp | TID: 0x58d67d
 
 */
