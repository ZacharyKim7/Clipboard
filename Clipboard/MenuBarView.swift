import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appDelegate: AppDelegate

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
        appDelegate.showPopup()
    }

    private func openSettings() {
        appDelegate.openSettings()
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }
}
