import Cocoa

/// A minimal Swift wrapper around MacDown's `MPDocument` implementation.
final class MPDocumentWrapper {

    private enum Property: String {
        case markdown
    }

    private unowned let mpDocument: NSDocument

    var markdown: String {
        (mpDocument.value(forKey: Property.markdown.rawValue) as? String) ?? ""
    }

    init(mpDocument: NSDocument) {
        self.mpDocument = mpDocument
    }
}
