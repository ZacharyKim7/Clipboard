import SwiftUI
import AppKit

@main
struct ClipboardApp: App {
    
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

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var clipboardManager = ClipboardManager()
    private var popupMenuController: PopupMenuController?
    private var windowManager: WindowManager

    override init() {
        self.windowManager = WindowManager()
        super.init()
        // Initialize popupMenuController after clipboardManager is set up
        popupMenuController = PopupMenuController(clipboardManager: clipboardManager)
    }

    func showPopup() {
        popupMenuController?.showPopup()
    }
    
    func hidePopup() {
        popupMenuController?.hidePopup()
    }
    
    func openSettings() {
        windowManager.openNewWindow()
    }
}

class WindowManager: ObservableObject {
    private var settingsWindow: NSWindow?

    func openNewWindow() {
        // Ensure this runs on the main thread
            // Create and configure the window
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false
            )
            
            newWindow.title = "Settings"
        newWindow.contentView = NSHostingView(rootView: SettingView())
            
            // Make the new window key and bring it to the front
            newWindow.makeKeyAndOrderFront(nil)
            
            // Store the reference to the window
            self.settingsWindow = newWindow
            
            // Optionally set the window as a top-level window for better management
            NSApp.activate(ignoringOtherApps: true)
    }
}
