import 'package:flutter/material.dart';
import '../main.dart';
import 'farmer_map_screen.dart';
import 'recommendations_screen.dart';
import 'irrigation_screen.dart';
import 'reports_screen.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: AppTheme.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppTheme.textMid),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildScoreRow(),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(context),
                  const SizedBox(height: 24),
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildActionsSection(context),
                  const SizedBox(height: 24),
                  _buildWeatherRow(),
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
          colors: [AppTheme.leafGreen, AppTheme.mint, AppTheme.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nafas Gabès',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      tooltip: 'Déconnexion',
                      onPressed: () => _logout(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Tableau de bord — Agriculteur 🌿',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      children: [
        Expanded(
          child: _ScoreCard(
            icon: Icons.water_drop_rounded,
            label: 'Stress Hydrique',
            value: '74',
            unit: '/100',
            color: AppTheme.skyBlue,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ScoreCard(
            icon: Icons.grass_rounded,
            label: 'Impact Agri.',
            value: '68',
            unit: '/100',
            color: AppTheme.mint,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    final recs = [
      ("Réduire l'irrigation de 30% aujourd'hui", Icons.water_drop_outlined),
      ("Surveiller l'humidité du sol", Icons.sensors),
      ("Préférer les cultures résistantes à la sécheresse", Icons.eco_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.mint.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mint.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppTheme.mint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Recommandations IA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _navigate(context, RecommendationsScreen()),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recs.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.paleGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(r.$2, color: AppTheme.mint, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r.$1,
                      style: const TextStyle(
                        color: AppTheme.textMid,
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

  Widget _buildActionsSection(BuildContext context) {
    final actions = [
      _FarmerAction(
        icon: Icons.map_rounded,
        label: 'Carte agricole',
        sublabel: 'Mes parcelles',
        color: AppTheme.teal,
        onTap: () => _navigate(context, const FarmerMapScreen()),
      ),
      _FarmerAction(
        icon: Icons.eco_rounded,
        label: 'Recommandations',
        sublabel: 'Conseils IA',
        color: AppTheme.mint,
        onTap: () => _navigate(context, const RecommendationsScreen()),
      ),
      _FarmerAction(
        icon: Icons.water_rounded,
        label: 'Irrigation',
        sublabel: 'Gestion eau',
        color: AppTheme.skyBlue,
        onTap: () => _navigate(context, const IrrigationScreen()),
      ),
      _FarmerAction(
        icon: Icons.bar_chart_rounded,
        label: 'Rapports',
        sublabel: 'Statistiques',
        color: AppTheme.leafGreen,
        onTap: () => _navigate(context, const ReportsScreen()),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.4,
      children: actions.map((a) => _FarmerActionCard(item: a)).toList(),
    );
  }

  Widget _buildWeatherRow() {
    final items = [
      ('Température', '32°C', Icons.thermostat_rounded, AppTheme.warning),
      ('Humidité', '45%', Icons.water_drop_rounded, AppTheme.skyBlue),
      ('Vent', '18 km/h', Icons.air_rounded, AppTheme.teal),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Météo locale',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: items.map((item) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: item == items.last ? 0 : 10),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: item.$4.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(item.$3, color: item.$4, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.$4,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _ScoreCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
          ),
        ],
      ),
    );
  }
}

class _FarmerAction {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _FarmerAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });
}

class _FarmerActionCard extends StatelessWidget {
  final _FarmerAction item;

  const _FarmerActionCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.color.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                item.sublabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}