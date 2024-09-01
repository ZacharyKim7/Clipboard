import SwiftUI

struct FirstTimeUserView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(spacing: 20) {
            // App Logo or Cool Symbol
            Image(systemName: "doc.plaintext")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 5)

            // Title
            Text("Welcome to Clipboard!")
                .font(.title)
                .fontWeight(.bold)

            // Brief Explanation
            Text("You’re using the free version of Clipboard Manager. This version allows you to store up to 5 copies.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            // How to Use
            VStack(alignment: .leading, spacing: 10) {
                Text("How to Use:")
                    .font(.headline)
                
                Text("1. Copy text or images to your clipboard as usual.")
                Text("2. Access your stored copies from the menu bar or from the clipboard history toolbar (")
                                + Text("Control + V")
                                    .fontWeight(.bold) // Highlighting shortcut
                                    .foregroundColor(.blue) // Change color to blue
                                + Text(")")
                Text("3. Click on an item to paste it or manage your clipboard history.")
                Text("4. Upgrade for unlimited storage and advanced features.")
            }
            .font(.body)
            .padding(.horizontal)

            // Get Started Button
            Button(action: {
                appDelegate.showPopup()
            }) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()

        }
        .padding()
    }
}

struct FirstTimeUserView_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeUserView()
    }
}
