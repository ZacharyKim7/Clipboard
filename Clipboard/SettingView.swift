import SwiftUI
import StoreKit


struct SettingView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var ClipboardManager: ClipboardManager
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

struct GrowingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(.red)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
                .frame(width: 150, height: 15)
        }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("General Settings")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 15))
                    .padding(.top, 10)
                    .padding(.horizontal, 5)
                
                Divider()
                
                HStack {
                    Text("Deletes all saved copies from cache")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    
                    Spacer()
                    
                    Button("Clean Cache") {
                        clipboardManager.clearCache()
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                }
                .padding([.top, .leading, .trailing], 12)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading) // Align the VStack to top-left
            }
            .navigationTitle("General Settings")
        }
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
