import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'stat_card.dart';
import 'theme_provider.dart';
import 'music_provider.dart';
import 'premium_provider.dart';
import 'america_button_game.dart';
import 'europe_button_game.dart';
import 'asia_button_game.dart';
import 'africa_button_game.dart';
import 'oceania_button_game.dart';
import 'us_states_button_game.dart';
import 'natural_wonders_button_game.dart';
import 'world_cuisine_button_game.dart';
import 'stadiums_button_game.dart';
import 'airports_button_game.dart';
import 'generic_button_game.dart';
import 'app_localizations.dart';
import 'paywall_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalizations().initialize();
  
  await Purchases.configure(
    PurchasesConfiguration('appl_jkIjDYkOJEWviaBULUAEohpHxkM')
      ..appUserID = null
      ..observerMode = false,
  );
  
  runApp(const ProviderScope(child: GeoPinApp()));
}

class GeoPinApp extends ConsumerWidget {
  const GeoPinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize music provider to load saved preference
    ref.watch(musicProvider);
    final themeMode = ref.watch(themeProvider);
    
    return ListenableBuilder(
      listenable: AppLocalizations(),
      builder: (context, child) {
        return MaterialApp(
          title: 'GeoPin',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

// MODELS

class Category {
  Category({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.isLocked,
    this.backgroundImage,
    this.isPremium = false,
  });

  final String id;
  final String titleKey;
  final IconData icon;
  final bool isLocked;
  final String? backgroundImage;
  final bool isPremium;
  
  String get title => AppLocalizations().get(titleKey);
}

class Question {
  Question({
    required this.id,
    required this.categoryId,
    required this.prompt,
    required this.lat,
    required this.lng,
    this.polygon,
    this.isPolygonBased = false,
  });

  final String id;
  final String categoryId;
  final String prompt; // Orijinal İngilizce soru
  final double lat;
  final double lng;
  final List<LatLng>? polygon; // Ülke sınırları için polygon koordinatları
  final bool isPolygonBased; // Polygon tabanlı soru mu?

  LatLng get location => LatLng(lat, lng);
  
  // Lokalize edilmiş soru metni
  String getLocalizedPrompt() {
    final currentLang = AppLocalizations().currentLanguage;
    if (currentLang == 'tr') {
      // Türkçe için çeviri ara
      final key = _promptToKey(prompt);
      final translated = AppLocalizations().get(key);
      if (translated != key) {
        return translated;
      }
    }
    // İngilizce veya çeviri yoksa orijinal prompt
    return prompt;
  }
  
  // Prompt'u çeviri anahtarına dönüştür
  String _promptToKey(String prompt) {
    String key = prompt.toLowerCase().trim();
    // Tüm soru formatlarını 'q_' ile başlat
    key = key.replaceAll('where is ', 'q_')
             .replaceAll('where are ', 'q_')
             .replaceAll('where do ', 'q_');
    // Remove 'the' article (both with spaces and after q_)
    key = key.replaceAll(' the ', ' ')
             .replaceAll('the ', '')
             .trim();
    key = key.replaceAll('?', '').replaceAll("'", '').replaceAll('"', '');
    key = key.replaceAll(' ', '_').replaceAll(',', '').replaceAll('(', '').replaceAll(')', '');
    key = key.replaceAll('.', '').replaceAll('–', '').replaceAll(''', '').replaceAll(''', '');
    // Clean up multiple underscores and trim
    while (key.contains('__')) {
      key = key.replaceAll('__', '_');
    }
    // Remove leading/trailing underscores
    key = key.replaceAll(RegExp(r'^_+|_+$'), '');
    return key;
  }
}

// SABİT KATEGORİLER (ileride JSON'dan okunacak)
final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    // 1) Tourist Places 1
    Category(
      id: 'tourist_places_1',
      titleKey: 'tourist_places_1',
      icon: Icons.travel_explore,
      isLocked: false,
      backgroundImage: 'assets/images/tourist_places.jpg',
    ),
    // 2) Tourist Places 2
    Category(
      id: 'tourist_places_2',
      titleKey: 'tourist_places_2',
      icon: Icons.travel_explore,
      isLocked: false,
      backgroundImage: 'assets/images/tourist_places_2.jpg',
    ),
    // 3) Capitals 1
    Category(
      id: 'capitals_1',
      titleKey: 'capitals_1',
      icon: Icons.location_city,
      isLocked: false,
      backgroundImage: 'assets/images/capitals.jpg',
    ),
    // 4) Capitals 2
    Category(
      id: 'capitals_2',
      titleKey: 'capitals_2',
      icon: Icons.location_city,
      isLocked: false,
      backgroundImage: 'assets/images/capitals2.jpg',
    ),
    // 5) Historical Landmarks (eski Historical Monuments, kilitsiz)
    Category(
      id: 'monuments',
      titleKey: 'historical_landmarks',
      icon: Icons.account_balance,
      isLocked: false,
      backgroundImage: 'assets/images/monuments.jpg',
    ),
    // 5) America
    Category(
      id: 'america',
      titleKey: 'america',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/america.jpg',
    ),
    // 6) Europe 1
    Category(
      id: 'europe_1',
      titleKey: 'europe_1',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/europe.jpg',
    ),
    // 7) Europe 2
    Category(
      id: 'europe_2',
      titleKey: 'europe_2',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/europe.jpg',
    ),
    // 8) Asia 1
    Category(
      id: 'asia_1',
      titleKey: 'asia_1',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/asia.jpg',
    ),
    // 9) Asia 2
    Category(
      id: 'asia_2',
      titleKey: 'asia_2',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/asia.jpg',
    ),
    // 10) Africa 1
    Category(
      id: 'africa_1',
      titleKey: 'africa_1',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/africa.jpg',
    ),
    // 11) Africa 2
    Category(
      id: 'africa_2',
      titleKey: 'africa_2',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/africa.jpg',
    ),
    // 12) Africa 3
    Category(
      id: 'africa_3',
      titleKey: 'africa_3',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/africa.jpg',
    ),
    // 13) Oceania
    Category(
      id: 'oceania',
      titleKey: 'oceania',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/oceania.jpg',
    ),
    // 14) US States 1
    Category(
      id: 'us_states_1',
      titleKey: 'us_states_1',
      icon: Icons.flag,
      isLocked: false,
      backgroundImage: 'assets/images/us_states.jpg',
    ),
    // 15) US States 2
    Category(
      id: 'us_states_2',
      titleKey: 'us_states_2',
      icon: Icons.flag,
      isLocked: false,
      backgroundImage: 'assets/images/america_states2.jpg',
    ),
    // 16) US States 3
    Category(
      id: 'us_states_3',
      titleKey: 'us_states_3',
      icon: Icons.flag,
      isLocked: false,
      backgroundImage: 'assets/images/us_states3.jpg',
    ),
    // 17) US States 4
    Category(
      id: 'us_states_4',
      titleKey: 'us_states_4',
      icon: Icons.flag,
      isLocked: false,
      backgroundImage: 'assets/images/us_states4.jpg',
    ),
    // 11) Natural Wonders 1
    Category(
      id: 'natural_wonders_1',
      titleKey: 'natural_wonders_1',
      icon: Icons.landscape,
      isLocked: false,
      backgroundImage: 'assets/images/natural_wonders.jpg',
    ),
    // 12) Natural Wonders 2
    Category(
      id: 'natural_wonders_2',
      titleKey: 'natural_wonders_2',
      icon: Icons.landscape,
      isLocked: false,
      backgroundImage: 'assets/images/natural_wonders2.jpg',
    ),
    // 13) Natural Wonders 3
    Category(
      id: 'natural_wonders_3',
      titleKey: 'natural_wonders_3',
      icon: Icons.landscape,
      isLocked: false,
      backgroundImage: 'assets/images/natural_wonders3.jpg',
    ),
    // 14) Iconic Bridges
    Category(
      id: 'iconic_bridges',
      titleKey: 'iconic_bridges',
      icon: Icons.account_balance,
      isLocked: false,
      backgroundImage: 'assets/images/iconic_bridges.jpg',
      isPremium: true,
    ),
    // 14) Tallest Skyscrapers
    Category(
      id: 'tallest_skyscrapers',
      titleKey: 'tallest_skyscrapers',
      icon: Icons.apartment,
      isLocked: false,
      backgroundImage: 'assets/images/tallest_skyscrapers.jpg',
      isPremium: true,
    ),
    // 15) World Cuisine
    Category(
      id: 'world_cuisine',
      titleKey: 'world_cuisine',
      icon: Icons.restaurant,
      isLocked: false,
      backgroundImage: 'assets/images/world_cuisine.jpg',
      isPremium: true,
    ),
    // 16) Football Stadiums (mevcut stadiums kategorisi)
    Category(
      id: 'stadiums',
      titleKey: 'football_stadiums',
      icon: Icons.sports_soccer,
      isLocked: false,
      backgroundImage: 'assets/images/stadiums.jpg',
      isPremium: true,
    ),
    // 17) Famous Airports
    Category(
      id: 'airports',
      titleKey: 'famous_airports',
      icon: Icons.flight_takeoff,
      isLocked: false,
      backgroundImage: 'assets/images/airports.jpg',
      isPremium: true,
    ),
    Category(
      id: 'space_bases',
      titleKey: 'space_bases',
      icon: Icons.rocket_launch,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/space_bases.jpg',
    ),
    Category(
      id: 'tech_hubs',
      titleKey: 'tech_hubs',
      icon: Icons.memory,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/spacehubs.jpg',
    ),
    Category(
      id: 'scientific_wonders',
      titleKey: 'scientific_wonders',
      icon: Icons.science,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/scientifiwonders.jpg',
    ),
    Category(
      id: 'endemic_animals',
      titleKey: 'endemic_animals',
      icon: Icons.pets,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/endemic_animals.jpg',
    ),
    Category(
      id: 'extreme_points',
      titleKey: 'extreme_points',
      icon: Icons.thermostat,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/extreme_places.jpg',
    ),
    Category(
      id: 'volcanoes',
      titleKey: 'volcanoes',
      icon: Icons.local_fire_department,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/volcanoes.jpg',
    ),
    Category(
      id: 'f1_circuits',
      titleKey: 'f1_circuits',
      icon: Icons.sports_motorsports,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/formula1_circuits.jpg',
    ),
    Category(
      id: 'famous_brands',
      titleKey: 'famous_brands',
      icon: Icons.business,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/world_famous_brands.jpg',
    ),
    Category(
      id: 'famous_people',
      titleKey: 'famous_people',
      icon: Icons.person,
      isLocked: false,
      isPremium: true,
      backgroundImage: 'assets/images/Famous_characters.jpg',
    ),
  ];
});

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // Navigate to main screen after 2 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CategoryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container - gerçek app icon görseli ile
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.public,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    // App Name
                    Text(
                      'GeoPin',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tagline
                    Text(
                      AppLocalizations().get('app_tagline'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Loading indicator
                    const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoadingPurchase = false;

  Future<void> _showPremiumPurchaseDialog(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PaywallScreen(),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _purchasePremium(Package package) async {
    final loc = AppLocalizations();
    setState(() => _isLoadingPurchase = true);

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      
      debugPrint('Available entitlements: ${customerInfo.entitlements.all.keys}');
      final isPremium = customerInfo.entitlements.all['premium_GeoPin']?.isActive ?? false;
      
      if (isPremium) {
        ref.read(premiumProvider.notifier).refresh();
      }
      
      setState(() {
        _isLoadingPurchase = false;
      });

      if (!mounted) return;
      
      if (isPremium) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.amber),
                const SizedBox(width: 8),
                Text(loc.get('success')),
              ],
            ),
            content: Text(loc.get('premium_purchase_success')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.get('ok')),
              ),
            ],
          ),
        );
      }
    } on PlatformException catch (e) {
      setState(() => _isLoadingPurchase = false);
      
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.get('purchase_failed')}: ${e.message}')),
        );
      }
    } catch (e) {
      setState(() => _isLoadingPurchase = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.get('error')}: $e')),
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.get('english')),
              leading: Radio<String>(
                value: 'en',
                groupValue: loc.currentLanguage,
                onChanged: (value) async {
                  if (value != null) {
                    await loc.setLanguage(value);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  }
                },
              ),
              onTap: () async {
                await loc.setLanguage('en');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
            ListTile(
              title: Text(loc.get('turkish')),
              leading: Radio<String>(
                value: 'tr',
                groupValue: loc.currentLanguage,
                onChanged: (value) async {
                  if (value != null) {
                    await loc.setLanguage(value);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  }
                },
              ),
              onTap: () async {
                await loc.setLanguage('tr');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(loc.get('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              loc.get('general'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleSmall?.color?.withOpacity(0.8),
              ),
            ),
          ),
          if (!ref.watch(premiumProvider))
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: Text(loc.get('upgrade_to_premium')),
              subtitle: Text(loc.get('upgrade_description')),
              onTap: () {
                HapticFeedback.selectionClick();
                _showPremiumPurchaseDialog(context);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(loc.get('premium_active')),
              subtitle: Text(loc.get('premium_active_description')),
              enabled: false,
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.get('language')),
            subtitle: Text(loc.currentLanguageName),
            onTap: () {
              HapticFeedback.selectionClick();
              _showLanguageDialog(context);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              ref.watch(themeProvider) == ThemeMode.dark 
                  ? Icons.dark_mode 
                  : Icons.light_mode,
            ),
            title: Text(AppLocalizations().get('theme')),
            subtitle: Text(
              ref.watch(themeProvider) == ThemeMode.dark 
                  ? AppLocalizations().get('dark_mode') 
                  : AppLocalizations().get('light_mode'),
            ),
            value: ref.watch(themeProvider) == ThemeMode.light,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.music_note),
            title: Text(loc.get('music')),
            subtitle: Text(loc.get('music_description')),
            value: ref.watch(musicProvider),
            onChanged: (value) {
              HapticFeedback.selectionClick();
              ref.read(musicProvider.notifier).setEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              loc.get('app'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleSmall?.color?.withOpacity(0.8),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: Text(loc.get('rate_app')),
            onTap: () async {
              HapticFeedback.selectionClick();
              final url = Uri.parse('https://apps.apple.com/tr/app/geopin-geography-master/id6756518038');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(loc.get('share_app')),
            onTap: () {
              HapticFeedback.selectionClick();
              Share.share(
                'Check out GeoPin - Geography Master! Test your geography knowledge with fun challenges. Download now: https://apps.apple.com/tr/app/geopin-geography-master/id6756518038',
                subject: 'GeoPin - Geography Master',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(loc.get('contact_us')),
            subtitle: Text(loc.get('contact_description')),
            onTap: () async {
              HapticFeedback.selectionClick();
              final url = Uri.parse('https://cankatcaglar.github.io/geopin-pages/contact.html');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              loc.get('legal'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleSmall?.color?.withOpacity(0.8),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(loc.get('privacy_policy')),
            onTap: () async {
              HapticFeedback.selectionClick();
              final url = Uri.parse('https://cankatcaglar.github.io/geopin-pages/privacy-policy.html');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(loc.get('terms_of_use')),
            onTap: () async {
              HapticFeedback.selectionClick();
              final url = Uri.parse('https://cankatcaglar.github.io/geopin-pages/terms-of-use.html');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// CATEGORY SCREEN

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final loc = AppLocalizations();

    // Kategorileri gruplara ayır
    final continents = categories.where((c) => 
      c.id.contains('europe') || c.id.contains('asia') || 
      c.id.contains('africa') || c.id == 'america' || c.id == 'oceania'
    ).toList();
    
    final famousPlaces = categories.where((c) => 
      c.id.contains('tourist_places') || c.id.contains('capitals') || 
      c.id == 'historical_landmarks'
    ).toList();
    
    final nature = categories.where((c) => 
      c.id.contains('natural_wonders')
    ).toList();
    
    final usStates = categories.where((c) => 
      c.id.contains('us_states')
    ).toList();
    
    final premiumContent = categories.where((c) => 
      c.id == 'iconic_bridges' || c.id == 'tallest_skyscrapers' || 
      c.id == 'world_cuisine' || c.id == 'stadiums' || c.id == 'airports' ||
      c.id == 'space_bases' || c.id == 'tech_hubs' || 
      c.id == 'scientific_wonders' || c.id == 'endemic_animals' || 
      c.id == 'extreme_points' || c.id == 'volcanoes' ||
      c.id == 'f1_circuits' || c.id == 'famous_brands' || c.id == 'famous_people'
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.get('app_name'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 48),
        children: [
          if (famousPlaces.isNotEmpty)
            _CategorySection(
              title: loc.get('famous_places'),
              categories: famousPlaces,
            ),
          if (continents.isNotEmpty)
            _CategorySection(
              title: loc.get('continents'),
              categories: continents,
            ),
          if (usStates.isNotEmpty)
            _CategorySection(
              title: loc.get('us_states'),
              categories: usStates,
            ),
          if (nature.isNotEmpty)
            _CategorySection(
              title: loc.get('natural_wonders_section'),
              categories: nature,
            ),
          if (premiumContent.isNotEmpty)
            _CategorySection(
              title: loc.get('premium_content'),
              categories: premiumContent,
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.categories,
  });

  final String title;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 180,
                  child: _CategoryCard(category: categories[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumUser = ref.watch(premiumProvider);
    final isLocked = category.isLocked && !isPremiumUser;
    final showPremiumBadge = category.isPremium && !isPremiumUser;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.selectionClick();
        if (showPremiumBadge) {
          _showPremiumPurchaseDialog(context, ref);
        } else if (isLocked) {
          _showPaywall(context, category);
        } else {
          // America, Europe, Asia ve Africa kategorileri için özel butonlu harita ekranlarını aç
          if (category.id == 'america') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AmericaButtonGameScreen(),
              ),
            );
          } else if (category.id == 'europe_1' || category.id == 'europe_2') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EuropeButtonGameScreen(
                  categoryId: category.id,
                  title: category.title,
                ),
              ),
            );
          } else if (category.id == 'asia_1' || category.id == 'asia_2') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AsiaButtonGameScreen(
                  title: category.title,
                  part: category.id == 'asia_1' ? 1 : 2,
                ),
              ),
            );
          } else if (category.id == 'africa_1' || category.id == 'africa_2' || category.id == 'africa_3') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AfricaButtonGameScreen(
                  title: category.title,
                  part: category.id == 'africa_1'
                      ? 1
                      : category.id == 'africa_2'
                          ? 2
                          : 3,
                ),
              ),
            );
          } else if (category.id == 'oceania') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OceaniaButtonGameScreen(),
              ),
            );
          } else if (category.id == 'us_states_1' ||
              category.id == 'us_states_2' ||
              category.id == 'us_states_3' ||
              category.id == 'us_states_4') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UsStatesButtonGameScreen(
                  title: category.title,
                  part: category.id == 'us_states_1'
                      ? 1
                      : category.id == 'us_states_2'
                          ? 2
                          : category.id == 'us_states_3'
                              ? 3
                              : 4,
                ),
              ),
            );
          } else if (category.id == 'natural_wonders_1' ||
              category.id == 'natural_wonders_2' ||
              category.id == 'natural_wonders_3') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NaturalWondersButtonGameScreen(
                  title: category.title,
                  part: category.id == 'natural_wonders_1'
                      ? 1
                      : category.id == 'natural_wonders_2'
                          ? 2
                          : 3,
                ),
              ),
            );
          } else if (category.id == 'stadiums') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StadiumsButtonGameScreen(),
              ),
            );
          } else if (category.id == 'world_cuisine') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WorldCuisineButtonGameScreen(),
              ),
            );
          } else if (category.id == 'airports') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AirportsButtonGameScreen(),
              ),
            );
          } else if (category.id == 'space_bases' ||
              category.id == 'tech_hubs' ||
              category.id == 'scientific_wonders' ||
              category.id == 'endemic_animals' ||
              category.id == 'extreme_points' ||
              category.id == 'volcanoes' ||
              category.id == 'f1_circuits' ||
              category.id == 'famous_brands' ||
              category.id == 'famous_people') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GenericButtonGameScreen(
                  categoryId: category.id,
                  title: category.title,
                  icon: category.icon,
                ),
              ),
            );
          } else {
            final questions = ref.read(questionsProvider);
            // Filter questions for this category
            final categoryQuestions = questions
                .where((q) => q.categoryId == category.id)
                .toList();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  categoryId: category.id,
                  categoryTitle: category.title,
                  questions: categoryQuestions,
                ),
              ),
            );
          }
        }
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isLocked
                ? [Colors.grey.shade800, Colors.grey.shade900]
                : [Colors.blue.shade400, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (category.backgroundImage != null)
                Positioned.fill(
                  child: Image.asset(
                    category.backgroundImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue.shade700.withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(
                            category.icon,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (category.backgroundImage != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
            // Kategori etiketi - kartın sol kenarına gömülü mat etiket
            Positioned(
              top: 10,
              left: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (showPremiumBadge)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, size: 16, color: Colors.amber),
                        const SizedBox(width: 6),
                        const Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (isLocked && !showPremiumBadge)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.lock, size: 16, color: Colors.amber),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _showPremiumPurchaseDialog(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PaywallScreen(),
      ),
    );
  }

  void _showPaywall(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PaywallScreen(),
      ),
    );
  }
}

// SORULAR VERİTABANI
final questionsProvider = Provider<List<Question>>((ref) {
  return [
    // --- TOURIST PLACES ---
    // EASY - Very famous tourist places everyone knows
    Question(
      id: 'statue_liberty',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Statue Liberty?',
      lat: 40.6892,
      lng: -74.0445,
    ),
    Question(
      id: 'eiffel',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Eiffel?',
      lat: 48.8584,
      lng: 2.2945,
    ),
    Question(
      id: 'colosseum',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Colosseum?',
      lat: 41.8902,
      lng: 12.4922,
    ),
    Question(
      id: 'bigben',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Bigben?',
      lat: 51.4994,
      lng: -0.1245,
    ),
    Question(
      id: 'sydney_opera',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Sydney Opera?',
      lat: -33.8568,
      lng: 151.2153,
    ),
    Question(
      id: 'taj_mahal',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Taj Mahal?',
      lat: 27.1751,
      lng: 78.0421,
    ),
    Question(
      id: 'great_wall',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Great Wall?',
      lat: 40.4319,
      lng: 116.5704,
    ),
    Question(
      id: 'golden_gate',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Golden Gate?',
      lat: 37.8199,
      lng: -122.4783,
    ),
    Question(
      id: 'christ_redeemer',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Christ Redeemer?',
      lat: -22.9519,
      lng: -43.2105,
    ),
    Question(
      id: 'burj_khalifa',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Burj Khalifa?',
      lat: 25.1972,
      lng: 55.2744,
    ),
    Question(
      id: 'louvre',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Louvre?',
      lat: 48.8606,
      lng: 2.3376,
    ),
    Question(
      id: 'stonehenge',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Stonehenge?',
      lat: 51.1789,
      lng: -1.8262,
    ),
    Question(
      id: 'notre_dame',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Notre Dame?',
      lat: 48.8530,
      lng: 2.3499,
    ),
    Question(
      id: 'versailles',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Versailles?',
      lat: 48.8049,
      lng: 2.1204,
    ),
    Question(
      id: 'acropolis',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Acropolis?',
      lat: 37.9715,
      lng: 23.7267,
    ),
    
    // MEDIUM - Well-known but might require some thought
    Question(
      id: 'sagrada_familia',
      categoryId: 'tourist_places_1',
      prompt: 'Where is La Sagrada Familia?',
      lat: 41.4036,
      lng: 2.1744,
    ),
    Question(
      id: 'neuschwanstein',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Neuschwanstein Castle?',
      lat: 47.5576,
      lng: 10.7498,
    ),
    Question(
      id: 'brandenburg_gate',
      categoryId: 'tourist_places_1',
      prompt: 'Where is Brandenburg Gate?',
      lat: 52.5163,
      lng: 13.3777,
    ),
    Question(
      id: 'saint_pauls',
      categoryId: 'tourist_places_1',
      prompt: 'Where is St Pauls Cathedral?',
      lat: 51.5138,
      lng: -0.0984,
    ),
    Question(
      id: 'windmills',
      categoryId: 'tourist_places_1',
      prompt: 'Where is the amsterdam windmills?',
      lat: 52.3740,
      lng: 4.8897,
    ),
    Question(
      id: 'petra',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Petra?',
      lat: 30.3285,
      lng: 35.4444,
    ),
    Question(
      id: 'angkor_wat',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Angkor Wat?',
      lat: 13.4125,
      lng: 103.8670,
    ),
    Question(
      id: 'chichen_itza',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Chichen Itza?',
      lat: 20.6843,
      lng: -88.5678,
    ),
    Question(
      id: 'niagara_falls',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Niagara Falls?',
      lat: 43.0962,
      lng: -79.0377,
    ),
    Question(
      id: 'grand_canyon',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the grand canyon?',
      lat: 36.1069,
      lng: -112.1129,
    ),
    Question(
      id: 'mount_rushmore',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Mount Rushmore?',
      lat: 43.8791,
      lng: -103.4591,
    ),
    Question(
      id: 'times_square',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Times Square?',
      lat: 40.7580,
      lng: -73.9855,
    ),
    Question(
      id: 'central_park',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Central Park?',
      lat: 40.7829,
      lng: -73.9654,
    ),
    Question(
      id: 'empire_state',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the empire state building?',
      lat: 40.7484,
      lng: -73.9857,
    ),
    Question(
      id: 'disneyland',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Disneyland?',
      lat: 33.8121,
      lng: -117.9190,
    ),
    Question(
      id: 'yosemite',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Yosemite National Park?',
      lat: 37.8651,
      lng: -119.5383,
    ),
    
    // HARD - More challenging locations
    Question(
      id: 'machu_picchu',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Machu Picchu?',
      lat: -13.1631,
      lng: -72.5450,
    ),
    Question(
      id: 'yellowstone',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Yellowstone National Park?',
      lat: 44.4280,
      lng: -110.5885,
    ),
    Question(
      id: 'liberty_bell',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the liberty bell?',
      lat: 39.9496,
      lng: -75.1503,
    ),
    Question(
      id: 'space_needle',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the space needle?',
      lat: 47.6205,
      lng: -122.3493,
    ),
    Question(
      id: 'hoover_dam',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the hoover dam?',
      lat: 36.0161,
      lng: -114.7377,
    ),
    Question(
      id: 'miami_beach',
      categoryId: 'tourist_places_2',
      prompt: 'Where is Miami Beach?',
      lat: 25.7907,
      lng: -80.1300,
    ),
    Question(
      id: 'las_vegas',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the las vegas strip?',
      lat: 36.1147,
      lng: -115.1728,
    ),
    Question(
      id: 'hollywood_sign',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the hollywood sign?',
      lat: 34.1341,
      lng: -118.3215,
    ),
    Question(
      id: 'colosseum_mexico',
      categoryId: 'tourist_places_2',
      prompt: 'Where is the colosseum in mexico city?',
      lat: 19.4326,
      lng: -99.1332,
    ),

    // --- NATURAL WONDERS (40 locations) ---
    Question(
      id: 'mount_everest',
      categoryId: 'natural_wonders',
      prompt: 'Where is Mount Everest?',
      lat: 27.9881,
      lng: 86.9250,
    ),
    Question(
      id: 'niagara_falls',
      categoryId: 'natural_wonders',
      prompt: 'Where is Niagara Falls?',
      lat: 43.0962,
      lng: -79.0377,
    ),
    Question(
      id: 'grand_canyon',
      categoryId: 'natural_wonders',
      prompt: 'Where is the grand canyon?',
      lat: 36.1069,
      lng: -112.1129,
    ),
    Question(
      id: 'amazon_rainforest',
      categoryId: 'natural_wonders',
      prompt: 'Where is the amazon rainforest?',
      lat: -3.4653,
      lng: -62.2159,
    ),
    Question(
      id: 'sahara_desert',
      categoryId: 'natural_wonders',
      prompt: 'Where is the sahara desert?',
      lat: 23.4162,
      lng: 25.6628,
    ),
    Question(
      id: 'great_barrier_reef',
      categoryId: 'natural_wonders',
      prompt: 'Where is the great barrier reef?',
      lat: -18.2871,
      lng: 147.6992,
    ),
    Question(
      id: 'mount_fuji',
      categoryId: 'natural_wonders',
      prompt: 'Where is Mount Fuji?',
      lat: 35.3606,
      lng: 138.7274,
    ),
    Question(
      id: 'dead_sea',
      categoryId: 'natural_wonders',
      prompt: 'Where is the dead sea?',
      lat: 31.5590,
      lng: 35.4732,
    ),
    Question(
      id: 'maldives',
      categoryId: 'natural_wonders',
      prompt: 'Where is the maldives?',
      lat: 3.2028,
      lng: 73.2207,
    ),
    Question(
      id: 'hawaii_natural',
      categoryId: 'natural_wonders',
      prompt: 'Where is Hawaii?',
      lat: 19.8968,
      lng: -155.5828,
    ),
    Question(
      id: 'antarctica',
      categoryId: 'natural_wonders',
      prompt: 'Where is Antarctica?',
      lat: -82.8628,
      lng: 135.0000,
    ),
    Question(
      id: 'loch_ness',
      categoryId: 'natural_wonders',
      prompt: 'Where is Loch Ness?',
      lat: 57.3229,
      lng: -4.4244,
    ),
    Question(
      id: 'mount_kilimanjaro',
      categoryId: 'natural_wonders',
      prompt: 'Where is Mount Kilimanjaro?',
      lat: -3.0674,
      lng: 37.3556,
    ),
    Question(
      id: 'victoria_falls',
      categoryId: 'natural_wonders',
      prompt: 'Where is Victoria Falls?',
      lat: -17.9243,
      lng: 25.8560,
    ),
    Question(
      id: 'galapagos_islands',
      categoryId: 'natural_wonders',
      prompt: 'Where is the galapagos islands?',
      lat: -0.9538,
      lng: -90.9656,
    ),
    Question(
      id: 'yellowstone',
      categoryId: 'natural_wonders',
      prompt: 'Where is Yellowstone National Park?',
      lat: 44.4280,
      lng: -110.5885,
    ),
    Question(
      id: 'the_alps',
      categoryId: 'natural_wonders',
      prompt: 'Where is the alps?',
      lat: 46.8876,
      lng: 9.6570,
    ),
    Question(
      id: 'black_forest',
      categoryId: 'natural_wonders',
      prompt: 'Where is the black forest?',
      lat: 48.0640,
      lng: 8.2285,
    ),
    Question(
      id: 'mount_etna',
      categoryId: 'natural_wonders',
      prompt: 'Where is Mount Etna?',
      lat: 37.7510,
      lng: 14.9934,
    ),
    Question(
      id: 'santorini',
      categoryId: 'natural_wonders',
      prompt: 'Where is Santorini?',
      lat: 36.3932,
      lng: 25.4615,
    ),
    Question(
      id: 'red_sea',
      categoryId: 'natural_wonders',
      prompt: 'Where is the red sea?',
      lat: 20.2802,
      lng: 38.5126,
    ),
    Question(
      id: 'caribbean_sea',
      categoryId: 'natural_wonders',
      prompt: 'Where is the caribbean sea?',
      lat: 15.3266,
      lng: -75.0152,
    ),
    Question(
      id: 'nile_river',
      categoryId: 'natural_wonders',
      prompt: 'Where is the nile river?',
      lat: 19.0,
      lng: 31.0,
    ),
    Question(
      id: 'lake_victoria',
      categoryId: 'natural_wonders',
      prompt: 'Where is Lake Victoria?',
      lat: -1.0,
      lng: 33.0,
    ),
    Question(
      id: 'madagascar',
      categoryId: 'natural_wonders',
      prompt: 'Where is Madagascar?',
      lat: -18.7669,
      lng: 46.8691,
    ),
    Question(
      id: 'greenland',
      categoryId: 'natural_wonders',
      prompt: 'Where is Greenland?',
      lat: 72.0000,
      lng: -40.0000,
    ),
    Question(
      id: 'iceland',
      categoryId: 'natural_wonders',
      prompt: 'Where is Iceland?',
      lat: 64.9631,
      lng: -19.0208,
    ),
    Question(
      id: 'bali',
      categoryId: 'natural_wonders',
      prompt: 'Where is Bali?',
      lat: -8.3405,
      lng: 115.0920,
    ),
    Question(
      id: 'mount_olympus',
      categoryId: 'natural_wonders',
      prompt: 'Where is Mount Olympus?',
      lat: 40.0856,
      lng: 22.3580,
    ),
    Question(
      id: 'matterhorn',
      categoryId: 'natural_wonders',
      prompt: 'Where is the matterhorn?',
      lat: 45.9763,
      lng: 7.6586,
    ),
    Question(
      id: 'capri',
      categoryId: 'natural_wonders',
      prompt: 'Where is the island of capri?',
      lat: 40.5532,
      lng: 14.2222,
    ),
    Question(
      id: 'pamukkale',
      categoryId: 'natural_wonders',
      prompt: 'Where is Pamukkale?',
      lat: 37.9240,
      lng: 29.1190,
    ),
    Question(
      id: 'cappadocia',
      categoryId: 'natural_wonders',
      prompt: 'Where is Cappadocia?',
      lat: 38.6431,
      lng: 34.8310,
    ),
    Question(
      id: 'dead_vlei',
      categoryId: 'natural_wonders',
      prompt: 'Where is Dead Vlei In The Namib Desert?',
      lat: -24.7433,
      lng: 15.2950,
    ),
    Question(
      id: 'ha_long_bay',
      categoryId: 'natural_wonders',
      prompt: 'Where is Ha Long Bay?',
      lat: 20.9101,
      lng: 107.1839,
    ),
    Question(
      id: 'lake_baikal',
      categoryId: 'natural_wonders',
      prompt: 'Where is Lake Baikal?',
      lat: 53.5587,
      lng: 108.1650,
    ),
    Question(
      id: 'bora_bora',
      categoryId: 'natural_wonders',
      prompt: 'Where is Bora Bora?',
      lat: -16.5004,
      lng: -151.7415,
    ),
    Question(
      id: 'seychelles_natural',
      categoryId: 'natural_wonders',
      prompt: 'Where is the seychelles?',
      lat: -4.6796,
      lng: 55.4920,
    ),
    Question(
      id: 'canary_islands',
      categoryId: 'natural_wonders',
      prompt: 'Where is the canary islands?',
      lat: 28.2936,
      lng: -16.6214,
    ),
    Question(
      id: 'rocky_mountains',
      categoryId: 'natural_wonders',
      prompt: 'Where is the rocky mountains?',
      lat: 39.1178,
      lng: -106.4454,
    ),

    // --- ICONIC BRIDGES ---
    Question(
      id: 'golden_gate_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the golden gate bridge?',
      lat: 37.8199,
      lng: -122.4783,
    ),
    Question(
      id: 'tower_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Tower Bridge?',
      lat: 51.5055,
      lng: -0.0754,
    ),
    Question(
      id: 'sydney_harbour_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the sydney harbour bridge?',
      lat: -33.8523,
      lng: 151.2108,
    ),
    Question(
      id: 'brooklyn_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the brooklyn bridge?',
      lat: 40.7061,
      lng: -73.9969,
    ),
    Question(
      id: 'rialto_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the rialto bridge?',
      lat: 45.4380,
      lng: 12.3358,
    ),
    Question(
      id: 'ponte_vecchio',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Ponte Vecchio?',
      lat: 43.7687,
      lng: 11.2531,
    ),
    Question(
      id: 'charles_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Charles Bridge?',
      lat: 50.0865,
      lng: 14.4114,
    ),
    Question(
      id: 'akashi_kaikyo_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the akashi kaikyo bridge?',
      lat: 34.6178,
      lng: 135.0217,
    ),
    Question(
      id: 'millau_viaduct',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the millau viaduct?',
      lat: 44.0775,
      lng: 3.0226,
    ),
    Question(
      id: 'bosphorus_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the 15 july martyrs bosphorus bridge?',
      lat: 41.0450,
      lng: 29.0336,
    ),
    Question(
      id: 'vasco_da_gama_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the vasco da gama bridge?',
      lat: 38.7636,
      lng: -9.0370,
    ),
    Question(
      id: 'chapel_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the chapel bridge kapellbrücke?',
      lat: 47.0517,
      lng: 8.3073,
    ),
    Question(
      id: 'pont_du_gard',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Pont Du Gard?',
      lat: 43.9475,
      lng: 4.5350,
    ),
    Question(
      id: 'chain_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the chain bridge in budapest?',
      lat: 47.4980,
      lng: 19.0407,
    ),
    Question(
      id: 'helix_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is the helix bridge?',
      lat: 1.2864,
      lng: 103.8607,
    ),
    Question(
      id: 'sheikh_zayed_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Sheikh Zayed Bridge?',
      lat: 24.4672,
      lng: 54.4514,
    ),
    Question(
      id: 'banpo_bridge',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Banpo Bridge?',
      lat: 37.5125,
      lng: 126.9961,
    ),
    Question(
      id: 'stari_most',
      categoryId: 'iconic_bridges',
      prompt: 'Where is Stari Most?',
      lat: 43.3375,
      lng: 17.8144,
    ),

    // --- TALLEST SKYSCRAPERS ---
    Question(
      id: 'burj_khalifa',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Burj Khalifa?',
      lat: 25.1972,
      lng: 55.2744,
    ),
    Question(
      id: 'empire_state_building',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the empire state building?',
      lat: 40.7484,
      lng: -73.9857,
    ),
    Question(
      id: 'taipei_101',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Taipei 101?',
      lat: 25.0339,
      lng: 121.5645,
    ),
    Question(
      id: 'petronas_towers',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the petronas towers?',
      lat: 3.1579,
      lng: 101.7118,
    ),
    Question(
      id: 'shanghai_tower',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the shanghai tower?',
      lat: 31.2336,
      lng: 121.5055,
    ),
    Question(
      id: 'one_world_trade_center',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is One World Trade Center?',
      lat: 40.7127,
      lng: -74.0134,
    ),
    Question(
      id: 'the_shard',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the shard?',
      lat: 51.5045,
      lng: -0.0865,
    ),
    Question(
      id: 'willis_tower',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Willis Sears Tower?',
      lat: 41.8789,
      lng: -87.6359,
    ),
    Question(
      id: 'burj_al_arab',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Burj Al Arab?',
      lat: 25.1412,
      lng: 55.1853,
    ),
    Question(
      id: 'chrysler_building',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the chrysler building?',
      lat: 40.7516,
      lng: -73.9755,
    ),
    Question(
      id: 'lotte_world_tower',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Lotte World Tower?',
      lat: 37.5131,
      lng: 127.1026,
    ),
    Question(
      id: 'abraj_al_bait',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Abraj Al Bait Mecca Clock Tower?',
      lat: 21.4187,
      lng: 39.8256,
    ),
    Question(
      id: 'marina_bay_sands',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Marina Bay Sands?',
      lat: 1.2834,
      lng: 103.8607,
    ),
    Question(
      id: 'kingdom_centre',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the kingdom centre?',
      lat: 24.7115,
      lng: 46.6745,
    ),
    Question(
      id: 'turning_torso',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the turning torso?',
      lat: 55.6141,
      lng: 12.9703,
    ),
    Question(
      id: 'landmark_81',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Landmark 81?',
      lat: 10.7942,
      lng: 106.7215,
    ),
    Question(
      id: 'gran_torre_santiago',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is Gran Torre Santiago?',
      lat: -33.4147,
      lng: -70.6073,
    ),
    Question(
      id: 'lakhta_center',
      categoryId: 'tallest_skyscrapers',
      prompt: 'Where is the lakhta center?',
      lat: 59.9861,
      lng: 30.1775,
    ),

    // --- WORLD CUISINE ---
    Question(
      id: 'pizza_naples',
      categoryId: 'world_cuisine',
      prompt: 'Where is the home of neapolitan pizza?',
      lat: 40.8518,
      lng: 14.2681,
    ),
    Question(
      id: 'sushi_tokyo',
      categoryId: 'world_cuisine',
      prompt: 'Where is Tokyo The Home Of Sushi?',
      lat: 35.6762,
      lng: 139.6503,
    ),
    Question(
      id: 'hamburger_hamburg',
      categoryId: 'world_cuisine',
      prompt: 'Where is Hamburg Origin Of The Hamburger Name?',
      lat: 53.5511,
      lng: 9.9937,
    ),
    Question(
      id: 'croissant_paris',
      categoryId: 'world_cuisine',
      prompt: 'Where is Paris Croissants?',
      lat: 48.8566,
      lng: 2.3522,
    ),
    Question(
      id: 'tacos_mexico_city',
      categoryId: 'world_cuisine',
      prompt: 'Where is Mexico City Famous For Tacos?',
      lat: 19.4326,
      lng: -99.1332,
    ),
    Question(
      id: 'paella_valencia',
      categoryId: 'world_cuisine',
      prompt: 'Where is Valencia Home Of Paella?',
      lat: 39.4699,
      lng: -0.3763,
    ),
    Question(
      id: 'peking_duck_beijing',
      categoryId: 'world_cuisine',
      prompt: 'Where is Beijing Famous For Peking Duck?',
      lat: 39.9042,
      lng: 116.4074,
    ),
    Question(
      id: 'fish_and_chips_london',
      categoryId: 'world_cuisine',
      prompt: 'Where is London Famous For Fish And Chips?',
      lat: 51.5074,
      lng: -0.1278,
    ),
    Question(
      id: 'pad_thai_bangkok',
      categoryId: 'world_cuisine',
      prompt: 'Where is Bangkok Home Of Pad Thai?',
      lat: 13.7563,
      lng: 100.5018,
    ),
    Question(
      id: 'baklava_gaziantep',
      categoryId: 'world_cuisine',
      prompt: 'Where is Gaziantep Famous For Baklava?',
      lat: 37.0662,
      lng: 37.3833,
    ),
    Question(
      id: 'wiener_schnitzel_vienna',
      categoryId: 'world_cuisine',
      prompt: 'Where is Vienna Famous For Wiener Schnitzel?',
      lat: 48.2082,
      lng: 16.3738,
    ),
    Question(
      id: 'goulash_budapest',
      categoryId: 'world_cuisine',
      prompt: 'Where is Budapest Famous For Goulash?',
      lat: 47.4979,
      lng: 19.0402,
    ),
    Question(
      id: 'pho_hanoi',
      categoryId: 'world_cuisine',
      prompt: 'Where is Hanoi Home Of Pho?',
      lat: 21.0278,
      lng: 105.8342,
    ),
    Question(
      id: 'poutine_montreal',
      categoryId: 'world_cuisine',
      prompt: 'Where is Montreal Famous For Poutine?',
      lat: 45.5017,
      lng: -73.5673,
    ),
    Question(
      id: 'feijoada_rio',
      categoryId: 'world_cuisine',
      prompt: 'Where is Rio De Janeiro Famous For Feijoada?',
      lat: -22.9068,
      lng: -43.1729,
    ),
    Question(
      id: 'dim_sum_hong_kong',
      categoryId: 'world_cuisine',
      prompt: 'Where is Hong Kong Famous For Dim Sum?',
      lat: 22.3193,
      lng: 114.1694,
    ),
    Question(
      id: 'butter_chicken_delhi',
      categoryId: 'world_cuisine',
      prompt: 'Where is New Delhi Famous For Butter Chicken?',
      lat: 28.6139,
      lng: 77.2090,
    ),
    Question(
      id: 'tapas_barcelona',
      categoryId: 'world_cuisine',
      prompt: 'Where is Barcelona Famous For Tapas?',
      lat: 41.3851,
      lng: 2.1734,
    ),

    // --- FOOTBALL STADIUMS ---
    Question(
      id: 'camp_nou',
      categoryId: 'stadiums',
      prompt: 'Where is Camp Nou The Largest Stadium In Europe?',
      lat: 41.3809,
      lng: 2.1228,
    ),
    Question(
      id: 'wembley_stadium',
      categoryId: 'stadiums',
      prompt: 'Where is Wembley Stadium The Home Of Football?',
      lat: 51.5560,
      lng: -0.2796,
    ),
    Question(
      id: 'maracana',
      categoryId: 'stadiums',
      prompt: 'Where is Maracanã The Iconic World Cup Venue?',
      lat: -22.9121,
      lng: -43.2302,
    ),
    Question(
      id: 'santiago_bernabeu',
      categoryId: 'stadiums',
      prompt: 'Where is Santiago Bernabéu Home Of Real Madrid?',
      lat: 40.4531,
      lng: -3.6883,
    ),
    Question(
      id: 'old_trafford',
      categoryId: 'stadiums',
      prompt: 'Where is Old Trafford The Theatre Of Dreams?',
      lat: 53.4631,
      lng: -2.2913,
    ),
    Question(
      id: 'allianz_arena',
      categoryId: 'stadiums',
      prompt: 'Where is Allianz Arena With Its Color-Changing Exterior?',
      lat: 48.2188,
      lng: 11.6247,
    ),
    Question(
      id: 'san_siro',
      categoryId: 'stadiums',
      prompt: 'Where is San Siro Giuseppe Meazza The Iconic Milan Stadium?',
      lat: 45.4781,
      lng: 9.1240,
    ),
    Question(
      id: 'anfield',
      categoryId: 'stadiums',
      prompt: 'Where is Anfield?',
      lat: 53.4308,
      lng: -2.9608,
    ),
    Question(
      id: 'la_bombonera',
      categoryId: 'stadiums',
      prompt: 'Where is La Bombonera Home Of Boca Juniors?',
      lat: -34.6356,
      lng: -58.3649,
    ),
    Question(
      id: 'estadio_azteca',
      categoryId: 'stadiums',
      prompt: 'Where is Estadio Azteca Host Of Two World Cup Finals?',
      lat: 19.3033,
      lng: -99.1500,
    ),
    Question(
      id: 'signal_iduna_park',
      categoryId: 'stadiums',
      prompt: 'Where is Signal Iduna Park Home Of The Yellow Wall?',
      lat: 51.4926,
      lng: 7.4519,
    ),
    Question(
      id: 'stade_de_france',
      categoryId: 'stadiums',
      prompt: 'Where is Stade De France The National Stadium Of France?',
      lat: 48.9244,
      lng: 2.3601,
    ),
    Question(
      id: 'emirates_stadium',
      categoryId: 'stadiums',
      prompt: 'Where is Emirates Stadium Modern Home Of Arsenal?',
      lat: 51.5550,
      lng: -0.1084,
    ),
    Question(
      id: 'johan_cruyff_arena',
      categoryId: 'stadiums',
      prompt: 'Where is Johan Cruyff Arena Home Of Ajax?',
      lat: 52.3143,
      lng: 4.9414,
    ),
    Question(
      id: 'estadio_da_luz',
      categoryId: 'stadiums',
      prompt: 'Where is Estádio Da Luz Home Of Benfica?',
      lat: 38.7530,
      lng: -9.1848,
    ),
    Question(
      id: 'metlife_stadium',
      categoryId: 'stadiums',
      prompt: 'Where is Metlife Stadium Near New York City?',
      lat: 40.8135,
      lng: -74.0745,
    ),
    Question(
      id: 'lusail_stadium',
      categoryId: 'stadiums',
      prompt: 'Where is Lusail Stadium The 2022 World Cup Final Venue?',
      lat: 25.4207,
      lng: 51.4904,
    ),
    Question(
      id: 'atatürk_olympic_stadium',
      categoryId: 'stadiums',
      prompt: 'Where is Atatürk Olympic Stadium Famous For The 2005 Ucl Final?',
      lat: 41.0703,
      lng: 28.7656,
    ),

    // --- FAMOUS AIRPORTS ---
    Question(
      id: 'lhr_heathrow',
      categoryId: 'airports',
      prompt: 'Where is London Heathrow Airport Lhr?',
      lat: 51.4700,
      lng: -0.4543,
    ),
    Question(
      id: 'jfk_new_york',
      categoryId: 'airports',
      prompt: 'Where is John F Kennedy International Airport Jfk?',
      lat: 40.6413,
      lng: -73.7781,
    ),
    Question(
      id: 'sin_changi',
      categoryId: 'airports',
      prompt: 'Where is Singapore Changi Airport Sin?',
      lat: 1.3644,
      lng: 103.9915,
    ),
    Question(
      id: 'dxb_dubai',
      categoryId: 'airports',
      prompt: 'Where is Dubai International Airport Dxb?',
      lat: 25.2532,
      lng: 55.3657,
    ),
    Question(
      id: 'ist_istanbul',
      categoryId: 'airports',
      prompt: 'Where is Istanbul Airport Ist?',
      lat: 41.2621,
      lng: 28.7276,
    ),
    Question(
      id: 'cdg_paris',
      categoryId: 'airports',
      prompt: 'Where is Paris Charles De Gaulle Airport Cdg?',
      lat: 49.0097,
      lng: 2.5479,
    ),
    Question(
      id: 'lax_los_angeles',
      categoryId: 'airports',
      prompt: 'Where is Los Angeles International Airport Lax?',
      lat: 33.9416,
      lng: -118.4085,
    ),
    Question(
      id: 'hnd_haneda',
      categoryId: 'airports',
      prompt: 'Where is Tokyo Haneda Airport Hnd?',
      lat: 35.5494,
      lng: 139.7798,
    ),
    Question(
      id: 'ams_schiphol',
      categoryId: 'airports',
      prompt: 'Where is Amsterdam Schiphol Airport Ams?',
      lat: 52.3105,
      lng: 4.7683,
    ),
    Question(
      id: 'fra_frankfurt',
      categoryId: 'airports',
      prompt: 'Where is Frankfurt Airport Fra?',
      lat: 50.0379,
      lng: 8.5622,
    ),
    Question(
      id: 'atl_atlanta',
      categoryId: 'airports',
      prompt: 'Where is Hartsfield-Jackson Atlanta International Airport Atl?',
      lat: 33.6407,
      lng: -84.4277,
    ),
    Question(
      id: 'icn_incheon',
      categoryId: 'airports',
      prompt: 'Where is Incheon International Airport Icn?',
      lat: 37.4602,
      lng: 126.4407,
    ),
    Question(
      id: 'hkg_hong_kong',
      categoryId: 'airports',
      prompt: 'Where is Hong Kong International Airport Hkg?',
      lat: 22.3080,
      lng: 113.9185,
    ),
    Question(
      id: 'doh_hamad',
      categoryId: 'airports',
      prompt: 'Where is Hamad International Airport Doh?',
      lat: 25.2731,
      lng: 51.6081,
    ),
    Question(
      id: 'sfo_san_francisco',
      categoryId: 'airports',
      prompt: 'Where is San Francisco International Airport Sfo?',
      lat: 37.6213,
      lng: -122.3790,
    ),
    Question(
      id: 'ord_ohare',
      categoryId: 'airports',
      prompt: 'Where is Chicago OHare International Airport?',
      lat: 41.9742,
      lng: -87.9073,
    ),
    Question(
      id: 'mad_barajas',
      categoryId: 'airports',
      prompt: 'Where is Adolfo Suárez Madridbarajas Airport Mad?',
      lat: 40.4983,
      lng: -3.5676,
    ),
    Question(
      id: 'den_denver',
      categoryId: 'airports',
      prompt: 'Where is Denver International Airport Den?',
      lat: 39.8561,
      lng: -104.6737,
    ),

    // --- FORMULA 1 CIRCUITS ---
    Question(
      id: 'monaco_gp',
      categoryId: 'f1_circuits',
      prompt: 'Where is Monaco Grand Prix Circuit?',
      lat: 43.7347,
      lng: 7.4206,
    ),
    Question(
      id: 'istanbul_park',
      categoryId: 'f1_circuits',
      prompt: 'Where is Istanbul Park Circuit?',
      lat: 40.9517,
      lng: 29.4050,
    ),
    Question(
      id: 'silverstone',
      categoryId: 'f1_circuits',
      prompt: 'Where is Silverstone Circuit?',
      lat: 52.0786,
      lng: -1.0169,
    ),
    Question(
      id: 'monza',
      categoryId: 'f1_circuits',
      prompt: 'Where is Monza Circuit?',
      lat: 45.6156,
      lng: 9.2811,
    ),
    Question(
      id: 'spa_francorchamps',
      categoryId: 'f1_circuits',
      prompt: 'Where is Spa-Francorchamps Circuit?',
      lat: 50.4372,
      lng: 5.9714,
    ),
    Question(
      id: 'suzuka',
      categoryId: 'f1_circuits',
      prompt: 'Where is Suzuka Circuit?',
      lat: 34.8431,
      lng: 136.5408,
    ),
    Question(
      id: 'interlagos',
      categoryId: 'f1_circuits',
      prompt: 'Where is Interlagos Circuit?',
      lat: -23.7036,
      lng: -46.6997,
    ),
    Question(
      id: 'yas_marina',
      categoryId: 'f1_circuits',
      prompt: 'Where is Yas Marina Circuit?',
      lat: 24.4672,
      lng: 54.6031,
    ),
    Question(
      id: 'circuit_de_barcelona',
      categoryId: 'f1_circuits',
      prompt: 'Where is Circuit de Barcelona-Catalunya?',
      lat: 41.5700,
      lng: 2.2611,
    ),
    Question(
      id: 'red_bull_ring',
      categoryId: 'f1_circuits',
      prompt: 'Where is Red Bull Ring?',
      lat: 47.2197,
      lng: 14.7647,
    ),
    Question(
      id: 'hungaroring',
      categoryId: 'f1_circuits',
      prompt: 'Where is Hungaroring?',
      lat: 47.5789,
      lng: 19.2486,
    ),
    Question(
      id: 'marina_bay',
      categoryId: 'f1_circuits',
      prompt: 'Where is Marina Bay Street Circuit?',
      lat: 1.2914,
      lng: 103.8644,
    ),
    Question(
      id: 'circuit_gilles_villeneuve',
      categoryId: 'f1_circuits',
      prompt: 'Where is Circuit Gilles Villeneuve?',
      lat: 45.5000,
      lng: -73.5278,
    ),
    Question(
      id: 'cota',
      categoryId: 'f1_circuits',
      prompt: 'Where is Circuit of the Americas?',
      lat: 30.1328,
      lng: -97.6411,
    ),
    Question(
      id: 'zandvoort',
      categoryId: 'f1_circuits',
      prompt: 'Where is Zandvoort Circuit?',
      lat: 52.3889,
      lng: 4.5408,
    ),

    // --- WORLD FAMOUS BRANDS ---
    Question(
      id: 'ikea_sweden',
      categoryId: 'famous_brands',
      prompt: 'Where is IKEA from?',
      lat: 56.8389,
      lng: 14.8258,
    ),
    Question(
      id: 'samsung_korea',
      categoryId: 'famous_brands',
      prompt: 'Where is Samsung from?',
      lat: 37.5665,
      lng: 126.9780,
    ),
    Question(
      id: 'nokia_finland',
      categoryId: 'famous_brands',
      prompt: 'Where is Nokia from?',
      lat: 60.1695,
      lng: 24.9354,
    ),
    Question(
      id: 'bmw_germany',
      categoryId: 'famous_brands',
      prompt: 'Where is BMW from?',
      lat: 48.1351,
      lng: 11.5820,
    ),
    Question(
      id: 'mercedes_germany',
      categoryId: 'famous_brands',
      prompt: 'Where is Mercedes-Benz from?',
      lat: 48.7758,
      lng: 9.1829,
    ),
    Question(
      id: 'audi_germany',
      categoryId: 'famous_brands',
      prompt: 'Where is Audi from?',
      lat: 48.3668,
      lng: 10.8986,
    ),
    Question(
      id: 'ferrari_italy',
      categoryId: 'famous_brands',
      prompt: 'Where is Ferrari from?',
      lat: 44.5311,
      lng: 10.8644,
    ),
    Question(
      id: 'lamborghini_italy',
      categoryId: 'famous_brands',
      prompt: 'Where is Lamborghini from?',
      lat: 44.6478,
      lng: 11.1283,
    ),
    Question(
      id: 'apple_usa',
      categoryId: 'famous_brands',
      prompt: 'Where is Apple from?',
      lat: 37.3318,
      lng: -122.0312,
    ),
    Question(
      id: 'coca_cola_usa',
      categoryId: 'famous_brands',
      prompt: 'Where is Coca-Cola from?',
      lat: 33.7490,
      lng: -84.3880,
    ),
    Question(
      id: 'toyota_japan',
      categoryId: 'famous_brands',
      prompt: 'Where is Toyota from?',
      lat: 35.0844,
      lng: 137.1536,
    ),
    Question(
      id: 'sony_japan',
      categoryId: 'famous_brands',
      prompt: 'Where is Sony from?',
      lat: 35.6762,
      lng: 139.7653,
    ),
    Question(
      id: 'adidas_germany',
      categoryId: 'famous_brands',
      prompt: 'Where is Adidas from?',
      lat: 49.4521,
      lng: 11.0767,
    ),
    Question(
      id: 'lego_denmark',
      categoryId: 'famous_brands',
      prompt: 'Where is LEGO from?',
      lat: 55.7308,
      lng: 9.1242,
    ),
    Question(
      id: 'nestle_switzerland',
      categoryId: 'famous_brands',
      prompt: 'Where is Nestlé from?',
      lat: 46.4667,
      lng: 6.8333,
    ),

    // --- FAMOUS PEOPLE & CHARACTERS ---
    Question(
      id: 'santa_claus',
      categoryId: 'famous_people',
      prompt: 'Where is Santa Claus from?',
      lat: 66.5039,
      lng: 25.7294,
    ),
    Question(
      id: 'dracula',
      categoryId: 'famous_people',
      prompt: 'Where is Count Dracula from?',
      lat: 45.5144,
      lng: 25.3675,
    ),
    Question(
      id: 'messi',
      categoryId: 'famous_people',
      prompt: 'Where is Lionel Messi from?',
      lat: -32.9442,
      lng: -60.6505,
    ),
    Question(
      id: 'cristiano_ronaldo',
      categoryId: 'famous_people',
      prompt: 'Where is Cristiano Ronaldo from?',
      lat: 32.6669,
      lng: -16.9241,
    ),
    Question(
      id: 'shakespeare',
      categoryId: 'famous_people',
      prompt: 'Where is William Shakespeare from?',
      lat: 52.1917,
      lng: -1.7078,
    ),
    Question(
      id: 'mozart',
      categoryId: 'famous_people',
      prompt: 'Where is Wolfgang Amadeus Mozart from?',
      lat: 47.8095,
      lng: 13.0550,
    ),
    Question(
      id: 'einstein',
      categoryId: 'famous_people',
      prompt: 'Where is Albert Einstein from?',
      lat: 48.3984,
      lng: 9.9908,
    ),
    Question(
      id: 'picasso',
      categoryId: 'famous_people',
      prompt: 'Where is Pablo Picasso from?',
      lat: 36.7213,
      lng: -4.4214,
    ),
    Question(
      id: 'beethoven',
      categoryId: 'famous_people',
      prompt: 'Where is Ludwig van Beethoven from?',
      lat: 50.7374,
      lng: 7.0982,
    ),
    Question(
      id: 'napoleon',
      categoryId: 'famous_people',
      prompt: 'Where is Napoleon Bonaparte from?',
      lat: 41.9270,
      lng: 8.7369,
    ),
    Question(
      id: 'tesla',
      categoryId: 'famous_people',
      prompt: 'Where is Nikola Tesla from?',
      lat: 44.5553,
      lng: 15.8783,
    ),
    Question(
      id: 'pele',
      categoryId: 'famous_people',
      prompt: 'Where is Pelé from?',
      lat: -23.2237,
      lng: -45.9009,
    ),
    Question(
      id: 'maradona',
      categoryId: 'famous_people',
      prompt: 'Where is Diego Maradona from?',
      lat: -34.6037,
      lng: -58.3816,
    ),
    Question(
      id: 'sherlock_holmes',
      categoryId: 'famous_people',
      prompt: 'Where is Sherlock Holmes from?',
      lat: 51.5074,
      lng: -0.1278,
    ),
    Question(
      id: 'harry_potter',
      categoryId: 'famous_people',
      prompt: 'Where is Harry Potter from?',
      lat: 51.5074,
      lng: -0.1278,
    ),

    // --- US STATES (50 states, Alaska & Hawaii dahil) ---
    Question(
      id: 'us_alabama',
      categoryId: 'us_states',
      prompt: 'Where is Alabama?',
      lat: 32.8067,
      lng: -86.7911,
    ),
    Question(
      id: 'us_alaska',
      categoryId: 'us_states',
      prompt: 'Where is Alaska?',
      lat: 64.2008,
      lng: -149.4937,
    ),
    Question(
      id: 'us_arizona',
      categoryId: 'us_states',
      prompt: 'Where is Arizona?',
      lat: 34.0489,
      lng: -111.0937,
    ),
    Question(
      id: 'us_arkansas',
      categoryId: 'us_states',
      prompt: 'Where is Arkansas?',
      lat: 35.2010,
      lng: -91.8318,
    ),
    Question(
      id: 'us_california',
      categoryId: 'us_states',
      prompt: 'Where is California?',
      lat: 36.7783,
      lng: -119.4179,
    ),
    Question(
      id: 'us_colorado',
      categoryId: 'us_states',
      prompt: 'Where is Colorado?',
      lat: 39.5501,
      lng: -105.7821,
    ),
    Question(
      id: 'us_connecticut',
      categoryId: 'us_states',
      prompt: 'Where is Connecticut?',
      lat: 41.6032,
      lng: -73.0877,
    ),
    Question(
      id: 'us_delaware',
      categoryId: 'us_states',
      prompt: 'Where is Delaware?',
      lat: 38.9108,
      lng: -75.5277,
    ),
    Question(
      id: 'us_florida',
      categoryId: 'us_states',
      prompt: 'Where is Florida?',
      lat: 27.6648,
      lng: -81.5158,
    ),
    Question(
      id: 'us_georgia',
      categoryId: 'us_states',
      prompt: 'Where is Georgia Us?',
      lat: 32.1656,
      lng: -82.9001,
    ),
    Question(
      id: 'us_hawaii',
      categoryId: 'us_states',
      prompt: 'Where is Hawaii?',
      lat: 19.8968,
      lng: -155.5828,
    ),
    Question(
      id: 'us_idaho',
      categoryId: 'us_states',
      prompt: 'Where is Idaho?',
      lat: 44.0682,
      lng: -114.7420,
    ),
    Question(
      id: 'us_illinois',
      categoryId: 'us_states',
      prompt: 'Where is Illinois?',
      lat: 40.6331,
      lng: -89.3985,
    ),
    Question(
      id: 'us_indiana',
      categoryId: 'us_states',
      prompt: 'Where is Indiana?',
      lat: 40.2672,
      lng: -86.1349,
    ),
    Question(
      id: 'us_iowa',
      categoryId: 'us_states',
      prompt: 'Where is Iowa?',
      lat: 41.8780,
      lng: -93.0977,
    ),
    Question(
      id: 'us_kansas',
      categoryId: 'us_states',
      prompt: 'Where is Kansas?',
      lat: 39.0119,
      lng: -98.4842,
    ),
    Question(
      id: 'us_kentucky',
      categoryId: 'us_states',
      prompt: 'Where is Kentucky?',
      lat: 37.8393,
      lng: -84.2700,
    ),
    Question(
      id: 'us_louisiana',
      categoryId: 'us_states',
      prompt: 'Where is Louisiana?',
      lat: 31.2448,
      lng: -92.1450,
    ),
    Question(
      id: 'us_maine',
      categoryId: 'us_states',
      prompt: 'Where is Maine?',
      lat: 45.2538,
      lng: -69.4455,
    ),
    Question(
      id: 'us_maryland',
      categoryId: 'us_states',
      prompt: 'Where is Maryland?',
      lat: 39.0458,
      lng: -76.6413,
    ),
    Question(
      id: 'us_massachusetts',
      categoryId: 'us_states',
      prompt: 'Where is Massachusetts?',
      lat: 42.4072,
      lng: -71.3824,
    ),
    Question(
      id: 'us_michigan',
      categoryId: 'us_states',
      prompt: 'Where is Michigan?',
      lat: 44.3148,
      lng: -85.6024,
    ),
    Question(
      id: 'us_minnesota',
      categoryId: 'us_states',
      prompt: 'Where is Minnesota?',
      lat: 46.7296,
      lng: -94.6859,
    ),
    Question(
      id: 'us_mississippi',
      categoryId: 'us_states',
      prompt: 'Where is Mississippi?',
      lat: 32.3547,
      lng: -89.3985,
    ),
    Question(
      id: 'us_missouri',
      categoryId: 'us_states',
      prompt: 'Where is Missouri?',
      lat: 37.9643,
      lng: -91.8318,
    ),
    Question(
      id: 'us_montana',
      categoryId: 'us_states',
      prompt: 'Where is Montana?',
      lat: 46.8797,
      lng: -110.3626,
    ),
    Question(
      id: 'us_nebraska',
      categoryId: 'us_states',
      prompt: 'Where is Nebraska?',
      lat: 41.4925,
      lng: -99.9018,
    ),
    Question(
      id: 'us_nevada',
      categoryId: 'us_states',
      prompt: 'Where is Nevada?',
      lat: 38.8026,
      lng: -116.4194,
    ),
    Question(
      id: 'us_new_hampshire',
      categoryId: 'us_states',
      prompt: 'Where is New Hampshire?',
      lat: 43.1939,
      lng: -71.5724,
    ),
    Question(
      id: 'us_new_jersey',
      categoryId: 'us_states',
      prompt: 'Where is New Jersey?',
      lat: 40.0583,
      lng: -74.4057,
    ),
    Question(
      id: 'us_new_mexico',
      categoryId: 'us_states',
      prompt: 'Where is New Mexico?',
      lat: 34.5199,
      lng: -105.8701,
    ),
    Question(
      id: 'us_new_york',
      categoryId: 'us_states',
      prompt: 'Where is New York State?',
      lat: 43.2994,
      lng: -74.2179,
    ),
    Question(
      id: 'us_north_carolina',
      categoryId: 'us_states',
      prompt: 'Where is North Carolina?',
      lat: 35.7596,
      lng: -79.0193,
    ),
    Question(
      id: 'us_north_dakota',
      categoryId: 'us_states',
      prompt: 'Where is North Dakota?',
      lat: 47.5515,
      lng: -101.0020,
    ),
    Question(
      id: 'us_ohio',
      categoryId: 'us_states',
      prompt: 'Where is Ohio?',
      lat: 40.4173,
      lng: -82.9071,
    ),
    Question(
      id: 'us_oklahoma',
      categoryId: 'us_states',
      prompt: 'Where is Oklahoma?',
      lat: 35.4676,
      lng: -97.5164,
    ),
    Question(
      id: 'us_oregon',
      categoryId: 'us_states',
      prompt: 'Where is Oregon?',
      lat: 43.8041,
      lng: -120.5542,
    ),
    Question(
      id: 'us_pennsylvania',
      categoryId: 'us_states',
      prompt: 'Where is Pennsylvania?',
      lat: 41.2033,
      lng: -77.1945,
    ),
    Question(
      id: 'us_rhode_island',
      categoryId: 'us_states',
      prompt: 'Where is Rhode Island?',
      lat: 41.5801,
      lng: -71.4774,
    ),
    Question(
      id: 'us_south_carolina',
      categoryId: 'us_states',
      prompt: 'Where is South Carolina?',
      lat: 33.8361,
      lng: -81.1637,
    ),
    Question(
      id: 'us_south_dakota',
      categoryId: 'us_states',
      prompt: 'Where is South Dakota?',
      lat: 43.9695,
      lng: -99.9018,
    ),
    Question(
      id: 'us_tennessee',
      categoryId: 'us_states',
      prompt: 'Where is Tennessee?',
      lat: 35.5175,
      lng: -86.5804,
    ),
    Question(
      id: 'us_texas',
      categoryId: 'us_states',
      prompt: 'Where is Texas?',
      lat: 31.9686,
      lng: -99.9018,
    ),
    Question(
      id: 'us_utah',
      categoryId: 'us_states',
      prompt: 'Where is Utah?',
      lat: 39.3210,
      lng: -111.0937,
    ),
    Question(
      id: 'us_vermont',
      categoryId: 'us_states',
      prompt: 'Where is Vermont?',
      lat: 44.5588,
      lng: -72.5778,
    ),
    Question(
      id: 'us_virginia',
      categoryId: 'us_states',
      prompt: 'Where is Virginia?',
      lat: 37.4316,
      lng: -78.6569,
    ),
    Question(
      id: 'us_washington',
      categoryId: 'us_states',
      prompt: 'Where is Washington State?',
      lat: 47.7511,
      lng: -120.7401,
    ),
    Question(
      id: 'us_west_virginia',
      categoryId: 'us_states',
      prompt: 'Where is West Virginia?',
      lat: 38.5976,
      lng: -80.4549,
    ),
    Question(
      id: 'us_wisconsin',
      categoryId: 'us_states',
      prompt: 'Where is Wisconsin?',
      lat: 43.7844,
      lng: -88.7879,
    ),
    Question(
      id: 'us_wyoming',
      categoryId: 'us_states',
      prompt: 'Where is Wyoming?',
      lat: 43.0759,
      lng: -107.2903,
    ),

    // --- COUNTRIES --- (removed)

    // --- CAPITALS ---
    // EASY - Very famous capitals everyone knows
    Question(
      id: 'paris',
      categoryId: 'capitals_1',
      prompt: 'Where is Paris?',
      lat: 48.8566,
      lng: 2.3522,
    ),
    Question(
      id: 'london',
      categoryId: 'capitals_1',
      prompt: 'Where is London?',
      lat: 51.5074,
      lng: -0.1278,
    ),
    Question(
      id: 'washington',
      categoryId: 'capitals_1',
      prompt: 'Where is Washington Dc?',
      lat: 38.9072,
      lng: -77.0369,
    ),
    Question(
      id: 'tokyo',
      categoryId: 'capitals_1',
      prompt: 'Where is Tokyo?',
      lat: 35.6762,
      lng: 139.6503,
    ),
    Question(
      id: 'moscow',
      categoryId: 'capitals_1',
      prompt: 'Where is Moscow?',
      lat: 55.7558,
      lng: 37.6173,
    ),
    Question(
      id: 'beijing',
      categoryId: 'capitals_1',
      prompt: 'Where is Beijing?',
      lat: 39.9042,
      lng: 116.4074,
    ),
    Question(
      id: 'rome',
      categoryId: 'capitals_1',
      prompt: 'Where is Rome?',
      lat: 41.9028,
      lng: 12.4964,
    ),
    Question(
      id: 'berlin',
      categoryId: 'capitals_1',
      prompt: 'Where is Berlin?',
      lat: 52.5200,
      lng: 13.4050,
    ),
    Question(
      id: 'madrid',
      categoryId: 'capitals_1',
      prompt: 'Where is Madrid?',
      lat: 40.4168,
      lng: -3.7038,
    ),
    Question(
      id: 'cairo',
      categoryId: 'capitals_1',
      prompt: 'Where is Cairo?',
      lat: 30.0444,
      lng: 31.2357,
    ),

    // MEDIUM - Well-known capitals
    Question(
      id: 'ankara',
      categoryId: 'capitals_1',
      prompt: 'Where is Ankara?',
      lat: 39.9334,
      lng: 32.8597,
    ),
    Question(
      id: 'vienna',
      categoryId: 'capitals_1',
      prompt: 'Where is Vienna?',
      lat: 48.2082,
      lng: 16.3738,
    ),
    Question(
      id: 'athens',
      categoryId: 'capitals_1',
      prompt: 'Where is Athens?',
      lat: 37.9838,
      lng: 23.7275,
    ),
    Question(
      id: 'stockholm',
      categoryId: 'capitals_1',
      prompt: 'Where is Stockholm?',
      lat: 59.3293,
      lng: 18.0686,
    ),
    Question(
      id: 'oslo',
      categoryId: 'capitals_1',
      prompt: 'Where is Oslo?',
      lat: 59.9139,
      lng: 10.7522,
    ),
    Question(
      id: 'copenhagen',
      categoryId: 'capitals_1',
      prompt: 'Where is Copenhagen?',
      lat: 55.6761,
      lng: 12.5683,
    ),
    Question(
      id: 'warsaw',
      categoryId: 'capitals_1',
      prompt: 'Where is Warsaw?',
      lat: 52.2297,
      lng: 21.0122,
    ),
    Question(
      id: 'prague',
      categoryId: 'capitals_1',
      prompt: 'Where is Prague?',
      lat: 50.0755,
      lng: 14.4378,
    ),
    Question(
      id: 'budapest',
      categoryId: 'capitals_1',
      prompt: 'Where is Budapest?',
      lat: 47.4979,
      lng: 19.0402,
    ),
    Question(
      id: 'lisbon',
      categoryId: 'capitals_1',
      prompt: 'Where is Lisbon?',
      lat: 38.7223,
      lng: -9.1393,
    ),
    Question(
      id: 'dublin',
      categoryId: 'capitals_2',
      prompt: 'Where is Dublin?',
      lat: 53.3498,
      lng: -6.2603,
    ),
    Question(
      id: 'brussels',
      categoryId: 'capitals_2',
      prompt: 'Where is Brussels?',
      lat: 50.8503,
      lng: 4.3517,
    ),
    Question(
      id: 'amsterdam',
      categoryId: 'capitals_2',
      prompt: 'Where is Amsterdam?',
      lat: 52.3676,
      lng: 4.9041,
    ),
    Question(
      id: 'canberra',
      categoryId: 'capitals_2',
      prompt: 'Where is Canberra?',
      lat: -35.2809,
      lng: 149.1300,
    ),
    Question(
      id: 'wellington',
      categoryId: 'capitals_2',
      prompt: 'Where is Wellington?',
      lat: -41.2865,
      lng: 174.7762,
    ),

    // HARD - Lesser-known capitals
    Question(
      id: 'brasilia',
      categoryId: 'capitals_2',
      prompt: 'Where is Brasília?',
      lat: -15.8267,
      lng: -47.9218,
    ),
    Question(
      id: 'ottawa',
      categoryId: 'capitals_2',
      prompt: 'Where is Ottawa?',
      lat: 45.4215,
      lng: -75.6972,
    ),
    Question(
      id: 'bern',
      categoryId: 'capitals_2',
      prompt: 'Where is Bern?',
      lat: 46.9480,
      lng: 7.4474,
    ),
    Question(
      id: 'nairobi',
      categoryId: 'capitals_2',
      prompt: 'Where is Nairobi?',
      lat: -1.2864,
      lng: 36.8172,
    ),
    Question(
      id: 'hanoi',
      categoryId: 'capitals_2',
      prompt: 'Where is Hanoi?',
      lat: 21.0285,
      lng: 105.8542,
    ),
    Question(
      id: 'manila',
      categoryId: 'capitals_2',
      prompt: 'Where is Manila?',
      lat: 14.5995,
      lng: 120.9842,
    ),
    Question(
      id: 'santiago',
      categoryId: 'capitals_2',
      prompt: 'Where is Santiago?',
      lat: -33.4489,
      lng: -70.6693,
    ),
    Question(
      id: 'lima',
      categoryId: 'capitals_2',
      prompt: 'Where is Lima?',
      lat: -12.0464,
      lng: -77.0428,
    ),
    Question(
      id: 'bogota',
      categoryId: 'capitals_2',
      prompt: 'Where is Bogotá?',
      lat: 4.7110,
      lng: -74.0721,
    ),
    Question(
      id: 'riyadh',
      categoryId: 'capitals_2',
      prompt: 'Where is Riyadh?',
      lat: 24.7136,
      lng: 46.6753,
    ),
    Question(
      id: 'tehran',
      categoryId: 'capitals_2',
      prompt: 'Where is Tehran?',
      lat: 35.6892,
      lng: 51.3890,
    ),
    Question(
      id: 'islamabad',
      categoryId: 'capitals_2',
      prompt: 'Where is Islamabad?',
      lat: 33.6844,
      lng: 73.0479,
    ),
    Question(
      id: 'kathmandu',
      categoryId: 'capitals_2',
      prompt: 'Where is Kathmandu?',
      lat: 27.7172,
      lng: 85.3240,
    ),
    Question(
      id: 'addis_ababa',
      categoryId: 'capitals_2',
      prompt: 'Where is Addis Ababa?',
      lat: 9.0320,
      lng: 38.7469,
    ),
    Question(
      id: 'kampala',
      categoryId: 'capitals_2',
      prompt: 'Where is Kampala?',
      lat: 0.3476,
      lng: 32.5825,
    ),
  
    // --- HISTORICAL LANDMARKS ---
    // 20 easy but different landmarks (no overlap with Tourist Places)
    Question(
      id: 'blue_mosque',
      categoryId: 'monuments',
      prompt: 'Where is Blue Mosque?',
      lat: 41.0054,
      lng: 28.9768,
    ),
    Question(
      id: 'hagia_sophia',
      categoryId: 'monuments',
      prompt: 'Where is Hagia Sophia?',
      lat: 41.0086,
      lng: 28.9802,
    ),
    Question(
      id: 'kremlin_red_square',
      categoryId: 'monuments',
      prompt: 'Where is the kremlin and red square?',
      lat: 55.7539,
      lng: 37.6208,
    ),
    Question(
      id: 'tower_bridge',
      categoryId: 'monuments',
      prompt: 'Where is Tower Bridge?',
      lat: 51.5055,
      lng: -0.0754,
    ),
    Question(
      id: 'buckingham_palace',
      categoryId: 'monuments',
      prompt: 'Where is Buckingham Palace?',
      lat: 51.5014,
      lng: -0.1419,
    ),
    Question(
      id: 'cn_tower',
      categoryId: 'monuments',
      prompt: 'Where is the cn tower?',
      lat: 43.6426,
      lng: -79.3871,
    ),
    Question(
      id: 'gateway_arch',
      categoryId: 'monuments',
      prompt: 'Where is the gateway arch?',
      lat: 38.6247,
      lng: -90.1848,
    ),
    Question(
      id: 'uluru',
      categoryId: 'monuments',
      prompt: 'Where is Uluru Ayers Rock?',
      lat: -25.3444,
      lng: 131.0369,
    ),
    Question(
      id: 'mount_fuji',
      categoryId: 'monuments',
      prompt: 'Where is Mount Fuji?',
      lat: 35.3606,
      lng: 138.7274,
    ),
    Question(
      id: 'table_mountain',
      categoryId: 'monuments',
      prompt: 'Where is Table Mountain?',
      lat: -33.9628,
      lng: 18.4098,
    ),
    Question(
      id: 'matterhorn',
      categoryId: 'monuments',
      prompt: 'Where is the matterhorn?',
      lat: 45.9763,
      lng: 7.6586,
    ),
    Question(
      id: 'mont_saint_michel',
      categoryId: 'monuments',
      prompt: 'Where is Mont Saint-Michel?',
      lat: 48.6360,
      lng: -1.5115,
    ),
    Question(
      id: 'blue_lagoon',
      categoryId: 'monuments',
      prompt: 'Where is the blue lagoon in iceland?',
      lat: 63.8804,
      lng: -22.4495,
    ),
    Question(
      id: 'alhambra',
      categoryId: 'monuments',
      prompt: 'Where is the alhambra?',
      lat: 37.1761,
      lng: -3.5881,
    ),
    Question(
      id: 'edinburgh_castle',
      categoryId: 'monuments',
      prompt: 'Where is Edinburgh Castle?',
      lat: 55.9486,
      lng: -3.1999,
    ),
    Question(
      id: 'pisa_tower',
      categoryId: 'monuments',
      prompt: 'Where is the leaning tower of pisa?',
      lat: 43.7230,
      lng: 10.3966,
    ),
    Question(
      id: 'abu_simbel',
      categoryId: 'monuments',
      prompt: 'Where is Abu Simbel?',
      lat: 22.3372,
      lng: 31.6258,
    ),
    Question(
      id: 'moai_easter_island',
      categoryId: 'monuments',
      prompt: 'Where is the moai statues on easter island?',
      lat: -27.1212,
      lng: -109.3664,
    ),
    Question(
      id: 'saint_basils',
      categoryId: 'monuments',
      prompt: "Where is Saint Basil's Cathedral?",
      lat: 55.7525,
      lng: 37.6231,
    ),
    Question(
      id: 'himeji_castle',
      categoryId: 'monuments',
      prompt: 'Where is Himeji Castle?',
      lat: 34.8394,
      lng: 134.6939,
    ),

    // --- AMERICA (Polygon-based) ---
    Question(
      id: 'usa',
      categoryId: 'america',
      prompt: 'Where is United States?',
      lat: 39.8283,
      lng: -98.5795,
      isPolygonBased: true,
      polygon: [
        LatLng(49.0, -125.0), // Northwest
        LatLng(49.0, -66.0),  // Northeast
        LatLng(25.0, -80.0),  // Southeast Florida
        LatLng(25.0, -97.0),  // South Texas
        LatLng(32.0, -117.0), // Southwest California
        LatLng(49.0, -125.0), // Close polygon
      ],
    ),
    Question(
      id: 'alaska',
      categoryId: 'america',
      prompt: 'Where is Alaska?',
      lat: 64.2008, // Alaska merkezi civarı
      lng: -149.4937,
      isPolygonBased: true,
    ),
    Question(
      id: 'canada',
      categoryId: 'america',
      prompt: 'Where is Canada?',
      lat: 56.1304,
      lng: -106.3468,
      isPolygonBased: true,
      polygon: [
        LatLng(83.0, -141.0), // Northwest Arctic
        LatLng(83.0, -52.0),  // Northeast
        LatLng(42.0, -52.0),  // Southeast
        LatLng(49.0, -95.0),  // South central
        LatLng(49.0, -123.0), // Southwest BC
        LatLng(60.0, -141.0), // West Alaska border
        LatLng(83.0, -141.0), // Close
      ],
    ),
    Question(
      id: 'mexico',
      categoryId: 'america',
      prompt: 'Where is Mexico?',
      lat: 23.6345,
      lng: -102.5528,
      isPolygonBased: true,
      polygon: [
        LatLng(32.0, -117.0), // Northwest Baja
        LatLng(32.0, -97.0),  // Northeast Texas border
        LatLng(25.0, -97.0),  // East coast
        LatLng(18.0, -88.0),  // Yucatan
        LatLng(14.5, -92.0),  // Guatemala border
        LatLng(14.5, -118.0), // Southwest
        LatLng(23.0, -110.0), // Baja south
        LatLng(32.0, -117.0), // Close
      ],
    ),
    Question(
      id: 'brazil',
      categoryId: 'america',
      prompt: 'Where is Brazil?',
      lat: -14.2350,
      lng: -51.9253,
      isPolygonBased: true,
      polygon: [
        LatLng(5.0, -60.0),   // North Roraima
        LatLng(5.0, -34.0),   // Northeast coast
        LatLng(-33.0, -53.0), // South Rio Grande
        LatLng(-33.0, -73.0), // Southwest border
        LatLng(-10.0, -73.0), // West Acre
        LatLng(5.0, -60.0),   // Close
      ],
    ),
    Question(
      id: 'argentina',
      categoryId: 'america',
      prompt: 'Where is Argentina?',
      lat: -38.4161,
      lng: -63.6167,
      isPolygonBased: true,
      polygon: [
        LatLng(-22.0, -65.0), // North border
        LatLng(-22.0, -54.0), // Northeast
        LatLng(-55.0, -66.0), // South Tierra del Fuego
        LatLng(-55.0, -73.0), // Southwest
        LatLng(-22.0, -69.0), // Northwest Chile border
        LatLng(-22.0, -65.0), // Close
      ],
    ),
    Question(
      id: 'colombia',
      categoryId: 'america',
      prompt: 'Where is Colombia?',
      lat: 4.5709,
      lng: -74.2973,
      isPolygonBased: true,
      polygon: [
        LatLng(12.0, -72.0),  // North Caribbean
        LatLng(12.0, -66.0),  // Northeast Venezuela
        LatLng(-4.0, -67.0),  // Southeast Amazon
        LatLng(-4.0, -79.0),  // Southwest Ecuador
        LatLng(1.0, -79.0),   // West Pacific
        LatLng(12.0, -77.0),  // Northwest Panama
        LatLng(12.0, -72.0),  // Close
      ],
    ),
    Question(
      id: 'chile',
      categoryId: 'america',
      prompt: 'Where is Chile?',
      lat: -35.6751,
      lng: -71.5430,
      isPolygonBased: true,
      polygon: [
        LatLng(-17.0, -70.0), // North
        LatLng(-17.0, -66.0), // Northeast Bolivia
        LatLng(-55.0, -68.0), // South
        LatLng(-55.0, -75.0), // Southwest
        LatLng(-17.0, -70.0), // Close
      ],
    ),
    Question(
      id: 'peru',
      categoryId: 'america',
      prompt: 'Where is Peru?',
      lat: -9.1900,
      lng: -75.0152,
      isPolygonBased: true,
      polygon: [
        LatLng(-0.5, -75.0),  // North Ecuador
        LatLng(-0.5, -70.0),  // Northeast Colombia
        LatLng(-18.0, -69.0), // Southeast Bolivia
        LatLng(-18.0, -76.0), // Southwest coast
        LatLng(-0.5, -81.0),  // West Pacific
        LatLng(-0.5, -75.0),  // Close
      ],
    ),
    // Ek Amerika ülkeleri
    Question(
      id: 'belize',
      categoryId: 'america',
      prompt: 'Where is Belize?',
      lat: 17.1899,
      lng: -88.4976,
      isPolygonBased: true,
    ),
    Question(
      id: 'costa_rica',
      categoryId: 'america',
      prompt: 'Where is Costa Rica?',
      lat: 9.7489,
      lng: -83.7534,
      isPolygonBased: true,
    ),
    Question(
      id: 'el_salvador',
      categoryId: 'america',
      prompt: 'Where is El Salvador?',
      lat: 13.7942,
      lng: -88.8965,
      isPolygonBased: true,
    ),
    Question(
      id: 'guatemala',
      categoryId: 'america',
      prompt: 'Where is Guatemala?',
      lat: 15.7835,
      lng: -90.2308,
      isPolygonBased: true,
    ),
    Question(
      id: 'honduras',
      categoryId: 'america',
      prompt: 'Where is Honduras?',
      lat: 15.1999,
      lng: -86.2419,
      isPolygonBased: true,
    ),
    Question(
      id: 'nicaragua',
      categoryId: 'america',
      prompt: 'Where is Nicaragua?',
      lat: 12.8654,
      lng: -85.2072,
      isPolygonBased: true,
    ),
    Question(
      id: 'panama',
      categoryId: 'america',
      prompt: 'Where is Panama?',
      lat: 8.5380,
      lng: -80.7821,
      isPolygonBased: true,
    ),
    Question(
      id: 'bolivia',
      categoryId: 'america',
      prompt: 'Where is Bolivia?',
      lat: -16.2902,
      lng: -63.5887,
      isPolygonBased: true,
    ),
    Question(
      id: 'ecuador',
      categoryId: 'america',
      prompt: 'Where is Ecuador?',
      lat: -1.8312,
      lng: -78.1834,
      isPolygonBased: true,
    ),
    Question(
      id: 'guyana',
      categoryId: 'america',
      prompt: 'Where is Guyana?',
      lat: 4.8604,
      lng: -58.9302,
      isPolygonBased: true,
    ),
    Question(
      id: 'paraguay',
      categoryId: 'america',
      prompt: 'Where is Paraguay?',
      lat: -23.4425,
      lng: -58.4438,
      isPolygonBased: true,
    ),
    Question(
      id: 'suriname',
      categoryId: 'america',
      prompt: 'Where is Suriname?',
      lat: 3.9193,
      lng: -56.0278,
      isPolygonBased: true,
    ),
    Question(
      id: 'uruguay',
      categoryId: 'america',
      prompt: 'Where is Uruguay?',
      lat: -32.5228,
      lng: -55.7658,
      isPolygonBased: true,
    ),
    Question(
      id: 'venezuela',
      categoryId: 'america',
      prompt: 'Where is Venezuela?',
      lat: 6.4238,
      lng: -66.5897,
      isPolygonBased: true,
    ),
    // --- EUROPE 1 (A–L) ---
    Question(
      id: 'albania',
      categoryId: 'europe_1',
      prompt: 'Where is Albania?',
      lat: 41.1533,
      lng: 20.1683,
      isPolygonBased: true,
    ),
    Question(
      id: 'andorra',
      categoryId: 'europe_1',
      prompt: 'Where is Andorra?',
      lat: 42.5063,
      lng: 1.5218,
      isPolygonBased: true,
    ),
    Question(
      id: 'armenia',
      categoryId: 'europe_1',
      prompt: 'Where is Armenia?',
      lat: 40.0691,
      lng: 45.0382,
      isPolygonBased: true,
    ),
    Question(
      id: 'austria',
      categoryId: 'europe_1',
      prompt: 'Where is Austria?',
      lat: 47.5162,
      lng: 14.5501,
      isPolygonBased: true,
    ),
    Question(
      id: 'azerbaijan',
      categoryId: 'europe_1',
      prompt: 'Where is Azerbaijan?',
      lat: 40.1431,
      lng: 47.5769,
      isPolygonBased: true,
    ),
    Question(
      id: 'belarus',
      categoryId: 'europe_1',
      prompt: 'Where is Belarus?',
      lat: 53.7098,
      lng: 27.9534,
      isPolygonBased: true,
    ),
    Question(
      id: 'belgium',
      categoryId: 'europe_1',
      prompt: 'Where is Belgium?',
      lat: 50.5039,
      lng: 4.4699,
      isPolygonBased: true,
    ),
    Question(
      id: 'bosnia_and_herzegovina',
      categoryId: 'europe_1',
      prompt: 'Where is Bosnia And Herzegovina?',
      lat: 43.9159,
      lng: 17.6791,
      isPolygonBased: true,
    ),
    Question(
      id: 'bulgaria',
      categoryId: 'europe_1',
      prompt: 'Where is Bulgaria?',
      lat: 42.7339,
      lng: 25.4858,
      isPolygonBased: true,
    ),
    Question(
      id: 'croatia',
      categoryId: 'europe_1',
      prompt: 'Where is Croatia?',
      lat: 45.1000,
      lng: 15.2000,
      isPolygonBased: true,
    ),
    Question(
      id: 'cyprus',
      categoryId: 'europe_1',
      prompt: 'Where is Cyprus?',
      lat: 35.1264,
      lng: 33.4299,
      isPolygonBased: true,
    ),
    Question(
      id: 'czechia',
      categoryId: 'europe_1',
      prompt: 'Where is Czechia?',
      lat: 49.8175,
      lng: 15.4730,
      isPolygonBased: true,
    ),
    Question(
      id: 'denmark',
      categoryId: 'europe_1',
      prompt: 'Where is Denmark?',
      lat: 56.2639,
      lng: 9.5018,
      isPolygonBased: true,
    ),
    Question(
      id: 'estonia',
      categoryId: 'europe_1',
      prompt: 'Where is Estonia?',
      lat: 58.5953,
      lng: 25.0136,
      isPolygonBased: true,
    ),
    Question(
      id: 'finland',
      categoryId: 'europe_1',
      prompt: 'Where is Finland?',
      lat: 61.9241,
      lng: 25.7482,
      isPolygonBased: true,
    ),
    Question(
      id: 'france',
      categoryId: 'europe_1',
      prompt: 'Where is France?',
      lat: 46.2276,
      lng: 2.2137,
      isPolygonBased: true,
    ),
    Question(
      id: 'georgia',
      categoryId: 'europe_1',
      prompt: 'Where is Georgia?',
      lat: 42.3154,
      lng: 43.3569,
      isPolygonBased: true,
    ),
    Question(
      id: 'germany',
      categoryId: 'europe_1',
      prompt: 'Where is Germany?',
      lat: 51.1657,
      lng: 10.4515,
      isPolygonBased: true,
    ),
    Question(
      id: 'greece',
      categoryId: 'europe_1',
      prompt: 'Where is Greece?',
      lat: 39.0742,
      lng: 21.8243,
      isPolygonBased: true,
    ),
    Question(
      id: 'hungary',
      categoryId: 'europe_1',
      prompt: 'Where is Hungary?',
      lat: 47.1625,
      lng: 19.5033,
      isPolygonBased: true,
    ),
    Question(
      id: 'iceland',
      categoryId: 'europe_1',
      prompt: 'Where is Iceland?',
      lat: 64.9631,
      lng: -19.0208,
      isPolygonBased: true,
    ),
    Question(
      id: 'ireland',
      categoryId: 'europe_1',
      prompt: 'Where is Ireland?',
      lat: 53.1424,
      lng: -7.6921,
      isPolygonBased: true,
    ),
    Question(
      id: 'italy',
      categoryId: 'europe_1',
      prompt: 'Where is Italy?',
      lat: 41.8719,
      lng: 12.5674,
      isPolygonBased: true,
    ),
    Question(
      id: 'kazakhstan',
      categoryId: 'europe_1',
      prompt: 'Where is Kazakhstan?',
      lat: 48.0196,
      lng: 66.9237,
      isPolygonBased: true,
    ),
    Question(
      id: 'kosovo',
      categoryId: 'europe_1',
      prompt: 'Where is Kosovo?',
      lat: 42.6026,
      lng: 20.9030,
      isPolygonBased: true,
    ),
    Question(
      id: 'latvia',
      categoryId: 'europe_1',
      prompt: 'Where is Latvia?',
      lat: 56.8796,
      lng: 24.6032,
      isPolygonBased: true,
    ),
    Question(
      id: 'liechtenstein',
      categoryId: 'europe_1',
      prompt: 'Where is Liechtenstein?',
      lat: 47.1660,
      lng: 9.5554,
      isPolygonBased: true,
    ),
    Question(
      id: 'lithuania',
      categoryId: 'europe_1',
      prompt: 'Where is Lithuania?',
      lat: 55.1694,
      lng: 23.8813,
      isPolygonBased: true,
    ),
    Question(
      id: 'luxembourg',
      categoryId: 'europe_1',
      prompt: 'Where is Luxembourg?',
      lat: 49.8153,
      lng: 6.1296,
      isPolygonBased: true,
    ),

    // --- EUROPE 2 (M–Z) ---
    Question(
      id: 'malta',
      categoryId: 'europe_2',
      prompt: 'Where is Malta?',
      lat: 35.9375,
      lng: 14.3754,
      isPolygonBased: true,
    ),
    Question(
      id: 'moldova',
      categoryId: 'europe_2',
      prompt: 'Where is Moldova?',
      lat: 47.4116,
      lng: 28.3699,
      isPolygonBased: true,
    ),
    Question(
      id: 'monaco',
      categoryId: 'europe_2',
      prompt: 'Where is Monaco?',
      lat: 43.7384,
      lng: 7.4246,
      isPolygonBased: true,
    ),
    Question(
      id: 'montenegro',
      categoryId: 'europe_2',
      prompt: 'Where is Montenegro?',
      lat: 42.7087,
      lng: 19.3744,
      isPolygonBased: true,
    ),
    Question(
      id: 'netherlands',
      categoryId: 'europe_2',
      prompt: 'Where is the netherlands?',
      lat: 52.1326,
      lng: 5.2913,
      isPolygonBased: true,
    ),
    Question(
      id: 'north_macedonia',
      categoryId: 'europe_2',
      prompt: 'Where is North Macedonia?',
      lat: 41.6086,
      lng: 21.7453,
      isPolygonBased: true,
    ),
    Question(
      id: 'norway',
      categoryId: 'europe_2',
      prompt: 'Where is Norway?',
      lat: 60.4720,
      lng: 8.4689,
      isPolygonBased: true,
    ),
    Question(
      id: 'poland',
      categoryId: 'europe_2',
      prompt: 'Where is Poland?',
      lat: 51.9194,
      lng: 19.1451,
      isPolygonBased: true,
    ),
    Question(
      id: 'portugal',
      categoryId: 'europe_2',
      prompt: 'Where is Portugal?',
      lat: 39.3999,
      lng: -8.2245,
      isPolygonBased: true,
    ),
    Question(
      id: 'romania',
      categoryId: 'europe_2',
      prompt: 'Where is Romania?',
      lat: 45.9432,
      lng: 24.9668,
      isPolygonBased: true,
    ),
    Question(
      id: 'russia',
      categoryId: 'europe_2',
      prompt: 'Where is Russia?',
      lat: 61.5240,
      lng: 105.3188,
      isPolygonBased: true,
    ),
    Question(
      id: 'san_marino',
      categoryId: 'europe_2',
      prompt: 'Where is San Marino?',
      lat: 43.9424,
      lng: 12.4578,
      isPolygonBased: true,
    ),
    Question(
      id: 'serbia',
      categoryId: 'europe_2',
      prompt: 'Where is Serbia?',
      lat: 44.0165,
      lng: 21.0059,
      isPolygonBased: true,
    ),
    Question(
      id: 'slovakia',
      categoryId: 'europe_2',
      prompt: 'Where is Slovakia?',
      lat: 48.6690,
      lng: 19.6990,
      isPolygonBased: true,
    ),
    Question(
      id: 'slovenia',
      categoryId: 'europe_2',
      prompt: 'Where is Slovenia?',
      lat: 46.1512,
      lng: 14.9955,
      isPolygonBased: true,
    ),
    Question(
      id: 'spain',
      categoryId: 'europe_2',
      prompt: 'Where is Spain?',
      lat: 40.4637,
      lng: -3.7492,
      isPolygonBased: true,
    ),
    Question(
      id: 'sweden',
      categoryId: 'europe_2',
      prompt: 'Where is Sweden?',
      lat: 60.1282,
      lng: 18.6435,
      isPolygonBased: true,
    ),
    Question(
      id: 'switzerland',
      categoryId: 'europe_2',
      prompt: 'Where is Switzerland?',
      lat: 46.8182,
      lng: 8.2275,
      isPolygonBased: true,
    ),
    Question(
      id: 'turkey',
      categoryId: 'europe_2',
      prompt: 'Where is Turkey?',
      lat: 38.9637,
      lng: 35.2433,
      isPolygonBased: true,
    ),
    Question(
      id: 'ukraine',
      categoryId: 'europe_2',
      prompt: 'Where is Ukraine?',
      lat: 48.3794,
      lng: 31.1656,
      isPolygonBased: true,
    ),
    Question(
      id: 'united_kingdom',
      categoryId: 'europe_2',
      prompt: 'Where is the united kingdom?',
      lat: 55.3781,
      lng: -3.4360,
      isPolygonBased: true,
    ),
    Question(
      id: 'vatican_city',
      categoryId: 'europe_2',
      prompt: 'Where is Vatican City?',
      lat: 41.9029,
      lng: 12.4534,
      isPolygonBased: true,
    ),
    // --- ASIA ---
    Question(
      id: 'afghanistan',
      categoryId: 'asia',
      prompt: 'Where is Afghanistan?',
      lat: 33.9391,
      lng: 67.7100,
      isPolygonBased: true,
    ),
    Question(
      id: 'armenia_asia',
      categoryId: 'asia',
      prompt: 'Where is Armenia?',
      lat: 40.0691,
      lng: 45.0382,
      isPolygonBased: true,
    ),
    Question(
      id: 'azerbaijan_asia',
      categoryId: 'asia',
      prompt: 'Where is Azerbaijan?',
      lat: 40.1431,
      lng: 47.5769,
      isPolygonBased: true,
    ),
    Question(
      id: 'bahrain',
      categoryId: 'asia',
      prompt: 'Where is Bahrain?',
      lat: 26.0667,
      lng: 50.5577,
      isPolygonBased: true,
    ),
    Question(
      id: 'bangladesh',
      categoryId: 'asia',
      prompt: 'Where is Bangladesh?',
      lat: 23.6850,
      lng: 90.3563,
      isPolygonBased: true,
    ),
    Question(
      id: 'bhutan',
      categoryId: 'asia',
      prompt: 'Where is Bhutan?',
      lat: 27.5142,
      lng: 90.4336,
      isPolygonBased: true,
    ),
    Question(
      id: 'brunei',
      categoryId: 'asia',
      prompt: 'Where is Brunei?',
      lat: 4.5353,
      lng: 114.7277,
      isPolygonBased: true,
    ),
    Question(
      id: 'cambodia',
      categoryId: 'asia',
      prompt: 'Where is Cambodia?',
      lat: 12.5657,
      lng: 104.9910,
      isPolygonBased: true,
    ),
    Question(
      id: 'china',
      categoryId: 'asia',
      prompt: 'Where is China?',
      lat: 35.8617,
      lng: 104.1954,
      isPolygonBased: true,
    ),
    Question(
      id: 'cyprus_asia',
      categoryId: 'asia',
      prompt: 'Where is Cyprus?',
      lat: 35.1264,
      lng: 33.4299,
      isPolygonBased: true,
    ),
    Question(
      id: 'georgia_asia',
      categoryId: 'asia',
      prompt: 'Where is Georgia?',
      lat: 42.3154,
      lng: 43.3569,
      isPolygonBased: true,
    ),
    Question(
      id: 'india',
      categoryId: 'asia',
      prompt: 'Where is India?',
      lat: 20.5937,
      lng: 78.9629,
      isPolygonBased: true,
    ),
    Question(
      id: 'indonesia',
      categoryId: 'asia',
      prompt: 'Where is Indonesia?',
      lat: -0.7893,
      lng: 113.9213,
      isPolygonBased: true,
    ),
    Question(
      id: 'iran',
      categoryId: 'asia',
      prompt: 'Where is Iran?',
      lat: 32.4279,
      lng: 53.6880,
      isPolygonBased: true,
    ),
    Question(
      id: 'iraq',
      categoryId: 'asia',
      prompt: 'Where is Iraq?',
      lat: 33.2232,
      lng: 43.6793,
      isPolygonBased: true,
    ),
    Question(
      id: 'israel',
      categoryId: 'asia',
      prompt: 'Where is Israel?',
      lat: 31.0461,
      lng: 34.8516,
      isPolygonBased: true,
    ),
    Question(
      id: 'japan',
      categoryId: 'asia',
      prompt: 'Where is Japan?',
      lat: 36.2048,
      lng: 138.2529,
      isPolygonBased: true,
    ),
    Question(
      id: 'jordan',
      categoryId: 'asia',
      prompt: 'Where is Jordan?',
      lat: 30.5852,
      lng: 36.2384,
      isPolygonBased: true,
    ),
    Question(
      id: 'kazakhstan_asia',
      categoryId: 'asia',
      prompt: 'Where is Kazakhstan?',
      lat: 48.0196,
      lng: 66.9237,
      isPolygonBased: true,
    ),
    Question(
      id: 'kuwait',
      categoryId: 'asia',
      prompt: 'Where is Kuwait?',
      lat: 29.3117,
      lng: 47.4818,
      isPolygonBased: true,
    ),
    Question(
      id: 'kyrgyzstan',
      categoryId: 'asia',
      prompt: 'Where is Kyrgyzstan?',
      lat: 41.2044,
      lng: 74.7661,
      isPolygonBased: true,
    ),
    Question(
      id: 'laos',
      categoryId: 'asia',
      prompt: 'Where is Laos?',
      lat: 19.8563,
      lng: 102.4955,
      isPolygonBased: true,
    ),
    Question(
      id: 'lebanon',
      categoryId: 'asia',
      prompt: 'Where is Lebanon?',
      lat: 33.8547,
      lng: 35.8623,
      isPolygonBased: true,
    ),
    Question(
      id: 'malaysia',
      categoryId: 'asia',
      prompt: 'Where is Malaysia?',
      lat: 4.2105,
      lng: 101.9758,
      isPolygonBased: true,
    ),
    Question(
      id: 'maldives',
      categoryId: 'asia',
      prompt: 'Where is Maldives?',
      lat: 3.2028,
      lng: 73.2207,
      isPolygonBased: true,
    ),
    Question(
      id: 'mongolia',
      categoryId: 'asia',
      prompt: 'Where is Mongolia?',
      lat: 46.8625,
      lng: 103.8467,
      isPolygonBased: true,
    ),
    Question(
      id: 'myanmar',
      categoryId: 'asia',
      prompt: 'Where is Myanmar?',
      lat: 21.9162,
      lng: 95.9560,
      isPolygonBased: true,
    ),
    Question(
      id: 'nepal',
      categoryId: 'asia',
      prompt: 'Where is Nepal?',
      lat: 28.3949,
      lng: 84.1240,
      isPolygonBased: true,
    ),
    Question(
      id: 'north_korea',
      categoryId: 'asia',
      prompt: 'Where is North Korea?',
      lat: 40.3399,
      lng: 127.5101,
      isPolygonBased: true,
    ),
    Question(
      id: 'oman',
      categoryId: 'asia',
      prompt: 'Where is Oman?',
      lat: 21.4735,
      lng: 55.9754,
      isPolygonBased: true,
    ),
    Question(
      id: 'pakistan',
      categoryId: 'asia',
      prompt: 'Where is Pakistan?',
      lat: 30.3753,
      lng: 69.3451,
      isPolygonBased: true,
    ),
    Question(
      id: 'palestine',
      categoryId: 'asia',
      prompt: 'Where is Palestine?',
      lat: 31.9522,
      lng: 35.2332,
      isPolygonBased: true,
    ),
    Question(
      id: 'philippines',
      categoryId: 'asia',
      prompt: 'Where is the philippines?',
      lat: 12.8797,
      lng: 121.7740,
      isPolygonBased: true,
    ),
    Question(
      id: 'qatar',
      categoryId: 'asia',
      prompt: 'Where is Qatar?',
      lat: 25.3548,
      lng: 51.1839,
      isPolygonBased: true,
    ),
    Question(
      id: 'saudi_arabia',
      categoryId: 'asia',
      prompt: 'Where is Saudi Arabia?',
      lat: 23.8859,
      lng: 45.0792,
      isPolygonBased: true,
    ),
    Question(
      id: 'singapore',
      categoryId: 'asia',
      prompt: 'Where is Singapore?',
      lat: 1.3521,
      lng: 103.8198,
      isPolygonBased: true,
    ),
    Question(
      id: 'south_korea',
      categoryId: 'asia',
      prompt: 'Where is South Korea?',
      lat: 35.9078,
      lng: 127.7669,
      isPolygonBased: true,
    ),
    Question(
      id: 'sri_lanka',
      categoryId: 'asia',
      prompt: 'Where is Sri Lanka?',
      lat: 7.8731,
      lng: 80.7718,
      isPolygonBased: true,
    ),
    Question(
      id: 'syria',
      categoryId: 'asia',
      prompt: 'Where is Syria?',
      lat: 34.8021,
      lng: 38.9968,
      isPolygonBased: true,
    ),
    Question(
      id: 'taiwan',
      categoryId: 'asia',
      prompt: 'Where is Taiwan?',
      lat: 23.6978,
      lng: 120.9605,
      isPolygonBased: true,
    ),
    Question(
      id: 'tajikistan',
      categoryId: 'asia',
      prompt: 'Where is Tajikistan?',
      lat: 38.8610,
      lng: 71.2761,
      isPolygonBased: true,
    ),
    Question(
      id: 'thailand',
      categoryId: 'asia',
      prompt: 'Where is Thailand?',
      lat: 15.8700,
      lng: 100.9925,
      isPolygonBased: true,
    ),
    Question(
      id: 'timor_leste',
      categoryId: 'asia',
      prompt: 'Where is Timor-Leste?',
      lat: -8.8742,
      lng: 125.7275,
      isPolygonBased: true,
    ),
    Question(
      id: 'turkmenistan',
      categoryId: 'asia',
      prompt: 'Where is Turkmenistan?',
      lat: 38.9697,
      lng: 59.5563,
      isPolygonBased: true,
    ),
    Question(
      id: 'united_arab_emirates',
      categoryId: 'asia',
      prompt: 'Where is the united arab emirates?',
      lat: 23.4241,
      lng: 53.8478,
      isPolygonBased: true,
    ),
    Question(
      id: 'uzbekistan',
      categoryId: 'asia',
      prompt: 'Where is Uzbekistan?',
      lat: 41.3775,
      lng: 64.5853,
      isPolygonBased: true,
    ),
    Question(
      id: 'vietnam',
      categoryId: 'asia',
      prompt: 'Where is Vietnam?',
      lat: 14.0583,
      lng: 108.2772,
      isPolygonBased: true,
    ),
    Question(
      id: 'yemen',
      categoryId: 'asia',
      prompt: 'Where is Yemen?',
      lat: 15.5527,
      lng: 48.5164,
      isPolygonBased: true,
    ),

    // --- AFRICA ---
    Question(
      id: 'algeria',
      categoryId: 'africa',
      prompt: 'Where is Algeria?',
      lat: 28.0339,
      lng: 1.6596,
      isPolygonBased: true,
    ),
    Question(
      id: 'angola',
      categoryId: 'africa',
      prompt: 'Where is Angola?',
      lat: -11.2027,
      lng: 17.8739,
      isPolygonBased: true,
    ),
    Question(
      id: 'benin',
      categoryId: 'africa',
      prompt: 'Where is Benin?',
      lat: 9.3077,
      lng: 2.3158,
      isPolygonBased: true,
    ),
    Question(
      id: 'botswana',
      categoryId: 'africa',
      prompt: 'Where is Botswana?',
      lat: -22.3285,
      lng: 24.6849,
      isPolygonBased: true,
    ),
    Question(
      id: 'burkina_faso',
      categoryId: 'africa',
      prompt: 'Where is Burkina Faso?',
      lat: 12.2383,
      lng: -1.5616,
      isPolygonBased: true,
    ),
    Question(
      id: 'burundi',
      categoryId: 'africa',
      prompt: 'Where is Burundi?',
      lat: -3.3731,
      lng: 29.9189,
      isPolygonBased: true,
    ),
    Question(
      id: 'cabo_verde',
      categoryId: 'africa',
      prompt: 'Where is Cabo Verde?',
      lat: 16.5388,
      lng: -23.0418,
      isPolygonBased: true,
    ),
    Question(
      id: 'cameroon',
      categoryId: 'africa',
      prompt: 'Where is Cameroon?',
      lat: 7.3697,
      lng: 12.3547,
      isPolygonBased: true,
    ),
    Question(
      id: 'central_african_republic',
      categoryId: 'africa',
      prompt: 'Where is the central african republic?',
      lat: 6.6111,
      lng: 20.9394,
      isPolygonBased: true,
    ),
    Question(
      id: 'chad',
      categoryId: 'africa',
      prompt: 'Where is Chad?',
      lat: 15.4542,
      lng: 18.7322,
      isPolygonBased: true,
    ),
    Question(
      id: 'comoros',
      categoryId: 'africa',
      prompt: 'Where is Comoros?',
      lat: -11.6455,
      lng: 43.3333,
      isPolygonBased: true,
    ),
    Question(
      id: 'democratic_republic_of_the_congo',
      categoryId: 'africa',
      prompt: 'Where is the democratic republic of the congo?',
      lat: -4.0383,
      lng: 21.7587,
      isPolygonBased: true,
    ),
    Question(
      id: 'republic_of_the_congo',
      categoryId: 'africa',
      prompt: 'Where is the republic of the congo?',
      lat: -0.2280,
      lng: 15.8277,
      isPolygonBased: true,
    ),
    Question(
      id: 'djibouti',
      categoryId: 'africa',
      prompt: 'Where is Djibouti?',
      lat: 11.8251,
      lng: 42.5903,
      isPolygonBased: true,
    ),
    Question(
      id: 'egypt',
      categoryId: 'africa',
      prompt: 'Where is Egypt?',
      lat: 26.8206,
      lng: 30.8025,
      isPolygonBased: true,
    ),
    Question(
      id: 'equatorial_guinea',
      categoryId: 'africa',
      prompt: 'Where is Equatorial Guinea?',
      lat: 1.6508,
      lng: 10.2679,
      isPolygonBased: true,
    ),
    Question(
      id: 'eritrea',
      categoryId: 'africa',
      prompt: 'Where is Eritrea?',
      lat: 15.1794,
      lng: 39.7823,
      isPolygonBased: true,
    ),
    Question(
      id: 'eswatini',
      categoryId: 'africa',
      prompt: 'Where is Eswatini?',
      lat: -26.5225,
      lng: 31.4659,
      isPolygonBased: true,
    ),
    Question(
      id: 'ethiopia',
      categoryId: 'africa',
      prompt: 'Where is Ethiopia?',
      lat: 9.1450,
      lng: 40.4897,
      isPolygonBased: true,
    ),
    Question(
      id: 'gabon',
      categoryId: 'africa',
      prompt: 'Where is Gabon?',
      lat: -0.8037,
      lng: 11.6094,
      isPolygonBased: true,
    ),
    Question(
      id: 'gambia',
      categoryId: 'africa',
      prompt: 'Where is the gambia?',
      lat: 13.4432,
      lng: -15.3101,
      isPolygonBased: true,
    ),
    Question(
      id: 'ghana',
      categoryId: 'africa',
      prompt: 'Where is Ghana?',
      lat: 7.9465,
      lng: -1.0232,
      isPolygonBased: true,
    ),
    Question(
      id: 'guinea',
      categoryId: 'africa',
      prompt: 'Where is Guinea?',
      lat: 9.9456,
      lng: -9.6966,
      isPolygonBased: true,
    ),
    Question(
      id: 'guinea_bissau',
      categoryId: 'africa',
      prompt: 'Where is Guinea-Bissau?',
      lat: 11.8037,
      lng: -15.1804,
      isPolygonBased: true,
    ),
    Question(
      id: 'ivory_coast',
      categoryId: 'africa',
      prompt: 'Where is Ivory Coast?',
      lat: 7.5399,
      lng: -5.5471,
      isPolygonBased: true,
    ),
    Question(
      id: 'kenya',
      categoryId: 'africa',
      prompt: 'Where is Kenya?',
      lat: -0.0236,
      lng: 37.9062,
      isPolygonBased: true,
    ),
    Question(
      id: 'lesotho',
      categoryId: 'africa',
      prompt: 'Where is Lesotho?',
      lat: -29.6100,
      lng: 28.2336,
      isPolygonBased: true,
    ),
    Question(
      id: 'liberia',
      categoryId: 'africa',
      prompt: 'Where is Liberia?',
      lat: 6.4281,
      lng: -9.4295,
      isPolygonBased: true,
    ),
    Question(
      id: 'libya',
      categoryId: 'africa',
      prompt: 'Where is Libya?',
      lat: 26.3351,
      lng: 17.2283,
      isPolygonBased: true,
    ),
    Question(
      id: 'madagascar',
      categoryId: 'africa',
      prompt: 'Where is Madagascar?',
      lat: -18.7669,
      lng: 46.8691,
      isPolygonBased: true,
    ),
    Question(
      id: 'malawi',
      categoryId: 'africa',
      prompt: 'Where is Malawi?',
      lat: -13.2543,
      lng: 34.3015,
      isPolygonBased: true,
    ),
    Question(
      id: 'mali',
      categoryId: 'africa',
      prompt: 'Where is Mali?',
      lat: 17.5707,
      lng: -3.9962,
      isPolygonBased: true,
    ),
    Question(
      id: 'mauritania',
      categoryId: 'africa',
      prompt: 'Where is Mauritania?',
      lat: 21.0079,
      lng: -10.9408,
      isPolygonBased: true,
    ),
    Question(
      id: 'mauritius',
      categoryId: 'africa',
      prompt: 'Where is Mauritius?',
      lat: -20.3484,
      lng: 57.5522,
      isPolygonBased: true,
    ),
    Question(
      id: 'morocco',
      categoryId: 'africa',
      prompt: 'Where is Morocco?',
      lat: 31.7917,
      lng: -7.0926,
      isPolygonBased: true,
    ),
    Question(
      id: 'mozambique',
      categoryId: 'africa',
      prompt: 'Where is Mozambique?',
      lat: -18.6657,
      lng: 35.5296,
      isPolygonBased: true,
    ),
    Question(
      id: 'namibia',
      categoryId: 'africa',
      prompt: 'Where is Namibia?',
      lat: -22.9576,
      lng: 18.4904,
      isPolygonBased: true,
    ),
    Question(
      id: 'niger',
      categoryId: 'africa',
      prompt: 'Where is Niger?',
      lat: 17.6078,
      lng: 8.0817,
      isPolygonBased: true,
    ),
    Question(
      id: 'nigeria',
      categoryId: 'africa',
      prompt: 'Where is Nigeria?',
      lat: 9.0820,
      lng: 8.6753,
      isPolygonBased: true,
    ),
    Question(
      id: 'rwanda_africa',
      categoryId: 'africa',
      prompt: 'Where is Rwanda?',
      lat: -1.9403,
      lng: 29.8739,
      isPolygonBased: true,
    ),
    Question(
      id: 'sao_tome_and_principe',
      categoryId: 'africa',
      prompt: 'Where is São Tomé And Príncipe?',
      lat: 0.1864,
      lng: 6.6131,
      isPolygonBased: true,
    ),
    Question(
      id: 'senegal',
      categoryId: 'africa',
      prompt: 'Where is Senegal?',
      lat: 14.4974,
      lng: -14.4524,
      isPolygonBased: true,
    ),
    Question(
      id: 'seychelles',
      categoryId: 'africa',
      prompt: 'Where is Seychelles?',
      lat: -4.6796,
      lng: 55.4920,
      isPolygonBased: true,
    ),
    Question(
      id: 'sierra_leone',
      categoryId: 'africa',
      prompt: 'Where is Sierra Leone?',
      lat: 8.4606,
      lng: -11.7799,
      isPolygonBased: true,
    ),
    Question(
      id: 'somalia',
      categoryId: 'africa',
      prompt: 'Where is Somalia?',
      lat: 5.1521,
      lng: 46.1996,
      isPolygonBased: true,
    ),
    Question(
      id: 'south_africa',
      categoryId: 'africa',
      prompt: 'Where is South Africa?',
      lat: -30.5595,
      lng: 22.9375,
      isPolygonBased: true,
    ),
    Question(
      id: 'south_sudan',
      categoryId: 'africa',
      prompt: 'Where is South Sudan?',
      lat: 6.8769,
      lng: 31.3069,
      isPolygonBased: true,
    ),
    Question(
      id: 'sudan',
      categoryId: 'africa',
      prompt: 'Where is Sudan?',
      lat: 12.8628,
      lng: 30.2176,
      isPolygonBased: true,
    ),
    Question(
      id: 'tanzania',
      categoryId: 'africa',
      prompt: 'Where is Tanzania?',
      lat: -6.3690,
      lng: 34.8888,
      isPolygonBased: true,
    ),
    Question(
      id: 'togo',
      categoryId: 'africa',
      prompt: 'Where is Togo?',
      lat: 8.6195,
      lng: 0.8248,
      isPolygonBased: true,
    ),
    Question(
      id: 'tunisia',
      categoryId: 'africa',
      prompt: 'Where is Tunisia?',
      lat: 33.8869,
      lng: 9.5375,
      isPolygonBased: true,
    ),
    Question(
      id: 'uganda',
      categoryId: 'africa',
      prompt: 'Where is Uganda?',
      lat: 1.3733,
      lng: 32.2903,
      isPolygonBased: true,
    ),
    Question(
      id: 'zambia',
      categoryId: 'africa',
      prompt: 'Where is Zambia?',
      lat: -13.1339,
      lng: 27.8493,
      isPolygonBased: true,
    ),
    Question(
      id: 'zimbabwe',
      categoryId: 'africa',
      prompt: 'Where is Zimbabwe?',
      lat: -19.0154,
      lng: 29.1549,
      isPolygonBased: true,
    ),

    // --- OCEANIA ---
    Question(
      id: 'australia_oceania',
      categoryId: 'oceania',
      prompt: 'Where is Australia?',
      lat: -25.2744,
      lng: 133.7751,
      isPolygonBased: true,
    ),
    Question(
      id: 'new_zealand',
      categoryId: 'oceania',
      prompt: 'Where is New Zealand?',
      lat: -40.9006,
      lng: 174.8860,
      isPolygonBased: true,
    ),
    Question(
      id: 'papua_new_guinea',
      categoryId: 'oceania',
      prompt: 'Where is Papua New Guinea?',
      lat: -6.314993,
      lng: 143.955550,
      isPolygonBased: true,
    ),
    Question(
      id: 'fiji',
      categoryId: 'oceania',
      prompt: 'Where is Fiji?',
      lat: -17.7134,
      lng: 178.0650,
      isPolygonBased: true,
    ),
    Question(
      id: 'solomon_islands',
      categoryId: 'oceania',
      prompt: 'Where is the solomon islands?',
      lat: -9.6457,
      lng: 160.1562,
      isPolygonBased: true,
    ),
    Question(
      id: 'vanuatu',
      categoryId: 'oceania',
      prompt: 'Where is Vanuatu?',
      lat: -15.3767,
      lng: 166.9592,
      isPolygonBased: true,
    ),
    Question(
      id: 'samoa',
      categoryId: 'oceania',
      prompt: 'Where is Samoa?',
      lat: -13.7590,
      lng: -172.1046,
      isPolygonBased: true,
    ),
    Question(
      id: 'tonga',
      categoryId: 'oceania',
      prompt: 'Where is Tonga?',
      lat: -21.1790,
      lng: -175.1982,
      isPolygonBased: true,
    ),
    Question(
      id: 'kiribati',
      categoryId: 'oceania',
      prompt: 'Where is Kiribati?',
      lat: 1.8709,
      lng: -157.3620,
      isPolygonBased: true,
    ),
    Question(
      id: 'micronesia',
      categoryId: 'oceania',
      prompt: 'Where is Micronesia Federated States Of?',
      lat: 7.4256,
      lng: 150.5508,
      isPolygonBased: true,
    ),
    Question(
      id: 'marshall_islands',
      categoryId: 'oceania',
      prompt: 'Where is the marshall islands?',
      lat: 7.1315,
      lng: 171.1845,
      isPolygonBased: true,
    ),
    Question(
      id: 'palau',
      categoryId: 'oceania',
      prompt: 'Where is Palau?',
      lat: 7.5150,
      lng: 134.5825,
      isPolygonBased: true,
    ),
    Question(
      id: 'nauru',
      categoryId: 'oceania',
      prompt: 'Where is Nauru?',
      lat: -0.5228,
      lng: 166.9315,
      isPolygonBased: true,
    ),
    Question(
      id: 'tuvalu',
      categoryId: 'oceania',
      prompt: 'Where is Tuvalu?',
      lat: -7.1095,
      lng: 177.6493,
      isPolygonBased: true,
    ),
    Question(
      id: 'space_kennedy_space_center',
      categoryId: 'space_bases',
      prompt: 'Where is Kennedy Space Center?',
      lat: 28.5729,
      lng: -80.6490,
    ),
    Question(
      id: 'space_baikonur_cosmodrome',
      categoryId: 'space_bases',
      prompt: 'Where is Baikonur Cosmodrome?',
      lat: 45.9647,
      lng: 63.3050,
    ),
    Question(
      id: 'space_vandenberg',
      categoryId: 'space_bases',
      prompt: 'Where is Vandenberg Space Force Base?',
      lat: 34.7420,
      lng: -120.5720,
    ),
    Question(
      id: 'space_johnson_space_center',
      categoryId: 'space_bases',
      prompt: 'Where is Johnson Space Center?',
      lat: 29.5594,
      lng: -95.0892,
    ),
    Question(
      id: 'space_guiana_space_centre',
      categoryId: 'space_bases',
      prompt: 'Where is Guiana Space Centre?',
      lat: 5.2390,
      lng: -52.7680,
    ),
    Question(
      id: 'space_starbase',
      categoryId: 'space_bases',
      prompt: 'Where is SpaceX Starbase?',
      lat: 25.9970,
      lng: -97.1560,
    ),
    Question(
      id: 'space_tanegashima',
      categoryId: 'space_bases',
      prompt: 'Where is Tanegashima Space Center?',
      lat: 30.3750,
      lng: 130.9650,
    ),
    Question(
      id: 'space_satish_dhawan',
      categoryId: 'space_bases',
      prompt: 'Where is Satish Dhawan Space Centre?',
      lat: 13.7330,
      lng: 80.2330,
    ),
    Question(
      id: 'space_jiuquan',
      categoryId: 'space_bases',
      prompt: 'Where is Jiuquan Satellite Launch Center?',
      lat: 40.9600,
      lng: 100.2980,
    ),
    Question(
      id: 'space_wenchang',
      categoryId: 'space_bases',
      prompt: 'Where is Wenchang Space Launch Site?',
      lat: 19.6140,
      lng: 110.9510,
    ),
    Question(
      id: 'tech_silicon_valley',
      categoryId: 'tech_hubs',
      prompt: 'Where is Silicon Valley?',
      lat: 37.3870,
      lng: -122.0570,
    ),
    Question(
      id: 'tech_shenzhen',
      categoryId: 'tech_hubs',
      prompt: 'Where is Shenzhen?',
      lat: 22.5431,
      lng: 114.0579,
    ),
    Question(
      id: 'tech_bangalore',
      categoryId: 'tech_hubs',
      prompt: 'Where is Bangalore?',
      lat: 12.9716,
      lng: 77.5946,
    ),
    Question(
      id: 'tech_seoul_gangnam',
      categoryId: 'tech_hubs',
      prompt: 'Where is Gangnam (Seoul)?',
      lat: 37.4979,
      lng: 127.0276,
    ),
    Question(
      id: 'tech_tel_aviv',
      categoryId: 'tech_hubs',
      prompt: 'Where is Tel Aviv?',
      lat: 32.0853,
      lng: 34.7818,
    ),
    Question(
      id: 'tech_berlin',
      categoryId: 'tech_hubs',
      prompt: 'Where is Berlin?',
      lat: 52.5200,
      lng: 13.4050,
    ),
    Question(
      id: 'tech_singapore',
      categoryId: 'tech_hubs',
      prompt: 'Where is Singapore?',
      lat: 1.3521,
      lng: 103.8198,
    ),
    Question(
      id: 'tech_austin',
      categoryId: 'tech_hubs',
      prompt: 'Where is Austin?',
      lat: 30.2672,
      lng: -97.7431,
    ),
    Question(
      id: 'tech_tokyo',
      categoryId: 'tech_hubs',
      prompt: 'Where is Tokyo?',
      lat: 35.6762,
      lng: 139.6503,
    ),
    Question(
      id: 'tech_london',
      categoryId: 'tech_hubs',
      prompt: 'Where is London?',
      lat: 51.5074,
      lng: -0.1278,
    ),
    Question(
      id: 'science_cern',
      categoryId: 'scientific_wonders',
      prompt: 'Where is CERN?',
      lat: 46.2330,
      lng: 6.0550,
    ),
    Question(
      id: 'science_svalbard_seed_vault',
      categoryId: 'scientific_wonders',
      prompt: 'Where is Svalbard Global Seed Vault?',
      lat: 78.2350,
      lng: 15.4910,
    ),
    Question(
      id: 'science_ligo_livingston',
      categoryId: 'scientific_wonders',
      prompt: 'Where is LIGO Livingston Observatory?',
      lat: 30.5630,
      lng: -90.7740,
    ),
    Question(
      id: 'science_ligo_hanford',
      categoryId: 'scientific_wonders',
      prompt: 'Where is LIGO Hanford Observatory?',
      lat: 46.4550,
      lng: -119.4080,
    ),
    Question(
      id: 'science_keck_observatory',
      categoryId: 'scientific_wonders',
      prompt: 'Where is Keck Observatory?',
      lat: 19.8260,
      lng: -155.4740,
    ),
    Question(
      id: 'science_vlt_paranal',
      categoryId: 'scientific_wonders',
      prompt: 'Where is Paranal Observatory (VLT)?',
      lat: -24.6270,
      lng: -70.4040,
    ),
    Question(
      id: 'science_iter',
      categoryId: 'scientific_wonders',
      prompt: 'Where is ITER?',
      lat: 43.6920,
      lng: 5.7630,
    ),
    Question(
      id: 'science_jodrell_bank',
      categoryId: 'scientific_wonders',
      prompt: 'Where is Jodrell Bank Observatory?',
      lat: 53.2363,
      lng: -2.3071,
    ),
    Question(
      id: 'science_five_hundred_meter_aperture_spherical_telescope',
      categoryId: 'scientific_wonders',
      prompt: 'Where is FAST Telescope?',
      lat: 25.6529,
      lng: 106.8567,
    ),
    Question(
      id: 'science_south_pole_station',
      categoryId: 'scientific_wonders',
      prompt: 'Where is Amundsen–Scott South Pole Station?',
      lat: -90.0000,
      lng: 0.0000,
    ),
    Question(
      id: 'animal_lemurs_madagascar',
      categoryId: 'endemic_animals',
      prompt: 'Where do lemurs live?',
      lat: -18.7669,
      lng: 46.8691,
    ),
    Question(
      id: 'animal_kangaroos_australia',
      categoryId: 'endemic_animals',
      prompt: 'Where do kangaroos live?',
      lat: -25.2744,
      lng: 133.7751,
    ),
    Question(
      id: 'animal_komodo_dragon',
      categoryId: 'endemic_animals',
      prompt: 'Where is Komodo dragon found?',
      lat: -8.5500,
      lng: 119.4900,
    ),
    Question(
      id: 'animal_galapagos_tortoise',
      categoryId: 'endemic_animals',
      prompt: 'Where is Galapagos tortoise found?',
      lat: -0.9538,
      lng: -90.9656,
    ),
    Question(
      id: 'animal_kiwi_new_zealand',
      categoryId: 'endemic_animals',
      prompt: 'Where do kiwi birds live?',
      lat: -41.2865,
      lng: 174.7762,
    ),
    Question(
      id: 'animal_giant_panda',
      categoryId: 'endemic_animals',
      prompt: 'Where do giant pandas live?',
      lat: 31.2304,
      lng: 103.4170,
    ),
    Question(
      id: 'animal_bengal_tiger',
      categoryId: 'endemic_animals',
      prompt: 'Where do Bengal tigers live?',
      lat: 21.9497,
      lng: 89.1833,
    ),
    Question(
      id: 'animal_mountain_gorilla',
      categoryId: 'endemic_animals',
      prompt: 'Where do mountain gorillas live?',
      lat: -1.4850,
      lng: 29.5900,
    ),
    Question(
      id: 'animal_koala',
      categoryId: 'endemic_animals',
      prompt: 'Where do koalas live?',
      lat: -33.8688,
      lng: 151.2093,
    ),
    Question(
      id: 'animal_emperor_penguin',
      categoryId: 'endemic_animals',
      prompt: 'Where do emperor penguins live?',
      lat: -77.8500,
      lng: 166.6667,
    ),
    Question(
      id: 'extreme_death_valley',
      categoryId: 'extreme_points',
      prompt: 'Where is Death Valley?',
      lat: 36.5050,
      lng: -116.8470,
    ),
    Question(
      id: 'extreme_oymyakon',
      categoryId: 'extreme_points',
      prompt: 'Where is Oymyakon?',
      lat: 63.4630,
      lng: 142.7730,
    ),
    Question(
      id: 'extreme_mariana_trench',
      categoryId: 'extreme_points',
      prompt: 'Where is the Mariana Trench?',
      lat: 11.3500,
      lng: 142.2000,
    ),
    Question(
      id: 'extreme_north_pole',
      categoryId: 'extreme_points',
      prompt: 'Where is the North Pole?',
      lat: 90.0000,
      lng: 0.0000,
    ),
    Question(
      id: 'extreme_south_pole',
      categoryId: 'extreme_points',
      prompt: 'Where is the South Pole?',
      lat: -90.0000,
      lng: 0.0000,
    ),
    Question(
      id: 'extreme_atacama_desert',
      categoryId: 'extreme_points',
      prompt: 'Where is the Atacama Desert?',
      lat: -24.5000,
      lng: -69.2500,
    ),
    Question(
      id: 'extreme_danakil_depression',
      categoryId: 'extreme_points',
      prompt: 'Where is the Danakil Depression?',
      lat: 14.2410,
      lng: 40.3000,
    ),
    Question(
      id: 'extreme_lake_baikal',
      categoryId: 'extreme_points',
      prompt: 'Where is Lake Baikal?',
      lat: 53.5587,
      lng: 108.1650,
    ),
    Question(
      id: 'extreme_mount_everest',
      categoryId: 'extreme_points',
      prompt: 'Where is Mount Everest?',
      lat: 27.9881,
      lng: 86.9250,
    ),
    Question(
      id: 'extreme_dead_sea',
      categoryId: 'extreme_points',
      prompt: 'Where is the Dead Sea?',
      lat: 31.5590,
      lng: 35.4732,
    ),
    Question(
      id: 'volcano_etna',
      categoryId: 'volcanoes',
      prompt: 'Where is Mount Etna?',
      lat: 37.7510,
      lng: 14.9930,
    ),
    Question(
      id: 'volcano_fuji',
      categoryId: 'volcanoes',
      prompt: 'Where is Mount Fuji?',
      lat: 35.3606,
      lng: 138.7274,
    ),
    Question(
      id: 'volcano_kilauea',
      categoryId: 'volcanoes',
      prompt: 'Where is Kilauea?',
      lat: 19.4210,
      lng: -155.2870,
    ),
    Question(
      id: 'volcano_vesuvius',
      categoryId: 'volcanoes',
      prompt: 'Where is Mount Vesuvius?',
      lat: 40.8210,
      lng: 14.4260,
    ),
    Question(
      id: 'volcano_krakatoa',
      categoryId: 'volcanoes',
      prompt: 'Where is Krakatoa?',
      lat: -6.1020,
      lng: 105.4230,
    ),
    Question(
      id: 'volcano_eyjafjallajokull',
      categoryId: 'volcanoes',
      prompt: 'Where is Eyjafjallajokull?',
      lat: 63.6330,
      lng: -19.6200,
    ),
    Question(
      id: 'volcano_popocatepetl',
      categoryId: 'volcanoes',
      prompt: 'Where is Popocatepetl?',
      lat: 19.0230,
      lng: -98.6220,
    ),
    Question(
      id: 'volcano_mauna_loa',
      categoryId: 'volcanoes',
      prompt: 'Where is Mauna Loa?',
      lat: 19.4750,
      lng: -155.6080,
    ),
    Question(
      id: 'volcano_stromboli',
      categoryId: 'volcanoes',
      prompt: 'Where is Stromboli?',
      lat: 38.7890,
      lng: 15.2130,
    ),
    Question(
      id: 'volcano_kilimanjaro',
      categoryId: 'volcanoes',
      prompt: 'Where is Mount Kilimanjaro?',
      lat: -3.0674,
      lng: 37.3556,
    ),
  ];
});

// GAME STATE

class QuestionAnswer {
  QuestionAnswer({
    required this.userGuess,
    required this.distanceKm,
    required this.score,
  });

  final LatLng userGuess;
  final double distanceKm;
  final int score;
}

class GameState {
  const GameState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.userGuess,
    this.answers = const {},
  });

  final List<Question> questions;
  final int currentQuestionIndex;
  final LatLng? userGuess;
  final Map<int, QuestionAnswer> answers; // Her soru için cevap

  Question get currentQuestion => questions[currentQuestionIndex];
  LatLng get target => currentQuestion.location;
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  
  // Mevcut soru için cevap var mı?
  bool get hasAnswered => answers.containsKey(currentQuestionIndex);
  
  // Mevcut soru için cevap bilgileri
  QuestionAnswer? get currentAnswer => answers[currentQuestionIndex];
  double? get distanceKm => currentAnswer?.distanceKm;
  
  // Toplam skor
  int get totalScore {
    return answers.values.fold(0, (sum, answer) => sum + answer.score);
  }
  
  // Tüm sorular cevaplandı mı?
  bool get allQuestionsAnswered => answers.length == questions.length;

  GameState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    LatLng? userGuess,
    Map<int, QuestionAnswer>? answers,
  }) {
    return GameState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userGuess: userGuess,
      answers: answers ?? this.answers,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(List<Question> questions, {this.categoryId})
      : super(GameState(questions: questions));
  
  final String? categoryId;

  void setUserGuess(LatLng guess) {
    // Eğer bu soru daha önce cevaplandıysa, tahmini sıfırlama
    if (state.hasAnswered) {
      final newAnswers = Map<int, QuestionAnswer>.from(state.answers);
      newAnswers.remove(state.currentQuestionIndex);
      state = state.copyWith(
        userGuess: guess,
        answers: newAnswers,
      );
    } else {
      state = state.copyWith(userGuess: guess);
    }
  }

  void calculateDistance({bool? isInsidePolygon}) {
    if (state.userGuess == null) return;
    
    final currentQuestion = state.questions[state.currentQuestionIndex];
    
    // Polygon-based sorular için
    if (currentQuestion.isPolygonBased && isInsidePolygon != null) {
      final score = isInsidePolygon ? 1000 : 0; // Doğru ülke = 1000, yanlış = 0
      final newAnswers = Map<int, QuestionAnswer>.from(state.answers);
      newAnswers[state.currentQuestionIndex] = QuestionAnswer(
        userGuess: state.userGuess!,
        distanceKm: 0, // Polygon-based'de mesafe önemli değil
        score: score,
      );
      state = state.copyWith(answers: newAnswers);
      return;
    }
    
    // Normal point-based sorular için
    final distance = const Distance();
    final meters = distance(
      state.userGuess!,
      state.target,
    );

    final km = meters / 1000.0;
    final score = _calculateScore(km);
    
    // Bu soru için cevabı kaydet
    final newAnswers = Map<int, QuestionAnswer>.from(state.answers);
    newAnswers[state.currentQuestionIndex] = QuestionAnswer(
      userGuess: state.userGuess!,
      distanceKm: km,
      score: score,
    );

    state = state.copyWith(answers: newAnswers);
  }

  int _calculateScore(double km) {
    // Ülkeler kategorisi için özel skor: Ülke sınırları içinde = tam puan
    if (categoryId == 'countries') {
      if (km <= 1500) return 1000; // Ülke sınırları içinde
      if (km <= 3000) return 500;  // Yakın ülke
      if (km <= 5000) return 250;  // Aynı kıta
      return 100;
    }
    
    // Diğer kategoriler için normal skor
    if (km <= 50) return 1000;
    if (km <= 200) return 500;
    if (km <= 500) return 250;
    if (km <= 1000) return 100;
    return 0;
  }

  int calculateScore() {
    final answer = state.currentAnswer;
    if (answer == null) return 0;
    return answer.score;
  }

  void nextQuestion() {
    if (state.isLastQuestion) return;
    
    // Sonraki soruya geç, ama mevcut sorunun cevabını koru
    final nextIndex = state.currentQuestionIndex + 1;
    final nextAnswer = state.answers[nextIndex];
    
    state = state.copyWith(
      currentQuestionIndex: nextIndex,
      userGuess: nextAnswer?.userGuess, // Eğer bu soru daha önce cevaplandıysa tahmini göster
    );
  }

  void resetForNewQuestion() {
    // Yeni soruya geçerken haritayı sıfırla
    state = state.copyWith(userGuess: null);
  }

  void previousQuestion() {
    if (state.isFirstQuestion) return;
    
    // Önceki soruya geç, ama o sorunun cevabını koru
    final prevIndex = state.currentQuestionIndex - 1;
    final prevAnswer = state.answers[prevIndex];
    
    state = state.copyWith(
      currentQuestionIndex: prevIndex,
      userGuess: prevAnswer?.userGuess, // Eğer bu soru daha önce cevaplandıysa tahmini göster
    );
  }
}

// Game provider için parametre tuple'ı
typedef GameProviderParams = ({List<Question> questions, String categoryId});

final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, GameProviderParams>(
  (ref, params) => GameNotifier(params.questions, categoryId: params.categoryId),
);

// GAME SCREEN (HARİTA)

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.questions,
  });

  final String categoryId;
  final String categoryTitle;
  final List<Question> questions;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final MapController _mapController = MapController();
  
  // Helper getter for game provider params
  GameProviderParams get _gameParams => (questions: widget.questions, categoryId: widget.categoryId);

  // İki nokta arasındaki orta noktayı hesapla
  LatLng _getMidPoint(LatLng point1, LatLng point2) {
    return LatLng(
      (point1.latitude + point2.latitude) / 2,
      (point1.longitude + point2.longitude) / 2,
    );
  }

  // Pin'in alt uç noktasını hesapla (pin icon'u location_on, alt ucu biraz aşağıda)
  LatLng _getPinBottomPoint(LatLng point) {
    // location_on icon'unun alt ucu yaklaşık 0.002 derece aşağıda (zoom seviyesine göre değişir)
    return LatLng(
      point.latitude - 0.0015,
      point.longitude,
    );
  }

  // Polygon içinde nokta kontrolü (Ray Casting Algorithm)
  
  void _resetMapView() {
    // Ülkeler ve polygon-based kategorilerde haritayı resetleme - hile olmasın!
    if (widget.categoryId == 'countries' || 
        widget.categoryId == 'america' ||
        widget.categoryId == 'europe' ||
        widget.categoryId == 'asia' ||
        widget.categoryId == 'africa' ||
        widget.categoryId == 'oceania') {
      return;
    }
    
    final game = ref.read(gameProvider(_gameParams));
    _mapController.move(game.target, 4);
    _mapController.rotate(0);
  }

  void _zoomToAnswer() {
    // Ülkeler ve polygon-based kategorilerde otomatik zoom yapma - hile olmasın!
    if (widget.categoryId == 'countries' || 
        widget.categoryId == 'america' ||
        widget.categoryId == 'europe' ||
        widget.categoryId == 'asia' ||
        widget.categoryId == 'africa' ||
        widget.categoryId == 'oceania') {
      return;
    }
    
    final game = ref.read(gameProvider(_gameParams));
    // Zoom to show both user guess and correct answer
    final userPoint = game.currentAnswer?.userGuess ?? game.userGuess!;
    final bounds = LatLngBounds(userPoint, game.target);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(100)));
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider(_gameParams));

    // Haritanın başlangıç odağı: Polygon-based kategoriler için kıta merkezleri
    LatLng center;
    double initialZoom;
    
    if (widget.categoryId == 'countries') {
      center = const LatLng(20, 0); // Dünya
      initialZoom = 2.0;
    } else if (widget.categoryId == 'america') {
      center = const LatLng(0, -80); // Amerika kıtası merkezi
      initialZoom = 2.5;
    } else if (widget.categoryId == 'europe') {
      center = const LatLng(50, 15); // Avrupa merkezi
      initialZoom = 3.5;
    } else if (widget.categoryId == 'asia') {
      center = const LatLng(30, 100); // Asya merkezi
      initialZoom = 2.5;
    } else if (widget.categoryId == 'africa') {
      center = const LatLng(0, 20); // Afrika merkezi
      initialZoom = 3.0;
    } else if (widget.categoryId == 'oceania') {
      center = const LatLng(-25, 135); // Okyanusya merkezi
      initialZoom = 3.5;
    } else {
      center = game.target; // Normal sorular için hedef konum
      initialZoom = 4.0;
    }

    return Scaffold(
      body: Stack(
        children: [
          // HARİTA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: initialZoom,
              minZoom: 2,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, point) {
                HapticFeedback.selectionClick();
                if (!game.hasAnswered) {
                  ref.read(gameProvider(_gameParams).notifier).setUserGuess(point);
                }
              },
            ),
            children: [
              // Kategori bazlı harita seçimi
              TileLayer(
                urlTemplate: (widget.categoryId == 'countries' || 
                             widget.categoryId == 'capitals' || 
                             widget.categoryId == 'capitals_1' || 
                             widget.categoryId == 'capitals_2' || 
                             widget.categoryId == 'america' ||
                             widget.categoryId == 'europe' ||
                             widget.categoryId == 'asia' ||
                             widget.categoryId == 'africa' ||
                             widget.categoryId == 'oceania')
                    ? 'https://a.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png'
                    : 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geopin',
                maxZoom: 19,
                minZoom: 1,
                tileProvider: NetworkTileProvider(),
              ),
              // Polygon-based sorular için tıklanabilir ülke daireleri
              if (game.currentQuestion.isPolygonBased)
                CircleLayer(
                  circles: [
                    // Doğru ülkenin merkezi (her zaman göster)
                    CircleMarker(
                      point: game.target,
                      radius: 80,
                      color: game.hasAnswered && game.currentAnswer?.score == 1000 
                          ? Colors.green.withValues(alpha: 0.4) 
                          : Colors.blue.withValues(alpha: 0.3),
                      borderColor: game.hasAnswered && game.currentAnswer?.score == 1000 
                          ? Colors.green 
                          : Colors.blue,
                      borderStrokeWidth: 3,
                      useRadiusInMeter: false,
                    ),
                  ],
                ),
              // Kullanıcı tahmini ve gerçek hedef marker'ları (sadece point-based sorular için)
              if (!game.currentQuestion.isPolygonBased)
                MarkerLayer(
                  markers: [
                    // Kırmızı pin: Kullanıcının tahmini (henüz cevap verilmediyse userGuess, verildiyse currentAnswer'dan)
                    if (game.userGuess != null || game.currentAnswer != null)
                      Marker(
                        point: game.currentAnswer?.userGuess ?? game.userGuess!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),
                    // Yeşil pin: Doğru konum (sadece cevap verildikten sonra)
                    if (game.hasAnswered)
                      Marker(
                        point: game.target,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.greenAccent,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              // Çizgi: Kırmızı pin ile yeşil pin arası (sadece point-based sorular için)
              if (!game.currentQuestion.isPolygonBased && (game.userGuess != null || game.currentAnswer != null) && game.hasAnswered)
                PolylineLayer<Object>(
                  polylines: [
                    Polyline(
                      points: [
                        _getPinBottomPoint(game.currentAnswer?.userGuess ?? game.userGuess!),
                        _getPinBottomPoint(game.target),
                      ],
                      strokeWidth: 3,
                      color: Colors.purpleAccent.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              // Çizgi üzerine km yazısı (sadece point-based sorular için)
              if (!game.currentQuestion.isPolygonBased && (game.userGuess != null || game.currentAnswer != null) && game.hasAnswered && game.distanceKm != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _getMidPoint(
                        _getPinBottomPoint(game.currentAnswer?.userGuess ?? game.userGuess!),
                        _getPinBottomPoint(game.target),
                      ),
                      width: 80,
                      height: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${game.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // GLASSMORPHIC ÜST BAR
          SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Geri butonu
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.categoryTitle,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${AppLocalizations().get('score')}: ${game.totalScore}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              game.currentQuestion.getLocalizedPrompt(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${game.currentQuestionIndex + 1}/${game.totalQuestions}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pusula butonu - Haritayı kuzeye çevir
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.explore),
                          color: Colors.white,
                          iconSize: 24,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          tooltip: 'Reset map orientation',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _mapController.rotate(0);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ALT BAR (arka plan yok)
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!game.hasAnswered) ...[
                  if (game.userGuess == null)
                    BlinkingText(
                      text: AppLocalizations().get('tap_map_to_select'),
                      color: Colors.green,
                      fontSize: 18.0,
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final currentQuestion = game.currentQuestion;
                        
                        // Polygon-based sorular için direkt daire kontrolü
                        if (currentQuestion.isPolygonBased && game.userGuess != null) {
                          // Kullanıcının tıkladığı nokta doğru daireyi hedefliyor mu?
                          final distance = const Distance();
                          final meters = distance(game.userGuess!, game.target);
                          final km = meters / 1000.0;
                          // Sadece dairenin tam merkezine yakın tıklama (50km içinde)
                          final isCorrect = km <= 50;
                          ref
                              .read(gameProvider(_gameParams).notifier)
                              .calculateDistance(isInsidePolygon: isCorrect);
                        } else {
                          // Normal point-based sorular için
                          ref
                              .read(gameProvider(_gameParams).notifier)
                              .calculateDistance();
                        }
                        
                        _showResultDialog(context, ref);
                      },
                      child: Text(
                        AppLocalizations().get('guess'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ] else ...[
                  Row(
                    children: [
                      if (!game.isFirstQuestion)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(gameProvider(_gameParams).notifier)
                                  .previousQuestion();
                              // Reset map view when going to previous question
                              _resetMapView();
                            },
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: Text(AppLocalizations().get('previous')),
                          ),
                        ),
                      if (!game.isFirstQuestion) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (game.isLastQuestion) {
                              // Tüm sorular bitince sonuç ekranını göster
                              if (game.allQuestionsAnswered) {
                                _showFinalResults(context, ref);
                              } else {
                                Navigator.of(context).pop();
                              }
                            } else {
                              ref
                                  .read(gameProvider(_gameParams).notifier)
                                  .nextQuestion();
                              // Reset map view for next question
                              _resetMapView();
                            }
                          },
                          child: Text(
                            game.isLastQuestion ? AppLocalizations().get('close') : AppLocalizations().get('continue'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, WidgetRef ref) {
    final game = ref.read(gameProvider(_gameParams));
    final km = game.distanceKm ?? 0;
    final score = ref.read(gameProvider(_gameParams).notifier).calculateScore();

    // Auto-zoom to answer location
    _zoomToAnswer();

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations().get('result'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${km.toStringAsFixed(1)} ${AppLocalizations().get('km_away')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppLocalizations().get('your_score')} $score',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations().get('green_pin_shows_correct'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations().get('close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinalResults(BuildContext context, WidgetRef ref) {
    final game = ref.read(gameProvider(_gameParams));
    final totalScore = game.totalScore;
    final totalQuestions = game.totalQuestions;
    final maxPossibleScore = totalQuestions * 1000;
    final percentage = (totalScore / maxPossibleScore * 100).round();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade800,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations().get('game_completed'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                  Text(
                    widget.categoryTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations().get('total_score'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalScore',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$percentage% ' + AppLocalizations().get('success'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.quiz,
                        label: AppLocalizations().get('questions'),
                        value: '$totalQuestions',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.star,
                        label: AppLocalizations().get('average'),
                        value: (totalScore / totalQuestions).round().toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(); // Dialog'u kapat
                      Navigator.of(context).pop(); // GameScreen'den çık
                    },
                    child: Text(
                      AppLocalizations().get('back_to_main_menu'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
