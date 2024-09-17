import Foundation
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
}

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [ClipboardItem] = []

    private let historyKey = "ClipboardHistory"
    private var lastCopy: String? // Changed to optional to avoid initial nil comparison issues
    private var timer: Timer?
    private var copyingInProgress: Bool = false // Flag to avoid adding copied content again

    init() {
        loadClipboardHistory()
        lastCopy = clipboardHistory[0].content
        startMonitoringClipboard()
    }

    private func loadClipboardHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey) {
            let decoder = JSONDecoder()
            do {
                clipboardHistory = try decoder.decode([ClipboardItem].self, from: data)
            } catch {
                print("Error decoding clipboard history: \(error)")
            }
        }
    }

    private func saveClipboardHistory() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(clipboardHistory)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Error encoding clipboard history: \(error)")
        }
    }

    private func startMonitoringClipboard() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
        timer?.tolerance = 0.5
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if let copiedString = pasteboard.string(forType: .string) {
            // Check if the copied string is new and not being copied currently
            if !copyingInProgress && lastCopy != copiedString {
                clipboardHistory.insert(ClipboardItem(id: UUID(), content: copiedString), at: 0)
                saveClipboardHistory()
                lastCopy = copiedString
            }
        }
    }
    
    func deleteCopy(index: Int) {
        clipboardHistory.remove(at: index)
        saveClipboardHistory()
    }
    
    func selectCopy(index: Int) {
        guard index >= 0 && index < clipboardHistory.count else {
            print("Invalid index")
            return
        }

        let selectedItem = clipboardHistory[index]
        let pasteboard = NSPasteboard.general

        // Set flag to avoid adding this copy to history again
        copyingInProgress = true
        
        // Copy selected item to the clipboard
        pasteboard.clearContents()
        pasteboard.setString(selectedItem.content, forType: .string)
        lastCopy = selectedItem.content
        // Reset the flag after copying is done
        copyingInProgress = false
    }

    func interpretCopyType(index: Int) -> Int {
        // Ensure the index is within bounds
        guard index >= 0 && index < clipboardHistory.count else {
            return -1 // Index out of bounds
        }
        
        let content = clipboardHistory[index].content
        
        if let url = URL(string: content), url.scheme != nil, url.host != nil {
                // Check if URL ends with an image file extension
            let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff"]
            let pathExtension = url.pathExtension.lowercased()
            if imageExtensions.contains(pathExtension) {
                return 2
            }
            // Otherwise, return 1 for URL
            return 1
        }
        
        // If it's none of the above, assume it's normal text
        return 0
    }

}
