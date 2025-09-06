//
//  UInt64+FormattedString.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

/// Extension adding hexadecimal string formatting to UInt64.
extension UInt64 {
  /// A string representation of the unsigned 64-bit integer in hexadecimal format, 
  /// prefixed with "0x".
  var formattedString: String {
    "0x\(String(self, radix: 16))"
  }
}
