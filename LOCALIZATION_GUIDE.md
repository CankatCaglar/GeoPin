# GeoPin Localization System

## Overview
GeoPin now has a complete localization system supporting English and Turkish languages. Users can switch between languages in the Settings screen, and all UI text will automatically update throughout the app.

## Features Implemented

### 1. Language Selection
- **Location**: Settings → Language
- **Supported Languages**: 
  - English (en)
  - Turkish (tr)
- **Persistence**: Language preference is saved using SharedPreferences

### 2. Localized Components

#### Main App Screens
- ✅ Splash Screen (tagline)
- ✅ Settings Screen (all menu items and labels)
- ✅ Category Screen (all category titles)
- ✅ Premium/Paywall Dialog

#### Categories (All Translated)
- Tourist Places 1 & 2
- Capitals
- Historical Landmarks
- America, Europe 1-2, Asia 1-2, Africa 1-3
- Oceania
- US States 1-2
- Natural Wonders 1-2
- Iconic Bridges
- Tallest Skyscrapers
- World Cuisine
- Football Stadiums
- Famous Airports

#### UI Elements
- Settings menu items
- Premium upgrade messages
- Snackbar notifications
- Dialog buttons (Cancel, Get Premium, etc.)

## How It Works

### Architecture
1. **AppLocalizations** (`app_localizations.dart`): Main localization service
   - Manages current language state
   - Provides translation lookup via `get()` method
   - Extends `ChangeNotifier` for reactive UI updates
   - Persists language preference

2. **Category Model**: Updated to use `titleKey` instead of hardcoded titles
   - Each category has a `titleKey` that maps to translation keys
   - `title` getter automatically returns localized string

3. **GeoPinApp**: Wrapped with `ListenableBuilder`
   - Listens to AppLocalizations changes
   - Rebuilds entire app when language changes

### Usage Example

```dart
// Get localization instance
final loc = AppLocalizations();

// Get translated string
Text(loc.get('settings'))

// In widgets
Text(AppLocalizations().get('language'))
```

## Translation Keys

### Settings Screen
- `settings`, `general`, `app`, `legal`
- `upgrade_to_premium`, `upgrade_description`
- `language`, `english`, `turkish`
- `music`, `music_description`
- `rate_app`, `share_app`, `contact_us`, `contact_description`
- `privacy_policy`, `terms_of_use`

### Categories
- `tourist_places_1`, `tourist_places_2`
- `capitals`, `historical_landmarks`
- `america`, `europe_1`, `europe_2`
- `asia_1`, `asia_2`
- `africa_1`, `africa_2`, `africa_3`
- `oceania`
- `us_states_1`, `us_states_2`
- `natural_wonders_1`, `natural_wonders_2`
- `iconic_bridges`, `tallest_skyscrapers`
- `world_cuisine`, `football_stadiums`, `famous_airports`

### Premium/Paywall
- `premium`, `unlock_all_maps`, `get_premium`, `cancel`
- `category_included_in_pro`

### Messages
- `premium_upgrade_coming_soon`
- `language_selection_coming_soon`
- `rate_app_coming_soon`
- `share_app_coming_soon`
- `contact_flow_coming_soon`
- `privacy_policy_coming_soon`
- `terms_of_use_coming_soon`
- `purchase_flow_not_added`

## How to Add New Translations

1. Open `lib/app_localizations.dart`
2. Add new key-value pairs to both `_englishTranslations` and `_turkishTranslations` maps
3. Use the key in your UI: `AppLocalizations().get('your_new_key')`

Example:
```dart
const Map<String, String> _englishTranslations = {
  // ... existing translations
  'new_feature': 'New Feature',
};

const Map<String, String> _turkishTranslations = {
  // ... existing translations
  'new_feature': 'Yeni Özellik',
};
```

## Testing

### Manual Testing Steps
1. Launch the app
2. Navigate to Settings
3. Tap on "Language"
4. Select "Türkçe"
5. Verify all visible text changes to Turkish:
   - Settings screen labels
   - Category titles on home screen
   - Splash screen tagline (restart app)
   - Premium dialog text
6. Switch back to "English" and verify text reverts

### Expected Behavior
- Language change is immediate for current screen
- All screens reflect the new language
- Language preference persists across app restarts
- No app restart required for language change

## Files Modified

1. **lib/app_localizations.dart** (NEW)
   - Complete localization service with English and Turkish translations

2. **lib/localization_service.dart** (NEW)
   - Legacy file (can be removed if not used elsewhere)

3. **lib/main.dart** (MODIFIED)
   - Added localization import
   - Updated `main()` to initialize localization
   - Wrapped `GeoPinApp` with `ListenableBuilder`
   - Updated `Category` model to use `titleKey`
   - Updated all category definitions
   - Localized `SplashScreen` tagline
   - Converted `SettingsScreen` to StatefulWidget
   - Localized all Settings menu items
   - Added language selection dialog
   - Localized paywall dialog

## Future Enhancements

### To Localize Game Screens
The following game screen files need localization for questions and UI:
- `lib/america_button_game.dart`
- `lib/europe_button_game.dart`
- `lib/asia_button_game.dart`
- `lib/africa_button_game.dart`
- `lib/oceania_button_game.dart`
- `lib/us_states_button_game.dart`
- `lib/natural_wonders_button_game.dart`
- `lib/world_cuisine_button_game.dart`
- `lib/stadiums_button_game.dart`
- `lib/airports_button_game.dart`

### To Add More Languages
1. Add new language code to `AppLocalizations`
2. Create new translation map (e.g., `_spanishTranslations`)
3. Add to `_translations` map
4. Update language selection dialog

## Notes

- The system uses `shared_preferences` package for persistence
- All translations are stored in-memory for fast access
- The app automatically falls back to English if a translation key is missing
- Category titles are dynamically translated using getter properties
- The localization service is a singleton for consistent state management
