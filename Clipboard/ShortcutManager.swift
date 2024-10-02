import MASShortcut

class ShortcutManager: ObservableObject {
    @Published var currentShortcut: MASShortcut?
    private let appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        
        let defaultShortcut = MASShortcut(keyCode: Int(kVK_ANSI_V), modifierFlags: .control)
        // Ensure this call is made on the main actor
        Task { @MainActor in
            registerDefaultShortcut(defaultShortcut!)
        }
    }
    
    @MainActor func registerDefaultShortcut(_ shortcut: MASShortcut) {
        // Unregister the old shortcut if there is one
        if let current = currentShortcut {
            MASShortcutMonitor.shared().unregisterShortcut(current)
        }
        
        // Register the new shortcut
        appDelegate.registerShortcutBinding(with: shortcut)
        
        // Update the current shortcut
        currentShortcut = shortcut
    }
    
    @MainActor func updateShortcutBinding(with newShortcutBinding: MASShortcut) {
        appDelegate.updateShortcutBinding(with: currentShortcut!, with: newShortcutBinding)
        
        currentShortcut = newShortcutBinding
    }
}
