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
    
    override init() {
        
        super.init()
        // Initialize popupMenuController after clipboardManager is set up
        subscriptionsManager = SubscriptionManager(entitlementManager: entitlementManager)
        clipboardManager = ClipboardManager(entitlementManager: entitlementManager)
        windowManager = WindowManager()
        settingManager = SettingManager(subscriptionManager: subscriptionsManager!, clipboardManager: clipboardManager!, entitlementManager: entitlementManager)
        popupMenuController = PopupMenuController(clipboardManager: clipboardManager!, appDelegate: self, settingManager: settingManager!)
        checkFirstLaunch()
        setShortcutToOpenCopiesPanel()
    }
    
    func setShortcutToOpenCopiesPanel() {
        KeyboardShortcuts.setShortcut(.init(.m, modifiers: [.control]), for: .viewCopiesPanel)
        KeyboardShortcuts.onKeyUp(for: .viewCopiesPanel) {
            self.showPopup()
        }
    }
    
    func showPopup() {
        popupMenuController?.showPopup()
    }
    
    func hidePopup() {
        popupMenuController?.hidePopup()
    }
    
    func openSettings() {
        guard let settingManager = settingManager else { return }
        
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        newWindow.title = "Settings"
        
        // Set the content view to your SettingView and pass the SettingManager
        //let settingsView = SettingView(settingManager: settingManager)
        let testView = SettingView(settingManager: settingManager)
        newWindow.contentView = NSHostingView(rootView: testView)
        
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.isReleasedWhenClosed = false
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func openTestView() {
        windowManager?.openNewWindow(with: .test(TestView()), with: subscriptionsManager!, with: entitlementManager, with: clipboardManager!)
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
    
    func openNewWindow(with viewType: ViewType, with manager: SubscriptionManager, with entitlementManager: EntitlementManager, with clipboardManager: ClipboardManager) {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.titled, .closable, .resizable],
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
            //            case .setting:
            //                let settingsView = SettingView(settingManager: SettingManager)
            //                currWindow.contentView = NSHostingView(rootView: settingsView)
        case .test:
            let testView = TestView().environmentObject(manager).environmentObject(entitlementManager)
            currWindow.contentView = NSHostingView(rootView: testView)
        }
    }
}
