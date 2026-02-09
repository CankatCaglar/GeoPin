# GeoPin

GeoPin is an iOS geography game where you answer location challenges by placing pins on a map.

## Highlights

- **Map-based gameplay**
  - Answer questions by pinning the correct location on the map and earn points.
- **Category-based challenges**
  - Multiple themes (e.g. tourist places, capitals, etc.).
- **Localization**
  - In-app localization infrastructure (TR/EN).
- **Premium (IAP)**
  - Premium access via RevenueCat (`purchases_flutter`).
- **Background music**
  - Optional looping background music using `audioplayers`.

## Tech Stack

- **Flutter / Dart**
- **flutter_map + latlong2** (map & coordinates)
- **flutter_riverpod** (state management)
- **shared_preferences / hive** (local persistence)
- **purchases_flutter** (RevenueCat / in-app purchases)
- **url_launcher / share_plus** (links & sharing)

## Repository Structure (iOS-only)

- `lib/` Application source code
- `assets/` Images, JSON data and audio files
- `ios/` Xcode project and iOS configuration
- `pubspec.yaml` Dependencies and assets

## Getting Started (iOS)

> Note: This repository was intentionally simplified for the iOS target. Android/web/desktop folders were removed.

### Requirements

- Flutter SDK (Dart 3+)
- Xcode
- CocoaPods

### Run

```bash
flutter pub get

cd ios
pod install
cd ..

flutter run
```

## In-App Purchases (RevenueCat)

This app uses RevenueCat (`purchases_flutter`). Before running a production build:

- Make sure your RevenueCat project is configured for iOS
- Ensure your products/entitlements are set up correctly

Do not commit signing files, certificates, or private keys to this repository.

## App Store

- App Store link: (add your link here)

## License

All rights reserved. (If you prefer, we can replace this section with an explicit license.)
