import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class HealthAdviceScreen extends StatefulWidget {
  const HealthAdviceScreen({super.key});

  @override
  State<HealthAdviceScreen> createState() => _HealthAdviceScreenState();
}

class _HealthAdviceScreenState extends State<HealthAdviceScreen> {
  final List<String> _symptoms = [
    "Toux",
    "Essoufflement",
    "Maux de tête",
    "Irritation des yeux",
    "Irritation de la gorge",
    "Nausée",
    "Fatigue",
    "Vertiges",
  ];

  final Set<String> _selectedSymptoms = {};
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _getAdvice() async {
    if (_selectedSymptoms.isEmpty) {
      _showSnack(
        "Veuillez sélectionner au moins un symptôme",
        AppTheme.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.getHealthAdvice(
      symptoms: _selectedSymptoms.toList(),
    );

    setState(() {
      _isLoading = false;
      _result = result;
    });

    if (result == null) {
      _showSnack(
        "Erreur lors de la récupération des conseils",
        AppTheme.danger,
      );
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quels symptômes ressentez-vous ?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _symptoms.map((symptom) {
                      final selected = _selectedSymptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              _selectedSymptoms.remove(symptom);
                            } else {
                              _selectedSymptoms.add(symptom);
                            }
                          });
                        },
                        selectedColor: AppTheme.skyBlue.withOpacity(0.2),
                        checkmarkColor: AppTheme.skyBlue,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppTheme.skyBlue
                              : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getAdvice,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.health_and_safety_rounded),
                      label: Text(
                        _isLoading ? "Analyse..." : "Obtenir des conseils",
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_result != null) _buildResultCard(),
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
                  "Conseils santé",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final level = _result?["risk_level"] ?? "inconnu";
    final advice = (_result?["advice"] as List?)?.cast<String>() ?? [];

    Color color;
    if (level == "élevé") {
      color = AppTheme.danger;
    } else if (level == "modéré") {
      color = AppTheme.warning;
    } else {
      color = AppTheme.mint;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Niveau de vigilance : $level",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...advice.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.circle, size: 8, color: AppTheme.textMid),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      a,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMid,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "En cas de symptômes persistants ou sévères, consultez un professionnel de santé.",
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}