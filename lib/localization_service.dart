import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _languageKey = 'selected_language';
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // App General
      'app_name': 'GeoPin',
      'app_tagline': 'Test Your Geography Knowledge',
      
      // Settings Screen
      'settings': 'Settings',
      'general': 'General',
      'app': 'App',
      'legal': 'Legal',
      'upgrade_to_premium': 'Upgrade to Premium',
      'upgrade_description': 'Get ad-free experience and exclusive features',
      'language': 'Language',
      'english': 'English',
      'turkish': 'Turkish',
      'music': 'Music',
      'music_description': 'Background music during gameplay',
      'rate_app': 'Rate App',
      'share_app': 'Share App',
      'contact_us': 'Contact Us',
      'contact_description': 'Get in touch with our team',
      'privacy_policy': 'Privacy Policy',
      'terms_of_use': 'Terms of Use',
      
      // Categories
      'tourist_places_1': 'Tourist Places 1',
      'tourist_places_2': 'Tourist Places 2',
      'capitals': 'Capitals',
      'historical_landmarks': 'Historical Landmarks',
      'america': 'America',
      'europe_1': 'Europe 1',
      'europe_2': 'Europe 2',
      'asia_1': 'Asia 1',
      'asia_2': 'Asia 2',
      'africa_1': 'Africa 1',
      'africa_2': 'Africa 2',
      'africa_3': 'Africa 3',
      'oceania': 'Oceania',
      'us_states_1': 'US States 1',
      'us_states_2': 'US States 2',
      'natural_wonders_1': 'Natural Wonders 1',
      'natural_wonders_2': 'Natural Wonders 2',
      'iconic_bridges': 'Iconic Bridges',
      'tallest_skyscrapers': 'Tallest Skyscrapers',
      'world_cuisine': 'World Cuisine',
      'football_stadiums': 'Football Stadiums',
      'famous_airports': 'Famous Airports',
      
      // Game Screen
      'question': 'Question',
      'of': 'of',
      'score': 'Score',
      'time': 'Time',
      'submit': 'Submit',
      'next': 'Next',
      'finish': 'Finish',
      'correct': 'Correct!',
      'incorrect': 'Incorrect',
      'game_over': 'Game Over',
      'your_score': 'Your Score',
      'play_again': 'Play Again',
      'back_to_menu': 'Back to Menu',
      'tap_on_map': 'Tap on the map to answer',
      'distance_error': 'Distance Error',
      'km': 'km',
      'miles': 'miles',
      
      // Premium/Paywall
      'premium': 'Premium',
      'unlock_all_maps': 'Unlock all maps with Premium',
      'category_included_in_pro': 'category is included in PRO package. Get Premium to access all locked categories.',
      'get_premium': 'Get Premium',
      'cancel': 'Cancel',
      
      // Snackbar Messages
      'premium_upgrade_coming_soon': 'Premium upgrade coming soon.',
      'language_selection_coming_soon': 'Language selection coming soon.',
      'rate_app_coming_soon': 'Rate App coming soon.',
      'share_app_coming_soon': 'Share App coming soon.',
      'contact_flow_coming_soon': 'Contact flow coming soon.',
      'privacy_policy_coming_soon': 'Privacy Policy coming soon.',
      'terms_of_use_coming_soon': 'Terms of Use coming soon.',
      'purchase_flow_not_added': 'Purchase flow not yet added.',
      
      // Stats
      'total_score': 'Total Score',
      'games_played': 'Games Played',
      'best_score': 'Best Score',
      'average_accuracy': 'Average Accuracy',
      
      // Questions - Tourist Places
      'q_statue_liberty': 'Where is the Statue of Liberty?',
      'q_eiffel': 'Where is the Eiffel Tower?',
      'q_colosseum': 'Where is the Colosseum?',
      'q_bigben': 'Where is Big Ben?',
      'q_sydney_opera': 'Where is the Sydney Opera House?',
      'q_taj_mahal': 'Where is the Taj Mahal?',
      'q_great_wall': 'Where is the Great Wall of China?',
      'q_golden_gate': 'Where is the Golden Gate Bridge?',
      'q_christ_redeemer': 'Where is Christ the Redeemer?',
      'q_burj_khalifa': 'Where is Burj Khalifa?',
      'q_louvre': 'Where is the Louvre Museum?',
      'q_stonehenge': 'Where is Stonehenge?',
      'q_sagrada_familia': 'Where is Sagrada Familia?',
      'q_acropolis': 'Where is the Acropolis?',
      'q_petra': 'Where is Petra?',
      'q_machu_picchu': 'Where is Machu Picchu?',
      'q_angkor_wat': 'Where is Angkor Wat?',
      'q_forbidden_city': 'Where is the Forbidden City?',
      'q_neuschwanstein': 'Where is Neuschwanstein Castle?',
      'q_versailles': 'Where is the Palace of Versailles?',
    },
    'tr': {
      // App General
      'app_name': 'GeoPin',
      'app_tagline': 'Coğrafya Bilginizi Test Edin',
      
      // Settings Screen
      'settings': 'Ayarlar',
      'general': 'Genel',
      'app': 'Uygulama',
      'legal': 'Yasal',
      'upgrade_to_premium': 'Premium\'a Yükselt',
      'upgrade_description': 'Reklamsız deneyim ve özel özellikler edinin',
      'language': 'Dil',
      'english': 'İngilizce',
      'turkish': 'Türkçe',
      'music': 'Müzik',
      'music_description': 'Oyun sırasında arka plan müziği',
      'rate_app': 'Uygulamayı Değerlendir',
      'share_app': 'Uygulamayı Paylaş',
      'contact_us': 'Bize Ulaşın',
      'contact_description': 'Ekibimizle iletişime geçin',
      'privacy_policy': 'Gizlilik Politikası',
      'terms_of_use': 'Kullanım Koşulları',
      
      // Categories
      'tourist_places_1': 'Turistik Yerler 1',
      'tourist_places_2': 'Turistik Yerler 2',
      'capitals': 'Başkentler',
      'historical_landmarks': 'Tarihi Yerler',
      'america': 'Amerika',
      'europe_1': 'Avrupa 1',
      'europe_2': 'Avrupa 2',
      'asia_1': 'Asya 1',
      'asia_2': 'Asya 2',
      'africa_1': 'Afrika 1',
      'africa_2': 'Afrika 2',
      'africa_3': 'Afrika 3',
      'oceania': 'Okyanusya',
      'us_states_1': 'ABD Eyaletleri 1',
      'us_states_2': 'ABD Eyaletleri 2',
      'natural_wonders_1': 'Doğal Harikalar 1',
      'natural_wonders_2': 'Doğal Harikalar 2',
      'iconic_bridges': 'İkonik Köprüler',
      'tallest_skyscrapers': 'En Yüksek Gökdelenler',
      'world_cuisine': 'Dünya Mutfağı',
      'football_stadiums': 'Futbol Stadyumları',
      'famous_airports': 'Ünlü Havalimanları',
      
      // Game Screen
      'question': 'Soru',
      'of': '/',
      'score': 'Puan',
      'time': 'Süre',
      'submit': 'Gönder',
      'next': 'İleri',
      'finish': 'Bitir',
      'correct': 'Doğru!',
      'incorrect': 'Yanlış',
      'game_over': 'Oyun Bitti',
      'your_score': 'Puanınız',
      'play_again': 'Tekrar Oyna',
      'back_to_menu': 'Menüye Dön',
      'tap_on_map': 'Cevap vermek için haritaya dokunun',
      'distance_error': 'Mesafe Hatası',
      'km': 'km',
      'miles': 'mil',
      
      // Premium/Paywall
      'premium': 'Premium',
      'unlock_all_maps': 'Premium ile tüm haritaların kilidini açın',
      'category_included_in_pro': 'kategorisi PRO paketine dahildir. Tüm kilitli kategorilere erişmek için Premium alın.',
      'get_premium': 'Premium Al',
      'cancel': 'İptal',
      
      // Snackbar Messages
      'premium_upgrade_coming_soon': 'Premium yükseltme yakında.',
      'language_selection_coming_soon': 'Dil seçimi yakında.',
      'rate_app_coming_soon': 'Uygulama değerlendirme yakında.',
      'share_app_coming_soon': 'Uygulama paylaşımı yakında.',
      'contact_flow_coming_soon': 'İletişim akışı yakında.',
      'privacy_policy_coming_soon': 'Gizlilik Politikası yakında.',
      'terms_of_use_coming_soon': 'Kullanım Koşulları yakında.',
      'purchase_flow_not_added': 'Satın alma akışı henüz eklenmedi.',
      
      // Stats
      'total_score': 'Toplam Puan',
      'games_played': 'Oynanan Oyun',
      'best_score': 'En İyi Puan',
      'average_accuracy': 'Ortalama Doğruluk',
      
      // Questions - Tourist Places
      'q_statue_liberty': 'Özgürlük Heykeli nerede?',
      'q_eiffel': 'Eyfel Kulesi nerede?',
      'q_colosseum': 'Kolezyum nerede?',
      'q_bigben': 'Big Ben nerede?',
      'q_sydney_opera': 'Sidney Opera Binası nerede?',
      'q_taj_mahal': 'Tac Mahal nerede?',
      'q_great_wall': 'Çin Seddi nerede?',
      'q_golden_gate': 'Golden Gate Köprüsü nerede?',
      'q_christ_redeemer': 'Kurtarıcı İsa Heykeli nerede?',
      'q_burj_khalifa': 'Burj Khalifa nerede?',
      'q_louvre': 'Louvre Müzesi nerede?',
      'q_stonehenge': 'Stonehenge nerede?',
      'q_sagrada_familia': 'Sagrada Familia nerede?',
      'q_acropolis': 'Akropolis nerede?',
      'q_petra': 'Petra nerede?',
      'q_machu_picchu': 'Machu Picchu nerede?',
      'q_angkor_wat': 'Angkor Wat nerede?',
      'q_forbidden_city': 'Yasak Şehir nerede?',
      'q_neuschwanstein': 'Neuschwanstein Kalesi nerede?',
      'q_versailles': 'Versay Sarayı nerede?',
    },
  };
}

// Extension for easy access
extension LocalizationExtension on String {
  String get tr {
    return LocalizationService().translate(this);
  }
}
