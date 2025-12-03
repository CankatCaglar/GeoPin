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
  });

  final String id;
  final String title;
  final IconData icon;
  final bool isLocked;
}

class Question {
  Question({
    required this.id,
    required this.prompt,
    required this.lat,
    required this.lng,
  });

  final String id;
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
    ),
    Category(
      id: 'capitals',
      title: 'Capitals',
      icon: Icons.location_city,
      isLocked: false,
    ),
    Category(
      id: 'stadiums',
      title: 'Football Stadiums',
      icon: Icons.sports_soccer,
      isLocked: true,
    ),
    Category(
      id: 'monuments',
      title: 'Historical Monuments',
      icon: Icons.account_balance,
      isLocked: true,
    ),
    Category(
      id: 'movies',
      title: 'Movie Locations',
      icon: Icons.movie,
      isLocked: true,
    ),
    Category(
      id: 'resorts',
      title: 'Holiday Resorts',
      icon: Icons.beach_access,
      isLocked: true,
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
      duration: const Duration(milliseconds: 2000),
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

    // Navigate to main screen after 0.5 seconds
    Future.delayed(const Duration(seconds: 1), () {
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GameScreen(
                categoryId: category.id,
                categoryTitle: category.title,
                questions: questions,
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
                  Text(
                    isLocked ? 'PRO - Locked' : 'Free',
                    style: TextStyle(
                      color: isLocked ? Colors.amber : Colors.white70,
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
    // EASY - Very famous tourist places everyone knows
    Question(
      id: 'statue_liberty',
      prompt: 'Where is the Statue of Liberty?',
      lat: 40.6892,
      lng: -74.0445,
    ),
    Question(
      id: 'eiffel',
      prompt: 'Where is the Eiffel Tower?',
      lat: 48.8584,
      lng: 2.2945,
    ),
    Question(
      id: 'colosseum',
      prompt: 'Where is the Colosseum?',
      lat: 41.8902,
      lng: 12.4922,
    ),
    Question(
      id: 'bigben',
      prompt: 'Where is Big Ben?',
      lat: 51.4994,
      lng: -0.1245,
    ),
    Question(
      id: 'sydney_opera',
      prompt: 'Where is the Sydney Opera House?',
      lat: -33.8568,
      lng: 151.2153,
    ),
    Question(
      id: 'taj_mahal',
      prompt: 'Where is the Taj Mahal?',
      lat: 27.1751,
      lng: 78.0421,
    ),
    Question(
      id: 'great_wall',
      prompt: 'Where is the Great Wall of China?',
      lat: 40.4319,
      lng: 116.5704,
    ),
    Question(
      id: 'golden_gate',
      prompt: 'Where is the Golden Gate Bridge?',
      lat: 37.8199,
      lng: -122.4783,
    ),
    Question(
      id: 'christ_redeemer',
      prompt: 'Where is Christ the Redeemer?',
      lat: -22.9519,
      lng: -43.2105,
    ),
    Question(
      id: 'burj_khalifa',
      prompt: 'Where is Burj Khalifa?',
      lat: 25.1972,
      lng: 55.2744,
    ),
    Question(
      id: 'louvre',
      prompt: 'Where is the Louvre Museum?',
      lat: 48.8606,
      lng: 2.3376,
    ),
    Question(
      id: 'stonehenge',
      prompt: 'Where is Stonehenge?',
      lat: 51.1789,
      lng: -1.8262,
    ),
    Question(
      id: 'notre_dame',
      prompt: 'Where is Notre Dame Cathedral?',
      lat: 48.8530,
      lng: 2.3499,
    ),
    Question(
      id: 'versailles',
      prompt: 'Where is the Palace of Versailles?',
      lat: 48.8049,
      lng: 2.1204,
    ),
    Question(
      id: 'acropolis',
      prompt: 'Where is the Acropolis?',
      lat: 37.9715,
      lng: 23.7267,
    ),
    
    // MEDIUM - Well-known but might require some thought
    Question(
      id: 'sagrada_familia',
      prompt: 'Where is La Sagrada Familia?',
      lat: 41.4036,
      lng: 2.1744,
    ),
    Question(
      id: 'neuschwanstein',
      prompt: 'Where is Neuschwanstein Castle?',
      lat: 47.5576,
      lng: 10.7498,
    ),
    Question(
      id: 'brandenburg_gate',
      prompt: 'Where is Brandenburg Gate?',
      lat: 52.5163,
      lng: 13.3777,
    ),
    Question(
      id: 'saint_pauls',
      prompt: 'Where is St. Paul\'s Cathedral?',
      lat: 51.5138,
      lng: -0.0984,
    ),
    Question(
      id: 'windmills',
      prompt: 'Where are the Amsterdam Windmills?',
      lat: 52.3740,
      lng: 4.8897,
    ),
    Question(
      id: 'petra',
      prompt: 'Where is Petra?',
      lat: 30.3285,
      lng: 35.4444,
    ),
    Question(
      id: 'angkor_wat',
      prompt: 'Where is Angkor Wat?',
      lat: 13.4125,
      lng: 103.8670,
    ),
    Question(
      id: 'chichen_itza',
      prompt: 'Where is Chichen Itza?',
      lat: 20.6843,
      lng: -88.5678,
    ),
    Question(
      id: 'niagara_falls',
      prompt: 'Where are Niagara Falls?',
      lat: 43.0962,
      lng: -79.0377,
    ),
    Question(
      id: 'grand_canyon',
      prompt: 'Where is the Grand Canyon?',
      lat: 36.1069,
      lng: -112.1129,
    ),
    Question(
      id: 'mount_rushmore',
      prompt: 'Where is Mount Rushmore?',
      lat: 43.8791,
      lng: -103.4591,
    ),
    Question(
      id: 'times_square',
      prompt: 'Where is Times Square?',
      lat: 40.7580,
      lng: -73.9855,
    ),
    Question(
      id: 'central_park',
      prompt: 'Where is Central Park?',
      lat: 40.7829,
      lng: -73.9654,
    ),
    Question(
      id: 'empire_state',
      prompt: 'Where is the Empire State Building?',
      lat: 40.7484,
      lng: -73.9857,
    ),
    Question(
      id: 'disneyland',
      prompt: 'Where is Disneyland?',
      lat: 33.8121,
      lng: -117.9190,
    ),
    Question(
      id: 'yosemite',
      prompt: 'Where is Yosemite National Park?',
      lat: 37.8651,
      lng: -119.5383,
    ),
    
    // HARD - More challenging locations
    Question(
      id: 'machu_picchu',
      prompt: 'Where is Machu Picchu?',
      lat: -13.1631,
      lng: -72.5450,
    ),
    Question(
      id: 'yellowstone',
      prompt: 'Where is Yellowstone National Park?',
      lat: 44.4280,
      lng: -110.5885,
    ),
    Question(
      id: 'liberty_bell',
      prompt: 'Where is the Liberty Bell?',
      lat: 39.9496,
      lng: -75.1503,
    ),
    Question(
      id: 'space_needle',
      prompt: 'Where is the Space Needle?',
      lat: 47.6205,
      lng: -122.3493,
    ),
    Question(
      id: 'hoover_dam',
      prompt: 'Where is the Hoover Dam?',
      lat: 36.0161,
      lng: -114.7377,
    ),
    Question(
      id: 'miami_beach',
      prompt: 'Where is Miami Beach?',
      lat: 25.7907,
      lng: -80.1300,
    ),
    Question(
      id: 'las_vegas',
      prompt: 'Where is the Las Vegas Strip?',
      lat: 36.1147,
      lng: -115.1728,
    ),
    Question(
      id: 'hollywood_sign',
      prompt: 'Where is the Hollywood Sign?',
      lat: 34.1341,
      lng: -118.3215,
    ),
    Question(
      id: 'colosseum_mexico',
      prompt: 'Where is the Colosseum in Mexico City?',
      lat: 19.4326,
      lng: -99.1332,
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
  GameNotifier(List<Question> questions)
      : super(GameState(questions: questions));

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

final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, List<Question>>(
  (ref, questions) => GameNotifier(questions),
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
    final game = ref.read(gameProvider(widget.questions));
    _mapController.move(game.target, 4);
    _mapController.rotate(0);
  }

  void _zoomToAnswer() {
    final game = ref.read(gameProvider(widget.questions));
    // Zoom to show both user guess and correct answer
    final userPoint = game.currentAnswer?.userGuess ?? game.userGuess!;
    final bounds = LatLngBounds(userPoint, game.target);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(100)));
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider(widget.questions));

    // Haritanın başlangıç odağı: Mevcut sorunun konumuna yakın
    final center = game.target;

    return Scaffold(
      body: Stack(
        children: [
          // HARİTA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 4,
              minZoom: 2,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, point) {
                if (!game.hasAnswered) {
                  ref.read(gameProvider(widget.questions).notifier).setUserGuess(point);
                }
              },
            ),
            children: [
              // Original OpenStreetMap tiles with English labels
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.geo_quiz_master',
                retinaMode: true,
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
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!game.hasAnswered) ...[
                  if (game.userGuess == null)
                    BlinkingText(
                      text: 'Tap on the map to select your guess point.',
                      color: Colors.purple,
                      fontSize: 16.0,
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
                            .read(gameProvider(widget.questions).notifier)
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
                                  .read(gameProvider(widget.questions).notifier)
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
                                  .read(gameProvider(widget.questions).notifier)
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
    final game = ref.read(gameProvider(widget.questions));
    final km = game.distanceKm ?? 0;
    final score = ref.read(gameProvider(widget.questions).notifier).calculateScore();

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
    final game = ref.read(gameProvider(widget.questions));
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


