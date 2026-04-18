import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';
import '../services/api_service.dart';

class FarmerMapScreen extends StatefulWidget {
  const FarmerMapScreen({super.key});

  @override
  State<FarmerMapScreen> createState() => _FarmerMapScreenState();
}

class _FarmerMapScreenState extends State<FarmerMapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _gabesCenter = LatLng(33.8815, 10.0982);

  double _currentZoom = 10.8;
  bool _isLoading = true;
  String? _errorMessage;

  late List<_FarmZone> zones;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    zones = [
      _FarmZone(
        name: 'Gabes Rural Nord',
        crop: 'Oliviers',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '12 ha',
        position: const LatLng(33.910, 10.090),
        radius: 1600,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 31,
        humidity: 47,
        pressure: 1013,
        rain: 0,
        wind: 14,
        windDirection: 185,
        distanceUsine: 5.9,
        facteurIndustriel: 0.40,
      ),
      _FarmZone(
        name: 'Gabes Rural Centre',
        crop: 'Céréales',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '8 ha',
        position: const LatLng(33.881, 10.098),
        radius: 1500,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 32,
        humidity: 44,
        pressure: 1012,
        rain: 0,
        wind: 18,
        windDirection: 180,
        distanceUsine: 3.5,
        facteurIndustriel: 0.70,
      ),
      _FarmZone(
        name: 'Oasis Chenini',
        crop: 'Palmiers dattiers',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '5 ha',
        position: const LatLng(33.866, 10.061),
        radius: 1200,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 30,
        humidity: 50,
        pressure: 1014,
        rain: 0,
        wind: 12,
        windDirection: 200,
        distanceUsine: 7.2,
        facteurIndustriel: 0.30,
      ),
      _FarmZone(
        name: 'Ghannouch Agricole',
        crop: 'Maraîchage',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '10 ha',
        position: const LatLng(33.928, 10.050),
        radius: 1300,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 33,
        humidity: 49,
        pressure: 1011,
        rain: 0,
        wind: 21,
        windDirection: 168,
        distanceUsine: 1.5,
        facteurIndustriel: 0.93,
      ),
      _FarmZone(
        name: 'Metouia Parcelle Est',
        crop: 'Céréales',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '9 ha',
        position: const LatLng(33.967, 9.995),
        radius: 1450,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 32,
        humidity: 45,
        pressure: 1012,
        rain: 0,
        wind: 17,
        windDirection: 176,
        distanceUsine: 4.3,
        facteurIndustriel: 0.61,
      ),
      _FarmZone(
        name: 'Mtorrech Parcelle Ouest',
        crop: 'Oliviers',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '11 ha',
        position: const LatLng(33.901, 10.135),
        radius: 1500,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 31,
        humidity: 46,
        pressure: 1013,
        rain: 0,
        wind: 16,
        windDirection: 188,
        distanceUsine: 4.9,
        facteurIndustriel: 0.55,
      ),
      _FarmZone(
        name: 'Zrig Parcelle Sud',
        crop: 'Légumes',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '6 ha',
        position: const LatLng(33.840, 10.145),
        radius: 1200,
        recommendation: 'Analyse IA agricole en cours...',
        temperature: 30,
        humidity: 48,
        pressure: 1014,
        rain: 0,
        wind: 13,
        windDirection: 205,
        distanceUsine: 7.8,
        facteurIndustriel: 0.25,
      ),
      _FarmZone(
        name: 'El Hamma Oasis',
        crop: 'Palmiers',
        health: 'Chargement...',
        healthScore: 0,
        color: AppTheme.warning,
        area: '14 ha',
        position: const LatLng(33.892, 9.796),
        radius: 1100,
        recommendation: 'Analyse IA agricole en cours...',
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

          String health;
          Color color;
          int healthScore;
          double radius;
          String recommendation;

          if (score >= 80) {
            health = 'Stressé';
            color = AppTheme.danger;
            healthScore = 28;
            radius = 1200;
            recommendation =
                'Stress environnemental élevé. Réduire l’exposition et surveiller le sol rapidement.';
          } else if (score >= 50) {
            health = 'Moyen';
            color = AppTheme.warning;
            healthScore = 58;
            radius = 1500;
            recommendation =
                'Surveiller l’humidité du sol, ajuster l’arrosage et limiter les opérations sensibles.';
          } else {
            health = 'Bon';
            color = AppTheme.mint;
            healthScore = 84;
            radius = 1900;
            recommendation =
                'Conditions favorables. Maintenir une irrigation modérée et le suivi habituel.';
          }

          zones[i] = zones[i].copyWith(
            health: health,
            color: color,
            healthScore: healthScore,
            radius: radius,
            recommendation: recommendation,
          );
        }
      }
    } catch (e) {
      _errorMessage = "Impossible de charger les prédictions IA agricoles.";
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

  _FarmZone? get selectedZone =>
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
                              'Mes parcelles',
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
                                  color: AppTheme.mint,
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
                      const SizedBox(height: 180),
                    ],
                  ),
                ),
                if (selectedZone != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: _SmartFarmPanel(
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
                  Icon(
                    Icons.agriculture_rounded,
                    size: 16,
                    color: AppTheme.mint,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Gabès — Smart farm map',
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
        _Legend(color: AppTheme.mint, label: 'Bon'),
        _Legend(color: AppTheme.warning, label: 'Moyen'),
        _Legend(color: AppTheme.danger, label: 'Stressé'),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.leafGreen, AppTheme.mint, AppTheme.skyBlue],
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
                  'Carte agricole',
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
                  'Smart farm',
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

class _FarmZone {
  final String name;
  final String crop;
  final String health;
  final String area;
  final int healthScore;
  final Color color;
  final LatLng position;
  final double radius;
  final String recommendation;

  final double temperature;
  final double humidity;
  final double pressure;
  final double rain;
  final double wind;
  final double windDirection;
  final double distanceUsine;
  final double facteurIndustriel;

  const _FarmZone({
    required this.name,
    required this.crop,
    required this.health,
    required this.healthScore,
    required this.color,
    required this.area,
    required this.position,
    required this.radius,
    required this.recommendation,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.rain,
    required this.wind,
    required this.windDirection,
    required this.distanceUsine,
    required this.facteurIndustriel,
  });

  _FarmZone copyWith({
    String? name,
    String? crop,
    String? health,
    String? area,
    int? healthScore,
    Color? color,
    LatLng? position,
    double? radius,
    String? recommendation,
    double? temperature,
    double? humidity,
    double? pressure,
    double? rain,
    double? wind,
    double? windDirection,
    double? distanceUsine,
    double? facteurIndustriel,
  }) {
    return _FarmZone(
      name: name ?? this.name,
      crop: crop ?? this.crop,
      health: health ?? this.health,
      area: area ?? this.area,
      healthScore: healthScore ?? this.healthScore,
      color: color ?? this.color,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      recommendation: recommendation ?? this.recommendation,
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
  final _FarmZone zone;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: zone.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.grass_rounded, color: zone.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${zone.crop} · ${zone.area}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: zone.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  zone.health,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: zone.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: zone.healthScore / 100,
              minHeight: 8,
              backgroundColor: zone.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(zone.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Santé : ${zone.healthScore}/100',
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}

class _SmartFarmPanel extends StatelessWidget {
  final _FarmZone zone;
  final VoidCallback onClose;

  const _SmartFarmPanel({
    required this.zone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final aiStatus = zone.healthScore >= 70
        ? "Zone stable, pas d’action urgente."
        : zone.healthScore >= 45
            ? "Zone à surveiller dans les prochaines heures."
            : "Zone critique : priorité d’intervention.";

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
                  icon: Icons.grass_rounded,
                  label: zone.crop,
                  color: zone.color,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.analytics_rounded,
                  label: '${zone.healthScore}/100',
                  color: zone.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Surface : ${zone.area}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMid,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'État : ${zone.health}',
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
                aiStatus,
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
                zone.recommendation,
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

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
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
          child: Icon(icon, color: AppTheme.mint),
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