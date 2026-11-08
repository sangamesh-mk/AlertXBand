import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sensor_model.dart';
import 'sensor_history_service.dart';

class SensorSimulatorService {
  int _tick = 0;
  final Random _random = Random();

  Stream<SensorModel> watchReadings() {
    return Stream.periodic(const Duration(seconds: 2), (_) {
      _tick++;

      // DHT22 - Temperature and humidity
      final temperature = 32 + sin(_tick / 5) * 1.2;
      final humidity = 47 + sin(_tick / 7) * 3;

      // MAX30102 - Heart rate and SpO2
      final heartRate = 76 + _random.nextInt(9);
      final spo2 = 97 + _random.nextInt(3);

      // MQ-2 - Raw ADC readings
      final mq2RawAdc = 270 + _random.nextInt(31);

      // MPU6050 - Motion readings
      final accelerationMagnitudeG = 1.0 + (sin(_tick / 4) * 0.04);

      final gyroMagnitudeDps = 2.0 + _random.nextDouble() * 3.0;

      return SensorModel(
        // DHT22
        temperature: temperature,
        humidity: humidity,
        temperatureValid: true,
        humidityValid: true,

        // MAX30102
        heartRate: heartRate,
        spo2: spo2,
        healthSignalValid: true,

        // MQ-2
        mq2RawAdc: mq2RawAdc,
        mq2Available: true,
        mq2WarmedUp: true,
        mq2Calibrated: false,

        // MPU6050
        accelerationMagnitudeG: accelerationMagnitudeG,
        gyroMagnitudeDps: gyroMagnitudeDps,
        motionSensorAvailable: true,
        fallDetected: false,

        // Device and GPS
        deviceConnected: true,
        gpsAvailable: true,

        updatedAt: DateTime.now(),
      );
    }).asyncMap((reading) async {
      // Save each reading to SQLite.
      try {
        await SensorHistoryService.instance.saveReading(reading);
      } catch (error, stackTrace) {
        debugPrint('Sensor history save failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      // Continue displaying the reading even if database saving fails.
      return reading;
    });
  }
}

final sensorReadingsProvider = StreamProvider.autoDispose<SensorModel>((ref) {
  final simulator = SensorSimulatorService();
  return simulator.watchReadings();
});
