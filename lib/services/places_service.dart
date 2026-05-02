import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    this.secondaryText = '',
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final fmt = json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: fmt['main_text'] as String? ??
          json['description'] as String? ??
          '',
      secondaryText: fmt['secondary_text'] as String? ?? '',
    );
  }
}

class PlacesService {
  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  static Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.trim().length < 2) return [];

    try {
      final uri = Uri.parse(_autocompleteUrl).replace(queryParameters: {
        'input': input.trim(),
        'key': ApiConfig.googleMapsApiKey,
        'language': 'fr',
        'types': 'establishment|geocode',
      });

      final response =
          await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK' && status != 'ZERO_RESULTS') return [];
      if (status == 'ZERO_RESULTS') return [];

      return (data['predictions'] as List<dynamic>)
          .take(5)
          .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
