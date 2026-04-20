import 'dart:convert';
import 'package:http/http.dart' as http;

// limiting function for nominatim api to 1 req/sec to not get blocked 
class _RateLimiter {
  Future<void> _lastRequest = Future.value();

  Future<void> schedule() {
    _lastRequest = _lastRequest.then((_) async {
      await Future.delayed(const Duration(seconds: 1));
    });
    return _lastRequest;
  }
}

final _nominatimLimiter = _RateLimiter();

Future<Map<String, double>?> getCoordinates(String postcode) async {
  await _nominatimLimiter.schedule();

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

Future<double?> getDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) async {
  final url = Uri.parse(
    'http://router.project-osrm.org/route/v1/driving/'
    '$lon1,$lat1;$lon2,$lat2?overview=false'
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final distanceMeters = data['routes'][0]['distance'];
    return distanceMeters / 1000; // convert to km
  }

  return null;
}

// combines the nominatim api function (getCoordinates) and the osrm api function (getDistance) to get the distance between two postocodes
Future<double?> getDistanceFromPostcodes(
  String postcode1,
  String postcode2,
) async {
  final coord1 = await getCoordinates(postcode1);
  final coord2 = await getCoordinates(postcode2);

  if (coord1 == null || coord2 == null) return null;

  return await getDistance(
    coord1['lat']!,
    coord1['lon']!,
    coord2['lat']!,
    coord2['lon']!,
  );
}