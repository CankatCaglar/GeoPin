import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'main.dart' show questionsProvider, Question; // Question model ve questionsProvider'i kullanmak için

class AmericaButtonGameScreen extends ConsumerStatefulWidget {
  const AmericaButtonGameScreen({super.key});

  @override
  ConsumerState<AmericaButtonGameScreen> createState() => _AmericaButtonGameScreenState();
}

class _AmericaButtonGameScreenState extends ConsumerState<AmericaButtonGameScreen> {
  final MapController _mapController = MapController();

  int _currentIndex = 0;
  final Set<String> _answeredIds = {}; // Doğru bilinen ülkeler
  String? _selectedCountryId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allQuestions = ref.watch(questionsProvider);
    // Tüm America soruları (her ülke için bir soru)
    final allAmericaQuestions =
        allQuestions.where((q) => q.categoryId == 'america').toList();
    final totalQuestions = allAmericaQuestions.length;

    // Tüm ülkeler doğru cevaplandı mı?
    if (_answeredIds.length >= totalQuestions) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF020617)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'America Completed!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'You found all the countries in the Americas. Nice job explorer!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // CategoryScreen'e dön
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(
                        'Back to Main Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = allAmericaQuestions[_currentIndex];

    // Harita Amerika kıtasına sabit bakıyor
    const center = LatLng(0, -80);
    const initialZoom = 2.5;

    // Ekranda gösterilecek buton daireleri: sadece henüz doğru bilinmemiş ülkeler
    final visibleCountries = allAmericaQuestions
        .where((q) => !_answeredIds.contains(q.id))
        .toList();

    return Scaffold(
      // Arka plan görünmeyecek; map tüm alanı dolduracak
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('America Quiz'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Harita tüm alanı doldurur
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: initialZoom,
                minZoom: 2,
                maxZoom: 6,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  // En yakın butonu bul ve seç
                  if (visibleCountries.isEmpty) return;
                  final Distance distance = const Distance();
                  Question? nearest;
                  double? nearestKm;
                  for (final q in visibleCountries) {
                    final meters = distance(point, q.location);
                    final km = meters / 1000.0;
                    if (nearest == null || km < nearestKm!) {
                      nearest = q;
                      nearestKm = km;
                    }
                  }
                  if (nearest != null) {
                    setState(() {
                      _selectedCountryId = nearest!.id;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://a.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.geopin',
                  maxZoom: 19,
                  minZoom: 1,
                  tileProvider: NetworkTileProvider(),
                ),
                CircleLayer(
                  circles: [
                    for (final q in visibleCountries)
                      CircleMarker(
                        point: q.location,
                        radius: _selectedCountryId == q.id ? 14 : 10,
                        color: _selectedCountryId == q.id
                            ? Colors.purpleAccent.withOpacity(0.9) // Seçili nokta mor
                            : Colors.blue.withOpacity(0.7),
                        borderColor: Colors.white,
                        borderStrokeWidth: 2,
                        useRadiusInMeter: false,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Üstte soru metni overlay
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentQuestion.prompt,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Altta sadece buton overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCountryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tap on a circle to answer.')),
                    );
                    return;
                  }

                  final isCorrect = _selectedCountryId == currentQuestion.id;

                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect ? 'Correct!' : 'Wrong',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          isCorrect
                              ? 'You selected the right country.'
                              : 'That is not the correct country.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                // Yanlışsa aynı soruda kal, sadece seçimi temizle
                                if (isCorrect) {
                                  // Bu ülkeyi tamamen kaldır (noktası kaybolsun)
                                  _answeredIds.add(currentQuestion.id);

                                  // Eğer tüm ülkeler doğru bilindiyse, bitiş ekranına geç
                                  if (_answeredIds.length >= totalQuestions) {
                                    _currentIndex = 0; // index önemli değil, yukarıda answeredIds kontrolü bitirecek
                                  } else {
                                    // Doğruysa bir sonraki soruya geç (varsa)
                                    if (_currentIndex < totalQuestions - 1) {
                                      _currentIndex++;
                                    }
                                  }
                                }
                                _selectedCountryId = null;
                              });
                            },
                            child: const Text('Next'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _selectedCountryId == null
                      ? Colors.blueAccent // Başta mavi
                      : Colors.purpleAccent, // Seçim yapıldığında mor
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Guess',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
