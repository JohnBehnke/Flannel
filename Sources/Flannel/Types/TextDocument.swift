//
//  TextDocument.swift
//  
//
//  Created by John Behnke on 9/29/23.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.log, .plainText]
    }
    
    var text = ""
    
    init(text: String) {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
