import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'main.dart' show questionsProvider, Question;
import 'app_localizations.dart';

class NaturalWondersButtonGameScreen extends ConsumerStatefulWidget {
  const NaturalWondersButtonGameScreen({super.key, required this.title, required this.part});

  final String title; // AppLocalizations().get('natural_wonders_1') veya AppLocalizations().get('natural_wonders_2')
  final int part; // 1 veya 2

  @override
  ConsumerState<NaturalWondersButtonGameScreen> createState() => _NaturalWondersButtonGameScreenState();
}

class _NaturalWondersButtonGameScreenState extends ConsumerState<NaturalWondersButtonGameScreen> {
  final MapController _mapController = MapController();

  int _currentIndex = 0;
  final Set<String> _answeredIds = {}; // Doğru bilinen noktalar
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final allQuestions = ref.watch(questionsProvider);
    final allNaturalQuestions =
        allQuestions.where((q) => q.categoryId == 'natural_wonders').toList();

    // 40 soruyu iki parçaya böl
    final mid = (allNaturalQuestions.length / 2).ceil();
    final List<Question> wondersQuestions;
    if (widget.part == 1) {
      wondersQuestions = allNaturalQuestions.sublist(0, mid);
    } else {
      wondersQuestions = allNaturalQuestions.sublist(mid);
    }

    final totalQuestions = wondersQuestions.length;

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
                        AppLocalizations().get('wonders_completed'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          AppLocalizations().get('wonders_completed_msg'),
                          style: const TextStyle(
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
                        Navigator.of(context).pop();
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

    final currentQuestion = wondersQuestions[_currentIndex];

    // Dünya genelini gösterecek merkez
    const center = LatLng(20.0, 0.0);
    const initialZoom = 1.8;

    final visibleQuestions =
        wondersQuestions.where((q) => !_answeredIds.contains(q.id)).toList();

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
        title: Text(AppLocalizations().get(widget.part == 1 ? 'natural_wonders_1' : 'natural_wonders_2')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: initialZoom,
                minZoom: 1.3,
                maxZoom: 7,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  HapticFeedback.selectionClick();
                  if (visibleQuestions.isEmpty) return;
                  final Distance distance = const Distance();
                  Question? nearest;
                  double? nearestKm;
                  for (final q in visibleQuestions) {
                    final meters = distance(point, q.location);
                    final km = meters / 1000.0;
                    if (nearest == null || km < nearestKm!) {
                      nearest = q;
                      nearestKm = km;
                    }
                  }
                  if (nearest != null) {
                    setState(() {
                      _selectedId = nearest!.id;
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
                    for (final q in visibleQuestions)
                      CircleMarker(
                        point: q.location,
                        radius: _selectedId == q.id ? 14 : 10,
                        color: _selectedId == q.id
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (_selectedId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations().get('tap_circle_to_answer'))),
                    );
                    return;
                  }

                  final isCorrect = _selectedId == currentQuestion.id;

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
                              ? AppLocalizations().get('you_selected_correct')
                              : (AppLocalizations().currentLanguage == 'tr' ? 'Bu doğru cevap değil.' : 'That is not the correct answer.'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                if (isCorrect) {
                                  _answeredIds.add(currentQuestion.id);
                                  if (_answeredIds.length >= totalQuestions) {
                                    _currentIndex = 0;
                                  } else {
                                    if (_currentIndex < totalQuestions - 1) {
                                      _currentIndex++;
                                    }
                                  }
                                }
                                _selectedId = null;
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
                  backgroundColor:
                      _selectedId == null ? Colors.blueAccent : Colors.purpleAccent,
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
