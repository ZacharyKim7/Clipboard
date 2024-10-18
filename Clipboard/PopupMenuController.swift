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
    private var viewModel: PopupMenuViewModel

    init(clipboardManager: ClipboardManager, appDelegate: AppDelegate, settingManager: SettingManager) {
        self.clipboardManager = clipboardManager
        self.appDelegate = appDelegate
        self.settingManger = settingManager
        self.viewModel = PopupMenuViewModel()
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
        let popupView = PopupMenuView(clipboardManager: clipboardManager, appDelegate: appDelegate, settingsManager: settingManger, viewModel: viewModel)
        let hostingController = NSHostingController(rootView: popupView)
        
        // Create an NSWindow to host the view
        let window = PopupWindow(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: screenFrame.height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.level = .popUpMenu
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.auxiliary, .stationary, .moveToActiveSpace, .fullScreenAuxiliary]
        window.backgroundColor = .clear
        window.contentView = hostingController.view
        
//         Position the window
        let initialFrame = NSRect(
            x: screenFrame.minX, // Popup width
            y: screenFrame.minY,
            width: 250, // Popup width
            height: screenFrame.height
        )
        
    
        window.setFrame(initialFrame, display: true)
        self.window = window
    }
    
    func showPopup(settingManager: SettingManager) {
        if window == nil {
            return
        }
        window?.orderFrontRegardless()
        viewModel.showingPopup = true
        self.startMonitoringOutsideClicks(settingManager: settingManager)
        self.startMonitoringAppActivation(settingManager: settingManager)
        self.showingPopup = false
        
    }

    func hidePopup(settingManager: SettingManager) {
        viewModel.showingPopup = false
        self.stopMonitoringOutsideClicks()
        self.stopMonitoringAppActivation()
    }
    
    func resetWindow() {
        self.window?.orderOut(nil)
        createWindow(settingManager: settingManger)
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

class PopupWindow: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
}
