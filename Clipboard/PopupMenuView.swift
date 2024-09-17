import SwiftUI

struct PopupMenuView: View {
    
    @ObservedObject var clipboardManager: ClipboardManager
    @State private var deletingIndex: Int? = nil
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(clipboardManager.clipboardHistory.enumerated()), id: \.element.id) { index, item in
                        if index != deletingIndex {
                            Button(action: {
                                // Action to perform when the VStack is tapped
                                clipboardManager.selectCopy(index: index)
                            }) {
                                VStack {
                                    VStack {
                                        HStack {
                                            HStack {
                                                if index + 1 < 10 {
                                                    Text("⌘ + \(index+1)")
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color.red)
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
                                .frame(height: 200)
                                .transition(.move(edge: .leading))
                                .animation(.easeOut(duration: 0.3), value: deletingIndex)
                            }.buttonStyle(PlainButtonStyle())
                                .modifier(KeyboardShortcutModifier(index: index))
                            
                        }
                    }
                }
            }
            .padding(.vertical, 10)

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

struct KeyboardShortcutModifier: ViewModifier {
    let index: Int

    func body(content: Content) -> some View {
        if (1...9).contains(index + 1) {
            content.keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
        } else {
            content
        }
    }
}
