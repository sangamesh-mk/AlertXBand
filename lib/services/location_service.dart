import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final int satellites;
  final bool hasFix;
  final DateTime updatedAt;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.satellites,
    required this.hasFix,
    required this.updatedAt,
  });
}

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  final Random _random = Random();

  Stream<LocationModel> watchLocation() {
    return Stream.periodic(const Duration(seconds: 3), (_) {
      return LocationModel(
        // Simulated coordinates for development.
        latitude: 13.2470 + _random.nextDouble() * 0.0005,
        longitude: 77.7070 + _random.nextDouble() * 0.0005,
        altitude: 920 + _random.nextDouble() * 3,
        speed: _random.nextDouble() * 2,
        satellites: 7 + _random.nextInt(5),
        hasFix: true,
        updatedAt: DateTime.now(),
      );
    });
  }
}

final locationProvider = StreamProvider.autoDispose<LocationModel>((ref) {
  return LocationService.instance.watchLocation();
});
