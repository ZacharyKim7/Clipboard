import SwiftUI

struct SettingView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var selectedSection: SettingSection = .general

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { selectedSection = .general }) {
                        Label("General Settings", systemImage: "gear")
                    }
                    Button(action: { selectedSection = .subscription }) {
                        Label("Subscription Plan", systemImage: "creditcard")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 150)

            // Display the selected section's settings
            switch selectedSection {
            case .general:
                GeneralSettingsView().environmentObject(appDelegate)
            case .subscription:
                SubscriptionSettingsView()
            }
        }
        .frame(width: 500, height: 400)
    }
}

enum SettingSection {
    case general
    case subscription
}

struct GeneralSettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("volume") private var volume: Double = 0.5
    @AppStorage("notificationsEnable") private var notificationsEnabled = true

    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $isDarkMode)
            
            HStack {
                Text("Volume")
                Slider(value: $volume, in: 0...1)
            }
            
            Toggle("Enable Notifications", isOn: $notificationsEnabled)

            // Example usage of appDelegate
            Button(action: {
                appDelegate.showPopup()
            }) {
                Text("Show Popup")
            }
        }
        .padding()
        .navigationTitle("General Settings")
    }
}

struct SubscriptionSettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("subscriptionPlan") private var subscriptionPlan = "Basic"

    var body: some View {
        Form {
            Picker("Subscription Plan", selection: $subscriptionPlan) {
                Text("Basic").tag("Basic")
                Text("Pro").tag("Pro")
                Text("Enterprise").tag("Enterprise")
            }

            // Example usage of appDelegate
            Button(action: {
                appDelegate.showPopup()
            }) {
                Text("Show Popup")
            }
        }
        .padding()
        .navigationTitle("Subscription Plan")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(AppDelegate()) // Provide the appDelegate for preview
    }
}
