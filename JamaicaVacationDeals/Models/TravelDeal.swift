import Foundation

struct TravelDeal: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: URL
    let pubDate: Date?
    let source: String

    var formattedDate: String {
        guard let date = pubDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Plain-text description with HTML stripped.
    var plainDescription: String {
        guard let data = description.data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        else {
            return description
        }
        return attributed.string
    }
}
