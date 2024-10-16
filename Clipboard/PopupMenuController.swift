import AppKit
import SwiftUI

class PopupMenuController {
    private var hostingView: NSHostingController<PopupMenuView>?
    private var window: NSWindow?
    private var clickEventMonitor: Any?
    private var appActivationObserver: Any?
    private let clipboardManager: ClipboardManager
    private let appDelegate: AppDelegate
    private let settingManger: SettingManager
    private var hidingPopup: Bool = false
    private var showingPopup: Bool = false

    init(clipboardManager: ClipboardManager, appDelegate: AppDelegate, settingManager: SettingManager) {
        self.clipboardManager = clipboardManager
        self.appDelegate = appDelegate
        self.settingManger = settingManager
        self.createWindow(settingManager: settingManager)
    }
    
    func createWindow(settingManager: SettingManager) {
        var screen: NSScreen {
            // Find and return the NSScreen that matches the selected screen name
            return NSScreen.screens.first { $0.localizedName == settingManager.selectedScreen } ?? NSScreen.main!
        }
        // Get the full screen frame including the Dock
        let screenFrame = screen.frame

        // Create the SwiftUI view
        let popupView = PopupMenuView(clipboardManager: clipboardManager, appDelegate: appDelegate, settingsManager: settingManger)
        let hostingController = NSHostingController(rootView: popupView)
        
        // Create an NSWindow to host the view
        let window = PopupWindow(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: screenFrame.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.level = .popUpMenu
        window.isReleasedWhenClosed = false
        
        // Create a blurred background effect view
        let visualEffectView = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .menu
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.masksToBounds = true
        
        // Add the visual effect view to the window
        window.contentView = visualEffectView
        hostingController.view.frame = visualEffectView.bounds
        visualEffectView.addSubview(hostingController.view)
        
//         Position the window
        let initialFrame = NSRect(
            x: screenFrame.minX - settingManager.itemSize.dimensions.panelSize, // Popup width
            y: screenFrame.minY,
            width: settingManager.itemSize.dimensions.panelSize, // Popup width
            height: screenFrame.height
        )
        
    
        window.setFrame(initialFrame, display: true)
        
        self.window = window
    }
    
    func showPopup(settingManager: SettingManager) {
        if window == nil {
            return
        }
        if !self.showingPopup && !self.hidingPopup {
            self.showingPopup = true
            var screen: NSScreen {
                // Find and return the NSScreen that matches the selected screen name
                return NSScreen.screens.first { $0.localizedName == settingManager.selectedScreen } ?? NSScreen.main!
            }
            
            let screenFrame = screen.frame
            let finalFrame = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: 250, // Popup width
                height: screenFrame.height
            )
            
            // Animate the window to slide in from the left
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3 // Animation duration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window?.animator().setFrame(finalFrame, display: true)
            } completionHandler: {
                // Monitor mouse clicks outside the popup window
                self.startMonitoringOutsideClicks(settingManager: settingManager)
                self.startMonitoringAppActivation(settingManager: settingManager)
                self.showingPopup = false
            }
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        
    }

    func hidePopup(settingManager: SettingManager) {
        guard let window = self.window else {
            return }
        
        // Ensure the pane isn't already closing before attempting another close
        if !self.hidingPopup && !self.showingPopup {
            self.hidingPopup = true
            // Animate the window to slide out to the left
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3 // Animation duration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                let screenFrame = NSScreen.main?.frame ?? NSRect.zero
                let finalFrame = NSRect(
                    x: screenFrame.minX - settingManager.itemSize.dimensions.panelSize, // Popup width
                    y: screenFrame.minY,
                    width: 250, // Popup width
                    height: screenFrame.height
                )
                window.animator().setFrame(finalFrame, display: true)
            } completionHandler: {
                window.orderOut(nil)
                self.stopMonitoringOutsideClicks()
                self.stopMonitoringAppActivation()
                self.hidingPopup = false
            }
        }
        
    }

    
    private func startMonitoringOutsideClicks(settingManager: SettingManager) {
        clickEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self = self else { return }
            if let window = self.window {
                let clickLocation = window.convertFromScreen(NSRect(origin: event.locationInWindow, size: .zero)).origin
                if !window.contentView!.frame.contains(clickLocation) {
                    self.hidePopup(settingManager: settingManager)
                }
            }
        }
    }
    
    private func stopMonitoringOutsideClicks() {
        if let clickEventMonitor = clickEventMonitor {
            NSEvent.removeMonitor(clickEventMonitor)
            self.clickEventMonitor = nil
        }
    }
    
    private func startMonitoringAppActivation(settingManager: SettingManager) {
            appActivationObserver = NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
                self?.hidePopup(settingManager: settingManager)
            }
        }

    private func stopMonitoringAppActivation() {
        if let appActivationObserver = appActivationObserver {
            NotificationCenter.default.removeObserver(appActivationObserver)
            self.appActivationObserver = nil
        }
    }
}

class PopupWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}
