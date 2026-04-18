import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("Login failed: ${response.statusCode}");
        print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> predict({
    required double temperature,
    required double humidity,
    required double pressure,
    required double rain,
    required double wind,
    required double windDirection,
    required double distanceUsine,
    required double facteurIndustriel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "temperature": temperature,
          "humidity": humidity,
          "pressure": pressure,
          "rain": rain,
          "wind": wind,
          "wind_direction": windDirection,
          "distance_usine": distanceUsine,
          "facteur_industriel": facteurIndustriel,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("Predict failed: ${response.statusCode}");
        print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Predict error: $e");
      return null;
    }
  }
}