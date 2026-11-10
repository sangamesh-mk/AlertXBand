class DeviceModel {
  final String deviceId;
  final String name;
  final String firmwareVersion;
  final bool isConnected;
  final int batteryPercentage;
  final bool isSimulation;
  final DateTime lastUpdated;

  const DeviceModel({
    required this.deviceId,
    required this.name,
    required this.firmwareVersion,
    required this.isConnected,
    required this.batteryPercentage,
    required this.isSimulation,
    required this.lastUpdated,
  });

  DeviceModel copyWith({
    String? deviceId,
    String? name,
    String? firmwareVersion,
    bool? isConnected,
    int? batteryPercentage,
    bool? isSimulation,
    DateTime? lastUpdated,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      isConnected: isConnected ?? this.isConnected,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      isSimulation: isSimulation ?? this.isSimulation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'name': name,
      'firmwareVersion': firmwareVersion,
      'isConnected': isConnected,
      'batteryPercentage': batteryPercentage,
      'isSimulation': isSimulation,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceId: map['deviceId'] as String? ?? 'AXB-APP-SIMULATOR',
      name: map['name'] as String? ?? 'AlertXBand',
      firmwareVersion: map['firmwareVersion'] as String? ?? 'Demo',
      isConnected: map['isConnected'] as bool? ?? false,
      batteryPercentage: (map['batteryPercentage'] as num?)?.toInt() ?? 0,
      isSimulation: map['isSimulation'] as bool? ?? true,
      lastUpdated:
          DateTime.tryParse(map['lastUpdated']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
