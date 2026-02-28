import Foundation

/// Parses RSS/Atom XML and returns only hotel deals for Jamaica destinations.
final class RSSParser: NSObject, XMLParserDelegate {

    private var deals: [TravelDeal] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var isInsideItem = false
    private var insideCDATA = false
    private let sourceName: String

    // Keywords used to match Jamaica-related deals (case-insensitive)
    private static let jamaicaKeywords: [String] = [
        "jamaica", "kingston", "montego bay", "ocho rios", "negril",
        "runaway bay", "dunns river", "dunn's river", "mbj", "sandals jamaica",
        "iberostar jamaica", "riu montego", "excellence oyster bay"
    ]

    // Keywords used to match hotel/accommodation deals (case-insensitive)
    private static let hotelKeywords: [String] = [
        "hotel", "resort", "accommodation", "lodging", "stay", "room",
        "all-inclusive", "all inclusive", "villa", "suite", "guesthouse",
        "bed and breakfast", "b&b", "airbnb", "vrbo", "vacation rental",
        "hyatt", "hilton", "marriott", "intercontinental", "westin", "radisson",
        "sandals", "beaches", "iberostar", "riu", "excellence", "secrets",
        "royalton", "grand palladium", "half moon", "round hill", "tryall",
        "couples", "hideaway", "moon palace", "booking", "expedia hotel"
    ]

    init(sourceName: String) {
        self.sourceName = sourceName
    }

    func parse(data: Data) -> [TravelDeal] {
        deals = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return deals
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName.lowercased()
        if currentElement == "item" || currentElement == "entry" {
            isInsideItem = true
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
        }
        // Atom <link href="..."> handling
        if isInsideItem && currentElement == "link",
           let href = attributeDict["href"], !href.isEmpty {
            currentLink = href
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem else { return }
        switch currentElement {
        case "title":           currentTitle += string
        case "description",
             "content:encoded",
             "content",
             "summary":         currentDescription += string
        case "link":            currentLink += string
        case "pubdate",
             "published",
             "updated",
             "dc:date":         currentPubDate += string
        default:                break
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard isInsideItem else { return }
        guard let str = String(data: CDATABlock, encoding: .utf8) else { return }
        switch currentElement {
        case "title":           currentTitle += str
        case "description",
             "content:encoded",
             "content",
             "summary":         currentDescription += str
        default:                break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let element = elementName.lowercased()
        guard element == "item" || element == "entry" else { return }
        isInsideItem = false

        let combined = (currentTitle + " " + currentDescription).lowercased()
        let isJamaica = Self.jamaicaKeywords.contains { combined.contains($0) }
        let isHotel = Self.hotelKeywords.contains { combined.contains($0) }
        guard isJamaica && isHotel else { return }

        let linkString = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: linkString) else { return }

        let deal = TravelDeal(
            title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            link: url,
            pubDate: parseDate(currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)),
            source: sourceName
        )
        deals.append(deal)
    }

    // MARK: - Date Parsing

    private static let dateFormats = [
        "EEE, dd MMM yyyy HH:mm:ss Z",
        "EEE, dd MMM yyyy HH:mm:ss zzz",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd"
    ]

    private func parseDate(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in Self.dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) { return date }
        }
        return nil
    }
}
