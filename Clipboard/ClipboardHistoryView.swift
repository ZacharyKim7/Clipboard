import SwiftUI

struct ClipboardHistoryView: View {
    @Binding var isPresented: Bool
    var previousCopies: [String] // Example data, adjust as needed

    var body: some View {
        VStack(alignment: .leading) {
            Text("Previous Copies")
                .font(.headline)
                .padding()
            
            List(previousCopies, id: \.self) { copy in
                Text(copy)
            }
            
            Spacer()
        }
        .frame(width: 300) // Adjust the width as needed
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .offset(x: isPresented ? 0 : -300) // Slide in from the left
        .animation(.easeInOut) // Animate the slide-in effect
        .onTapGesture {
            // Dismiss the popup when tapping outside (if needed)
            isPresented = false
        }
    }
}
