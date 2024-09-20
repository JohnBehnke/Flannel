//
//  ContentView.swift
//  Example
//
//  Created by John Behnke on 9/19/24.
//

import SwiftUI
import Flannel
import OSLog

struct ContentView: View {
    let logger = Logger.init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "ContentView"
    )
    init () {
        logger.info("Initialized")
        logger.error("Error!")
        logger.warning("Error!")
        logger.debug("Debug!")
        logger.critical("Critical")
        logger.notice("Notice")
    }
    var body: some View {
        LogView()
    }
}

#Preview {
    ContentView()
}
