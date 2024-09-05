import SwiftUI

struct TestView: View {
    @State private var message: String = "Hello, World!"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.largeTitle)
                .padding()
            
            Button("Change Message") {
                message = "Shortcut keys are cool!"
            }
            .keyboardShortcut("m", modifiers: [.command])
            
            Button("Reset Message") {
                message = "Hello, World!"
            }
            .keyboardShortcut("r", modifiers: [.command])
        }
        .padding()
        .frame(width: 450, height: 500)
    }
}
