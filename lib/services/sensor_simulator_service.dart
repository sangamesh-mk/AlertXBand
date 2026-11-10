import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/sensor_model.dart';
import 'anomaly_detection_service.dart';
import 'device_service.dart';
import 'sensor_history_service.dart';
import 'simulation_control_service.dart';

/// Available sensor data sources.
enum SensorDataMode { simulator, hardware }

/// Controls whether the app reads simulated or real device data.
class SensorDataModeController extends Notifier<SensorDataMode> {
  @override
  SensorDataMode build() {
    return SensorDataMode.simulator;
  }

  void useSimulator() {
    state = SensorDataMode.simulator;
  }

  void useHardware() {
    state = SensorDataMode.hardware;
  }
}

final sensorDataModeProvider =
    NotifierProvider<SensorDataModeController, SensorDataMode>(
      SensorDataModeController.new,
    );

/// Stable identifier programmed into the ESP32.
const String alertXBandDeviceId = 'AXB-001';

/// Generates simulated sensor readings.
class SensorSimulatorService {
  SensorSimulatorService({DeviceService? deviceService, Random? random})
    : _deviceService = deviceService ?? DeviceService.instance,
      _random = random ?? Random();

  final DeviceService _deviceService;
  final Random _random;

  int _tick = 0;

  Stream<SensorModel> watchReadings() {
    return Stream.periodic(const Duration(seconds: 2), (_) {
      _tick++;

      final device = _deviceService;

      final connected = device.isConnected;
      final fallActive = device.isFallDetectionActive;
      final healthActive = device.isHealthMonitoringActive;
      final environmentActive = device.isEnvironmentMonitoringActive;

      var temperature = environmentActive ? 32 + sin(_tick / 5) * 1.2 : 0.0;

      final humidity = environmentActive ? 47 + sin(_tick / 7) * 3 : 0.0;

      var heartRate = healthActive ? 76 + _random.nextInt(9) : 0;

      var spo2 = healthActive ? 97 + _random.nextInt(3) : 0;

      var mq2RawAdc = environmentActive ? 270 + _random.nextInt(31) : 0;

      var acceleration = fallActive ? 1.0 + sin(_tick / 4) * 0.04 : 0.0;

      var gyro = fallActive ? 2.0 + _random.nextDouble() * 3.0 : 0.0;

      var fallDetected = false;

      final scenario = SimulationControlService.instance
          .consumePendingScenario();

      if (connected && scenario != null) {
        switch (scenario) {
          case SimulationScenario.fall:
            if (fallActive) {
              acceleration = 3.2;
              gyro = 220.0;
              fallDetected = true;
            }

          case SimulationScenario.lowSpo2:
            if (healthActive) {
              spo2 = 88;
            }

          case SimulationScenario.highGas:
            if (environmentActive) {
              mq2RawAdc = 650;
            }

          case SimulationScenario.highTemperature:
            if (environmentActive) {
              temperature = 40.0;
            }
        }
      }

      return SensorModel(
        temperature: connected ? temperature : 0,
        humidity: connected ? humidity : 0,
        temperatureValid: connected && environmentActive,
        humidityValid: connected && environmentActive,

        heartRate: connected ? heartRate : 0,
        spo2: connected ? spo2 : 0,
        healthSignalValid: connected && healthActive,

        mq2RawAdc: connected ? mq2RawAdc : 0,
        mq2Available: connected && environmentActive,
        mq2WarmedUp: connected && environmentActive,
        mq2Calibrated: false,

        accelerationMagnitudeG: connected ? acceleration : 0,
        gyroMagnitudeDps: connected ? gyro : 0,
        motionSensorAvailable: connected && fallActive,
        fallDetected: connected && fallActive && fallDetected,

        deviceConnected: connected,
        gpsAvailable: connected,

        isSimulated: true,
        deviceId: device.deviceId,
        connectionType: 'simulator',

        updatedAt: DateTime.now(),
      );
    });
  }
}

/// Reads real sensor telemetry from Firebase Realtime Database.
class SensorFirebaseService {
  SensorFirebaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  Stream<SensorModel> watchReadings({required String deviceId}) {
    final reference = _database.ref('devices/$deviceId/telemetry/latest');

    return reference.onValue.map((event) {
      final value = event.snapshot.value;

      // No telemetry has been received yet.
      if (value == null) {
        return SensorModel(
          temperature: 0,
          humidity: 0,
          heartRate: 0,
          spo2: 0,
          deviceConnected: false,
          fallDetected: false,
          gpsAvailable: false,
          isSimulated: false,
          deviceId: deviceId,
          connectionType: 'unknown',
          updatedAt: DateTime.now(),
        );
      }

      if (value is! Map) {
        throw const FormatException('Invalid Firebase telemetry format.');
      }

      final data = value.map((key, value) => MapEntry(key.toString(), value));

      return SensorModel.fromMap(
        Map<String, dynamic>.from(data),
        deviceId: deviceId,
      );
    });
  }
}

/// Shared processing pipeline for simulator and hardware readings.
Future<SensorModel> _processReading(SensorModel reading) async {
  // Synchronize real hardware telemetry with DeviceService.
  if (!reading.isSimulated) {
    DeviceService.instance.updateHardwareStatus(
      connected: reading.deviceConnected,
      batteryPercentage: reading.batteryPercentage,
      connectionType: reading.connectionType,
    );
  }

  // Evaluate anomalies from either data source.
  AnomalyDetectionService.instance.evaluate(reading);

  // Save valid connected readings to local SQLite history.
  if (reading.deviceConnected &&
      (reading.temperatureValid ||
          reading.healthSignalValid ||
          reading.mq2Available ||
          reading.motionSensorAvailable)) {
    try {
      await SensorHistoryService.instance.saveReading(reading);
    } catch (error, stackTrace) {
      debugPrint('Sensor history save failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  return reading;
}

/// Shared sensor readings provider.
///
/// Default mode is simulator.
/// Hardware mode listens to Firebase Realtime Database.
final sensorReadingsProvider = StreamProvider.autoDispose<SensorModel>((ref) {
  final mode = ref.watch(sensorDataModeProvider);

  late final Stream<SensorModel> readings;

  if (mode == SensorDataMode.hardware) {
    final firebaseService = SensorFirebaseService();

    readings = firebaseService.watchReadings(deviceId: alertXBandDeviceId);
  } else {
    final simulator = SensorSimulatorService();

    readings = simulator.watchReadings();
  }

  return readings.asyncMap(_processReading);
});
