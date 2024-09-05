import AppKit
import SwiftUI

class PopupMenuController {
    private var hostingView: NSHostingController<PopupMenuView>?
    private var window: NSWindow?
    private var clickEventMonitor: Any?
    private let clipboardManager: ClipboardManager
    private var hidingPopup: Bool = false

    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
    }
    
    func showPopup() {
        if window != nil {
            return
        }
        guard let screen = NSScreen.main else { return }
        // Get the full screen frame including the Dock
        let screenFrame = screen.frame

        // Create the SwiftUI view
        let popupView = PopupMenuView(clipboardManager: clipboardManager)
        let hostingController = NSHostingController(rootView: popupView)
        
        // Create an NSWindow to host the view
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: screenFrame.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = .floating
        window.isReleasedWhenClosed = false
        
        // Create a blurred background effect view
        let visualEffectView = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.masksToBounds = true
        
        // Add the visual effect view to the window
        window.contentView = visualEffectView
        hostingController.view.frame = visualEffectView.bounds
        visualEffectView.addSubview(hostingController.view)
        
        // Position the window
        let initialFrame = NSRect(
            x: -250, // Popup width
            y: screenFrame.minY,
            width: 250, // Popup width
            height: screenFrame.height
        )
        let finalFrame = NSRect(
            x: 0,
            y: screenFrame.minY,
            width: 250, // Popup width
            height: screenFrame.height
        )
        
        window.setFrame(initialFrame, display: true)
        
        // Animate the window to slide in from the left
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3 // Animation duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(finalFrame, display: true)
        } completionHandler: {
            self.window = window
            self.hostingView = hostingController
            
            // Monitor mouse clicks outside the popup window
            self.startMonitoringOutsideClicks()
        }
        
        window.makeKeyAndOrderFront(nil)
    }

    func hidePopup() {
        guard let window = self.window else {
            return }
        
        // Ensure the pane isn't already closing before attempting another close
        if !self.hidingPopup {
            self.hidingPopup = true
            // Animate the window to slide out to the left
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3 // Animation duration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                let screenFrame = NSScreen.main?.frame ?? NSRect.zero
                let finalFrame = NSRect(
                    x: -250, // Popup width
                    y: screenFrame.minY,
                    width: 250, // Popup width
                    height: screenFrame.height
                )
                window.animator().setFrame(finalFrame, display: true)
            } completionHandler: {
                window.orderOut(nil)
                self.window = nil
                self.hostingView = nil
                
                // Stop monitoring outside clicks
                self.stopMonitoringOutsideClicks()
                self.hidingPopup = false
            }
        }
        
    }

    
    private func startMonitoringOutsideClicks() {
        clickEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self = self else { return }
            if let window = self.window {
                let clickLocation = window.convertFromScreen(NSRect(origin: event.locationInWindow, size: .zero)).origin
                if !window.contentView!.frame.contains(clickLocation) {
                    self.hidePopup()
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
}
