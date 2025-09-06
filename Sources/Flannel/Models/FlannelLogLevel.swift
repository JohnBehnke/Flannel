//
//  FlannelLogLevel.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

enum FlannelLogLevel: String {
    case unknown
    case debug
    case info
    case notice
    case error
    case fault
}

extension FlannelLogLevel {
    init?(rawLevel: Int) {
        switch rawLevel {
        case 1:
            self = .debug
        case 2:
            self = .info
        case 3:
            self = .notice
        case 4:
            self = .error
        case 5:
            self = .fault
        default:
            self = .unknown
            
        }
    }
}
