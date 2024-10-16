import SwiftUI

class PopupMenuViewModel: ObservableObject {
    @Published var showingPopup: Bool = false
    // Add other state variables as needed
}

struct PopupMenuView: View {
    
    @ObservedObject var clipboardManager: ClipboardManager
    @ObservedObject var appDelegate: AppDelegate
    @ObservedObject var settingsManager: SettingManager
    //    @ObservedObject var subscriptionManager = SubscriptionManager()
    @State private var deletingIndex: Int? = nil
    @State private var offsetX: CGFloat = -250
    @ObservedObject var viewModel: PopupMenuViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    if clipboardManager.clipboardHistory.isEmpty {
                        Text(NSLocalizedString("no_items", comment: "Message when clipboard history is empty"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding() // Add padding around the text
                    } else {
                        if !appDelegate.entitlementManager.hasPro {
                            ForEach(Array(clipboardManager.clipboardHistory.prefix(settingsManager.numberOfCopies).enumerated()), id: \.element.id) { index, item in
                                if index != deletingIndex {
                                    ClipboardItemView(item: item, index: index, clipboardManager: clipboardManager, settingManager: settingsManager, deletingIndex: $deletingIndex)
                                }
                            }
                            if clipboardManager.clipboardHistory.count == 3 {
                                Button(action: {
                                    appDelegate.openTestView()
                                }) {
                                    LockIconView()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .frame(height: settingsManager.itemSize.dimensions.height)
                                }.buttonStyle(.plain)
                            }
                        } else {
                            // For paid users, display all items
                            ForEach(Array(clipboardManager.clipboardHistory.enumerated()), id: \.element.id) { index, item in
                                if index != deletingIndex {
                                    ClipboardItemView(item: item, index: index, clipboardManager: clipboardManager, settingManager: settingsManager, deletingIndex: $deletingIndex)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures VStack takes full space
                .padding(.vertical, 10)
            }
            .background(settingsManager.panelColor)
            .background(.thinMaterial)
            .offset(x: offsetX) // Apply the offset
            .animation(.easeInOut(duration: 0.35), value: offsetX)
            .onChange(of: viewModel.showingPopup) { newValue in
                if newValue {
                    // Animate to the right when showingPopup becomes true
                    offsetX = 0 // Adjust the value as needed
                } else {
                    // Reset offset if it becomes false
                    offsetX = -250
                }
            }
        }
    }
}

struct ClipboardItemView: View {
    let item: ClipboardItem
    let index: Int
    @ObservedObject var clipboardManager: ClipboardManager
    @ObservedObject var settingManager: SettingManager
    @Binding var deletingIndex: Int?
    
    var body: some View {
        Button(action: {
            clipboardManager.selectCopy(index: index)
        }) {
            VStack {
                HStack {
                    HStack {
                        if index + 1 < 10 {
                            Text("⌘ + \(index + 1)")
                                .fontWeight(.bold)
                                .foregroundColor(Color.red)
                        }
                        Spacer()
                    }
                    Text(displayText(for: item.contentType))
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                    HStack {
                        Spacer()
                        Button(action: {
                            startDeletion(at: index)
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.red)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal, 15)
                
                // Content view based on content type
                contentView(for: item)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.top, 5)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
            .frame(height: settingManager.itemSize.dimensions.width)
            .transition(.move(edge: .leading))
            .animation(.easeOut(duration: 0.3), value: deletingIndex)
        }
        .buttonStyle(PlainButtonStyle())
        .background(backgroundColor(for: item))
        .cornerRadius(10)
        .padding(10)
        .modifier(KeyboardShortcutModifier(index: index))
    }
    
    func backgroundColor(for item: ClipboardItem) -> Color {
        switch item.contentType {
            case 0:
                return Color.black.opacity(0.4)
            case 1:
                return Color.blue.opacity(0.4)
            case 2:
                return Color.red.opacity(0.4)
            default:
                return Color.clear
            }
        }
    
    private func contentView(for item: ClipboardItem) -> some View {
        switch item.contentType {
        case 0:
            return AnyView(TextView(content: item.plainText))
        case 1:
            return AnyView(LinkView(content: item.plainText))
        case 2:
            return AnyView(ImageView(content: item.imgUrl))
        default:
            return AnyView(Text("Unknown Content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center))
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
        case 0: return NSLocalizedString("text_label", comment: "Label for text copy cell")
        case 1: return NSLocalizedString("link_label", comment: "Label for link copy cell")
        case 2: return NSLocalizedString("image_label", comment: "Label for image copy cell")
        default: return NSLocalizedString("text_label", comment: "Label for text copy cell")
        }
    }
}

// Your other view structs remain unchanged (TextView, LinkView, ImageView)



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

struct LockIconView: View {
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "lock.fill") // Use the appropriate lock icon
                .font(.largeTitle) // Adjust size as needed
            Spacer()
            Text("Unlock more copies")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct ImageView: View {
    var content: String
    
    var body: some View {
        if content.hasPrefix("data:image/") {
            // Handle base64-encoded image
            if let imageData = base64ToData(base64String: content),
               let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(5)
            } else {
                Text("Invalid Image")
                    .foregroundColor(.gray)
            }
        } else if let imageURL = URL(string: content), imageURL.scheme != nil, imageURL.host != nil {
            // Handle normal image URL
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(5)
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            Text("Invalid Image URL")
                .foregroundColor(.gray)
        }
    }
    
    private func base64ToData(base64String: String) -> Data? {
        let base64 = base64String.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
            .replacingOccurrences(of: "data:image/png;base64,", with: "")
            .replacingOccurrences(of: "data:image/gif;base64,", with: "")
        return Data(base64Encoded: base64)
    }
}
