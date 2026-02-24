# JamaicaDeals – Copilot Instructions

## Project Overview
iOS app (SwiftUI, iOS 17+) that aggregates Jamaica travel deals from ~19 RSS/Atom feeds and displays them in a card list with an AdMob banner and an Expedia affiliate booking link.

## Build & Project Setup

### Generate the Xcode project
The `.xcodeproj` is generated from `project.yml` using XcodeGen — **do not edit `JamaicaDeals.xcodeproj` directly**.
```sh
xcodegen generate
```
Run this after any change to `project.yml` (new files, dependencies, build settings).

### Local Firebase setup
`GoogleService-Info.plist` is gitignored. Generate it from the committed template before building:
```sh
export FIREBASE_API_KEY="<your-key>"
sed "s|\${FIREBASE_API_KEY}|$FIREBASE_API_KEY|g" \
  JamaicaVacationDeals/GoogleService-Info.plist.template \
  > JamaicaVacationDeals/GoogleService-Info.plist
```
In CI (Xcode Cloud) this is handled automatically by `ci_scripts/ci_post_clone.sh` using the `FIREBASE_API_KEY` secret environment variable.

### Build / run
Open `JamaicaDeals.xcodeproj` in Xcode 15+ and run on a simulator or device (iOS 17+). There are no unit or UI tests.

## Architecture

```
App/
  JamaicaVacationDealsApp   – @main; configures FirebaseApp + GADMobileAds on init
Models/
  TravelDeal                – plain struct; strips HTML via NSAttributedString in plainDescription
Services/
  RSSFeedService            – @MainActor ObservableObject; fetches all feeds concurrently with TaskGroup
  RSSParser                 – XMLParserDelegate; filters items to Jamaica keywords; handles RSS + Atom
Views/
  ContentView               – root view; owns @StateObject RSSFeedService
  DealCardView              – Link wrapping a VStack card; opens deal.link in browser
  HeaderView                – black bar with Expedia affiliate Link
  AdBannerView              – UIViewRepresentable wrapping GADBannerView
```

**Data flow:** `ContentView.task` → `RSSFeedService.fetchDeals()` → concurrent `fetchFeed()` per source → `RSSParser.parse()` → filtered, deduplicated, date-sorted `[TravelDeal]` published back to the view.

## Key Conventions

- **Jamaica keyword filtering** happens in `RSSParser` (not `RSSFeedService`). Add new destination keywords to `RSSParser.jamaicaKeywords`.
- **New RSS sources** go in the `feedSources` array in `RSSFeedService`. Each entry is `(name: String, url: String)`.
- **Brand green** is `Color(red: 0.0, green: 0.55, blue: 0.27)` — used consistently across cards, buttons, and the header gradient. Don't substitute a system color.
- **AdMob ad unit IDs** in `AdBannerView` and `project.yml`'s `GADApplicationIdentifier` are currently test IDs (`ca-app-pub-3940256099942544/…`). Replace both with real IDs before a production release.
- **Expedia affiliate URL** (`https://expedia.com/affiliates/expedia-home.6MzBG4e`) appears in both `HeaderView` and `ContentView` (empty-state fallback). Keep them in sync.
- Swift 5.9, deployment target iOS 17.0 — use structured concurrency (`async/await`, `TaskGroup`) rather than callbacks or Combine.
