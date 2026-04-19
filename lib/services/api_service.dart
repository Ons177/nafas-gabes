import 'dart:convert';
import 'dart:typed_data';
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
      }

      print("Login failed: ${response.statusCode} — ${response.body}");
      return null;
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

    double? wind,
    double? distanceUsine,
    double? facteurIndustriel,

    double? windSpeed,
    double? windDirection,
    double? factoryActivity,
    double? residentialProximity,

    double pm25 = 0.0,
    double pm10 = 0.0,
    double no2 = 0.0,
    double so2 = 0.0,
    double co = 0.0,
    double o3 = 0.0,

    required int hour,
    required int month,
  }) async {
    try {
      final double finalWindSpeed = windSpeed ?? wind ?? 0.0;
      final double finalWindDirection = windDirection ?? 0.0;
      final double finalFactoryActivity =
          factoryActivity ?? facteurIndustriel ?? 0.0;
      final double finalResidentialProximity =
          residentialProximity ?? distanceUsine ?? 0.0;

      final payload = {
        "wind_speed": finalWindSpeed,
        "wind_direction": finalWindDirection,
        "humidity": humidity,
        "temperature": temperature,
        "pressure": pressure,
        "rain": rain,
        "factory_activity": finalFactoryActivity,
        "residential_proximity": finalResidentialProximity,
        "pm25": pm25,
        "pm10": pm10,
        "no2": no2,
        "so2": so2,
        "CO": co,
        "o3": o3,
        "hour": hour,
        "month": month,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("DATA envoyée: ${jsonEncode(payload)}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print("Predict failed: ${response.statusCode} — ${response.body}");
      return null;
    } catch (e) {
      print("Predict error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> submitReport({
    required String reportType,
    required String description,
    Uint8List? imageBytes,
    String? imageName,
    double latitude = 33.8833,
    double longitude = 10.0982,
  }) async {
    try {
      if (imageBytes == null) {
        final response = await http.post(
          Uri.parse("$baseUrl/report"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "report_type": reportType,
            "description": description,
            "latitude": latitude,
            "longitude": longitude,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        print("Submit report failed: ${response.statusCode} — ${response.body}");
        return null;
      }

      final uri = Uri.parse("$baseUrl/report/image");
      final request = http.MultipartRequest('POST', uri);

      request.fields['report_type'] = reportType;
      request.fields['description'] = description;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'photo.jpg',
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print(
        "Submit report (image) failed: ${response.statusCode} — ${response.body}",
      );
      return null;
    } catch (e) {
      print("Submit report error: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/reports"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }

      print("Get reports failed: ${response.statusCode} — ${response.body}");
      return [];
    } catch (e) {
      print("Get reports error: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/alerts"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }

      print("Get alerts failed: ${response.statusCode} — ${response.body}");
      return [];
    } catch (e) {
      print("Get alerts error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getCitizenDashboard() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/citizen/dashboard"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print("Citizen dashboard failed: ${response.statusCode} — ${response.body}");
      return null;
    } catch (e) {
      print("Citizen dashboard error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFarmerDashboard() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/farmer/dashboard"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print("Farmer dashboard failed: ${response.statusCode} — ${response.body}");
      return null;
    } catch (e) {
      print("Farmer dashboard error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFactoryDashboard() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/factory/dashboard"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print("Factory dashboard failed: ${response.statusCode} — ${response.body}");
      return null;
    } catch (e) {
      print("Factory dashboard error: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getSocialPosts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/social-posts"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }

      print("Get social posts failed: ${response.statusCode} — ${response.body}");
      return [];
    } catch (e) {
      print("Get social posts error: $e");
      return [];
    }
  }

  static Future<bool> createSocialPost({
    required String userFullName,
    required String postType,
    required String description,
    required String locationName,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/social-posts"),
      );

      request.fields["user_full_name"] = userFullName;
      request.fields["post_type"] = postType;
      request.fields["description"] = description;
      request.fields["location_name"] = locationName;

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName ?? 'post.jpg',
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print(
        "Create social post failed: ${response.statusCode} — ${response.body}",
      );
      return false;
    } catch (e) {
      print("Create social post error: $e");
      return false;
    }
  }

  static Future<bool> reactToPost({
    required int postId,
    required String reactionType,
    required String userFullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/social-posts/$postId/react"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reaction_type": reactionType,
          "user_full_name": userFullName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print("React to post failed: ${response.statusCode} — ${response.body}");
      return false;
    } catch (e) {
      print("React to post error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getHealthAdvice({
    required List<String> symptoms,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/health-advice"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "symptoms": symptoms,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print("Get health advice failed: ${response.statusCode} — ${response.body}");
      return null;
    } catch (e) {
      print("Get health advice error: $e");
      return null;
    }
  }
}