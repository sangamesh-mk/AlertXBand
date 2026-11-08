import '../models/sensor_model.dart';
import 'database_service.dart';

class SensorHistoryService {
  SensorHistoryService._();

  static final SensorHistoryService instance = SensorHistoryService._();

  final DatabaseService _database = DatabaseService.instance;

  Future<void> saveReading(SensorModel sensor) async {
    final reading = <String, dynamic>{
      'temperature': sensor.temperature,
      'humidity': sensor.humidity,
      'heart_rate': sensor.heartRate,
      'spo2': sensor.spo2,
      'mq2_raw_adc': sensor.mq2RawAdc,
      'acceleration_g': sensor.accelerationMagnitudeG,
      'gyro_dps': sensor.gyroMagnitudeDps,
      'device_connected': sensor.deviceConnected ? 1 : 0,
      'gps_available': sensor.gpsAvailable ? 1 : 0,
      'fall_detected': sensor.fallDetected ? 1 : 0,
      'temperature_valid': sensor.temperatureValid ? 1 : 0,
      'humidity_valid': sensor.humidityValid ? 1 : 0,
      'health_signal_valid': sensor.healthSignalValid ? 1 : 0,
      'mq2_available': sensor.mq2Available ? 1 : 0,
      'motion_available': sensor.motionSensorAvailable ? 1 : 0,
      'recorded_at': sensor.updatedAt.toIso8601String(),
    };

    await _database.insertSensorReading(reading);
  }

  Future<List<Map<String, dynamic>>> getHistory({int limit = 100}) {
    return _database.getSensorHistory(limit: limit);
  }

  Future<int> clearHistory() {
    return _database.deleteAllHistory();
  }
}
