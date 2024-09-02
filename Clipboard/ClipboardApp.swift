import SwiftUI

@main
struct ClipboardApp: App {
    @State private var isPopupPresented = true
    @State private var previousCopies = ["Sample Copy 1", "Sample Copy 2", "Sample Copy 3"] // Example data
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            FirstTimeUserView().environmentObject(appDelegate)
        }
        MenuBarExtra {
            MenuBarView().environmentObject(appDelegate)
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSWindowDelegate {
    private var isPopupVisible = false
    private let popupMenuController = PopupMenuController()
    
    private var settingsWindow: NSWindow?

    func showSettings() {
        print("showSettings called")
        
        if settingsWindow == nil {
            print("Creating new settings window")
            
            let settingsView = SettingView()
                .environmentObject(self) // Pass self as the environment object

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false
            )
            window.center()
            window.title = "Settings"
            window.contentView = NSHostingView(rootView: settingsView)
            window.makeKeyAndOrderFront(nil)
            window.delegate = self

            settingsWindow = window
        } else {
            print("Bringing existing settings window to the front")
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }

    func windowWillClose(_ notification: Notification) {
        if let closedWindow = notification.object as? NSWindow, closedWindow == settingsWindow {
            settingsWindow = nil
            print("Settings window has been closed and settingsWindow is set to nil.")
        }
    }

    func showPopup() {
        popupMenuController.showPopup()
    }

    func hidePopup() {
        popupMenuController.hidePopup()
    }
}
