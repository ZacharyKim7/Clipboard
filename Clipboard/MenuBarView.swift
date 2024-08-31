import SwiftUI

struct MenuBarView: View {
    var body: some View {
            VStack {
                Button(action: showCopies) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Show Copies")
                    }
                }
                Divider()
                Button(action: openSettings) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
                Divider()
                Button(action: quitApp) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Quit")
                    }
                }
            }
    }

    private func showCopies() {
        // Action for "Show Copies" button
    }

    private func openSettings() {
        // Action for "Settings" button
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }
}
