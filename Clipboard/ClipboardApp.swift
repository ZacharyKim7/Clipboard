//
//  ClipboardApp.swift
//  Clipboard
//
//  Created by Garrett Moody on 8/28/24.
//

import SwiftUI

@main
struct ClipboardApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
    }
}
