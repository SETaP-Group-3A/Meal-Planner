import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient.dart';
import '../models/store.dart';
import '../mock_data.dart';
import '../utils/haversine.dart';
import 'database_service.dart';

const String kPrefAddress = 'user.address';
const String kPrefAddressOptOut = 'user.addressOptOut';
const String kPrefLat = 'user.lat';
const String kPrefLon = 'user.lon';

// ---------------------------------------------------------------------------
// Postcode -> Coordinates  (postcodes.io)
// ---------------------------------------------------------------------------

/// resolves uk postcode to coordiantes, returns lat lon on success, null on failure / network invalid / address not found
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
    // network error or wrong json sent
  }
  return null;
}

/// reads user's saved address from SharedPreferences, postcode -> coords it via postcodes.io, and writes the resulting coordinates back to SharedPreferences
/// should save user's coordinates on a successful run, throws `null` and clear old coordinates if opted out, field is blank or call failed
Future<Map<String, double>?> resolveAndCacheUserCoordinates() async {
  final prefs = await SharedPreferences.getInstance();

  final optedOut = prefs.getBool(kPrefAddressOptOut) ?? false;
  final address = prefs.getString(kPrefAddress)?.trim() ?? '';

  if (optedOut || address.isEmpty) {
    await prefs.remove(kPrefLat);
    await prefs.remove(kPrefLon);
    return null;
  }

  final coords = await resolvePostcode(address);

  if (coords != null) {
    await prefs.setDouble(kPrefLat, coords['lat']!);
    await prefs.setDouble(kPrefLon, coords['lon']!);
    // recalculate every ingredient's distance due to new user location
    await DatabaseService.instance.updateAllIngredientDistances(
      userLat: coords['lat']!,
      userLon: coords['lon']!,
    );
  } else {
    // resolution failed, removed previous cached coordinates
    await prefs.remove(kPrefLat);
    await prefs.remove(kPrefLon);
  }

  return coords;
}

/// returns user's cached preferences, null if not cached
Future<Map<String, double>?> getCachedUserCoordinates() async {
  final prefs = await SharedPreferences.getInstance();
  final lat = prefs.getDouble(kPrefLat);
  final lon = prefs.getDouble(kPrefLon);
  if (lat == null || lon == null) return null;
  return {'lat': lat, 'lon': lon};
}

// ---------------------------------------------------------------------------
// distance calculation - using haversine formula between two coordinates
// ---------------------------------------------------------------------------
Future<double?> getDistanceFromPostcodes(
  String postcode1,
  String postcode2,
) async {
  final coord1 = await resolvePostcode(postcode1);
  final coord2 = await resolvePostcode(postcode2);

  if (coord1 == null || coord2 == null) return null;

  return haversineDistance(
    coord1['lat']!,
    coord1['lon']!,
    coord2['lat']!,
    coord2['lon']!,
  );
}

/// returns distance from user's cached distance to the store's coordinates
Future<double?> getDistanceFromUserToStore(
  double storeLat,
  double storeLon,
) async {
  final userCoords = await getCachedUserCoordinates();
  if (userCoords == null) return null;

  return haversineDistance(
    userCoords['lat']!,
    userCoords['lon']!,
    storeLat,
    storeLon,
  );
}

/// grabs ingredient's linked store, looks at store coordinates and returns distance from cached location to the store

Future<double?> getDistanceFromUserToIngredient(Ingredient ingredient) async {
  // ingredient must be linked to a store
  final storeId = ingredient.storeId;
  if (storeId == null) return null;

  // look up the store to get its coordinates
  final store = await DatabaseService.instance.getStoreById(storeId);
  if (store == null) return null;

  // measure from the user's cached location to the store
  return getDistanceFromUserToStore(store.latitude, store.longitude);
}

// nearest-store ranking — iterates mockStores, sorts by haversine distance
// returns all mock stores sorted by distance (km) from the given coordinates, nearest first
List<MapEntry<Store, double>> getNearestStores(double userLat, double userLon) {
  final ranked = mockStores.map((store) {
    final km = haversineDistance(
      userLat,
      userLon,
      store.latitude,
      store.longitude,
    );
    return MapEntry(store, km);
  }).toList();
  ranked.sort((a, b) => a.value.compareTo(b.value));
  return ranked;
}

/// convenience wrapper using a hardcoded mock location (future tech centre)
List<MapEntry<Store, double>> getNearestStoresToMockUser() {
  const mockLat = 50.798683; // future tech centre
  const mockLon = -1.099322;
  return getNearestStores(mockLat, mockLon);
}
