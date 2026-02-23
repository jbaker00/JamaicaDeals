import Foundation

@MainActor
final class RSSFeedService: ObservableObject {

    @Published var deals: [TravelDeal] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?

    /// RSS/Atom feed sources that regularly publish travel deals.
    private let feedSources: [(name: String, url: String)] = [
        // General travel deal aggregators (filtered to Jamaica keywords)
        ("The Flight Deal",    "https://www.theflightdeal.com/feed/"),
        ("Secret Flying",      "https://secretflying.com/feed/"),
        ("Fly4Free",           "https://fly4free.com/feed/"),
        ("Airfare Watchdog",   "https://airfarewatchdog.com/blog/feed/"),
        ("The Points Guy",     "https://thepointsguy.com/feed/"),
        ("Travel + Leisure",   "https://www.travelandleisure.com/rss/all.xml"),
        ("Frommer's",          "https://www.frommers.com/rss/news"),
        ("Travel Pulse",       "https://www.travelpulse.com/rss/news.xml"),
        // Jamaica-specific travel & tourism feeds
        ("Visit Jamaica",      "https://www.visitjamaica.com/blog/rss/"),
        ("Adventures from Elle","https://adventuresfromelle.com/feed/"),
        ("Getting Stamped",    "https://www.gettingstamped.com/category/destinations/caribbean/jamaica/feed/"),
        ("The Tryall Club",    "https://tryallclub.com/blog/feed/"),
        ("Simply Local",       "https://simplylocal.life/feed/"),
        ("Jamaicans.com",      "https://jamaicans.com/feed/"),
        // High-traffic general travel blogs that regularly cover Caribbean/luxury/deals
        ("Nomadic Matt",       "https://www.nomadicmatt.com/feed/"),
        ("A Luxury Travel Blog","https://www.aluxurytravelblog.com/feed/"),
        ("ViaTravelers",       "https://feeds.feedburner.com/viatravelers/xgwz"),
        ("HoneyTrek",          "https://www.honeytrek.com/feed/"),
        // US State Department travel advisories (Jamaica advisory will pass keyword filter)
        ("US Travel Advisory", "https://travel.state.gov/_res/rss/TAsTWs.xml")
    ]

    // MARK: - Public

    func fetchDeals() async {
        isLoading = true
        var allDeals: [TravelDeal] = []

        await withTaskGroup(of: [TravelDeal].self) { group in
            for source in feedSources {
                group.addTask { [weak self] in
                    guard let self else { return [] }
                    return await self.fetchFeed(name: source.name, urlString: source.url)
                }
            }
            for await result in group {
                allDeals.append(contentsOf: result)
            }
        }

        // Sort newest first; deduplicate by URL
        var seen = Set<String>()
        deals = allDeals
            .sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
            .filter { seen.insert($0.link.absoluteString).inserted }

        lastUpdated = Date()
        isLoading = false
    }

    // MARK: - Private

    private func fetchFeed(name: String, urlString: String) async -> [TravelDeal] {
        guard let url = URL(string: urlString) else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parser = RSSParser(sourceName: name)
            return parser.parse(data: data)
        } catch {
            return []
        }
    }
}
