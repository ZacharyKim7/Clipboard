import Cocoa
import SwiftUI

struct FirstTimeUserView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var dontShowAgain = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    
    var body: some View {
        VStack(spacing: 20) {
            // App Logo or Cool Symbol
            Image("CopyCat")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 20)

            // Title
            Text("Welcome to CopyCat!")
                .font(.title)
                .fontWeight(.bold)

            // Brief Explanation
            Text("You’re using the free version of CopyCat. This version allows you to store up to 3 copies.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            // How to Use
            VStack(alignment: .leading, spacing: 10) {
                Text("How to Use:")
                    .font(.headline)
                
                Text("1. Copy text, images, or links to your clipboard as usual.")
                Text("2. Access your stored copies from the menu bar or from the clipboard history toolbar (")
                                + Text("Control + V")
                                    .fontWeight(.bold) // Highlighting shortcut
                                    .foregroundColor(.blue) // Change color to blue
                                + Text(")")
                Text("3. Click on an item to paste it or manage your clipboard history.")
                Text("4. Upgrade for more copies and advanced settings.")
            }
            .font(.body)
            .padding(.horizontal)

            // Centered Get Started Button
            HStack {
                Spacer() // Left spacer to center the button
                
                Button(action: {
                    appDelegate.showPopup()
                    appDelegate.closeLaunchWindow()
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer() // Right spacer to center the button
            }
            .padding(.top, 20) // Add some spacing above the button

            // "Don't show this page again" button aligned to bottom-right
            HStack {
                Spacer() // Push the button to the right
                
                Toggle(isOn: $dontShowAgain) {
                    Text("Don't show this page again")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .underline()
                }
                .onChange(of: dontShowAgain) { value in
                    let userDefaults = UserDefaults.standard
                    let hasLaunchedBeforeKey = "hasLaunchedBefore"
                    userDefaults.set(value, forKey: hasLaunchedBeforeKey)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(.trailing, 10) // Right-align
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }
}

struct FirstTimeUserView_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeUserView()
    }
}
