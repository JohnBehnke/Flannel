//
//  UInt64+FormattedString.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

extension UInt64 {
    var formattedString: String {
        "0x\(String(self, radix: 16))"
    }
}
