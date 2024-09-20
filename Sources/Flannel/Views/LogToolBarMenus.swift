//
//  LogToolBarMenus.swift
//  Flannel
//
//  Created by John Behnke on 9/19/24.
//

import SwiftUI

struct LogToolBarMenus: View {
    @State var metadataVisibilityStore: MetadataOptionVisibilityStore
    @State var logTypeVisibilityStore: LogTypeVisibilityStore
    var body: some View {
        MetadataOptionsView(metadataVisibilityStore: metadataVisibilityStore)
        FilterOptionsView(logTypeVisibilityStore: logTypeVisibilityStore)
    }
}
