import SwiftUI

struct ContentView: View {

    @StateObject private var feedService = RSSFeedService()

    var body: some View {
        VStack(spacing: 0) {

            // ── Header: logo + Book Now ──────────────────────────────────────
            HeaderView()

            // ── Title bar ───────────────────────────────────────────────────
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("🇯🇲 JamaicaDeals")
                        .font(.title2)
                        .fontWeight(.bold)
                    if let updated = feedService.lastUpdated {
                        Text("Updated \(updated, style: .relative) ago")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button {
                    Task { await feedService.fetchDeals() }
                } label: {
                    Image(systemName: feedService.isLoading ? "ellipsis" : "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .disabled(feedService.isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            // ── Content area ─────────────────────────────────────────────────
            Group {
                if feedService.isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                        Text("Finding Jamaica deals…")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if feedService.deals.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("🌴")
                            .font(.system(size: 60))
                        Text("No Jamaica deals right now")
                            .font(.headline)
                        Text("Pull down to refresh or tap ↻ to check the latest deals.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        // Fallback: send user to book directly
                        Link(destination: URL(string: "https://expedia.com/affiliates/expedia-home.6MzBG4e")!) {
                            Label("Browse All Jamaica Deals", systemImage: "airplane")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.0, green: 0.55, blue: 0.27))
                                .cornerRadius(22)
                        }
                        .padding(.top, 6)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(feedService.deals) { deal in
                                DealCardView(deal: deal)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .refreshable {
                        await feedService.fetchDeals()
                    }
                }
            }

            Divider()

            // ── Google AdMob Banner ─────────────────────────────────────────
            AdBannerView()
                .frame(height: 50)
        }
        .task {
            await feedService.fetchDeals()
        }
    }
}

#Preview {
    ContentView()
}
