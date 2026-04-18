import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _gabesCenter = LatLng(33.8815, 10.0982);

  double _currentZoom = 10.8;
  bool _isLoading = true;
  String? _errorMessage;

  late List<_Zone> zones;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    zones = [
      _Zone(
        name: "Gabes Sud",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Zone industrielle proche avec exposition plus élevée.",
        position: const LatLng(33.850, 10.100),
        radius: 1900,
        citizenAlert: "Analyse IA en cours...",
        temperature: 33,
        humidity: 43,
        pressure: 1012,
        rain: 0,
        wind: 19,
        windDirection: 170,
        distanceUsine: 1.4,
        facteurIndustriel: 0.95,
      ),
      _Zone(
        name: "Gabes Centre",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Zone urbaine mixte avec trafic et activité industrielle.",
        position: const LatLng(33.881, 10.090),
        radius: 1700,
        citizenAlert: "Analyse IA en cours...",
        temperature: 32,
        humidity: 45,
        pressure: 1013,
        rain: 0,
        wind: 18,
        windDirection: 180,
        distanceUsine: 3.2,
        facteurIndustriel: 0.75,
      ),
      _Zone(
        name: "Chenini",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Zone résidentielle et oasis, généralement moins exposée.",
        position: const LatLng(33.866, 10.061),
        radius: 1300,
        citizenAlert: "Analyse IA en cours...",
        temperature: 31,
        humidity: 48,
        pressure: 1014,
        rain: 0,
        wind: 14,
        windDirection: 200,
        distanceUsine: 6.8,
        facteurIndustriel: 0.35,
      ),
      _Zone(
        name: "Ghannouch",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Zone côtière proche de l’activité industrielle lourde.",
        position: const LatLng(33.934, 10.055),
        radius: 2000,
        citizenAlert: "Analyse IA en cours...",
        temperature: 33,
        humidity: 50,
        pressure: 1011,
        rain: 0,
        wind: 22,
        windDirection: 165,
        distanceUsine: 1.1,
        facteurIndustriel: 0.98,
      ),
      _Zone(
        name: "Metouia",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Secteur intermédiaire entre habitat et zones d’activité.",
        position: const LatLng(33.967, 9.995),
        radius: 1600,
        citizenAlert: "Analyse IA en cours...",
        temperature: 32,
        humidity: 46,
        pressure: 1012,
        rain: 0,
        wind: 17,
        windDirection: 175,
        distanceUsine: 4.1,
        facteurIndustriel: 0.62,
      ),
      _Zone(
        name: "Mtorrech",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Secteur périurbain avec influence industrielle modérée.",
        position: const LatLng(33.901, 10.135),
        radius: 1500,
        citizenAlert: "Analyse IA en cours...",
        temperature: 31,
        humidity: 44,
        pressure: 1013,
        rain: 0,
        wind: 16,
        windDirection: 190,
        distanceUsine: 4.8,
        facteurIndustriel: 0.58,
      ),
      _Zone(
        name: "Zrig",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Zone résidentielle plus éloignée, exposition souvent plus faible.",
        position: const LatLng(33.840, 10.145),
        radius: 1200,
        citizenAlert: "Analyse IA en cours...",
        temperature: 30,
        humidity: 47,
        pressure: 1014,
        rain: 0,
        wind: 13,
        windDirection: 210,
        distanceUsine: 7.4,
        facteurIndustriel: 0.28,
      ),
      _Zone(
        name: "El Hamma",
        risk: "Chargement...",
        aqi: 0,
        color: AppTheme.warning,
        desc: "Zone plus intérieure, moins exposée mais surveillée.",
        position: const LatLng(33.892, 9.796),
        radius: 1100,
        citizenAlert: "Analyse IA en cours...",
        temperature: 34,
        humidity: 39,
        pressure: 1010,
        rain: 0,
        wind: 12,
        windDirection: 220,
        distanceUsine: 18.5,
        facteurIndustriel: 0.12,
      ),
    ];

    selectedIndex = 1;
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      for (int i = 0; i < zones.length; i++) {
        final z = zones[i];

        final result = await ApiService.predict(
          temperature: z.temperature,
          humidity: z.humidity,
          pressure: z.pressure,
          rain: z.rain,
          wind: z.wind,
          windDirection: z.windDirection,
          distanceUsine: z.distanceUsine,
          facteurIndustriel: z.facteurIndustriel,
        );

        if (result != null) {
          final score = (result["pollution_score"] as num).toDouble();
          final apiRisk = (result["risk_level"] as String).toLowerCase();

          String riskLabel;
          Color color;
          double radius;
          String alert;

          if (apiRisk == "danger" || score >= 80) {
            riskLabel = "Élevé";
            color = AppTheme.danger;
            radius = 2600;
            alert =
                "Alerte citoyenne : pollution élevée détectée. Limitez les sorties prolongées.";
          } else if (apiRisk == "moderate" || score >= 50) {
            riskLabel = "Moyen";
            color = AppTheme.warning;
            radius = 1900;
            alert =
                "Vigilance recommandée : qualité de l’air modérée, surveiller l’évolution.";
          } else {
            riskLabel = "Faible";
            color = AppTheme.mint;
            radius = 1200;
            alert =
                "Situation stable : qualité de l’air globalement acceptable.";
          }

          zones[i] = zones[i].copyWith(
            aqi: score.round(),
            risk: riskLabel,
            color: color,
            radius: radius,
            citizenAlert: alert,
          );
        }
      }
    } catch (e) {
      _errorMessage = "Impossible de charger les prédictions IA.";
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectZone(int index) {
    setState(() {
      selectedIndex = index;
      _currentZoom = 12.6;
    });
    _mapController.move(zones[index].position, _currentZoom);
  }

  void _recenterMap() {
    setState(() {
      _currentZoom = 10.8;
    });
    _mapController.move(_gabesCenter, _currentZoom);
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 0.8;
    });
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 0.8).clamp(5.0, 18.0);
    });
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  _Zone? get selectedZone =>
      selectedIndex == null ? null : zones[selectedIndex!];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMapCard(),
                      const SizedBox(height: 16),
                      _buildLegend(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Zones à risque',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isLoading
                                      ? Icons.sync_rounded
                                      : Icons.bolt_rounded,
                                  size: 14,
                                  color: AppTheme.teal,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isLoading ? 'Chargement IA' : 'IA réelle',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.danger,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      ...List.generate(zones.length, (i) {
                        final z = zones[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => _selectZone(i),
                            child: _ZoneCard(
                              zone: z,
                              isSelected: selectedIndex == i,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 170),
                    ],
                  ),
                ),
                if (selectedZone != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: _AlertPanel(
                      zone: selectedZone!,
                      onClose: () {
                        setState(() {
                          selectedIndex = null;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _gabesCenter,
              initialZoom: _currentZoom,
              onTap: (_, __) {
                setState(() {
                  selectedIndex = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile_app',
              ),
              CircleLayer(
                circles: zones.expand((zone) {
                  return [
                    CircleMarker(
                      point: zone.position,
                      radius: zone.radius,
                      useRadiusInMeter: true,
                      color: zone.color.withOpacity(0.08),
                      borderStrokeWidth: 0,
                    ),
                    CircleMarker(
                      point: zone.position,
                      radius: zone.radius * 0.68,
                      useRadiusInMeter: true,
                      color: zone.color.withOpacity(0.14),
                      borderStrokeWidth: 0,
                    ),
                    CircleMarker(
                      point: zone.position,
                      radius: zone.radius * 0.38,
                      useRadiusInMeter: true,
                      color: zone.color.withOpacity(0.22),
                      borderStrokeWidth: 0,
                    ),
                  ];
                }).toList(),
              ),
              CircleLayer(
                circles: zones.map((zone) {
                  final selected = selectedZone?.name == zone.name;
                  return CircleMarker(
                    point: zone.position,
                    radius: zone.radius,
                    useRadiusInMeter: true,
                    color: zone.color.withOpacity(selected ? 0.16 : 0.10),
                    borderColor: zone.color.withOpacity(0.45),
                    borderStrokeWidth: selected ? 3 : 2,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: List.generate(zones.length, (i) {
                  final zone = zones[i];
                  final isSelected = selectedIndex == i;

                  return Marker(
                    point: zone.position,
                    width: 110,
                    height: 95,
                    child: GestureDetector(
                      onTap: () => _selectZone(i),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: zone.color,
                            size: isSelected ? 44 : 36,
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: zone.color.withOpacity(0.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              zone.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: zone.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public, size: 16, color: AppTheme.teal),
                  SizedBox(width: 6),
                  Text(
                    'Gabès — Heatmap pollution',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: Column(
              children: [
                _MapControlButton(icon: Icons.add, onTap: _zoomIn),
                const SizedBox(height: 8),
                _MapControlButton(icon: Icons.remove, onTap: _zoomOut),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.my_location_rounded,
                  onTap: _recenterMap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: const [
        _LegendDot(color: AppTheme.danger, label: 'Élevé'),
        _LegendDot(color: AppTheme.warning, label: 'Moyen'),
        _LegendDot(color: AppTheme.mint, label: 'Faible'),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepTeal, AppTheme.teal, AppTheme.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Carte de Gabès',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IA live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Zone {
  final String name;
  final String risk;
  final int aqi;
  final Color color;
  final String desc;
  final LatLng position;
  final double radius;
  final String citizenAlert;

  final double temperature;
  final double humidity;
  final double pressure;
  final double rain;
  final double wind;
  final double windDirection;
  final double distanceUsine;
  final double facteurIndustriel;

  const _Zone({
    required this.name,
    required this.risk,
    required this.aqi,
    required this.color,
    required this.desc,
    required this.position,
    required this.radius,
    required this.citizenAlert,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.rain,
    required this.wind,
    required this.windDirection,
    required this.distanceUsine,
    required this.facteurIndustriel,
  });

  _Zone copyWith({
    String? name,
    String? risk,
    int? aqi,
    Color? color,
    String? desc,
    LatLng? position,
    double? radius,
    String? citizenAlert,
    double? temperature,
    double? humidity,
    double? pressure,
    double? rain,
    double? wind,
    double? windDirection,
    double? distanceUsine,
    double? facteurIndustriel,
  }) {
    return _Zone(
      name: name ?? this.name,
      risk: risk ?? this.risk,
      aqi: aqi ?? this.aqi,
      color: color ?? this.color,
      desc: desc ?? this.desc,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      citizenAlert: citizenAlert ?? this.citizenAlert,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      rain: rain ?? this.rain,
      wind: wind ?? this.wind,
      windDirection: windDirection ?? this.windDirection,
      distanceUsine: distanceUsine ?? this.distanceUsine,
      facteurIndustriel: facteurIndustriel ?? this.facteurIndustriel,
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final _Zone zone;
  final bool isSelected;

  const _ZoneCard({
    required this.zone,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: zone.color.withOpacity(0.5), width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(
            color: zone.color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: zone.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.blur_on_rounded, color: zone.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone.desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AQI ${zone.aqi}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: zone.color,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: zone.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  zone.risk,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: zone.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertPanel extends StatelessWidget {
  final _Zone zone;
  final VoidCallback onClose;

  const _AlertPanel({
    required this.zone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = zone.aqi >= 80
        ? "Pic probable dans les prochaines heures."
        : zone.aqi >= 50
            ? "Niveau modéré à surveiller."
            : "Situation plutôt stable à court terme.";

    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: zone.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.speed_rounded,
                  label: 'Score ${zone.aqi}',
                  color: zone.color,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.warning_amber_rounded,
                  label: zone.risk,
                  color: zone.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                zone.desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMid,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                prediction,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                zone.citizenAlert,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.96),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppTheme.teal),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}