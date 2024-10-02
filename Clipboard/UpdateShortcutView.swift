//
//  ShortcutInputView.swift
//  Clipboard
//
//  Created by Matija Benko on 9/28/24.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

struct ShortcutInputView: View {
    var body: some View {
        VStack {
            Text("Set Shortcut for CopiesPanel Mode")
            ShortcutRecorderView(name: .viewCopiesPanel) // Step 2: Use ShortcutRecorderView
        }
        .padding()
        .frame(width: 300, height: 100)
    }
}

//struct ShortcutRecorderView: NSViewRepresentable {
//    let name: KeyboardShortcuts.Name
//
//    func makeNSView(context: Context) -> KeyboardShortcuts.RecorderCocoa {
//        return KeyboardShortcuts.RecorderCocoa(for: name)
//    }
//
//    func updateNSView(_ nsView: KeyboardShortcuts.RecorderCocoa, context: Context) {
//    }
//}

//#Preview {
//    ShortcutInputView()
//}
