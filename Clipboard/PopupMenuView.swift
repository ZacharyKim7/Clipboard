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
                                            Text(String(displayText(for: clipboardManager.interpretCopyType(index: index))))
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
                                        switch clipboardManager.interpretCopyType(index: index) {
                                        case 0:
                                            TextView(content: item.content)
                                        case 1:
                                            LinkView(content: item.content)
                                        case 2:
                                            ImageView(content: item.content)
                                        default:
                                            Text("Unknown Content")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .multilineTextAlignment(.center)
                                        }
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
    
    private func displayText(for type: Int) -> String {
            switch type {
            case 0:
                return "Text"
            case 1:
                return "Link"
            case 2:
                return "Image"
            default:
                return "Unknown" // Fallback for unexpected values
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

struct TextView: View {
    var content: String
    
    var body: some View {
        Text(content.trimmingCharacters(in: .whitespaces))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}

struct LinkView: View {
    var content: String
    
    var body: some View {
        if let faviconURL = URL(string: "https://www.google.com/s2/favicons?sz=\(128)&domain=\(content)"), faviconURL.scheme != nil, faviconURL.host != nil {
            AsyncImage(url: faviconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(5)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

struct ImageView: View {
    var content: String
    
    var body: some View {
        if let imageURL = URL(string: content), imageURL.scheme != nil, imageURL.host != nil {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(5)
            } placeholder: {
                ProgressView()
            }
        }
    }
}
