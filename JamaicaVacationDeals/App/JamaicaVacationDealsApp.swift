import SwiftUI
import GoogleMobileAds
import FirebaseCore

@main
struct JamaicaDealsApp: App {

    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
