import 'package:flutter/material.dart';
import '../main.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
    final yields  = [68,    72,    65,    80,    74,    78];
    final maxYield = yields.reduce((a, b) => a > b ? a : b).toDouble();

    final reports = [
      _Report(title: 'Rapport mensuel — Juin 2025', date: '30 Juin 2025', type: 'Mensuel', icon: Icons.calendar_month_rounded, color: AppTheme.teal),
      _Report(title: 'Analyse sol — Parcelle Nord', date: '22 Juin 2025', type: 'Sol',     icon: Icons.terrain_rounded,         color: AppTheme.leafGreen),
      _Report(title: 'Consommation eau — Mai 2025', date: '31 Mai 2025',  type: 'Eau',     icon: Icons.water_drop_rounded,      color: AppTheme.skyBlue),
      _Report(title: 'Impact pollution — Q1 2025',  date: '01 Avr 2025', type: 'Pollution',icon: Icons.warning_amber_rounded,   color: AppTheme.danger),
    ];

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bar chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppTheme.mint.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rendement (quintaux/ha)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text('6 derniers mois', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(months.length, (i) {
                              final h = (yields[i] / maxYield) * 100;
                              final isMax = yields[i] == maxYield;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('${yields[i]}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                                          color: isMax ? AppTheme.mint : AppTheme.textLight)),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isMax
                                                ? [AppTheme.mint, AppTheme.leafGreen]
                                                : [AppTheme.skyBlue.withOpacity(0.5), AppTheme.teal.withOpacity(0.5)],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(months[i], style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Rapports disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 14),
                  ...reports.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportCard(report: r),
                  )),
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
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text('Rapports', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Report {
  final String title, date, type;
  final IconData icon;
  final Color color;
  const _Report({required this.title, required this.date, required this.type, required this.icon, required this.color});
}

class _ReportCard extends StatelessWidget {
  final _Report report;
  const _ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: report.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(report.icon, color: report.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(report.date, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: report.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(report.type, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: report.color)),
          ),
        ],
      ),
    );
  }
}