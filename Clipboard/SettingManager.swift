import Foundation
import SwiftUI

enum ItemSize: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
    
    var dimensions: (width: CGFloat, height: CGFloat, panelSize: CGFloat) {
        switch self {
        case .small:
            return (100, 100, 250)
        case .medium:
            return (200, 200, 350)
        case .large:
            return (400, 400, 550)
        }
    }
}

class SettingManager: ObservableObject {
    @ObservedObject var entitlementManager: EntitlementManager
    @Published var selectedSection: SettingSection = .general
    @Published var subscriptionPlan: String = "Basic"
    @Published var panelColor: Color = Color.gray {
        didSet {
            savePanelColor()
        }
    }
    @Published var itemSize: ItemSize = .medium {
        didSet {
            saveItemSize()
        }
    }
    @Published var numberOfCopies: Int = 3 {
        didSet {
            saveNumberOfCopies()
        }
    }
    @Published var selectedScreen: String = NSScreen.main?.localizedName ?? "" {
        didSet {
            saveSelectedScreen()
        }
    }
    @Published var pasteImmediately: Bool = false {
        didSet {
            savePasteImmediately()
        }
    }
    public var subscriptionManager: SubscriptionManager? = nil
    public var clipboardManager: ClipboardManager? = nil
    
    init(subscriptionManager: SubscriptionManager? = nil, clipboardManager: ClipboardManager? = nil, entitlementManager: EntitlementManager) {
        self.subscriptionManager = subscriptionManager
        self.clipboardManager = clipboardManager
        self.entitlementManager = entitlementManager
        
        loadSettings() // Load saved settings on initialization
        
        // Adjust the number of copies based on the entitlement
        numberOfCopies = entitlementManager.hasPro ? 50 : numberOfCopies
    }
    
    let generalSettingsLabel = LabelSettings(
        title: "General Settings",
        systemImage: "gear",
        fontSize: 14,
        width: 140,
        height: 35
    )
    
    let subscriptionLabel = LabelSettings(
        title: "Subscription Plan",
        systemImage: "creditcard",
        fontSize: 14,
        width: 140,
        height: 35
    )
    
    // MARK: - Load and Save Settings
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        // Load numberOfCopies from UserDefaults
        if let savedCopies = defaults.value(forKey: "numberOfCopies") as? Int {
            numberOfCopies = savedCopies
        }
        
        // Load panelColor from UserDefaults
        if let savedColorString = defaults.string(forKey: "panelColor"),
           let color = Color(rawValue: savedColorString) {
            panelColor = color
        }
        
        // Load panelSize from UserDefaults
        let savedSize = defaults.string(forKey: "panelSize") ?? ItemSize.medium.rawValue
        itemSize = ItemSize(rawValue: savedSize) ?? .medium
        
        if let savedScreen = defaults.value(forKey: "selectedScreen") as? String {
            selectedScreen = savedScreen
        }
        
        if let savedPasteImmediately = defaults.value(forKey: "pasteImmediately") as? Bool {
            pasteImmediately = savedPasteImmediately
        }
        
    }
    
    private func saveNumberOfCopies() {
        let defaults = UserDefaults.standard
        defaults.set(numberOfCopies, forKey: "numberOfCopies")
    }
    
    private func savePanelColor() {
        let defaults = UserDefaults.standard
        defaults.set(panelColor.rawValue, forKey: "panelColor")
    }
    
    private func saveItemSize() {
        let defaults = UserDefaults.standard
        defaults.set(itemSize.rawValue, forKey: "panelSize")  // Save itemSize to UserDefaults
    }
    
    private func saveSelectedScreen() {
        let defaults = UserDefaults.standard
        defaults.set(selectedScreen, forKey: "selectedScreen")  // Save itemSize to UserDefaults
    }
    
    private func savePasteImmediately() {
        let defaults = UserDefaults.standard
        defaults.set(pasteImmediately, forKey: "pasteImmediately")  
    }
}
