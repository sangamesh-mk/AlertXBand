class SensorModel {
  // DHT22 - Environmental monitoring
  final double temperature;
  final double humidity;
  final bool temperatureValid;
  final bool humidityValid;

  // MAX30102 - Health monitoring
  final int heartRate;
  final int spo2;
  final bool healthSignalValid;

  // MQ-2 - Gas monitoring
  final int mq2RawAdc;
  final bool mq2Available;
  final bool mq2WarmedUp;
  final bool mq2Calibrated;

  // MPU6050 - Motion monitoring
  final double accelerationMagnitudeG;
  final double gyroMagnitudeDps;
  final bool motionSensorAvailable;
  final bool fallDetected;

  // Device and GPS
  final bool deviceConnected;
  final bool gpsAvailable;

  // Timestamp
  final DateTime updatedAt;

  const SensorModel({
    required this.temperature,
    required this.humidity,
    required this.heartRate,
    required this.spo2,
    required this.deviceConnected,
    required this.fallDetected,
    required this.gpsAvailable,
    required this.updatedAt,

    this.temperatureValid = false,
    this.humidityValid = false,
    this.healthSignalValid = false,

    this.mq2RawAdc = 0,
    this.mq2Available = false,
    this.mq2WarmedUp = false,
    this.mq2Calibrated = false,

    this.accelerationMagnitudeG = 0.0,
    this.gyroMagnitudeDps = 0.0,
    this.motionSensorAvailable = false,
  });
}
