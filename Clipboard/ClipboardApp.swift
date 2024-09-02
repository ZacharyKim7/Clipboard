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

        override init() {
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
}
