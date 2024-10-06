//
//  SettingManager.swift
//  Clipboard
//
//  Created by Matija Benko on 9/26/24.
//

import Foundation
import SwiftUI

enum ItemSize {
    case small
    case medium
    case large
    
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
    @Published var panelColor: Color = Color.gray.opacity(0.1)
    @Published var itemSize: ItemSize = .medium
    @Published var numberOfCopies: Int = 3
    public var subscriptionManager: SubscriptionManager? = nil
    public var clipboardManager: ClipboardManager? = nil
    
    init(subscriptionManager: SubscriptionManager? = nil, clipboardManager: ClipboardManager? = nil, entitlementManager: EntitlementManager) {
        self.subscriptionManager = subscriptionManager
        self.clipboardManager = clipboardManager
        self.entitlementManager = entitlementManager

        numberOfCopies = entitlementManager.hasPro ? 50 : 3
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
    
}
