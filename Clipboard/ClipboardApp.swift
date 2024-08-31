//
//  ClipboardApp.swift
//  Clipboard
//
//  Created by Garrett Moody on 8/28/24.
//

import SwiftUI

@main
struct ClipboardApp: App {
    @State private var isPopupPresented = true
    @State private var previousCopies = ["Sample Copy 1", "Sample Copy 2", "Sample Copy 3"] // Example data
    
    var body: some Scene {
        WindowGroup {
            FirstTimeUserView()
        }
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
    }
}
