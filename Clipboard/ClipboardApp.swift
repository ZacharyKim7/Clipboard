import SwiftUI
import AppKit
import MASShortcut

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

enum ViewType
{
    case setting(SettingView)
    case test(TestView)
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var clipboardManager = ClipboardManager()
    private var popupMenuController: PopupMenuController?
    private var windowManager: WindowManager?
    
    override init() {
        super.init()
        // Initialize popupMenuController after clipboardManager is set up
        popupMenuController = PopupMenuController(clipboardManager: clipboardManager)
        windowManager = WindowManager()
        
        let shortcut = MASShortcut(keyCode: Int(kVK_ANSI_V), modifierFlags: .control)
        MASShortcutMonitor.shared().register(shortcut, withAction: {
            self.handleShortcut()
        })
    }
    
    func showPopup() {
        popupMenuController?.showPopup()
    }
    
    func hidePopup() {
        popupMenuController?.hidePopup()
    }
    
    func openSettings() {
        windowManager?.openNewWindow(with: .setting(SettingView()))
    }
    func openTestView() {
        windowManager?.openNewWindow(with: .test(TestView()))
    }
    
    private func handleShortcut() {
        showPopup()
    }
}

class WindowManager: ObservableObject {
    
    func openNewWindow(with viewType: ViewType) {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        
        newWindow.title = "Settings"
        // Dynamically opens window
        setWindowContentView(with: newWindow, with: viewType)
        newWindow.center()
        // Make the new window key and bring it to the front
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.isReleasedWhenClosed = false

        // Optionally set the window as a top-level window for better management
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setWindowContentView(with currWindow: NSWindow, with viewType: ViewType) {
        switch viewType {
        case .setting(let view):
            currWindow.contentView = NSHostingView(rootView: view)
        case .test(let view):
            currWindow.contentView = NSHostingView(rootView: view)
        }
    }
}
