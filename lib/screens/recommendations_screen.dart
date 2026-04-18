import 'package:flutter/material.dart';
import '../main.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _RecCategory(
        title: 'Irrigation',
        icon: Icons.water_drop_rounded,
        color: AppTheme.skyBlue,
        recs: [
          _Rec(title: "Réduire l'irrigation de 30%", detail: "Le stress hydrique est élevé aujourd'hui. Économisez l'eau en arrosant tôt le matin.", urgency: 'Urgent'),
          _Rec(title: 'Utiliser le goutte-à-goutte', detail: "Réduire les pertes par évaporation avec un système localisé.", urgency: 'Recommandé'),
        ],
      ),
      _RecCategory(
        title: 'Culture',
        icon: Icons.eco_rounded,
        color: AppTheme.mint,
        recs: [
          _Rec(title: 'Privilégier les cultures résistantes', detail: 'Sorgho, orge ou quinoa sont adaptés aux conditions actuelles.', urgency: 'Recommandé'),
          _Rec(title: 'Surveiller les maladies foliaires', detail: "L'humidité nocturne favorise les champignons. Inspectez vos plants.", urgency: 'Attention'),
        ],
      ),
      _RecCategory(
        title: 'Sol',
        icon: Icons.terrain_rounded,
        color: AppTheme.leafGreen,
        recs: [
          _Rec(title: "Mesurer l'humidité du sol", detail: "Utilisez une sonde pour adapter l'irrigation avec précision.", urgency: 'Recommandé'),
          _Rec(title: 'Ajouter du compost', detail: "Le taux de matière organique est faible. Enrichissez le sol avant la prochaine saison.", urgency: 'Planifier'),
        ],
      ),
      _RecCategory(
        title: 'Pollution',
        icon: Icons.warning_amber_rounded,
        color: AppTheme.danger,
        recs: [
          _Rec(title: 'Éviter la récolte ce soir', detail: "Pic de pollution prévu à 18h. Les dépôts atmosphériques peuvent contaminer les produits.", urgency: 'Urgent'),
        ],
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _CategorySection(category: cat),
              )).toList(),
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
              const Expanded(
                child: Text('Recommandations IA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Aujourd\'hui', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rec {
  final String title, detail, urgency;
  const _Rec({required this.title, required this.detail, required this.urgency});
}

class _RecCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_Rec> recs;
  const _RecCategory({required this.title, required this.icon, required this.color, required this.recs});
}

class _CategorySection extends StatelessWidget {
  final _RecCategory category;
  const _CategorySection({super.key, required this.category});

  Color _urgencyColor(String u) {
    switch (u) {
      case 'Urgent':     return AppTheme.danger;
      case 'Attention':  return AppTheme.warning;
      case 'Planifier':  return AppTheme.skyBlue;
      default:           return AppTheme.mint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: category.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(category.icon, color: category.color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(category.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 10),
        ...category.recs.map((rec) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: _urgencyColor(rec.urgency), width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text(rec.detail, style: const TextStyle(fontSize: 12, color: AppTheme.textMid, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _urgencyColor(rec.urgency).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(rec.urgency, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _urgencyColor(rec.urgency))),
              ),
            ],
          ),
        )),
      ],
    );
  }
}