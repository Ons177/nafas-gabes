import 'package:flutter/material.dart';
import '../pollution_service.dart';

class PredictTestScreen extends StatefulWidget {
  const PredictTestScreen({super.key});

  @override
  State<PredictTestScreen> createState() => _PredictTestScreenState();
}

class _PredictTestScreenState extends State<PredictTestScreen> {
  final TextEditingController tempController = TextEditingController(text: '32');
  final TextEditingController humidityController = TextEditingController(text: '45');
  final TextEditingController pressureController = TextEditingController(text: '1013');
  final TextEditingController rainController = TextEditingController(text: '0');
  final TextEditingController windController = TextEditingController(text: '18');
  final TextEditingController windDirectionController = TextEditingController(text: '180');
  final TextEditingController distanceUsineController = TextEditingController(text: '3.2');
  final TextEditingController facteurIndustrielController = TextEditingController(text: '0.9');

  String resultText = 'Aucun test effectué.';
  bool isLoading = false;

  Future<void> testPrediction() async {
    setState(() {
      isLoading = true;
      resultText = 'Chargement...';
    });

    try {
      final prediction = await PollutionService.predict(
        temperature: double.parse(tempController.text),
        humidity: double.parse(humidityController.text),
        pressure: double.parse(pressureController.text),
        rain: double.parse(rainController.text),
        wind: double.parse(windController.text),
        windDirection: double.parse(windDirectionController.text),
        distanceUsine: double.parse(distanceUsineController.text),
        facteurIndustriel: double.parse(facteurIndustrielController.text),
      );

      setState(() {
        resultText =
            'Pollution Score : ${prediction.pollutionScore}\n'
            'Risk Level : ${prediction.riskLevel}';
      });
    } catch (e) {
      setState(() {
        resultText = 'Erreur : $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tempController.dispose();
    humidityController.dispose();
    pressureController.dispose();
    rainController.dispose();
    windController.dispose();
    windDirectionController.dispose();
    distanceUsineController.dispose();
    facteurIndustrielController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color riskColor;
    if (resultText.toLowerCase().contains('danger')) {
      riskColor = Colors.red.shade100;
    } else if (resultText.toLowerCase().contains('moderate')) {
      riskColor = Colors.orange.shade100;
    } else if (resultText.toLowerCase().contains('safe')) {
      riskColor = Colors.green.shade100;
    } else {
      riskColor = Colors.grey.shade100;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test modèle IA'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField(label: 'Température', controller: tempController),
            buildField(label: 'Humidité', controller: humidityController),
            buildField(label: 'Pression', controller: pressureController),
            buildField(label: 'Pluie', controller: rainController),
            buildField(label: 'Vent', controller: windController),
            buildField(
              label: 'Direction du vent',
              controller: windDirectionController,
            ),
            buildField(
              label: 'Distance usine',
              controller: distanceUsineController,
            ),
            buildField(
              label: 'Facteur industriel',
              controller: facteurIndustrielController,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : testPrediction,
                child: Text(
                  isLoading ? 'Chargement...' : 'Tester prédiction',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                resultText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}