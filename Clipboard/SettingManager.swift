//
//  SettingManager.swift
//  Clipboard
//
//  Created by Matija Benko on 9/26/24.
//

import Foundation
import SwiftUI

class SettingManager: ObservableObject {
    @Published var selectedSection: SettingSection = .general
    @Published var subscriptionPlan: String = "Basic"
    public var subscriptionManager: SubscriptionManager? = nil
    public var clipboardManager: ClipboardManager? = nil
    
    init(subscriptionManager: SubscriptionManager? = nil, clipboardManager: ClipboardManager? = nil) {
        self.subscriptionManager = subscriptionManager
        self.clipboardManager = clipboardManager
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
