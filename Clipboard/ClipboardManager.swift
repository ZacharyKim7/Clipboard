import Foundation
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
}

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [ClipboardItem] = []

    private let historyKey = "ClipboardHistory"
    private var lastCopy = NSPasteboard.general.string(forType: .string)


    init() {
        loadClipboardHistory()
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
        let clipboardMonitor = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
        clipboardMonitor.tolerance = 0.5
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if let copiedString = pasteboard.string(forType: .string), lastCopy != nil && lastCopy != copiedString {
            clipboardHistory.insert(ClipboardItem(id: UUID(), content: copiedString), at: 0)
            saveClipboardHistory()
            lastCopy = copiedString
        }
    }
    
    func deleteCopy(index: Int) {
        clipboardHistory.remove(at: index)
        saveClipboardHistory()
    }
}
