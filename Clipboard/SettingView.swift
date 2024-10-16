import SwiftUI
import StoreKit
import KeyboardShortcuts


struct SettingView: View {
    @ObservedObject var settingManager: SettingManager
    @ObservedObject var appDelegate: AppDelegate
    @State private var selectedSection: SettingSection = .general
    
    let generalSettingsLabel = LabelSettings(
        title: "General Settings",
        systemImage: "gear",
        fontSize: 14,
        width: 140,
        height: 35
    )
    
    var body: some View {
        GeneralSettingsView(settingManager: settingManager, appDelegate: appDelegate, entitlementManager: settingManager.entitlementManager)
            .frame(width: 650, height: 500)
    }
    
    // Helper method to configure a label using the LabelSettings
    func configureLabel(with settings: LabelSettings) -> some View {
        Label(settings.title, systemImage: settings.systemImage)
            .font(.system(size: settings.fontSize))
    }
}

enum SettingSection {
    case general
    case subscription
}

struct GrowingButtonStyle: ButtonStyle {
    var backgroundColor: Color = .red
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .font(.system(size: 12))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .frame(width: 150, height: 15)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var settingManager: SettingManager
    @ObservedObject var appDelegate: AppDelegate
    @ObservedObject var entitlementManager: EntitlementManager
    @Environment(\.requestReview) var requestReview
    @State private var launchCount = UserDefaults.standard.integer(forKey: "launchCount")
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("General Settings")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                
                Divider()
                
                // Clean Cache Section
                HStack(alignment: .center) {
                    Text("Deletes all saved copies from cache")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("Clean Cache") {
                        settingManager.clipboardManager?.clearCache()
                    }
                    .buttonStyle(GrowingButtonStyle())
                }
                .padding([.top, .leading, .trailing, .bottom], 14)
                
                HStack(alignment: .center) {
                    Text("Set Shortcut for CopiesPanel Mode")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    ShortcutRecorderView(name: .viewCopiesPanel)
                        .frame(width: 50, height: 50)
                        .disabled(!entitlementManager.hasPro)
                    // Need to clean this, tried aligning both clean cache button and these to be
                    // centered but need to manual align it
                        .padding([.trailing], 50)
                }
                .padding([.top, .leading, .trailing, .bottom], 14)
                
                // Color Picker Section
                HStack {
                    Text("Set copies panel background color: ")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Dont allow users to change opacity
                    ColorPicker("Select Color", selection: $settingManager.panelColor, supportsOpacity: true)
                        .disabled(!entitlementManager.hasPro)
                    
                }
                .padding([.leading, .trailing, .bottom], 14)
                
                // Select Copies Size
                HStack {
                    Text("Select Item Size:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Picker("", selection: $settingManager.itemSize) {
                        Text("Small").tag(ItemSize.small)
                        Text("Medium").tag(ItemSize.medium)
                        Text("Large").tag(ItemSize.large)
                    }
                    .disabled(!entitlementManager.hasPro)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.leading, 10)
                    
                }
                .padding([.leading, .trailing, .bottom], 14)
                
                HStack {
                    Text("Selected Display:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Picker("", selection: $settingManager.selectedScreen) {
                        ForEach(NSScreen.screens, id: \.self) { screen in
                            Text(screen.localizedName).tag(screen.localizedName)
                        }
                    }
                    .disabled(NSScreen.screens.isEmpty) // Disable if no screens are available
                    .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for dropdown
                    .padding(.leading, 10)
                }
                .padding([.leading, .trailing, .bottom], 14)
                
                HStack {
                    Text("Paste Immediately:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    Spacer()
                    Toggle("", isOn: $settingManager.pasteImmediately)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))// Use MenuPickerStyle for dropdown
                    .padding([.trailing], 55)
                }
                .padding([.leading, .trailing, .bottom], 14)
                
                HStack(alignment: .center) {
                    Text("Rate our app")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("Rate App", action: {
                        // Trigger the review request when the button is pressed
                        requestReview()
                    }).buttonStyle(GrowingButtonStyle(backgroundColor: .green.opacity(0.5)))
                }
                .padding([.top, .leading, .trailing, .bottom], 14)
                
                HStack(alignment: .center) {
                    Text("Upgrade to Pro to access additional settings:")
                        .font(.system(size: 13))
                        .foregroundColor(.yellow.opacity(0.5))
                        .padding(.top, 14)

                    Spacer()
                    
                    Button("Upgrade", action: {
                        appDelegate.openTestView()
                    }).buttonStyle(GrowingButtonStyle(backgroundColor: .yellow.opacity(0.5)))
                }
                .padding([.top, .leading, .trailing, .bottom], 14)
                
                
                
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .topLeading)
            .navigationTitle("General Settings")
        }
    }
}

struct ShortcutRecorderView: NSViewRepresentable {
    let name: KeyboardShortcuts.Name
    
    func makeNSView(context: Context) -> KeyboardShortcuts.RecorderCocoa {
        return KeyboardShortcuts.RecorderCocoa(for: name)
    }
    
    func updateNSView(_ nsView: KeyboardShortcuts.RecorderCocoa, context: Context) {
    }
}

struct SubscriptionSettingsView: View {
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


//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        let temp = SettingManager()
//        SettingView(settingManager: temp)
//            .environmentObject(AppDelegate()) // Provide the appDelegate for preview
//    }
//}
