import SwiftUI
import GoogleMobileAds

/// Wraps a GADBannerView for use in SwiftUI.
struct AdBannerView: UIViewRepresentable {

    // ⚠️ Replace with your real AdMob Banner Ad Unit ID before publishing.
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = context.coordinator.rootViewController
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator {
        var rootViewController: UIViewController? {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        }
    }
}
