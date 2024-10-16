import Foundation
import AppKit
import MASShortcut

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let plainText: String
    let htmlString: String
    let contentType: Int
    let imgUrl: String
    
}

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [ClipboardItem] = []
    
    private let historyKey = "ClipboardHistory"
    private var lastCopy: ClipboardItem? // Changed to optional to avoid initial nil comparison issues
    private var timer: Timer?
    private var copyingInProgress: Bool = false // Flag to avoid adding copied content again
    private let entitlementManager: EntitlementManager
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        loadClipboardHistory()
        if clipboardHistory.count > 0 {
            lastCopy = clipboardHistory[0]
        } else {
            lastCopy = nil
        }
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
        if !copyingInProgress {
            let pasteboard = NSPasteboard.general
            let maxClipboardHistory = entitlementManager.hasPro ? 50 : 3 // Check user status

            if let htmlData = pasteboard.data(forType: .html),
               let htmlString = String(data: htmlData, encoding: .utf8),
               htmlString.contains("<img") {
                if lastCopy?.htmlString != extractImgTag(from: htmlString) {
                    let item = ClipboardItem(id: UUID(), plainText: "", htmlString: extractImgTag(from: htmlString), contentType: 2, imgUrl: extractImageSrc(from: htmlString))
                    clipboardHistory.insert(item, at: 0)
                    
                    // Limit the history size
                    if clipboardHistory.count > maxClipboardHistory {
                        clipboardHistory.removeLast(clipboardHistory.count - maxClipboardHistory)
                    }

                    saveClipboardHistory()
                    lastCopy = item
                    print("IMG")
                }
            } else {
                if let copiedString = pasteboard.string(forType: .string) {
                    // Check if the copied string is new and not being copied currently
                    var item: ClipboardItem
                    if lastCopy?.plainText != copiedString {
                        // Check if the copied string is a valid URL
                        if let url = URL(string: copiedString), url.scheme != nil, url.host != nil {
                            // It's a valid URL, save it as type '1'
                            item = ClipboardItem(id: UUID(), plainText: copiedString, htmlString: "", contentType: 1, imgUrl: "")
                            clipboardHistory.insert(item, at: 0)
                            print("URL")
                        } else {
                            // Not a valid URL, save as type '0'
                            item = ClipboardItem(id: UUID(), plainText: copiedString, htmlString: "", contentType: 0, imgUrl: "")
                            clipboardHistory.insert(item, at: 0)
                            print("Text")
                        }
                        
                        // Limit the history size
                        if clipboardHistory.count > maxClipboardHistory {
                            clipboardHistory.removeLast(clipboardHistory.count - maxClipboardHistory)
                        }

                        saveClipboardHistory()
                        lastCopy = item
                    }
                }
            }
        }
    }
    
    private func extractImgTag(from htmlString: String) -> String {
        let imgTagPattern = "<img[^>]*>"
        let regex = try? NSRegularExpression(pattern: imgTagPattern, options: .caseInsensitive)
        let nsString = htmlString as NSString
        let results = regex?.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // Return the first <img> tag found
        if let match = results?.first {
            return nsString.substring(with: match.range)
        }
        
        return ""
    }
    
    private func extractImageSrc(from htmlString: String) -> String {
        let regexPattern = "src=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        let nsString = htmlString as NSString
        let results = regex?.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // Return the first matched src URL if found
        if let match = results?.first, match.numberOfRanges > 1 {
            let range = match.range(at: 1) // The first capturing group
            return nsString.substring(with: range)
        }
        
        return ""
    }
    
    func deleteCopy(index: Int) {
        // Check if the index is within the valid range
        guard index >= 0 && index < clipboardHistory.count else {
            print("Index \(index) is out of range. No item deleted.")
            return
        }
        
        clipboardHistory.remove(at: index)
        saveClipboardHistory()
    }
    
    func selectCopy(index: Int) {
        guard index >= 0 && index < clipboardHistory.count else {
            print("Invalid index")
            return
        }
        
        // If user has the paste immediate setting on
        pasteText()
        
        let selectedItem = clipboardHistory[index]
        let pasteboard = NSPasteboard.general
        
        // Set flag to avoid adding this copy to history again
        copyingInProgress = true
        
        // Clear the clipboard
        pasteboard.clearContents()
        
        // Check the content type
        if selectedItem.contentType == 2 { // Image type
            // Assuming selectedItem.content is the HTML string representation
            if let htmlData = selectedItem.htmlString.data(using: .utf8) {
                pasteboard.setData(htmlData, forType: .html) // Set HTML data
                print("Copied HTML for image: \(selectedItem.htmlString)")
            }
        } else {
            // For other types, just set the string
            pasteboard.setString(selectedItem.plainText, forType: .string)
            print("Copied Plain Text: \(selectedItem.plainText)")
        }
        
        lastCopy = selectedItem
        
        // Reset the flag after copying is done
        copyingInProgress = false
    }
    
    func pasteText() {
        DispatchQueue.main.async {
          let vCode = UInt16(kVK_ANSI_V)
          let source = CGEventSource(stateID: .combinedSessionState)
          // Disable local keyboard events while pasting
          source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents],
                                                             state: .eventSuppressionStateSuppressionInterval)

          let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: true)
          let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: false)
          keyVDown?.flags = .maskCommand
          keyVUp?.flags = .maskCommand
          keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
          keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
    
    func clearCache() {
        clipboardHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
        saveClipboardHistory()
        
        print("Log: Clipboard cache been cleared!")
    }
}
