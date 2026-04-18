import 'dart:convert';
import 'package:http/http.dart' as http;

class PollutionPrediction {
  final double pollutionScore;
  final String riskLevel;

  PollutionPrediction({
    required this.pollutionScore,
    required this.riskLevel,
  });

  factory PollutionPrediction.fromJson(Map<String, dynamic> json) {
    return PollutionPrediction(
      pollutionScore: (json['pollution_score'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
    );
  }
}

class PollutionService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<PollutionPrediction> predict({
    required double temperature,
    required double humidity,
    required double pressure,
    required double rain,
    required double wind,
    required double windDirection,
    required double distanceUsine,
    required double facteurIndustriel,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'temperature': temperature,
        'humidity': humidity,
        'pressure': pressure,
        'rain': rain,
        'wind': wind,
        'wind_direction': windDirection,
        'distance_usine': distanceUsine,
        'facteur_industriel': facteurIndustriel,
      }),
    );

    if (response.statusCode == 200) {
      return PollutionPrediction.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Erreur API: ${response.body}');
    }
  }
}