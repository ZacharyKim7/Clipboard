import SwiftUI
import AppKit
import MASShortcut
import Cocoa

@main
struct ClipboardApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView().environmentObject(appDelegate)
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
    }
}

enum ViewType
{
    case setting(SettingView, title: String = "Settings")
    case test(TestView, title: String = "Test Title")
    
    var title: String {
        switch self {
        case .setting(_, let title):
            return title
        case .test(_, let title):
            return title
        }
    }
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
        checkFirstLaunch()
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
    
    private func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard
        let hasLaunchedBeforeKey = "hasLaunchedBefore"
        
        if userDefaults.bool(forKey: hasLaunchedBeforeKey) == false {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 800),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false
            )
            
            userDefaults.set(true, forKey: hasLaunchedBeforeKey)
            
            newWindow.title = "Clipboard"
            // Dynamically opens window
            newWindow.contentView = NSHostingView(rootView: FirstTimeUserView().environmentObject(self))
            newWindow.center()
            // Make the new window key and bring it to the front
            newWindow.makeKeyAndOrderFront(nil)
            newWindow.isReleasedWhenClosed = false

            // Optionally set the window as a top-level window for better management
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

class WindowManager: ObservableObject {
    
    func openNewWindow(with viewType: ViewType) {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 450),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        
        newWindow.title = viewType.title
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
            case .setting(let view, _):
                currWindow.contentView = NSHostingView(rootView: view)
            case .test(let view, _):
                currWindow.contentView = NSHostingView(rootView: view)
            }
        }
}
