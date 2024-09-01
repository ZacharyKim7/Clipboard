import SwiftUI

struct PopupMenuView: View {

    var body: some View {
        VStack {
            Text("Popup Menu")
                .font(.headline)
            Divider()
            Button("Option 1") {
                // Action for Option 1
            }
            Button("Option 2") {
                // Action for Option 2
            }
        }
    }
}
