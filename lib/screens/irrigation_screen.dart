import 'package:flutter/material.dart';
import '../main.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  final List<_Plot> plots = [
    _Plot(name: 'Parcelle Nord', crop: 'Oliviers', moisture: 62, lastIrrigation: 'Il y a 2 jours', scheduled: 'Demain 6h00', active: false),
    _Plot(name: 'Parcelle Centre', crop: 'Céréales', moisture: 28, lastIrrigation: 'Il y a 5 jours', scheduled: "Aujourd'hui 18h00", active: true),
    _Plot(name: 'Oasis Chenini', crop: 'Palmiers dattiers', moisture: 45, lastIrrigation: 'Il y a 3 jours', scheduled: 'Demain 7h30', active: false),
  ];

  @override
  Widget build(BuildContext context) {
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
                  _buildSummaryRow(),
                  const SizedBox(height: 24),
                  const Text('État des parcelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 14),
                  ...plots.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PlotCard(
                      plot: e.value,
                      onToggle: (val) => setState(() => plots[e.key].active = val),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final activeCount = plots.where((p) => p.active).length;
    final avgMoisture = plots.map((p) => p.moisture).reduce((a, b) => a + b) ~/ plots.length;

    return Row(
      children: [
        Expanded(child: _SummaryCard(icon: Icons.water_rounded, label: 'Actives', value: '$activeCount/${plots.length}', color: AppTheme.skyBlue)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(icon: Icons.opacity_rounded, label: 'Humidité moy.', value: '$avgMoisture%', color: AppTheme.mint)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(icon: Icons.schedule_rounded, label: 'Prévues', value: '${plots.length}', color: AppTheme.teal)),
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
              const Text('Irrigation', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Plot {
  final String name, crop, lastIrrigation, scheduled;
  final int moisture;
  bool active;
  _Plot({required this.name, required this.crop, required this.moisture, required this.lastIrrigation, required this.scheduled, required this.active});
}

class _PlotCard extends StatelessWidget {
  final _Plot plot;
  final ValueChanged<bool> onToggle;
  const _PlotCard({super.key, required this.plot, required this.onToggle});

  Color get _moistureColor {
    if (plot.moisture < 35) return AppTheme.danger;
    if (plot.moisture < 60) return AppTheme.warning;
    return AppTheme.mint;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.mint.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.grass_rounded, color: AppTheme.mint, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plot.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                    Text(plot.crop, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  ],
                ),
              ),
              Switch(
                value: plot.active,
                onChanged: onToggle,
                activeColor: AppTheme.mint,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Moisture bar
          Row(
            children: [
              const Text('Humidité', style: TextStyle(fontSize: 12, color: AppTheme.textMid)),
              const Spacer(),
              Text('${plot.moisture}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _moistureColor)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plot.moisture / 100,
              minHeight: 8,
              backgroundColor: _moistureColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_moistureColor),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.history_rounded, size: 14, color: AppTheme.textLight),
              const SizedBox(width: 4),
              Text(plot.lastIrrigation, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              const Spacer(),
              Icon(Icons.schedule_rounded, size: 14, color: AppTheme.teal),
              const SizedBox(width: 4),
              Text(plot.scheduled, style: const TextStyle(fontSize: 11, color: AppTheme.teal, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SummaryCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textLight), textAlign: TextAlign.center),
      ],
    ),
  );
}