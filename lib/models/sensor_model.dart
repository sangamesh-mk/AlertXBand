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

  // GPS - NEO-6M
  final bool gpsAvailable;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? speed;

  // Device status
  final bool deviceConnected;
  final int? batteryPercentage;

  // Communication information
  // Possible values: wifi, gsm, unknown, simulator.
  final String connectionType;

  // Simulation and device identification
  final bool isSimulated;
  final String deviceId;

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
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.batteryPercentage,
    this.connectionType = 'unknown',
    this.isSimulated = true,
    this.deviceId = 'AXB-APP-SIMULATOR',
  });

  // Convert Firebase Realtime Database data into SensorModel.
  factory SensorModel.fromMap(
    Map<String, dynamic> map, {
    required String deviceId,
  }) {
    double readDouble(String key, [double fallback = 0.0]) {
      final value = map[key];

      if (value is num) return value.toDouble();

      return double.tryParse(value?.toString() ?? '') ?? fallback;
    }

    int readInt(String key, [int fallback = 0]) {
      final value = map[key];

      if (value is num) return value.toInt();

      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool readBool(String key, [bool fallback = false]) {
      final value = map[key];

      if (value is bool) return value;

      if (value is num) return value != 0;

      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }

      return fallback;
    }

    DateTime readTimestamp() {
      final value = map['updatedAt'] ?? map['timestamp'];

      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
      }

      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      return DateTime.now();
    }

    return SensorModel(
      // DHT22
      temperature: readDouble('temperature'),
      humidity: readDouble('humidity'),
      temperatureValid: readBool('temperatureValid'),
      humidityValid: readBool('humidityValid'),

      // MAX30102
      heartRate: readInt('heartRate'),
      spo2: readInt('spo2'),
      healthSignalValid: readBool('healthSignalValid'),

      // MQ-2
      mq2RawAdc: readInt('mq2RawAdc'),
      mq2Available: readBool('mq2Available'),
      mq2WarmedUp: readBool('mq2WarmedUp'),
      mq2Calibrated: readBool('mq2Calibrated'),

      // MPU6050
      accelerationMagnitudeG: readDouble('accelerationMagnitudeG'),
      gyroMagnitudeDps: readDouble('gyroMagnitudeDps'),
      motionSensorAvailable: readBool('motionSensorAvailable'),
      fallDetected: readBool('fallDetected'),

      // GPS
      gpsAvailable: readBool('gpsAvailable'),
      latitude: map['latitude'] == null ? null : readDouble('latitude'),
      longitude: map['longitude'] == null ? null : readDouble('longitude'),
      altitude: map['altitude'] == null ? null : readDouble('altitude'),
      speed: map['speed'] == null ? null : readDouble('speed'),

      // Device status
      deviceConnected: readBool('deviceConnected'),
      batteryPercentage: map['batteryPercentage'] == null
          ? null
          : readInt('batteryPercentage'),

      // Communication
      connectionType: map['connectionType']?.toString() ?? 'unknown',

      // Metadata
      isSimulated: readBool('isSimulated'),
      deviceId: deviceId,

      // Timestamp
      updatedAt: readTimestamp(),
    );
  }
}
