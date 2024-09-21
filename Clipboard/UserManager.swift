import Foundation

struct UserProfile: Codable {
    let paidUser: Bool
    let userHasOpened: Bool
    let paneItemSize: String
    let addToClipboard: Bool
}

class UserManager: ObservableObject {
    @Published var userProfile: UserProfile
    
    init() {
        userProfile = UserProfile(paidUser: false, userHasOpened: false, paneItemSize: "small", addToClipboard: false)
        loadUserProfile()
    }
    
    private func loadUserProfile() {
        let defaults = UserDefaults.standard
        
        // Load values from UserDefaults
        let paidUser = defaults.bool(forKey: "paidUser")
        let userHasOpened = defaults.bool(forKey: "userHasOpened")
        let paneItemSize = defaults.string(forKey: "paneItemSize") ?? "small" // Default if not set
        let addToClipboard = defaults.bool(forKey: "addToClipboard")
        // Update userProfile
        userProfile = UserProfile(paidUser: paidUser, userHasOpened: userHasOpened, paneItemSize: paneItemSize, addToClipboard: addToClipboard)
    }
    
    // Optionally, you can create a method to save user settings
    func saveUserProfile() {
        let defaults = UserDefaults.standard
        defaults.set(userProfile.paidUser, forKey: "paidUser")
        defaults.set(userProfile.userHasOpened, forKey: "userHasOpened")
        defaults.set(userProfile.paneItemSize, forKey: "paneItemSize")
        defaults.set(userProfile.addToClipboard, forKey: "addToClipboard")
    }
}
