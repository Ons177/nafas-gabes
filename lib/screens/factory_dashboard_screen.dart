import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';
import '../services/api_service.dart';

class FactoryDashboardScreen extends StatefulWidget {
  const FactoryDashboardScreen({super.key});

  @override
  State<FactoryDashboardScreen> createState() => _FactoryDashboardScreenState();
}

class _FactoryDashboardScreenState extends State<FactoryDashboardScreen> {
  final MapController _mapController = MapController();

  static const LatLng _factoryPosition = LatLng(33.892, 10.060);
  static const LatLng _gabesCenter = LatLng(33.8815, 10.0982);

  bool isLoading = true;
  String? errorMessage;

  double pollutionScore = 0;
  String riskLevel = "safe";

  final Map<String, double> meteo = {
    "temperature": 33,
    "humidity": 42,
    "pressure": 1012,
    "rain": 0,
    "wind": 22,
    "windDirection": 165,
    "distanceUsine": 1.2,
    "facteurIndustriel": 0.95,
  };

  final Map<String, double> gasSensors = {
    "SO2": 68,
    "NO2": 39,
    "CO": 1.2,
    "H2S": 9,
  };

  late List<_ExposureZone> zones;

  @override
  void initState() {
    super.initState();

    zones = [
      const _ExposureZone(
        name: "Gabes Centre",
        position: LatLng(33.881, 10.090),
        populationLabel: "Zone urbaine dense",
        distanceLabel: "3.2 km",
      ),
      const _ExposureZone(
        name: "Ghannouch",
        position: LatLng(33.934, 10.055),
        populationLabel: "Zone côtière",
        distanceLabel: "4.6 km",
      ),
      const _ExposureZone(
        name: "Chenini",
        position: LatLng(33.866, 10.061),
        populationLabel: "Zone résidentielle",
        distanceLabel: "2.8 km",
      ),
      const _ExposureZone(
        name: "Mtorrech",
        position: LatLng(33.901, 10.135),
        populationLabel: "Secteur périurbain",
        distanceLabel: "6.1 km",
      ),
    ];

    _loadFactoryPrediction();
  }

  Future<void> _loadFactoryPrediction() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.predict(
        temperature: meteo["temperature"]!,
        humidity: meteo["humidity"]!,
        pressure: meteo["pressure"]!,
        rain: meteo["rain"]!,
        wind: meteo["wind"]!,
        windDirection: meteo["windDirection"]!,
        distanceUsine: meteo["distanceUsine"]!,
        facteurIndustriel: meteo["facteurIndustriel"]!,
      );

      if (result != null) {
        setState(() {
          pollutionScore = (result["pollution_score"] as num).toDouble();
          riskLevel = (result["risk_level"] as String).toLowerCase();
        });
      } else {
        setState(() {
          errorMessage = "Aucune réponse reçue depuis l'API.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Impossible de charger les données IA.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Color get riskColor {
    switch (riskLevel) {
      case "danger":
        return AppTheme.danger;
      case "moderate":
        return AppTheme.warning;
      default:
        return AppTheme.mint;
    }
  }

  String get riskLabel {
    switch (riskLevel) {
      case "danger":
        return "Critique";
      case "moderate":
        return "Vigilance";
      default:
        return "Stable";
    }
  }

  String get windDirectionLabel {
    final value = meteo["windDirection"]!;
    if (value >= 337.5 || value < 22.5) return "N";
    if (value < 67.5) return "NE";
    if (value < 112.5) return "E";
    if (value < 157.5) return "SE";
    if (value < 202.5) return "S";
    if (value < 247.5) return "SO";
    if (value < 292.5) return "O";
    return "NO";
  }

  List<String> get recommendations {
    final List<String> actions = [];

    if (pollutionScore >= 80) {
      actions.add("Réduire immédiatement la production de 15%.");
      actions.add("Activer la filtration renforcée.");
      actions.add("Reporter les rejets non essentiels.");
    } else if (pollutionScore >= 50) {
      actions.add("Surveiller en continu les émissions sur 2 heures.");
      actions.add("Optimiser le système de filtration.");
      actions.add("Limiter les opérations les plus émissives.");
    } else {
      actions.add("Maintenir l’activité normale avec surveillance standard.");
      actions.add("Continuer le suivi météo et capteurs.");
    }

    if ((gasSensors["SO2"] ?? 0) > 60) {
      actions.add("Alerter le responsable HSE sur le niveau SO2.");
    }
    if ((meteo["wind"] ?? 0) > 20) {
      actions.add("Surveiller les zones sous le vent autour de l’usine.");
    }

    return actions;
  }

  String get peakWindow {
    if (pollutionScore >= 80) return "12:00 - 14:00";
    if (pollutionScore >= 50) return "13:00 - 15:00";
    return "Aucun pic critique prévu";
  }

  String get impactedZone {
    if ((meteo["windDirection"] ?? 0) >= 150 && (meteo["windDirection"] ?? 0) <= 210) {
      return "Gabes Centre";
    }
    return "Ghannouch";
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTopStats(),
                  const SizedBox(height: 18),
                  isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                ],
              ),
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard Usine",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pilotage industriel intelligent — Nafas Gabès",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLoading ? Icons.sync_rounded : Icons.factory_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLoading ? "Chargement" : riskLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _loadFactoryPrediction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Actualiser"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _MetricCard(
          title: "Pollution Score",
          value: isLoading ? "..." : pollutionScore.toStringAsFixed(1),
          subtitle: "Sortie IA",
          icon: Icons.analytics_rounded,
          color: riskColor,
        ),
        _MetricCard(
          title: "Niveau de risque",
          value: riskLabel,
          subtitle: "Décision globale",
          icon: Icons.warning_amber_rounded,
          color: riskColor,
        ),
        _MetricCard(
          title: "Vent",
          value: "${meteo["wind"]!.toStringAsFixed(0)} km/h",
          subtitle: "Cap $windDirectionLabel",
          icon: Icons.air_rounded,
          color: AppTheme.skyBlue,
        ),
        _MetricCard(
          title: "SO₂",
          value: "${gasSensors["SO2"]!.toStringAsFixed(0)} ppb",
          subtitle: "Capteur principal",
          icon: Icons.sensors_rounded,
          color: (gasSensors["SO2"]! > 60) ? AppTheme.danger : AppTheme.mint,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildMapCard(),
              const SizedBox(height: 16),
              _buildExposedZonesCard(),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildMeteoCard(),
              const SizedBox(height: 16),
              _buildGasCard(),
              const SizedBox(height: 16),
              _buildRecommendationCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMapCard(),
        const SizedBox(height: 16),
        _buildMeteoCard(),
        const SizedBox(height: 16),
        _buildGasCard(),
        const SizedBox(height: 16),
        _buildRecommendationCard(),
        const SizedBox(height: 16),
        _buildExposedZonesCard(),
      ],
    );
  }

  Widget _buildMapCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.teal.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Carte d’exposition industrielle",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Visualisation des zones potentiellement impactées selon l’IA et le vent.",
            style: TextStyle(
              color: AppTheme.textMid.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 420,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _gabesCenter,
                  initialZoom: 10.8,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.mobile_app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _factoryPosition,
                        radius: riskLevel == "danger"
                            ? 3200
                            : riskLevel == "moderate"
                                ? 2200
                                : 1400,
                        useRadiusInMeter: true,
                        color: riskColor.withOpacity(0.10),
                        borderColor: riskColor.withOpacity(0.45),
                        borderStrokeWidth: 3,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _factoryPosition,
                        width: 120,
                        height: 90,
                        child: Column(
                          children: [
                            Icon(
                              Icons.factory_rounded,
                              size: 38,
                              color: riskColor,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Usine",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...zones.map((zone) {
                        return Marker(
                          point: zone.position,
                          width: 110,
                          height: 90,
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 34,
                                color: zone.name == impactedZone
                                    ? riskColor
                                    : AppTheme.skyBlue,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  zone.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: zone.name == impactedZone
                                        ? riskColor
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeteoCard() {
    return _PanelCard(
      title: "Conditions météo",
      icon: Icons.cloud_queue_rounded,
      child: Column(
        children: [
          _InfoRow("Température", "${meteo["temperature"]!.toStringAsFixed(0)} °C"),
          _InfoRow("Humidité", "${meteo["humidity"]!.toStringAsFixed(0)} %"),
          _InfoRow("Pression", "${meteo["pressure"]!.toStringAsFixed(0)} hPa"),
          _InfoRow("Pluie", "${meteo["rain"]!.toStringAsFixed(1)} mm"),
          _InfoRow("Vitesse vent", "${meteo["wind"]!.toStringAsFixed(0)} km/h"),
          _InfoRow("Direction vent", windDirectionLabel),
        ],
      ),
    );
  }

  Widget _buildGasCard() {
    return _PanelCard(
      title: "Capteurs gaz",
      icon: Icons.sensors_rounded,
      child: Column(
        children: [
          _SensorRow("SO₂", "${gasSensors["SO2"]} ppb", gasSensors["SO2"]! > 60 ? AppTheme.danger : AppTheme.mint),
          _SensorRow("NO₂", "${gasSensors["NO2"]} ppb", gasSensors["NO2"]! > 50 ? AppTheme.warning : AppTheme.mint),
          _SensorRow("CO", "${gasSensors["CO"]} ppm", gasSensors["CO"]! > 2 ? AppTheme.warning : AppTheme.mint),
          _SensorRow("H₂S", "${gasSensors["H2S"]} ppb", gasSensors["H2S"]! > 10 ? AppTheme.warning : AppTheme.mint),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return _PanelCard(
      title: "Décision IA & recommandations",
      icon: Icons.psychology_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: AppTheme.danger),
              ),
            ),
          Row(
            children: [
              _StatusChip(
                label: riskLabel,
                color: riskColor,
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: "Pic: $peakWindow",
                color: AppTheme.skyBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Zone la plus exposée actuellement : $impactedZone",
            style: const TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppTheme.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppTheme.textMid,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExposedZonesCard() {
    return _PanelCard(
      title: "Zones sous surveillance",
      icon: Icons.place_rounded,
      child: Column(
        children: zones.map((zone) {
          final highlighted = zone.name == impactedZone;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: highlighted
                  ? riskColor.withOpacity(0.08)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: highlighted
                    ? riskColor.withOpacity(0.25)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city_rounded,
                  color: highlighted ? riskColor : AppTheme.teal,
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
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        "${zone.populationLabel} • ${zone.distanceLabel}",
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (highlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      riskLabel,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExposureZone {
  final String name;
  final LatLng position;
  final String populationLabel;
  final String distanceLabel;

  const _ExposureZone({
    required this.name,
    required this.position,
    required this.populationLabel,
    required this.distanceLabel,
  });
}

class _PanelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PanelCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.teal.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.paleTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.teal),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMid,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMid,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SensorRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMid,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}