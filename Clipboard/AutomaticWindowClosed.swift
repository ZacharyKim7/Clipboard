import SwiftUI

extension View {
    func closeWindow() {
        let window = NSApplication.shared.keyWindow
        window?.close()
    }
}
