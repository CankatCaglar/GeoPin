import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
  });

  final String id;
  final String categoryId;
  final String prompt;
  final double lat;
  final double lng;

  LatLng get location => LatLng(lat, lng);
}

// SABİT KATEGORİLER (ileride JSON'dan okunacak)
final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(
      id: 'tourist_places',
      title: 'Tourist Places',
      icon: Icons.travel_explore,
      isLocked: false,
      backgroundImage: 'assets/images/tourist_places.jpg',
    ),
    Category(
      id: 'countries',
      title: 'Countries',
      icon: Icons.map,
      isLocked: false,
      backgroundImage: 'assets/images/countries.jpg',
    ),
    Category(
      id: 'capitals',
      title: 'Capitals',
      icon: Icons.location_on,
      isLocked: false,
      backgroundImage: 'assets/images/capitals.jpg',
    ),
    Category(
      id: 'cities',
      title: 'Cities',
      icon: Icons.apartment,
      isLocked: false,
      backgroundImage: 'assets/images/cities.jpg',
    ),
    Category(
      id: 'stadiums',
      title: 'Football Stadiums',
      icon: Icons.sports_soccer,
      isLocked: true,
      backgroundImage: 'assets/images/stadiums.jpg',
    ),
    Category(
      id: 'monuments',
      title: 'Historical Monuments',
      icon: Icons.account_balance,
      isLocked: true,
      backgroundImage: 'assets/images/monuments.jpg',
    ),
    Category(
      id: 'movies',
      title: 'Movie Locations',
      icon: Icons.movie,
      isLocked: true,
      backgroundImage: 'assets/images/movies.jpg',
    ),
    Category(
      id: 'resorts',
      title: 'Holiday Resorts',
      icon: Icons.beach_access,
      isLocked: true,
      backgroundImage: 'assets/images/resorts.jpg',
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
                      // Logo Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 60,
                          color: Colors.white,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    category.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
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

  void calculateDistance() {
    if (state.userGuess == null) return;
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

  void _resetMapView() {
    // Ülkeler kategorisinde haritayı resetleme - hile olmasın!
    if (widget.categoryId == 'countries') {
      return;
    }
    
    final game = ref.read(gameProvider(_gameParams));
    _mapController.move(game.target, 4);
    _mapController.rotate(0);
  }

  void _zoomToAnswer() {
    // Ülkeler kategorisinde otomatik zoom yapma - hile olmasın!
    if (widget.categoryId == 'countries') {
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

    // Haritanın başlangıç odağı: Ülkeler için dünya haritası, diğerleri için soru konumu
    final center = widget.categoryId == 'countries' 
        ? const LatLng(20, 0) // Dünyanın ortası
        : game.target;
    final initialZoom = widget.categoryId == 'countries' ? 2.0 : 4.0;

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
                urlTemplate: (widget.categoryId == 'countries' || widget.categoryId == 'capitals')
                    ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.geo_quiz_master',
              ),
              // Kullanıcı tahmini ve gerçek hedef marker'ları
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
              // Çizgi: Kırmızı pin ile yeşil pin arası (pinlerin alt uçlarından birleşiyor)
              if ((game.userGuess != null || game.currentAnswer != null) && game.hasAnswered)
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
              // Çizgi üzerine km yazısı (siyah yazı, arka plan yok)
              if ((game.userGuess != null || game.currentAnswer != null) && game.hasAnswered && game.distanceKm != null)
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
                        ref
                            .read(gameProvider(_gameParams).notifier)
                            .calculateDistance();
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
                      child: _StatCard(
                        icon: Icons.quiz,
                        label: 'Questions',
                        value: '$totalQuestions',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// BLINKING TEXT WIDGET
class BlinkingText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;

  const BlinkingText({
    super.key,
    required this.text,
    required this.color,
    required this.fontSize,
  });

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Normal blinking speed
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true); // Smooth blinking
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.color,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}


