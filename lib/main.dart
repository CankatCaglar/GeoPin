import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'stat_card.dart';
import 'america_button_game.dart';

void main() {
  runApp(const ProviderScope(child: GeoPinApp()));
}

class GeoPinApp extends StatelessWidget {
  const GeoPinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoPin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro',
      ),
      home: const SplashScreen(),
    );
  }
}

// MODELS

class Category {
  Category({
    required this.id,
    required this.title,
    required this.icon,
    required this.isLocked,
    this.backgroundImage,
  });

  final String id;
  final String title;
  final IconData icon;
  final bool isLocked;
  final String? backgroundImage;
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
  final String prompt;
  final double lat;
  final double lng;
  final List<LatLng>? polygon; // Ülke sınırları için polygon koordinatları
  final bool isPolygonBased; // Polygon tabanlı soru mu?

  LatLng get location => LatLng(lat, lng);
}

// SABİT KATEGORİLER (ileride JSON'dan okunacak)
final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    // 1) Tourist Places
    Category(
      id: 'tourist_places',
      title: 'Tourist Places',
      icon: Icons.travel_explore,
      isLocked: false,
      backgroundImage: 'assets/images/tourist_places.jpg',
    ),
    // 2) Countries
    Category(
      id: 'countries',
      title: 'Countries',
      icon: Icons.map,
      isLocked: false,
      backgroundImage: 'assets/images/countries.jpg',
    ),
    // 3) Capitals
    Category(
      id: 'capitals',
      title: 'Capitals',
      icon: Icons.location_on,
      isLocked: false,
      backgroundImage: 'assets/images/capitals.jpg',
    ),
    // 4) Historical Landmarks (eski Historical Monuments, kilitsiz)
    Category(
      id: 'monuments',
      title: 'Historical Landmarks',
      icon: Icons.account_balance,
      isLocked: false,
      backgroundImage: 'assets/images/monuments.jpg',
    ),
    // 5) America
    Category(
      id: 'america',
      title: 'America',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/america.jpg',
    ),
    // 6) Europe
    Category(
      id: 'europe',
      title: 'Europe',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/europe.jpg',
    ),
    // 7) Asia
    Category(
      id: 'asia',
      title: 'Asia',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/asia.jpg',
    ),
    // 8) Africa
    Category(
      id: 'africa',
      title: 'Africa',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/africa.jpg',
    ),
    // 9) Oceania
    Category(
      id: 'oceania',
      title: 'Oceania',
      icon: Icons.public,
      isLocked: false,
      backgroundImage: 'assets/images/oceania.jpg',
    ),
    // 10) US States (buradan sonrası premium)
    Category(
      id: 'us_states',
      title: 'US States',
      icon: Icons.flag,
      isLocked: true,
      backgroundImage: 'assets/images/us_states.jpg',
    ),
    // 11) Natural Wonders
    Category(
      id: 'natural_wonders',
      title: 'Natural Wonders',
      icon: Icons.landscape,
      isLocked: true,
      backgroundImage: 'assets/images/natural_wonders.jpg',
    ),
    // 12) Football Stadiums (mevcut stadiums kategorisi)
    Category(
      id: 'stadiums',
      title: 'Football Stadiums',
      icon: Icons.sports_soccer,
      isLocked: true,
      backgroundImage: 'assets/images/stadiums.jpg',
    ),
    // 13) Famous Airports
    Category(
      id: 'airports',
      title: 'Famous Airports',
      icon: Icons.flight_takeoff,
      isLocked: true,
      backgroundImage: 'assets/images/airports.jpg',
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
    Future.delayed(const Duration(seconds: 2), () {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: Center(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/app_icon.png', // Yeni ana ikon görselin
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // App Name
                      const Text(
                        'GeoPin',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      Text(
                        'Test Your Geography Knowledge',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoPin'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(category: category);
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = category.isLocked;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (isLocked) {
          _showPaywall(context, category);
        } else {
          // America kategorisi için özel butonlu harita ekranını aç
          if (category.id == 'america') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AmericaButtonGameScreen(),
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
          image: category.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(category.backgroundImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (isLocked)
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
                        if (category.id != 'monuments') ...[
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
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context, Category category) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text(
                    'Unlock all maps with Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${category.title}" category is included in PRO package. Get Premium to access all locked categories.',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.tealAccent.shade400,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // TODO: Satın alma entegrasyonu.
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Purchase flow not yet added.'),
                    ),
                  );
                },
                child: const Text(
                  'Get Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
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
      categoryId: 'tourist_places',
      prompt: 'Where is the Statue of Liberty?',
      lat: 40.6892,
      lng: -74.0445,
    ),
    Question(
      id: 'eiffel',
      categoryId: 'tourist_places',
      prompt: 'Where is the Eiffel Tower?',
      lat: 48.8584,
      lng: 2.2945,
    ),
    Question(
      id: 'colosseum',
      categoryId: 'tourist_places',
      prompt: 'Where is the Colosseum?',
      lat: 41.8902,
      lng: 12.4922,
    ),
    Question(
      id: 'bigben',
      categoryId: 'tourist_places',
      prompt: 'Where is Big Ben?',
      lat: 51.4994,
      lng: -0.1245,
    ),
    Question(
      id: 'sydney_opera',
      categoryId: 'tourist_places',
      prompt: 'Where is the Sydney Opera House?',
      lat: -33.8568,
      lng: 151.2153,
    ),
    Question(
      id: 'taj_mahal',
      categoryId: 'tourist_places',
      prompt: 'Where is the Taj Mahal?',
      lat: 27.1751,
      lng: 78.0421,
    ),
    Question(
      id: 'great_wall',
      categoryId: 'tourist_places',
      prompt: 'Where is the Great Wall of China?',
      lat: 40.4319,
      lng: 116.5704,
    ),
    Question(
      id: 'golden_gate',
      categoryId: 'tourist_places',
      prompt: 'Where is the Golden Gate Bridge?',
      lat: 37.8199,
      lng: -122.4783,
    ),
    Question(
      id: 'christ_redeemer',
      categoryId: 'tourist_places',
      prompt: 'Where is Christ the Redeemer?',
      lat: -22.9519,
      lng: -43.2105,
    ),
    Question(
      id: 'burj_khalifa',
      categoryId: 'tourist_places',
      prompt: 'Where is Burj Khalifa?',
      lat: 25.1972,
      lng: 55.2744,
    ),
    Question(
      id: 'louvre',
      categoryId: 'tourist_places',
      prompt: 'Where is the Louvre Museum?',
      lat: 48.8606,
      lng: 2.3376,
    ),
    Question(
      id: 'stonehenge',
      categoryId: 'tourist_places',
      prompt: 'Where is Stonehenge?',
      lat: 51.1789,
      lng: -1.8262,
    ),
    Question(
      id: 'notre_dame',
      categoryId: 'tourist_places',
      prompt: 'Where is Notre Dame Cathedral?',
      lat: 48.8530,
      lng: 2.3499,
    ),
    Question(
      id: 'versailles',
      categoryId: 'tourist_places',
      prompt: 'Where is the Palace of Versailles?',
      lat: 48.8049,
      lng: 2.1204,
    ),
    Question(
      id: 'acropolis',
      categoryId: 'tourist_places',
      prompt: 'Where is the Acropolis?',
      lat: 37.9715,
      lng: 23.7267,
    ),
    
    // MEDIUM - Well-known but might require some thought
    Question(
      id: 'sagrada_familia',
      categoryId: 'tourist_places',
      prompt: 'Where is La Sagrada Familia?',
      lat: 41.4036,
      lng: 2.1744,
    ),
    Question(
      id: 'neuschwanstein',
      categoryId: 'tourist_places',
      prompt: 'Where is Neuschwanstein Castle?',
      lat: 47.5576,
      lng: 10.7498,
    ),
    Question(
      id: 'brandenburg_gate',
      categoryId: 'tourist_places',
      prompt: 'Where is Brandenburg Gate?',
      lat: 52.5163,
      lng: 13.3777,
    ),
    Question(
      id: 'saint_pauls',
      categoryId: 'tourist_places',
      prompt: 'Where is St. Paul\'s Cathedral?',
      lat: 51.5138,
      lng: -0.0984,
    ),
    Question(
      id: 'windmills',
      categoryId: 'tourist_places',
      prompt: 'Where are the Amsterdam Windmills?',
      lat: 52.3740,
      lng: 4.8897,
    ),
    Question(
      id: 'petra',
      categoryId: 'tourist_places',
      prompt: 'Where is Petra?',
      lat: 30.3285,
      lng: 35.4444,
    ),
    Question(
      id: 'angkor_wat',
      categoryId: 'tourist_places',
      prompt: 'Where is Angkor Wat?',
      lat: 13.4125,
      lng: 103.8670,
    ),
    Question(
      id: 'chichen_itza',
      categoryId: 'tourist_places',
      prompt: 'Where is Chichen Itza?',
      lat: 20.6843,
      lng: -88.5678,
    ),
    Question(
      id: 'niagara_falls',
      categoryId: 'tourist_places',
      prompt: 'Where are Niagara Falls?',
      lat: 43.0962,
      lng: -79.0377,
    ),
    Question(
      id: 'grand_canyon',
      categoryId: 'tourist_places',
      prompt: 'Where is the Grand Canyon?',
      lat: 36.1069,
      lng: -112.1129,
    ),
    Question(
      id: 'mount_rushmore',
      categoryId: 'tourist_places',
      prompt: 'Where is Mount Rushmore?',
      lat: 43.8791,
      lng: -103.4591,
    ),
    Question(
      id: 'times_square',
      categoryId: 'tourist_places',
      prompt: 'Where is Times Square?',
      lat: 40.7580,
      lng: -73.9855,
    ),
    Question(
      id: 'central_park',
      categoryId: 'tourist_places',
      prompt: 'Where is Central Park?',
      lat: 40.7829,
      lng: -73.9654,
    ),
    Question(
      id: 'empire_state',
      categoryId: 'tourist_places',
      prompt: 'Where is the Empire State Building?',
      lat: 40.7484,
      lng: -73.9857,
    ),
    Question(
      id: 'disneyland',
      categoryId: 'tourist_places',
      prompt: 'Where is Disneyland?',
      lat: 33.8121,
      lng: -117.9190,
    ),
    Question(
      id: 'yosemite',
      categoryId: 'tourist_places',
      prompt: 'Where is Yosemite National Park?',
      lat: 37.8651,
      lng: -119.5383,
    ),
    
    // HARD - More challenging locations
    Question(
      id: 'machu_picchu',
      categoryId: 'tourist_places',
      prompt: 'Where is Machu Picchu?',
      lat: -13.1631,
      lng: -72.5450,
    ),
    Question(
      id: 'yellowstone',
      categoryId: 'tourist_places',
      prompt: 'Where is Yellowstone National Park?',
      lat: 44.4280,
      lng: -110.5885,
    ),
    Question(
      id: 'liberty_bell',
      categoryId: 'tourist_places',
      prompt: 'Where is the Liberty Bell?',
      lat: 39.9496,
      lng: -75.1503,
    ),
    Question(
      id: 'space_needle',
      categoryId: 'tourist_places',
      prompt: 'Where is the Space Needle?',
      lat: 47.6205,
      lng: -122.3493,
    ),
    Question(
      id: 'hoover_dam',
      categoryId: 'tourist_places',
      prompt: 'Where is the Hoover Dam?',
      lat: 36.0161,
      lng: -114.7377,
    ),
    Question(
      id: 'miami_beach',
      categoryId: 'tourist_places',
      prompt: 'Where is Miami Beach?',
      lat: 25.7907,
      lng: -80.1300,
    ),
    Question(
      id: 'las_vegas',
      categoryId: 'tourist_places',
      prompt: 'Where is the Las Vegas Strip?',
      lat: 36.1147,
      lng: -115.1728,
    ),
    Question(
      id: 'hollywood_sign',
      categoryId: 'tourist_places',
      prompt: 'Where is the Hollywood Sign?',
      lat: 34.1341,
      lng: -118.3215,
    ),
    Question(
      id: 'colosseum_mexico',
      categoryId: 'tourist_places',
      prompt: 'Where is the Colosseum in Mexico City?',
      lat: 19.4326,
      lng: -99.1332,
    ),

    // --- COUNTRIES ---
    // EASY - Large, distinct, or famous countries
    Question(
      id: 'france',
      categoryId: 'countries',
      prompt: 'Where is France?',
      lat: 46.2276,
      lng: 2.2137,
    ),
    Question(
      id: 'usa',
      categoryId: 'countries',
      prompt: 'Where is the United States?',
      lat: 37.0902,
      lng: -95.7129,
    ),
    Question(
      id: 'china',
      categoryId: 'countries',
      prompt: 'Where is China?',
      lat: 35.8617,
      lng: 104.1954,
    ),
    Question(
      id: 'brazil',
      categoryId: 'countries',
      prompt: 'Where is Brazil?',
      lat: -14.2350,
      lng: -51.9253,
    ),
    Question(
      id: 'australia',
      categoryId: 'countries',
      prompt: 'Where is Australia?',
      lat: -25.2744,
      lng: 133.7751,
    ),
    Question(
      id: 'india',
      categoryId: 'countries',
      prompt: 'Where is India?',
      lat: 20.5937,
      lng: 78.9629,
    ),
    Question(
      id: 'russia',
      categoryId: 'countries',
      prompt: 'Where is Russia?',
      lat: 61.5240,
      lng: 105.3188,
    ),
    Question(
      id: 'italy',
      categoryId: 'countries',
      prompt: 'Where is Italy?',
      lat: 41.8719,
      lng: 12.5674,
    ),
    Question(
      id: 'united_kingdom',
      categoryId: 'countries',
      prompt: 'Where is the United Kingdom?',
      lat: 55.3781,
      lng: -3.4360,
    ),
    Question(
      id: 'germany',
      categoryId: 'countries',
      prompt: 'Where is Germany?',
      lat: 51.1657,
      lng: 10.4515,
    ),
    Question(
      id: 'japan',
      categoryId: 'countries',
      prompt: 'Where is Japan?',
      lat: 36.2048,
      lng: 138.2529,
    ),
    Question(
      id: 'canada',
      categoryId: 'countries',
      prompt: 'Where is Canada?',
      lat: 56.1304,
      lng: -106.3468,
    ),
    Question(
      id: 'mexico',
      categoryId: 'countries',
      prompt: 'Where is Mexico?',
      lat: 23.6345,
      lng: -102.5528,
    ),
    Question(
      id: 'egypt',
      categoryId: 'countries',
      prompt: 'Where is Egypt?',
      lat: 26.8206,
      lng: 30.8025,
    ),
    Question(
      id: 'spain',
      categoryId: 'countries',
      prompt: 'Where is Spain?',
      lat: 40.4637,
      lng: -3.7492,
    ),

    // MEDIUM - Moderately difficult countries
    Question(
      id: 'turkey',
      categoryId: 'countries',
      prompt: 'Where is Turkey?',
      lat: 38.9637,
      lng: 35.2433,
    ),
    Question(
      id: 'argentina',
      categoryId: 'countries',
      prompt: 'Where is Argentina?',
      lat: -38.4161,
      lng: -63.6167,
    ),
    Question(
      id: 'saudi_arabia',
      categoryId: 'countries',
      prompt: 'Where is Saudi Arabia?',
      lat: 23.8859,
      lng: 45.0792,
    ),
    Question(
      id: 'south_africa',
      categoryId: 'countries',
      prompt: 'Where is South Africa?',
      lat: -30.5595,
      lng: 22.9375,
    ),
    Question(
      id: 'indonesia',
      categoryId: 'countries',
      prompt: 'Where is Indonesia?',
      lat: -0.7893,
      lng: 113.9213,
    ),
    Question(
      id: 'iran',
      categoryId: 'countries',
      prompt: 'Where is Iran?',
      lat: 32.4279,
      lng: 53.6880,
    ),
    Question(
      id: 'ukraine',
      categoryId: 'countries',
      prompt: 'Where is Ukraine?',
      lat: 48.3794,
      lng: 31.1656,
    ),
    Question(
      id: 'thailand',
      categoryId: 'countries',
      prompt: 'Where is Thailand?',
      lat: 15.8700,
      lng: 100.9925,
    ),
    Question(
      id: 'poland',
      categoryId: 'countries',
      prompt: 'Where is Poland?',
      lat: 51.9194,
      lng: 19.1451,
    ),
    Question(
      id: 'colombia',
      categoryId: 'countries',
      prompt: 'Where is Colombia?',
      lat: 4.5709,
      lng: -74.2973,
    ),
    Question(
      id: 'sweden',
      categoryId: 'countries',
      prompt: 'Where is Sweden?',
      lat: 60.1282,
      lng: 18.6435,
    ),
    Question(
      id: 'norway',
      categoryId: 'countries',
      prompt: 'Where is Norway?',
      lat: 60.4720,
      lng: 8.4689,
    ),
    Question(
      id: 'pakistan',
      categoryId: 'countries',
      prompt: 'Where is Pakistan?',
      lat: 30.3753,
      lng: 69.3451,
    ),
    Question(
      id: 'peru',
      categoryId: 'countries',
      prompt: 'Where is Peru?',
      lat: -9.1900,
      lng: -75.0152,
    ),
    Question(
      id: 'vietnam',
      categoryId: 'countries',
      prompt: 'Where is Vietnam?',
      lat: 14.0583,
      lng: 108.2772,
    ),

    // HARD - Smaller or less obvious countries
    Question(
      id: 'greece',
      categoryId: 'countries',
      prompt: 'Where is Greece?',
      lat: 39.0742,
      lng: 21.8243,
    ),
    Question(
      id: 'portugal',
      categoryId: 'countries',
      prompt: 'Where is Portugal?',
      lat: 39.3999,
      lng: -8.2245,
    ),
    Question(
      id: 'chile',
      categoryId: 'countries',
      prompt: 'Where is Chile?',
      lat: -35.6751,
      lng: -71.5430,
    ),
    Question(
      id: 'new_zealand',
      categoryId: 'countries',
      prompt: 'Where is New Zealand?',
      lat: -40.9006,
      lng: 174.8860,
    ),
    Question(
      id: 'iceland',
      categoryId: 'countries',
      prompt: 'Where is Iceland?',
      lat: 64.9631,
      lng: -19.0208,
    ),
    Question(
      id: 'madagascar',
      categoryId: 'countries',
      prompt: 'Where is Madagascar?',
      lat: -18.7669,
      lng: 46.8691,
    ),
    Question(
      id: 'morocco',
      categoryId: 'countries',
      prompt: 'Where is Morocco?',
      lat: 31.7917,
      lng: -7.0926,
    ),
    Question(
      id: 'switzerland',
      categoryId: 'countries',
      prompt: 'Where is Switzerland?',
      lat: 46.8182,
      lng: 8.2275,
    ),
    Question(
      id: 'cuba',
      categoryId: 'countries',
      prompt: 'Where is Cuba?',
      lat: 21.5218,
      lng: -77.7812,
    ),
    Question(
      id: 'north_korea',
      categoryId: 'countries',
      prompt: 'Where is North Korea?',
      lat: 40.3399,
      lng: 127.5101,
    ),

    // --- CAPITALS ---
    // EASY - Very famous capitals everyone knows
    Question(
      id: 'paris',
      categoryId: 'capitals',
      prompt: 'Where is Paris?',
      lat: 48.8566,
      lng: 2.3522,
    ),
    Question(
      id: 'london',
      categoryId: 'capitals',
      prompt: 'Where is London?',
      lat: 51.5074,
      lng: -0.1278,
    ),
    Question(
      id: 'washington',
      categoryId: 'capitals',
      prompt: 'Where is Washington D.C.?',
      lat: 38.9072,
      lng: -77.0369,
    ),
    Question(
      id: 'tokyo',
      categoryId: 'capitals',
      prompt: 'Where is Tokyo?',
      lat: 35.6762,
      lng: 139.6503,
    ),
    Question(
      id: 'moscow',
      categoryId: 'capitals',
      prompt: 'Where is Moscow?',
      lat: 55.7558,
      lng: 37.6173,
    ),
    Question(
      id: 'beijing',
      categoryId: 'capitals',
      prompt: 'Where is Beijing?',
      lat: 39.9042,
      lng: 116.4074,
    ),
    Question(
      id: 'rome',
      categoryId: 'capitals',
      prompt: 'Where is Rome?',
      lat: 41.9028,
      lng: 12.4964,
    ),
    Question(
      id: 'berlin',
      categoryId: 'capitals',
      prompt: 'Where is Berlin?',
      lat: 52.5200,
      lng: 13.4050,
    ),
    Question(
      id: 'madrid',
      categoryId: 'capitals',
      prompt: 'Where is Madrid?',
      lat: 40.4168,
      lng: -3.7038,
    ),
    Question(
      id: 'cairo',
      categoryId: 'capitals',
      prompt: 'Where is Cairo?',
      lat: 30.0444,
      lng: 31.2357,
    ),

    // MEDIUM - Well-known capitals
    Question(
      id: 'ankara',
      categoryId: 'capitals',
      prompt: 'Where is Ankara?',
      lat: 39.9334,
      lng: 32.8597,
    ),
    Question(
      id: 'vienna',
      categoryId: 'capitals',
      prompt: 'Where is Vienna?',
      lat: 48.2082,
      lng: 16.3738,
    ),
    Question(
      id: 'athens',
      categoryId: 'capitals',
      prompt: 'Where is Athens?',
      lat: 37.9838,
      lng: 23.7275,
    ),
    Question(
      id: 'stockholm',
      categoryId: 'capitals',
      prompt: 'Where is Stockholm?',
      lat: 59.3293,
      lng: 18.0686,
    ),
    Question(
      id: 'oslo',
      categoryId: 'capitals',
      prompt: 'Where is Oslo?',
      lat: 59.9139,
      lng: 10.7522,
    ),
    Question(
      id: 'copenhagen',
      categoryId: 'capitals',
      prompt: 'Where is Copenhagen?',
      lat: 55.6761,
      lng: 12.5683,
    ),
    Question(
      id: 'warsaw',
      categoryId: 'capitals',
      prompt: 'Where is Warsaw?',
      lat: 52.2297,
      lng: 21.0122,
    ),
    Question(
      id: 'prague',
      categoryId: 'capitals',
      prompt: 'Where is Prague?',
      lat: 50.0755,
      lng: 14.4378,
    ),
    Question(
      id: 'budapest',
      categoryId: 'capitals',
      prompt: 'Where is Budapest?',
      lat: 47.4979,
      lng: 19.0402,
    ),
    Question(
      id: 'lisbon',
      categoryId: 'capitals',
      prompt: 'Where is Lisbon?',
      lat: 38.7223,
      lng: -9.1393,
    ),
    Question(
      id: 'dublin',
      categoryId: 'capitals',
      prompt: 'Where is Dublin?',
      lat: 53.3498,
      lng: -6.2603,
    ),
    Question(
      id: 'brussels',
      categoryId: 'capitals',
      prompt: 'Where is Brussels?',
      lat: 50.8503,
      lng: 4.3517,
    ),
    Question(
      id: 'amsterdam',
      categoryId: 'capitals',
      prompt: 'Where is Amsterdam?',
      lat: 52.3676,
      lng: 4.9041,
    ),
    Question(
      id: 'canberra',
      categoryId: 'capitals',
      prompt: 'Where is Canberra?',
      lat: -35.2809,
      lng: 149.1300,
    ),
    Question(
      id: 'wellington',
      categoryId: 'capitals',
      prompt: 'Where is Wellington?',
      lat: -41.2865,
      lng: 174.7762,
    ),

    // HARD - Lesser-known capitals
    Question(
      id: 'brasilia',
      categoryId: 'capitals',
      prompt: 'Where is Brasília?',
      lat: -15.8267,
      lng: -47.9218,
    ),
    Question(
      id: 'ottawa',
      categoryId: 'capitals',
      prompt: 'Where is Ottawa?',
      lat: 45.4215,
      lng: -75.6972,
    ),
    Question(
      id: 'bern',
      categoryId: 'capitals',
      prompt: 'Where is Bern?',
      lat: 46.9480,
      lng: 7.4474,
    ),
    Question(
      id: 'nairobi',
      categoryId: 'capitals',
      prompt: 'Where is Nairobi?',
      lat: -1.2864,
      lng: 36.8172,
    ),
    Question(
      id: 'hanoi',
      categoryId: 'capitals',
      prompt: 'Where is Hanoi?',
      lat: 21.0285,
      lng: 105.8542,
    ),
    Question(
      id: 'manila',
      categoryId: 'capitals',
      prompt: 'Where is Manila?',
      lat: 14.5995,
      lng: 120.9842,
    ),
    Question(
      id: 'santiago',
      categoryId: 'capitals',
      prompt: 'Where is Santiago?',
      lat: -33.4489,
      lng: -70.6693,
    ),
    Question(
      id: 'lima',
      categoryId: 'capitals',
      prompt: 'Where is Lima?',
      lat: -12.0464,
      lng: -77.0428,
    ),
    Question(
      id: 'bogota',
      categoryId: 'capitals',
      prompt: 'Where is Bogotá?',
      lat: 4.7110,
      lng: -74.0721,
    ),
    Question(
      id: 'riyadh',
      categoryId: 'capitals',
      prompt: 'Where is Riyadh?',
      lat: 24.7136,
      lng: 46.6753,
    ),
    Question(
      id: 'tehran',
      categoryId: 'capitals',
      prompt: 'Where is Tehran?',
      lat: 35.6892,
      lng: 51.3890,
    ),
    Question(
      id: 'islamabad',
      categoryId: 'capitals',
      prompt: 'Where is Islamabad?',
      lat: 33.6844,
      lng: 73.0479,
    ),
    Question(
      id: 'kathmandu',
      categoryId: 'capitals',
      prompt: 'Where is Kathmandu?',
      lat: 27.7172,
      lng: 85.3240,
    ),
    Question(
      id: 'addis_ababa',
      categoryId: 'capitals',
      prompt: 'Where is Addis Ababa?',
      lat: 9.0320,
      lng: 38.7469,
    ),
    Question(
      id: 'kampala',
      categoryId: 'capitals',
      prompt: 'Where is Kampala?',
      lat: 0.3476,
      lng: 32.5825,
    ),
  
    // --- HISTORICAL LANDMARKS ---
    // 20 easy but different landmarks (no overlap with Tourist Places)
    Question(
      id: 'blue_mosque',
      categoryId: 'monuments',
      prompt: 'Where is the Blue Mosque (Sultan Ahmed Mosque)?',
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
      prompt: 'Where are the Kremlin and Red Square?',
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
      prompt: 'Where is the CN Tower?',
      lat: 43.6426,
      lng: -79.3871,
    ),
    Question(
      id: 'gateway_arch',
      categoryId: 'monuments',
      prompt: 'Where is the Gateway Arch?',
      lat: 38.6247,
      lng: -90.1848,
    ),
    Question(
      id: 'uluru',
      categoryId: 'monuments',
      prompt: 'Where is Uluru (Ayers Rock)?',
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
      prompt: 'Where is the Matterhorn?',
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
      prompt: 'Where is the Blue Lagoon in Iceland?',
      lat: 63.8804,
      lng: -22.4495,
    ),
    Question(
      id: 'alhambra',
      categoryId: 'monuments',
      prompt: 'Where is the Alhambra?',
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
      prompt: 'Where is the Leaning Tower of Pisa?',
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
      prompt: 'Where are the Moai statues on Easter Island?',
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
      prompt: 'Where is the United States?',
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
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng vertex1 = polygon[i];
      LatLng vertex2 = polygon[(i + 1) % polygon.length];

      if (_rayCastIntersect(point, vertex1, vertex2)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // Tek sayıda kesişim = içeride
  }

  bool _rayCastIntersect(LatLng point, LatLng vertexA, LatLng vertexB) {
    double px = point.longitude;
    double py = point.latitude;
    double ax = vertexA.longitude;
    double ay = vertexA.latitude;
    double bx = vertexB.longitude;
    double by = vertexB.latitude;

    if (ay > by) {
      ax = vertexB.longitude;
      ay = vertexB.latitude;
      bx = vertexA.longitude;
      by = vertexA.latitude;
    }

    if (py == ay || py == by) py += 0.00000001;
    if ((py > by || py < ay) || (px > (ax > bx ? ax : bx))) return false;
    if (px < (ax < bx ? ax : bx)) return true;

    double red = (py - ay) / (by - ay);
    double blue = (px - ax) / (bx - ax);
    return blue >= red;
  }

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
                          ? Colors.green.withOpacity(0.4) 
                          : Colors.blue.withOpacity(0.3),
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
                      color: Colors.purpleAccent.withOpacity(0.8),
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
                          color: Colors.white.withOpacity(0.9),
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
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.categoryTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
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
                          'Score: ${game.totalScore}',
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
                              game.currentQuestion.prompt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                          color: Colors.white.withOpacity(0.15),
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
                      text: 'Tap on the map to select your guess point.',
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
                      child: const Text(
                        'Guess',
                        style: TextStyle(
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
                              ref
                                  .read(gameProvider(_gameParams).notifier)
                                  .previousQuestion();
                              // Reset map view when going to previous question
                              _resetMapView();
                            },
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Previous'),
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
                            game.isLastQuestion ? 'Complete' : 'Continue',
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

    showDialog<void>(      context: context,
      barrierColor: Colors.black.withOpacity(0.42),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.42),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Result',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${km.toStringAsFixed(1)} km away!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your score: $score',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Green pin shows the correct location, red pin shows your guess.',
                  style: TextStyle(
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
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
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
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Game Completed!',
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
                      const Text(
                        'Total Score',
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
                        '$percentage% success',
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
                        label: 'Questions',
                        value: '$totalQuestions',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.star,
                        label: 'Average',
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
                      Navigator.of(context).pop(); // Dialog'u kapat
                      Navigator.of(context).pop(); // GameScreen'den çık
                    },
                    child: const Text(
                      'Back to Main Menu',
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
