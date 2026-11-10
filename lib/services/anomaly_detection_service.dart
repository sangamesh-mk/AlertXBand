import '../models/sensor_model.dart';
import 'alert_service.dart';

class AnomalyDetectionService {
  AnomalyDetectionService._();

  static final AnomalyDetectionService instance = AnomalyDetectionService._();

  // Provisional thresholds for software simulation.
  static const double fallAccelerationThreshold = 2.5;
  static const double fallGyroscopeThreshold = 180.0;

  static const int lowHeartRateThreshold = 50;
  static const int highHeartRateThreshold = 120;
  static const int lowSpo2Threshold = 92;

  static const double highTemperatureThreshold = 38.0;
  static const int highGasAdcThreshold = 500;

  // Prevent repeated alerts for the same category.
  static const Duration alertCooldown = Duration(seconds: 60);

  final Map<String, DateTime> _lastAlertTime = {};

  bool _isCooldownComplete(String category) {
    final previousAlert = _lastAlertTime[category];

    if (previousAlert == null) return true;

    return DateTime.now().difference(previousAlert) >= alertCooldown;
  }

  void _recordAlert(String category) {
    _lastAlertTime[category] = DateTime.now();
  }

  void evaluate(SensorModel reading) {
    // Never evaluate readings from a disconnected device.
    if (!reading.deviceConnected || !reading.isSimulated) return;

    _checkFall(reading);
    _checkHealth(reading);
    _checkTemperature(reading);
    _checkGas(reading);
  }

  void _checkFall(SensorModel reading) {
    if (!reading.motionSensorAvailable) return;

    final fallDetected =
        reading.fallDetected ||
        (reading.accelerationMagnitudeG >= fallAccelerationThreshold &&
            reading.gyroMagnitudeDps >= fallGyroscopeThreshold);

    if (!fallDetected || !_isCooldownComplete('fall')) return;

    _recordAlert('fall');
    AlertService.instance.simulateFallAlert();
  }

  void _checkHealth(SensorModel reading) {
    if (!reading.healthSignalValid) return;

    final abnormalHeartRate =
        reading.heartRate < lowHeartRateThreshold ||
        reading.heartRate > highHeartRateThreshold;

    final abnormalSpo2 = reading.spo2 < lowSpo2Threshold;

    if ((!abnormalHeartRate && !abnormalSpo2) ||
        !_isCooldownComplete('health')) {
      return;
    }

    _recordAlert('health');
    AlertService.instance.simulateHealthAlert();
  }

  void _checkTemperature(SensorModel reading) {
    if (!reading.temperatureValid) return;

    if (reading.temperature < highTemperatureThreshold ||
        !_isCooldownComplete('temperature')) {
      return;
    }

    _recordAlert('temperature');
    AlertService.instance.simulateTemperatureAlert();
  }

  void _checkGas(SensorModel reading) {
    if (!reading.mq2Available || !reading.mq2WarmedUp) return;

    if (reading.mq2RawAdc < highGasAdcThreshold ||
        !_isCooldownComplete('gas')) {
      return;
    }

    _recordAlert('gas');
    AlertService.instance.simulateGasAlert();
  }

  // Useful for controlled testing without waiting for cooldowns.
  void resetCooldowns() {
    _lastAlertTime.clear();
  }
}
