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
    
    @ObservedObject var clipboardManager: ClipboardManager
    @State private var deletingIndex: Int? = nil
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Button(action: {
                    print("WOOHO")
                }
                        ) {
                    Text("HEYY")
                }.keyboardShortcut("2",modifiers: .command)
                VStack(spacing: 0) {
                    ForEach(Array(clipboardManager.clipboardHistory.enumerated()), id: \.element.id) { index, item in
                        if index != deletingIndex {
                            Button(action: {
                                        // Action to perform when the VStack is tapped
                                        print("VStack tapped!")
                            }) {
                                VStack {
                                    VStack {
                                        HStack {
                                            HStack {
                                                if index + 1 < 10 {
                                                    Text("⌘ + \(index+1)")
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color.red)
                                                } else {
                                                    Text("\(index+1)")
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color.gray)
                                                }
                                                Spacer() // Spacer to push the text to the left
                                            }
                                            Text("LINK")
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.gray)
                                            HStack {
                                                Spacer() // Spacer to push the button to the right
                                                Button(action: {
                                                    startDeletion(at: index)
                                                }) {
                                                    Image(systemName: "xmark")
                                                        .foregroundColor(Color.red)
                                                }.buttonStyle(.plain)
                                            }
                                        }
                                        
                                        .padding(.top, 5)
                                        .padding(.horizontal, 5)
                                        Text(item.content.trimmingCharacters(in: .whitespaces))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .multilineTextAlignment(.center)
                                    }.background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                }
                                .frame(height: geometry.size.height / CGFloat(clipboardHistory.count))
                                .transition(.move(edge: .leading))
                                .animation(.easeOut(duration: 0.3), value: deletingIndex)
                            }.buttonStyle(PlainButtonStyle())
                                .keyboardShortcut("1", modifiers: .command)
                      }
                    }
                }
            }
            .padding(.vertical, 50)
            
        }
    }
    
    private func startDeletion(at index: Int) {
            withAnimation {
                deletingIndex = index
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                clipboardManager.deleteCopy(index: index)
                deletingIndex = nil
            }
    }
}


