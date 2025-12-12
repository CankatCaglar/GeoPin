import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'main.dart' show questionsProvider, Question; // Question ve questionsProvider kullanımı
import 'app_localizations.dart';

class EuropeButtonGameScreen extends ConsumerStatefulWidget {
  const EuropeButtonGameScreen({super.key, required this.categoryId, required this.title});

  final String categoryId; // 'europe_1' veya 'europe_2'
  final String title;

  @override
  ConsumerState<EuropeButtonGameScreen> createState() => _EuropeButtonGameScreenState();
}

class _EuropeButtonGameScreenState extends ConsumerState<EuropeButtonGameScreen> {
  final MapController _mapController = MapController();

  int _currentIndex = 0;
  final Set<String> _answeredIds = {}; // Doğru bilinen ülkeler
  String? _selectedCountryId;

  @override
  Widget build(BuildContext context) {
    final allQuestions = ref.watch(questionsProvider);
    // İlgili Europe kategorisindeki tüm sorular
    final europeQuestions = allQuestions
        .where((q) => q.categoryId == widget.categoryId)
        .toList();
    final totalQuestions = europeQuestions.length;

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
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${widget.title} Completed!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'You found all the countries in this part of Europe. Nice job explorer!',
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
                        HapticFeedback.lightImpact();
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
                      label: Text(
                        AppLocalizations().get('back_to_main_menu'),
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

    final currentQuestion = europeQuestions[_currentIndex];

    // Harita Avrupa kıtasına sabit bakıyor
    const center = LatLng(50, 15);
    const initialZoom = 3.5;

    // Ekranda gösterilecek buton daireleri: sadece henüz doğru bilinmemiş ülkeler
    final visibleCountries = europeQuestions
        .where((q) => !_answeredIds.contains(q.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.title),
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
                maxZoom: 7,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  HapticFeedback.selectionClick();
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
                            ? Colors.purpleAccent.withValues(alpha: 0.9)
                            : Colors.blue.withValues(alpha: 0.7),
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
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentQuestion.getLocalizedPrompt(),
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
                  HapticFeedback.lightImpact();
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
                              color: isCorrect
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect ? AppLocalizations().get('correct') : AppLocalizations().get('wrong'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          isCorrect
                              ? (AppLocalizations().currentLanguage == 'tr' 
                                  ? 'Doğru ülkeyi seçtiniz.' 
                                  : 'You selected the right country.')
                              : (AppLocalizations().currentLanguage == 'tr'
                                  ? 'Bu doğru ülke değil.'
                                  : 'That is not the correct country.'),
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
                                    _currentIndex = 0;
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
                            child: Text(AppLocalizations().get('next')),
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
                      ? Colors.blueAccent
                      : Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  AppLocalizations().get('guess'),
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
