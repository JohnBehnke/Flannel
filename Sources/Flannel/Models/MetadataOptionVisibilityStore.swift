//
//  MetadataOptionVisibilityStore.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import Foundation

@Observable
class MetadataOptionVisibilityStore {
    var showMetadata: Bool = true
    var showTimestamp: Bool = true
    var showType: Bool = true
    var showLibrary: Bool = true
    var showPIDTID: Bool = true
    var showSubsystem: Bool = true
    var showCategory: Bool = true
    var showProcessName: Bool = true
}
