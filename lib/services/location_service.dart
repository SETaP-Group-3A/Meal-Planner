import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
// ---------------------------------------------------------------------------
// Postcode -> Coordinates  (postcodes.io)
// ---------------------------------------------------------------------------
 
Future<Map<String, double>?> resolvePostcode(String postcode) async {
  final cleaned = postcode.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  final url = Uri.parse('https://api.postcodes.io/postcodes/$cleaned');
 
  try {
    final response = await http.get(url);
 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
 
      if (result != null) {
        final lat = (result['latitude'] as num?)?.toDouble();
        final lon = (result['longitude'] as num?)?.toDouble();
 
        if (lat != null && lon != null) {
          return {'lat': lat, 'lon': lon};
        }
      }
    }
  } catch (_) {
    
  }
  return null;
}
 
const kPrefAddress = 'user.address';
const kPrefAddressOptOut = 'user.addressOptOut';
const kPrefLat = 'user.lat';
const kPrefLon = 'user.lon';
 
/// reads user's saved address from SharedPreferences, postcode -> coords it via postcodes.io, and writes the resulting coordinates back to SharedPreferences
/// should save user's coordinates on a successful run, throws `null` and clear old coordinates if opted out, field is blank or call failed
Future<Map<String, double>?> resolveAndCacheUserCoordinates() async {
  final prefs = await SharedPreferences.getInstance();
 
  final optedOut = prefs.getBool(kPrefAddressOptOut) ?? false;
  final address  = prefs.getString(kPrefAddress)?.trim() ?? '';
 
  if (optedOut || address.isEmpty) {
    await prefs.remove(kPrefLat);
    await prefs.remove(kPrefLon);
    return null;
  }
 
  final coords = await resolvePostcode(address);
 
  if (coords != null) {
    await prefs.setDouble(kPrefLat, coords['lat']!);
    await prefs.setDouble(kPrefLon, coords['lon']!);
  } else {
    
    await prefs.remove(kPrefLat);
    await prefs.remove(kPrefLon);
  }
 
  return coords;
}
 
/// returns the user's cached coordinates from SharedPreferences without making the postcode.io call
Future<Map<String, double>?> getCachedUserCoordinates() async {
  final prefs = await SharedPreferences.getInstance();
  final lat = prefs.getDouble(kPrefLat);
  final lon = prefs.getDouble(kPrefLon);
  if (lat == null || lon == null) return null;
  return {'lat': lat, 'lon': lon};
}

/// might remove the osrm function soon due to unreliability
 
Future<double?> getDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) async {
  final url = Uri.parse(
    'http://router.project-osrm.org/route/v1/driving/'
    '$lon1,$lat1;$lon2,$lat2?overview=false',
  );
 
  try {
    final response = await http.get(url);
 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final distanceMeters =
          (data['routes'] as List).first['distance'] as num;
      return distanceMeters / 1000;
    }
  } catch (_) {
    
  }
 
  return null;
}
 
/// marked for removal as well, rewrite into haversine formula
Future<double?> getDistanceFromPostcodes(
  String postcode1,
  String postcode2,
) async {
  final coord1 = await resolvePostcode(postcode1);
  final coord2 = await resolvePostcode(postcode2);
 
  if (coord1 == null || coord2 == null) return null;
 
  return getDistance(
    coord1['lat']!,
    coord1['lon']!,
    coord2['lat']!,
    coord2['lon']!,
  );
}
 
// looking for something more like this instead of the OSRM function, maybe using the haversine formula?
Future<double?> getDistanceFromUserToStore(
  double storeLat,
  double storeLon,
) async {
  final userCoords = await getCachedUserCoordinates();
  if (userCoords == null) return null;
 
  return getDistance(
    userCoords['lat']!,
    userCoords['lon']!,
    storeLat,
    storeLon,
  );
}