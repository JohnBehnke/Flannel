//
//  LogEntryRowView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI

struct LogEntryRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let entry: FlannelLogEntry
    let metadataVisibility: MetadataOptionVisibilityStore
    @State private var showPIDTIDPopover: Bool = false
    @State private var showTypePopover: Bool = false
//    @State private var logTypePopover: LogTypePopoverModel?
    var body: some View {
        HStack {
            VStack(spacing: 12) {
                
                Text(entry.message)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                
                if metadataVisibility.showMetadata {
                    HStack {
                        if metadataVisibility.showType {
                            Button {
                                                                showTypePopover.toggle()
//                                logTypePopover = LogTypePopoverModel(message: entry.level.rawValue.capitalized)
                            } label: {
                                Image(systemName: entry.symbol)
                                    .resizable()
                                    .frame(width: 8, height: 8)
                                    .padding(3)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .background(entry.color)
                                    .clipShape(.rect(cornerRadius: 2))
                            }
                            //                            LogTypeView(entry: entry)
                            //                            .popover(isPresented: $showTypePopover){
                            //
                            //                                if sizeClass == .compact {
                            //                                    LogTypeView(entry: entry)
                            //                                        .presentationDetents([.fraction(0.2)])
                            //                                        .presentationDragIndicator(.visible)
                            //                                } else {
                            //                                    LogTypeView(entry: entry)
                            //                                        .frame(width: 300, height: 100)
                            //                                }
                            //
                            //                            }
//                            .popover(item: $logTypePopover){ detail in
//                                Form {
//                                    Section("Type") {
//                                        Text(detail.message)
//                                    }
//                                }
//                                .frame(width: 300, height: 100)
//                                
//                            }
                            
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack {
                                if metadataVisibility.showTimestamp {
                                    Text(entry.date.formatted(date: .omitted, time: .complete))
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
                                        
//                                        if sizeClass == .compact {
//                                            PIDTIDView(entry: entry)
//                                                .presentationDetents([.fraction(0.3)])
//                                                .presentationDragIndicator(.visible)
//                                        } else {
//                                            PIDTIDView(entry: entry)
//                                                .frame(width: 300, height: 200)
//                                        }
                                        
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
    }
}

#Preview {
    LogEntryRowView(entry: .mockFlannelEntry, metadataVisibility: MetadataOptionVisibilityStore())
}
