import SwiftUI
import StoreKit


struct SettingView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var selectedSection: SettingSection = .general
    
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

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { selectedSection = .general }) {
                        configureLabel(with: generalSettingsLabel)
                    }
                    Button(action: { selectedSection = .subscription }) {
                        configureLabel(with: subscriptionLabel)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 180)

            // Display the selected section's settings
            switch selectedSection {
            case .general:
                GeneralSettingsView()
            case .subscription:
                SubscriptionSettingsView()
            }
        }
        .frame(width: 650, height: 500)
    }
    
    // Helper method to configure a label using the LabelSettings
        func configureLabel(with settings: LabelSettings) -> some View {
            Label(settings.title, systemImage: settings.systemImage)
                .font(.system(size: settings.fontSize))
                .frame(width: settings.width, height: settings.height)
        }
}

enum SettingSection {
    case general
    case subscription
}

struct GeneralSettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("CopyCat Shortcuts")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                Divider()
                
                // Placeholder
                Text("Shortcut 1: Action")
                    .padding([.bottom, .top], 10)
                Text("Shortcut 2: Action")
                    .padding(.bottom, 10)

            }
            .padding([.top, .leading], 16)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading) // Align the VStack to top-left
        }
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

            Button(action: {
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
