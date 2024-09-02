import Foundation
import AppKit

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [String] = []

    private let historyKey = "ClipboardHistory"

    init() {
        loadClipboardHistory()
        startMonitoringClipboard()
    }

    private func loadClipboardHistory() {
        if let savedHistory = UserDefaults.standard.array(forKey: historyKey) as? [String] {
            clipboardHistory = savedHistory
        }
    }

    private func saveClipboardHistory() {
        UserDefaults.standard.set(clipboardHistory, forKey: historyKey)
    }

    private func startMonitoringClipboard() {
        let clipboardMonitor = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
        clipboardMonitor.tolerance = 0.5
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if let copiedString = pasteboard.string(forType: .string), !clipboardHistory.contains(copiedString) {
            clipboardHistory.append(copiedString)
            saveClipboardHistory()
        }
    }
}
