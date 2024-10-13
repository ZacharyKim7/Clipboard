import Foundation
import SwiftUI
import AppKit

// Extend Color to conform to RawRepresentable
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .gray // Default color if decoding fails
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor ?? .gray
            self = Color(color) // No opacity applied here
        } catch {
            self = .gray
        }
    }
    
    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

struct UserProfile: Codable {
    let paidUser: Bool
    let userHasOpened: Bool
    let paneItemSize: String
    let addToClipboard: Bool
    var panelColorRaw: String // Store Color as a rawValue String
    let numOfCopies: Int
    
    // Computed property to convert stored panelColorRaw to Color
    var panelColor: Color {
        return Color(rawValue: panelColorRaw) ?? .gray.opacity(0.1)
    }
    
    // Convenience method for updating the panel color
    mutating func updatePanelColor(_ color: Color) {
        panelColorRaw = color.rawValue
    }
}

class UserManager: ObservableObject {
    @Published var userProfile: UserProfile
    
    init() {
        // Default values for the user profile
        userProfile = UserProfile(
            paidUser: false,
            userHasOpened: false,
            paneItemSize: "medium",
            addToClipboard: false,
            panelColorRaw: Color.gray.opacity(0.1).rawValue, // Store as string
            numOfCopies: 3
        )
        loadUserProfile()
    }
    
    private func loadUserProfile() {
        let defaults = UserDefaults.standard
        
        // Load values from UserDefaults with defaults to avoid nil issues
        let paidUser = defaults.bool(forKey: "paidUser")
        let userHasOpened = defaults.bool(forKey: "userHasOpened")
        let panelItemSize = defaults.string(forKey: "panelItemSize") ?? "medium" // Provide a default
        let addToClipboard = defaults.bool(forKey: "addToClipboard")
        let numOfCopies = defaults.integer(forKey: "numOfCopies") // This defaults to 0 if not set
        let panelColorRaw = defaults.string(forKey: "panelColor") ?? Color.gray.opacity(0.1).rawValue // Provide a default
        
        userProfile = UserProfile(
            paidUser: paidUser,
            userHasOpened: userHasOpened,
            paneItemSize: panelItemSize,
            addToClipboard: addToClipboard,
            panelColorRaw: panelColorRaw,
            numOfCopies: numOfCopies
        )
    }
    
    func saveUserProfile() {
        let defaults = UserDefaults.standard
        defaults.set(userProfile.paidUser, forKey: "paidUser")
        defaults.set(userProfile.userHasOpened, forKey: "userHasOpened")
        defaults.set(userProfile.paneItemSize, forKey: "paneItemSize")
        defaults.set(userProfile.addToClipboard, forKey: "addToClipboard")
        defaults.set(userProfile.numOfCopies, forKey: "numOfCopies")
        defaults.set(userProfile.panelColorRaw, forKey: "panelColor")
    }
}
