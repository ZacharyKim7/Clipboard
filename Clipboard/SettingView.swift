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
            .frame(width: 500, height: 500)
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

struct proContent: View {
    
    @ObservedObject var settingManager: SettingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("Set shortcut for copies panel:")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Spacer()
                
                ShortcutRecorderView(name: .viewCopiesPanel)
            }
            .padding([.top, .leading, .trailing, .bottom], 14)
            
            // Color Picker Section
            HStack {
                Text("Set background color for copies panel:")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Dont allow users to change opacity
                ColorPicker("Select color", selection: $settingManager.panelColor, supportsOpacity: true)
                
//                Button("Select Color") {
//                    openColorWheel()
//                }
//                .padding()
            }
            .padding([.leading, .trailing, .bottom], 14)
            
            // Select Copies Size
            HStack {
                Text("Select item size:")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                
                Picker("", selection: $settingManager.itemSize) {
                    Text("Small").tag(ItemSize.small)
                    Text("Medium").tag(ItemSize.medium)
                    Text("Large").tag(ItemSize.large)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.leading, 10)
                
            }
            .padding([.leading, .trailing, .bottom], 14)
            
        }
    }
    
    private func openColorWheel() {
        let colorWheelWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        colorWheelWindow.center()
        colorWheelWindow.setFrameAutosaveName("Color Wheel")
        colorWheelWindow.contentView = NSHostingView(rootView: ColorWheel(settingManager: settingManager))
        colorWheelWindow.makeKeyAndOrderFront(nil)
        colorWheelWindow.isReleasedWhenClosed = false
    }
    
}

struct GeneralSettingsView: View {
    @ObservedObject var settingManager: SettingManager
    @ObservedObject var appDelegate: AppDelegate
    @ObservedObject var entitlementManager: EntitlementManager
    @Environment(\.requestReview) var requestReview
    @State private var launchCount = UserDefaults.standard.integer(forKey: "launchCount")
    
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("General Settings")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                
                Divider()
                
                HStack {
                    Text("Click to paste:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    Spacer()
                    Toggle("", isOn: $settingManager.pasteImmediately)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))// Use MenuPickerStyle for dropdown
                    .padding([.trailing], 55)
                }
                .padding([.leading, .trailing, .bottom], 14)
                
                HStack {
                    Text("Selected display:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Picker("", selection: $settingManager.selectedScreen) {
                        ForEach(NSScreen.screens, id: \.self) { screen in
                            Text(screen.localizedName).tag(screen.localizedName)
                        }
                    }
                    .onChange(of: settingManager.selectedScreen, perform: { newValue in
                        appDelegate.resetPopup()
                    })
                    .disabled(NSScreen.screens.isEmpty) // Disable if no screens are available
                    .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for dropdown
                    .padding(.leading, 10)
                }
                .padding([.leading, .trailing, .bottom], 14)
                
                // Clean Cache Section
                HStack(alignment: .center) {
                    Text("Delete all saved copies from memory:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("Clear Copies") {
                        settingManager.clipboardManager?.clearCache()
                    }
                    .buttonStyle(GrowingButtonStyle())
                }
                .padding([.top, .leading, .trailing, .bottom], 14)
                
                HStack(alignment: .center) {
                    Text("Rate our app:")
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

                    Spacer()
                    
                    Button("Upgrade", action: {
                        appDelegate.openTestView()
                    }).buttonStyle(GrowingButtonStyle(backgroundColor: .yellow.opacity(0.5)))
                }
                .padding([.top, .leading, .trailing, .bottom], 14)
                
                Text("Pro Settings")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                
                Divider()
                
                if entitlementManager.hasPro {
                    proContent(settingManager: settingManager)
                    } else {
                        ZStack {
                            proContent(settingManager: settingManager)
                                .opacity(0.3) // Blur effect by reducing opacity
                                .disabled(true)
                            
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                                .padding(5)
                        }
                    }
                Spacer()
            }
            .navigationTitle("General Settings")
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

struct ColorWheel: View {
    @ObservedObject var settingManager: SettingManager // Default color
    @State private var angle: CGFloat = 0
    @State private var brightness: Double = 1.0
    @State private var saturation: Double = 1.0

    var body: some View {
        VStack {
            Circle()
                .fill(AngularGradient(gradient: Gradient(colors: generateColors()), center: .center))
                .frame(width: 100, height: 100)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            updateColor(at: value.location)
                        }
                )
                .gesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            updateColor(at: value.location)
                        }
                )

            HStack {
                Text("Brightness")
                Slider(value: $brightness, in: 0...1, step: 0.01)
                    .onChange(of: brightness) { _ in
                        updateSelectedColor()
                    }
            }
            .padding()

            HStack {
                Text("Saturation")
                Slider(value: $saturation, in: 0...1, step: 0.01)
                    .onChange(of: saturation) { _ in
                        updateSelectedColor()
                    }
            }
            .padding()

            RoundedRectangle(cornerRadius: 15)
                            .fill(settingManager.panelColor)
                            .frame(width: 200, height: 100)
                            .padding()
        }
        .padding()
    }

    // Generate colors around the wheel
    private func generateColors() -> [Color] {
        return (0..<360).map { Color(hue: Double($0) / 360.0, saturation: 1.0, brightness: 1.0) }
    }
    
    private func updateSelectedColor() {
        let hue = (angle < 0 ? angle + (2 * CGFloat.pi) : angle) / (2 * CGFloat.pi)
        settingManager.panelColor = Color(hue: Double(hue), saturation: saturation, brightness: brightness, opacity: 0.1)
    }
    
    private func updateColor(at location: CGPoint) {
            let center = CGPoint(x: 50, y: 50) // Center of the circle
            let deltaX = location.x - center.x
            let deltaY = location.y - center.y
            angle = atan2(deltaY, deltaX) // Angle in radians

            // Normalize the angle to get the hue
            let hue = (angle < 0 ? angle + (2 * CGFloat.pi) : angle) / (2 * CGFloat.pi)
        settingManager.panelColor = Color(hue: Double(hue), saturation: saturation, brightness: brightness, opacity: 0.1)
        }
}
