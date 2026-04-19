import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'alerts_screen.dart';
import 'report_screen.dart';
import 'social_feed_screen.dart';
import 'health_advice_screen.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'health_advice_screen.dart';
class CitizenDashboard extends StatefulWidget {
  final String fullName;

  const CitizenDashboard({super.key, required this.fullName});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  List<Map<String, dynamic>> _latestReports = [];
  bool _loadingReports = true;

  @override
  void initState() {
    super.initState();
    _loadLatestReports();
  }

  Future<void> _loadLatestReports() async {
    final data = await ApiService.getReports();
    setState(() {
      _latestReports = data.take(3).toList();
      _loadingReports = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadLatestReports,
        color: AppTheme.teal,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildRiskCard(),
                    const SizedBox(height: 16),
                    _buildAlertCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildActionGrid(context),
                    const SizedBox(height: 24),
                    _buildAirQualityStrip(),
                    const SizedBox(height: 24),
                    _buildLatestReportsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestReportsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_rounded, color: AppTheme.mint, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Signalements récents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              ).then((_) => _loadLatestReports()),
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
        const SizedBox(height: 14),
        if (_loadingReports)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppTheme.teal),
            ),
          )
        else if (_latestReports.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.paleGreen.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.mint,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Aucun signalement récent',
                  style: TextStyle(color: AppTheme.textMid, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ..._latestReports.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MiniReportCard(report: r),
            ),
          ),
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bonjour, ${widget.fullName}',
                      style: const TextStyle(
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
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsScreen()),
                      ).then((_) => _loadLatestReports()),
                    ),
                  ),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatusBadge(
                    label: 'IA active',
                    color: AppTheme.mint,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: 'Zone surveillée',
                    color: AppTheme.skyBlue,
                    icon: Icons.radar_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.danger.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: AppTheme.danger,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gabes Sud',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    _Tag(label: 'Risque Élevé', color: AppTheme.danger),
                    SizedBox(width: 8),
                    _Tag(label: 'Score: 82', color: AppTheme.teal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withOpacity(0.12),
            AppTheme.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppTheme.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerte active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pic de pollution attendu dans 2h. Portez un masque et fermez vos fenêtres.',
                  style: TextStyle(
                    color: AppTheme.textMid,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.map_rounded,
        label: 'Carte',
        sublabel: 'Zones à risque',
        color: AppTheme.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        ),
      ),
      _ActionItem(
        icon: Icons.report_rounded,
        label: 'Signaler',
        sublabel: 'Pollution',
        color: AppTheme.danger,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ).then((_) => _loadLatestReports()),
      ),
      _ActionItem(
        icon: Icons.notifications_rounded,
        label: 'Alertes',
        sublabel: 'Voir tout',
        color: AppTheme.warning,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlertsScreen()),
        ).then((_) => _loadLatestReports()),
      ),
      _ActionItem(
        icon: Icons.people_rounded,
        label: 'Communauté',
        sublabel: 'Citoyens',
        color: AppTheme.mint,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SocialFeedScreen(fullName: widget.fullName),
          ),
        ),
      ),
      _ActionItem(
        icon: Icons.health_and_safety_rounded,
        label: 'Conseils',
        sublabel: 'Santé & Env.',
        color: AppTheme.skyBlue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HealthAdviceScreen(),
          ),
        ),
      ),
      _ActionItem(
        icon: Icons.insights_rounded,
        label: 'IA',
        sublabel: 'Prédictions',
        color: AppTheme.deepTeal,
        onTap: () {},
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: actions.map((a) => _ActionCard(item: a)).toList(),
    );
  }

  Widget _buildAirQualityStrip() {
    final metrics = [
      ('PM2.5', '42', 'µg/m³', AppTheme.warning),
      ('NO₂', '18', 'ppb', AppTheme.mint),
      ('SO₂', '65', 'ppb', AppTheme.danger),
      ('CO', '0.9', 'ppm', AppTheme.skyBlue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Qualité de l'air — maintenant",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: metrics
              .map(
                (m) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: m == metrics.last ? 0 : 10),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: m.$4.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          m.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMid,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.$2,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: m.$4,
                          ),
                        ),
                        Text(
                          m.$3,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MiniReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _MiniReportCard({super.key, required this.report});

  Color _color(String? type) {
    switch (type?.toLowerCase()) {
      case 'fumée industrielle':
        return AppTheme.danger;
      case 'eau contaminée':
        return AppTheme.skyBlue;
      case 'déchets sauvages':
        return AppTheme.warning;
      default:
        return AppTheme.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = report['type'] as String? ?? 'Signalement';
    final description = report['description'] as String? ?? '';
    final createdAt = report['created_at'] as String? ?? '';
    final color = _color(type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.report_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMid,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            createdAt,
            style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;

  const _ActionCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.color.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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