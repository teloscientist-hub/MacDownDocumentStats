import AppKit

@objc(MacDownDocumentStatsController)
public final class MacDownDocumentStatsController: NSObject {

    @objc
    public var name: String {
        "Document Stats"
    }

    @objc(run:)
    public func run(sender: Any?) -> Bool {
        guard let currentDocument = NSDocumentController.shared.currentDocument else {
            showAlert(
                title: "Document Stats",
                body: "No active document was found. Open a Markdown document in MacDown and run the plug-in again."
            )
            return false
        }

        let markdown = MPDocumentWrapper(mpDocument: currentDocument).markdown
        let fileURL = currentDocument.fileURL
        let fileAttributes = fileURL.flatMap { try? FileManager.default.attributesOfItem(atPath: $0.path) }

        let stats = DocumentStats(
            displayName: currentDocument.displayName,
            path: fileURL?.path,
            lineCount: lineCount(in: markdown),
            wordCount: wordCount(in: markdown),
            characterCount: markdown.count,
            nonWhitespaceCharacterCount: nonWhitespaceCharacterCount(in: markdown),
            utf8ByteCount: markdown.lengthOfBytes(using: .utf8),
            creationDate: fileAttributes?[.creationDate] as? Date,
            modificationDate: fileAttributes?[.modificationDate] as? Date,
            fileSizeBytes: fileAttributes?[.size] as? NSNumber
        )

        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Document Stats"
        alert.informativeText = formattedBody(for: stats)
        alert.addButton(withTitle: "Copy")
        alert.addButton(withTitle: "OK")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(formattedCopyText(for: stats), forType: .string)
        }

        return true
    }
}

private struct DocumentStats {
    let displayName: String
    let path: String?
    let lineCount: Int
    let wordCount: Int
    let characterCount: Int
    let nonWhitespaceCharacterCount: Int
    let utf8ByteCount: Int
    let creationDate: Date?
    let modificationDate: Date?
    let fileSizeBytes: NSNumber?
}

private func lineCount(in text: String) -> Int {
    guard !text.isEmpty else { return 0 }

    var count = 1
    var previousWasCR = false

    for scalar in text.unicodeScalars {
        switch scalar.value {
        case 13: // \r
            count += 1
            previousWasCR = true
        case 10: // \n
            if previousWasCR {
                previousWasCR = false
            } else {
                count += 1
            }
        default:
            previousWasCR = false
        }
    }

    return count
}

private func wordCount(in text: String) -> Int {
    let nsText = text as NSString
    var count = 0

    nsText.enumerateSubstrings(
        in: NSRange(location: 0, length: nsText.length),
        options: [.byWords, .localized]
    ) { _, _, _, _ in
        count += 1
    }

    return count
}

private func nonWhitespaceCharacterCount(in text: String) -> Int {
    text.unicodeScalars.filter { !CharacterSet.whitespacesAndNewlines.contains($0) }.count
}

private func formattedBody(for stats: DocumentStats) -> String {
    [
        "Name: \(stats.displayName)",
        "Path: \(stats.path ?? "Unsaved document")",
        "",
        "Lines: \(stats.lineCount)",
        "Words: \(stats.wordCount)",
        "Characters: \(stats.characterCount)",
        "Characters (no whitespace): \(stats.nonWhitespaceCharacterCount)",
        "UTF-8 bytes: \(stats.utf8ByteCount)",
        "File size: \(formattedFileSize(from: stats.fileSizeBytes))",
        "",
        "Created: \(formattedDate(stats.creationDate))",
        "Modified: \(formattedDate(stats.modificationDate))"
    ].joined(separator: "\n")
}

private func formattedCopyText(for stats: DocumentStats) -> String {
    """
    Document Stats
    Name: \(stats.displayName)
    Path: \(stats.path ?? "Unsaved document")
    Lines: \(stats.lineCount)
    Words: \(stats.wordCount)
    Characters: \(stats.characterCount)
    Characters (no whitespace): \(stats.nonWhitespaceCharacterCount)
    UTF-8 bytes: \(stats.utf8ByteCount)
    File size: \(formattedFileSize(from: stats.fileSizeBytes))
    Created: \(formattedDate(stats.creationDate))
    Modified: \(formattedDate(stats.modificationDate))
    """
}

private func formattedDate(_ date: Date?) -> String {
    guard let date else { return "Not available" }

    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter.string(from: date)
}

private func formattedFileSize(from number: NSNumber?) -> String {
    guard let number else { return "Not available" }

    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: number.int64Value)
}

private func showAlert(title: String, body: String) {
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.messageText = title
    alert.informativeText = body
    alert.runModal()
}
