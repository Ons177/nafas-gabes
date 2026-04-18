import 'package:flutter/material.dart';
import '../main.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      _Alert(
        title: "Pic de pollution attendu",
        message: "Dans 2h, le taux de pollution risque d'augmenter à Gabes Sud.",
        level: "Élevé",
        icon: Icons.warning_amber_rounded,
        color: AppTheme.danger,
        time: "Il y a 5 min",
      ),
      _Alert(
        title: "Vent fort détecté",
        message: "Le vent peut disperser les émissions vers les zones résidentielles.",
        level: "Moyen",
        icon: Icons.air_rounded,
        color: AppTheme.warning,
        time: "Il y a 23 min",
      ),
      _Alert(
        title: "Précaution recommandée",
        message: "Fermez les fenêtres et limitez les sorties si vous êtes sensibles.",
        level: "Faible",
        icon: Icons.health_and_safety_rounded,
        color: AppTheme.mint,
        time: "Il y a 1h",
      ),
      _Alert(
        title: "Amélioration prévue",
        message: "Les conditions atmosphériques devraient s'améliorer après 20h.",
        level: "Info",
        icon: Icons.wb_sunny_rounded,
        color: AppTheme.skyBlue,
        time: "Il y a 2h",
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AlertCard(alert: alerts[i]),
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
                  'Alertes',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('4 actives', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Alert {
  final String title, message, level, time;
  final IconData icon;
  final Color color;
  const _Alert({required this.title, required this.message, required this.level, required this.icon, required this.color, required this.time});
}

class _AlertCard extends StatelessWidget {
  final _Alert alert;
  const _AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: alert.color, width: 4)),
        boxShadow: [BoxShadow(color: alert.color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alert.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(alert.icon, color: alert.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(alert.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: alert.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(alert.level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: alert.color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(alert.message, style: const TextStyle(color: AppTheme.textMid, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 8),
                  Text(alert.time, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}