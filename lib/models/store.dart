class Store {
  final String id;
  final String name;
  final String postcode;
  final double latitude;
  final double longitude;
 
  const Store({
    required this.id,
    required this.name,
    required this.postcode,
    required this.latitude,
    required this.longitude,
  });
 
  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as String,
      name: map['name'] as String,
      postcode: map['postcode'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'postcode': postcode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
 
  @override
  String toString() =>
      '$name ($postcode) [${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}]';
}
 