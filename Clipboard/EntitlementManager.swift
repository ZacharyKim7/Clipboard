import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults()
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
