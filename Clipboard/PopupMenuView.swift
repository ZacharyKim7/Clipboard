import SwiftUI

struct PopupMenuView: View {
    // Sample clipboard history data
    let clipboardHistory: [String] = [
        "First copied text",
        "Second copied text",
        "Another copied text",
        "Yet another copied text",
        "More copied text",
        "Final copied text"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(clipboardHistory, id: \.self) { item in
                        VStack {
                            Text(item)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            
                            Divider()
                        }
                        .frame(height: geometry.size.height / CGFloat(clipboardHistory.count))
                        .padding(.horizontal, 10)
                    }
                }
            }
            .padding(.vertical, 50)
        }
    }
}
