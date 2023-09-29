//
//  FilterOptionsView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import SwiftUI

struct FilterOptionsView: View {
    @State var logTypeVisibilityStore: LogTypeVisibilityStore
    
    #warning("I'm kind of grossed out by this pattern (setting state but then responding to on change, look into something better?")
    @State private var showInfo: Bool = true
    @State private var showNotice: Bool = true
    @State private var showDebug: Bool = true
    @State private var showError: Bool = true
    @State private var showFault: Bool = true
    
    var body: some View {
            
            Toggle(isOn: $showInfo, label: {
                Text("Info")
            }).onChange(of: showInfo) { _, newValue in
                logTypeVisibilityStore.logTypes[.info] = newValue
            }
            Toggle(isOn: $showNotice, label: {
                Text("Notice")
            }).onChange(of: showNotice) { _, newValue in
                logTypeVisibilityStore.logTypes[.notice] = newValue
            }
            Toggle(isOn: $showDebug, label: {
                Text("Debug")
            }).onChange(of: showDebug) { _, newValue in
                logTypeVisibilityStore.logTypes[.debug] = newValue
            }
            Toggle(isOn: $showError, label: {
                Text("Error")
            }).onChange(of: showError) { _, newValue in
                logTypeVisibilityStore.logTypes[.error] = newValue
            }
            Toggle(isOn: $showFault, label: {
                Text("Fault")
            }).onChange(of: showFault) { _, newValue in
                logTypeVisibilityStore.logTypes[.fault] = newValue
            }
        
    }
}

#Preview {
    FilterOptionsView(logTypeVisibilityStore: LogTypeVisibilityStore())
}
