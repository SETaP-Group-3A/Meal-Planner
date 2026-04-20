import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, double>?> getCoordinates(String postcode) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?postalcode=$postcode&country=UK&format=json'
  );

  final response = await http.get(
    url,
    headers: {
      'User-Agent': 'Meal-Planner'
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data.isNotEmpty) {
      return {
        'lat': double.parse(data[0]['lat']),
        'lon': double.parse(data[0]['lon']),
      };
    }
  }
  return null;
}
