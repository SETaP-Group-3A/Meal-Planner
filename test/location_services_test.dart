import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
import 'package:meal_planner/services/location_service.dart';
import 'package:meal_planner/services/database_service.dart';
 
void main() {
  setUpAll(() async {
    await DatabaseService.initForTesting();
  });
 
  tearDownAll(() async {
    await DatabaseService.closeForTesting();
  });
  group('resolveAndCacheUserCoordinates - ingredient distance updates', () {
    Future<List<double>> getIngredientDistances() async {
      final ingredients = await DatabaseService.instance.getAllIngredients();
      return ingredients.map((i) => i.distance).toList();
    }
 
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });
 
    test('Valid UK postcode updates all ingredient distances in the database',
        () async {
      SharedPreferences.setMockInitialValues({
        kPrefAddress: 'SW1A 1AA',
        kPrefAddressOptOut: false,
      });
 
      final distancesBefore = await getIngredientDistances();
 
      await resolveAndCacheUserCoordinates();
 
      final distancesAfter = await getIngredientDistances();
 

      expect(
        distancesAfter,
        isNot(equals(distancesBefore)),
        reason: 'Ingredient distances should have been recalculated from the '
            'resolved postcode coordinates',
      );
 
      final ingredients = await DatabaseService.instance.getAllIngredients();
      for (final ingredient in ingredients) {
        if (ingredient.storeId != null) {
          expect(
            ingredient.distance,
            greaterThan(0),
            reason: '${ingredient.name} has a storeId so its distance should '
                'be a positive haversine result',
          );
        }
      }
    });
 
    test('Invalid UK postcode leaves all ingredient distances unchanged',
        () async {
      SharedPreferences.setMockInitialValues({
        kPrefAddress: 'ZZ99 9ZZ',
        kPrefAddressOptOut: false,
      });
 
      final distancesBefore = await getIngredientDistances();
 
      final result = await resolveAndCacheUserCoordinates();
 
      final distancesAfter = await getIngredientDistances();
 
      expect(
        result,
        isNull,
        reason: 'An invalid postcode should return null',
      );
      expect(
        distancesAfter,
        equals(distancesBefore),
        reason: 'Ingredient distances must not change when the postcode '
            'could not be resolved',
      );
    });
 
    test('Empty user address leaves all ingredient distances unchanged',
        () async {
      SharedPreferences.setMockInitialValues({
        kPrefAddress: '',
        kPrefAddressOptOut: false,
      });
 
      final distancesBefore = await getIngredientDistances();
 
      final result = await resolveAndCacheUserCoordinates();
 
      final distancesAfter = await getIngredientDistances();
 
      expect(
        result,
        isNull,
        reason: 'An empty address should return null',
      );
      expect(
        distancesAfter,
        equals(distancesBefore),
        reason: 'Ingredient distances must not change when no address is set',
      );
    });
  });
 
  group('getDistanceFromPostcodes - live postcodes.io API', () {
 
    test('Two valid UK postcodes return a positive distance in kilometres',
        () async {

      final distance = await getDistanceFromPostcodes('SW1A 1AA', 'M1 1AE');
 
      expect(
        distance,
        isNotNull,
        reason: 'Both postcodes are valid so a distance should be returned',
      );
      expect(
        distance!,
        greaterThan(0),
        reason: 'The two postcodes are in different cities so distance > 0',
      );
      expect(
        distance,
        inInclusiveRange(200, 350),
        reason: 'London to Manchester straight-line should be ~260 km',
      );
    });
  });
}