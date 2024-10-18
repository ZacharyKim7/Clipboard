import AppKit
import StoreKit
import Cocoa
import MASShortcut
import SwiftUI
import KeyboardShortcuts


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
    //    case setting(SettingView)
    case test(TestView)
    case subscriptionView(SubscriptionView)
}
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var clipboardManager: ClipboardManager?
    @Published var storeVM = StoreVM()
    @Published var entitlementManager = EntitlementManager()
    private var settingManager: SettingManager?
    private var subscriptionsManager: SubscriptionManager?
    private var popupMenuController: PopupMenuController?
    private var windowManager: WindowManager?
    
    // Keep a reference to the settings window
    private var settingsWindow: NSWindow?
    private var launchWindow: NSWindow?
    
    
    override init() {
        
        super.init()
        // Initialize popupMenuController after clipboardManager is set up
        subscriptionsManager = SubscriptionManager(entitlementManager: entitlementManager)
        clipboardManager = ClipboardManager(entitlementManager: entitlementManager)
        windowManager = WindowManager()
        settingManager = SettingManager(subscriptionManager: subscriptionsManager!, clipboardManager: clipboardManager!, entitlementManager: entitlementManager)
        clipboardManager!.settingManager = settingManager
        popupMenuController = PopupMenuController(clipboardManager: clipboardManager!, appDelegate: self, settingManager: settingManager!)
        checkFirstLaunch()
        setShortcutToOpenCopiesPanel()
    }
    
    func setShortcutToOpenCopiesPanel() {
        KeyboardShortcuts.setShortcut(.init(.v, modifiers: [.control]), for: .viewCopiesPanel)
        KeyboardShortcuts.onKeyUp(for: .viewCopiesPanel) {
            self.showPopup()
        }
    }
    
    func showPopup() {
        popupMenuController?.showPopup(settingManager: settingManager!)
    }
    
    func hidePopup() {
        popupMenuController?.hidePopup(settingManager: settingManager!)
    }
    
//    func resetPopup() {
//        popupMenuController?.resetWindow()
//    }
    
    func openSettings() {
        // Check if the window already exists and is open
        if let window = settingsWindow {
            // Bring the window to the front if it already exists
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Create the settings window
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false
            )
            newWindow.title = "Settings"
            
            // Set the content view to the SettingView and pass the SettingManager
            let settingsView = SettingView(settingManager: settingManager!, appDelegate: self)
            newWindow.contentView = NSHostingView(rootView: settingsView)
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
            newWindow.isReleasedWhenClosed = false
            
            // Activate the app and bring the window to the front
            NSApp.activate(ignoringOtherApps: true)
            
            // Store the window reference to avoid recreating it
            settingsWindow = newWindow
            
            // Add an observer to clean up the reference when the window is closed
            NotificationCenter.default.addObserver(self, selector: #selector(windowDidClose(_:)), name: NSWindow.willCloseNotification, object: newWindow)
        }
    }
    
    // Handle window close to release the reference
    @objc func windowDidClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil // Release the reference when window is closed
        }
    }
    
    func openTestView() {
        // Create the new window
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 620),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        newWindow.title = "Subscriptions"
        
        // Set the content view with the environment objects
        let testView = TestView()
            .environmentObject(subscriptionsManager!)
            .environmentObject(entitlementManager)

        newWindow.contentView = NSHostingView(rootView: testView)

        // Center the window on the screen
        newWindow.center()

        // Make the window key and front
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.isReleasedWhenClosed = false

        // Activate the app
        NSApp.activate(ignoringOtherApps: true)
    }
    
    
    private func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard
        let hasLaunchedBeforeKey = "hasLaunchedBefore"
        userDefaults.set(false, forKey: hasLaunchedBeforeKey)
        //        userDefaults.removeObject(forKey: "ClipboardHistory")
        if !userDefaults.bool(forKey: hasLaunchedBeforeKey) && !entitlementManager.hasPro {
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
            launchWindow = newWindow
            NSApp.activate(ignoringOtherApps: true)
            
        }
    }
    
    func closeLaunchWindow() {
        if let launchWindow {
            launchWindow.close()
        }
    }
}

class WindowManager: ObservableObject {
    
    func openNewWindow(with viewType: ViewType, with manager: SubscriptionManager, with entitlementManager: EntitlementManager, with clipboardManager: ClipboardManager) {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false
        )
        
        newWindow.title = "Settings"
        // Dynamically opens window
        setWindowContentView(with: newWindow, with: viewType, with: manager, with: entitlementManager, with: clipboardManager)
        newWindow.center()
        // Make the new window key and bring it to the front
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.isReleasedWhenClosed = false
        
        // Optionally set the window as a top-level window for better management
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setWindowContentView(with currWindow: NSWindow, with viewType: ViewType, with manager: SubscriptionManager, with entitlementManager: EntitlementManager, with clipboardManager: ClipboardManager) {
            switch viewType {
            // case .setting:
            //     let settingsView = SettingView().environmentObject(clipboardManager)
            //     currWindow.contentView = NSHostingView(rootView: settingsView)
            case .test:
                let testView = TestView().environmentObject(manager).environmentObject(entitlementManager)
                currWindow.contentView = NSHostingView(rootView: testView)
            case .subscriptionView:
                let subscriptionView = SubscriptionView().environmentObject(manager).environmentObject(entitlementManager)
                currWindow.contentView = NSHostingView(rootView: subscriptionView)
            }
    }
}
