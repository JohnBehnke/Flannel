//
//  LogTypeVisibilityStore.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

@Observable
class LogTypeVisibilityStore {
    var logTypes: [FlannelLogLevel : Bool] = [
        .debug: true,
        .info: true,
        .error: true,
        .fault: true,
        .notice: true
    ]
    
}
