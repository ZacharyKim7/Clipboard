import AppKit
import StoreKit
import Cocoa
import MASShortcut
import SwiftUI


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
    case setting(SettingView)
    case test(TestView)
}
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var clipboardManager: ClipboardManager?
    @Published var storeVM = StoreVM()
    @Published var entitlementManager = EntitlementManager()
    private var subscriptionsManager: SubscriptionManager?
    private var popupMenuController: PopupMenuController?
    private var windowManager: WindowManager?
    
    override init() {
        
        super.init()
        // Initialize popupMenuController after clipboardManager is set up
        subscriptionsManager = SubscriptionManager(entitlementManager: entitlementManager)
        clipboardManager = ClipboardManager(entitlementManager: entitlementManager)
        popupMenuController = PopupMenuController(clipboardManager: clipboardManager!, appDelegate: self)
        windowManager = WindowManager()
        checkFirstLaunch()
        
        
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
        windowManager?.openNewWindow(with: .setting(SettingView()), with: subscriptionsManager!, with: entitlementManager)
    }
    func openTestView() {
        windowManager?.openNewWindow(with: .test(TestView()), with: subscriptionsManager!, with: entitlementManager)
    }
    
    private func handleShortcut() {
        showPopup()
    }
    
    private func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard
        let hasLaunchedBeforeKey = "hasLaunchedBefore"
        userDefaults.set(false, forKey: hasLaunchedBeforeKey)
//        userDefaults.removeObject(forKey: "ClipboardHistory")
        if !userDefaults.bool(forKey: hasLaunchedBeforeKey) {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 520),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            newWindow.title = "Clipboard"
            newWindow.contentView = NSHostingView(rootView: FirstTimeUserView().environmentObject(self))
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
            newWindow.isReleasedWhenClosed = false

            NSApp.activate(ignoringOtherApps: true)
            
        }
    }
}

class WindowManager: ObservableObject {
    
    func openNewWindow(with viewType: ViewType, with manager: SubscriptionManager, with entitlementManager: EntitlementManager) {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        
        newWindow.title = "Settings"
        // Dynamically opens window
        setWindowContentView(with: newWindow, with: viewType, with: manager, with: entitlementManager)
        newWindow.center()
        // Make the new window key and bring it to the front
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.isReleasedWhenClosed = false

        // Optionally set the window as a top-level window for better management
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setWindowContentView(with currWindow: NSWindow, with viewType: ViewType, with manager: SubscriptionManager, with entitlementManager: EntitlementManager) {
            switch viewType {
            case .setting:
                let settingsView = SettingView()
                currWindow.contentView = NSHostingView(rootView: settingsView)
            case .test:
                let testView = TestView().environmentObject(manager).environmentObject(entitlementManager)
                currWindow.contentView = NSHostingView(rootView: testView)
            }
    }
}
