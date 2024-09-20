//
//  ShareView.swift
//
//
//  Created by John Behnke on 9/29/23.
//

import Foundation
import SwiftUI

#if os(iOS)
struct ShareView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController
    
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
#elseif os(macOS)
struct ShareView: NSViewRepresentable {
    @Binding var isPresented: Bool
    var sharingItems: [Any] = []
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator
            
            // !! MUST BE CALLED IN ASYNC, otherwise blocks update
            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }
    
    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: ShareView
        
        init(owner: ShareView) {
            self.owner = owner
        }
        
        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            
            // do here whatever more needed here with selected service
            
            sharingServicePicker.delegate = nil   // << cleanup
            self.owner.isPresented = false        // << dismiss
        }
    }
}
#endif
