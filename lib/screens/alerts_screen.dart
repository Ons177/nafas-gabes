import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String? _error;

  // Alertes système fixes (météo, prévisions IA…)
  final List<_StaticAlert> _systemAlerts = [
    _StaticAlert(
      title: "Pic de pollution prévu",
      message: "Dans 2h, le taux de pollution risque d'augmenter à Gabes Sud.",
      level: "Élevé",
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFE74C3C),
      time: "Il y a 5 min",
    ),
    _StaticAlert(
      title: "Vent fort détecté",
      message: "Le vent peut disperser les émissions vers les zones résidentielles.",
      level: "Moyen",
      icon: Icons.air_rounded,
      color: Color(0xFFE67E22),
      time: "Il y a 23 min",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.getReports();
      setState(() { _reports = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = "Impossible de charger les signalements."; _isLoading = false; });
    }
  }

  Color _levelColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'fumée industrielle': return AppTheme.danger;
      case 'eau contaminée':     return AppTheme.skyBlue;
      case 'déchets sauvages':   return AppTheme.warning;
      case 'odeur suspecte':     return AppTheme.leafGreen;
      default:                   return AppTheme.teal;
    }
  }

  IconData _levelIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'fumée industrielle': return Icons.factory_rounded;
      case 'eau contaminée':     return Icons.water_drop_rounded;
      case 'déchets sauvages':   return Icons.delete_rounded;
      case 'odeur suspecte':     return Icons.air_rounded;
      default:                   return Icons.report_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _systemAlerts.length + _reports.length;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, totalCount),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReports,
              color: AppTheme.teal,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [

                  // ── Alertes système ──
                  _SectionTitle(label: 'Alertes système', icon: Icons.sensors_rounded, color: AppTheme.teal),
                  const SizedBox(height: 10),
                  ..._systemAlerts.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StaticAlertCard(alert: a),
                  )),

                  const SizedBox(height: 20),

                  // ── Signalements citoyens ──
                  _SectionTitle(
                    label: 'Signalements citoyens',
                    icon: Icons.people_rounded,
                    color: AppTheme.mint,
                    count: _reports.length,
                  ),
                  const SizedBox(height: 10),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.teal)),
                    )
                  else if (_error != null)
                    _ErrorCard(message: _error!, onRetry: _loadReports)
                  else if (_reports.isEmpty)
                    _EmptyCard()
                  else
                    ..._reports.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReportAlertCard(report: r, levelColor: _levelColor(r['type']), levelIcon: _levelIcon(r['type'])),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
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
                child: Text('Alertes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('$count actives', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              // Refresh manuel
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  onPressed: _loadReports,
                  tooltip: 'Actualiser',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Static alert (système) ────────────────────────────────────────────────────
class _StaticAlert {
  final String title, message, level, time;
  final IconData icon;
  final Color color;
  const _StaticAlert({required this.title, required this.message, required this.level, required this.icon, required this.color, required this.time});
}

class _StaticAlertCard extends StatelessWidget {
  final _StaticAlert alert;
  const _StaticAlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) => Container(
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
            decoration: BoxDecoration(color: alert.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(alert.icon, color: alert.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(alert.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: alert.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
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

// ── Citizen report card ───────────────────────────────────────────────────────
class _ReportAlertCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final Color levelColor;
  final IconData levelIcon;
  const _ReportAlertCard({super.key, required this.report, required this.levelColor, required this.levelIcon});

  @override
  Widget build(BuildContext context) {
    final type        = report['type']        as String? ?? 'Signalement';
    final description = report['description'] as String? ?? '';
    final createdAt   = report['created_at']  as String? ?? '';
    final imageUrl    = report['image_url']   as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: levelColor, width: 4)),
        boxShadow: [BoxShadow(color: levelColor.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image si disponible
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                imageUrl.startsWith('http') ? imageUrl : 'http://127.0.0.1:8000/$imageUrl',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(levelIcon, color: levelColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(type,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: const Text('Citoyen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.teal)),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(description, style: const TextStyle(color: AppTheme.textMid, fontSize: 13, height: 1.4)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(createdAt, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                        ],
                      ),
                    ],
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

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int? count;
  const _SectionTitle({required this.label, required this.icon, required this.color, this.count});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      if (count != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    ],
  );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.danger.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        const Icon(Icons.wifi_off_rounded, color: AppTheme.danger, size: 32),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: AppTheme.textMid, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal),
        ),
      ],
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppTheme.paleGreen.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      children: [
        Icon(Icons.check_circle_outline_rounded, color: AppTheme.mint, size: 40),
        SizedBox(height: 12),
        Text('Aucun signalement pour le moment', style: TextStyle(color: AppTheme.textMid, fontSize: 14), textAlign: TextAlign.center),
        SizedBox(height: 4),
        Text('Tirez vers le bas pour actualiser', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
      ],
    ),
  );
}