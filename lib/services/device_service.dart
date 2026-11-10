import 'package:flutter/foundation.dart';

import '../models/device_model.dart';

class DiagnosticResult {
  const DiagnosticResult({
    required this.name,
    required this.status,
    required this.passed,
  });

  final String name;
  final String status;
  final bool passed;
}

class DeviceService extends ChangeNotifier {
  DeviceService._();

  static final DeviceService instance = DeviceService._();

  static const String simulatedDeviceId = 'AXB-APP-SIMULATOR';
  static const String hardwareDeviceId = 'AXB-001';

  // Current operating mode.
  bool _isSimulationMode = true;

  // Simulator status.
  bool _simulatorConnected = true;
  static const int _simulatorBatteryPercentage = 85;

  // Real ESP32 status.
  bool _hardwareConnected = false;
  int? _hardwareBatteryPercentage;
  String _connectionType = 'unknown';
  String _firmwareVersion = 'Not reported';

  DateTime _lastUpdated = DateTime.now();

  // Monitoring settings.
  bool _masterMonitoringEnabled = true;
  bool _fallDetectionEnabled = true;
  bool _healthMonitoringEnabled = true;
  bool _environmentMonitoringEnabled = true;

  // Operating mode getters.
  bool get isDemoMode => _isSimulationMode;

  bool get isSimulationMode => _isSimulationMode;

  bool get isHardwareMode => !_isSimulationMode;

  String get deviceId =>
      _isSimulationMode ? simulatedDeviceId : hardwareDeviceId;

  // Connection status.
  bool get isConnected =>
      _isSimulationMode ? _simulatorConnected : _hardwareConnected;

  int get batteryPercentage => _isSimulationMode
      ? _simulatorBatteryPercentage
      : (_hardwareBatteryPercentage ?? 0);

  int? get reportedBatteryPercentage => _isSimulationMode
      ? _simulatorBatteryPercentage
      : _hardwareBatteryPercentage;

  String get connectionType =>
      _isSimulationMode ? 'simulator' : _connectionType;

  String get firmwareVersion =>
      _isSimulationMode ? 'Software Simulator' : _firmwareVersion;

  DateTime get lastUpdated => _lastUpdated;

  // Monitoring settings.
  bool get masterMonitoringEnabled => _masterMonitoringEnabled;

  bool get fallDetectionEnabled => _fallDetectionEnabled;

  bool get healthMonitoringEnabled => _healthMonitoringEnabled;

  bool get environmentMonitoringEnabled => _environmentMonitoringEnabled;

  bool get isFallDetectionActive =>
      isConnected && _masterMonitoringEnabled && _fallDetectionEnabled;

  bool get isHealthMonitoringActive =>
      isConnected && _masterMonitoringEnabled && _healthMonitoringEnabled;

  bool get isEnvironmentMonitoringActive =>
      isConnected && _masterMonitoringEnabled && _environmentMonitoringEnabled;

  bool get isAnyMonitoringActive =>
      isFallDetectionActive ||
      isHealthMonitoringActive ||
      isEnvironmentMonitoringActive;

  DeviceModel get device {
    return DeviceModel(
      deviceId: deviceId,
      name: 'AlertXBand',
      firmwareVersion: firmwareVersion,
      isConnected: isConnected,
      batteryPercentage: batteryPercentage,
      isSimulation: _isSimulationMode,
      lastUpdated: _lastUpdated,
    );
  }

  String get formattedLastUpdated {
    final date = _lastUpdated.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  String get esp32Status {
    if (_isSimulationMode) {
      return _simulatorConnected ? 'Online (simulated)' : 'Offline (simulated)';
    }

    return _hardwareConnected ? 'Online' : 'Offline';
  }

  String get gpsStatus {
    if (_isSimulationMode) {
      return _simulatorConnected ? 'Available (simulated)' : 'Unavailable';
    }

    return _hardwareConnected ? 'Waiting for GPS telemetry' : 'Unavailable';
  }

  String get gsmStatus {
    if (_isSimulationMode) {
      return 'Not configured';
    }

    if (_connectionType == 'gsm') {
      return 'Connected through GSM';
    }

    return 'Not currently used';
  }

  String get sensorStatus {
    if (!isConnected) {
      return 'Controller disconnected';
    }

    if (!_masterMonitoringEnabled) {
      return 'Monitoring paused';
    }

    if (!isAnyMonitoringActive) {
      return 'All modules disabled';
    }

    return _isSimulationMode
        ? 'Modules ready (simulated)'
        : 'Modules receiving hardware data';
  }

  void _update() {
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Switch between simulator and hardware modes.
  void setSimulationMode(bool enabled) {
    if (_isSimulationMode == enabled) return;

    _isSimulationMode = enabled;

    // Restore monitoring settings when switching modes.
    _masterMonitoringEnabled = true;
    _fallDetectionEnabled = true;
    _healthMonitoringEnabled = true;
    _environmentMonitoringEnabled = true;

    _update();
  }

  /// Update hardware status from incoming Firebase telemetry.
  void updateHardwareStatus({
    required bool connected,
    int? batteryPercentage,
    String connectionType = 'unknown',
    String? firmwareVersion,
  }) {
    _hardwareConnected = connected;

    if (batteryPercentage != null) {
      _hardwareBatteryPercentage = batteryPercentage.clamp(0, 100);
    }

    _connectionType = connectionType.toLowerCase();

    if (firmwareVersion != null && firmwareVersion.isNotEmpty) {
      _firmwareVersion = firmwareVersion;
    }

    _update();
  }

  /// Manually mark hardware as disconnected.
  void markHardwareDisconnected() {
    _hardwareConnected = false;
    _connectionType = 'unknown';
    _update();
  }

  /// Simulator-only connection toggle.
  void toggleDemoConnection() {
    if (!_isSimulationMode) return;

    _simulatorConnected = !_simulatorConnected;

    if (!_simulatorConnected) {
      _masterMonitoringEnabled = false;
      _fallDetectionEnabled = false;
      _healthMonitoringEnabled = false;
      _environmentMonitoringEnabled = false;
    }

    _update();
  }

  void setMasterMonitoring(bool enabled) {
    if (!isConnected) return;

    _masterMonitoringEnabled = enabled;

    if (!enabled) {
      _fallDetectionEnabled = false;
      _healthMonitoringEnabled = false;
      _environmentMonitoringEnabled = false;
    }

    _update();
  }

  void setFallDetection(bool enabled) {
    if (!isConnected || !_masterMonitoringEnabled) return;

    _fallDetectionEnabled = enabled;
    _update();
  }

  void setHealthMonitoring(bool enabled) {
    if (!isConnected || !_masterMonitoringEnabled) return;

    _healthMonitoringEnabled = enabled;
    _update();
  }

  void setEnvironmentMonitoring(bool enabled) {
    if (!isConnected || !_masterMonitoringEnabled) return;

    _environmentMonitoringEnabled = enabled;
    _update();
  }

  Future<void> refreshStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _update();
  }

  Future<List<DiagnosticResult>> runDiagnostics() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _update();

    if (_isSimulationMode) {
      return [
        DiagnosticResult(
          name: 'ESP32 Controller',
          status: _simulatorConnected
              ? 'Simulated online'
              : 'Simulated offline',
          passed: _simulatorConnected,
        ),
        DiagnosticResult(
          name: 'Master Monitoring',
          status: _masterMonitoringEnabled
              ? 'Enabled in demo'
              : 'Disabled in demo',
          passed: _masterMonitoringEnabled,
        ),
        DiagnosticResult(
          name: 'Fall Detection',
          status: _fallDetectionEnabled
              ? 'Enabled in demo'
              : 'Disabled in demo',
          passed: isFallDetectionActive,
        ),
        DiagnosticResult(
          name: 'Health Monitoring',
          status: _healthMonitoringEnabled
              ? 'Enabled in demo'
              : 'Disabled in demo',
          passed: isHealthMonitoringActive,
        ),
        DiagnosticResult(
          name: 'Environment Monitoring',
          status: _environmentMonitoringEnabled
              ? 'Enabled in demo'
              : 'Disabled in demo',
          passed: isEnvironmentMonitoringActive,
        ),
        const DiagnosticResult(
          name: 'GPS',
          status: 'Simulated status only',
          passed: false,
        ),
        const DiagnosticResult(
          name: 'GSM / SIM800L',
          status: 'Not configured',
          passed: false,
        ),
      ];
    }

    return [
      DiagnosticResult(
        name: 'ESP32 Controller',
        status: _hardwareConnected ? 'Online' : 'Offline',
        passed: _hardwareConnected,
      ),
      DiagnosticResult(
        name: 'Firebase Telemetry',
        status: _hardwareConnected
            ? 'Receiving device data'
            : 'No recent device data',
        passed: _hardwareConnected,
      ),
      DiagnosticResult(
        name: 'Communication',
        status: _connectionType.toUpperCase(),
        passed:
            _hardwareConnected &&
            (_connectionType == 'wifi' || _connectionType == 'gsm'),
      ),
      DiagnosticResult(
        name: 'Battery',
        status: _hardwareBatteryPercentage == null
            ? 'Battery data unavailable'
            : '$_hardwareBatteryPercentage%',
        passed: _hardwareBatteryPercentage != null,
      ),
      DiagnosticResult(
        name: 'Master Monitoring',
        status: _masterMonitoringEnabled ? 'Enabled' : 'Disabled',
        passed: _masterMonitoringEnabled,
      ),
      DiagnosticResult(
        name: 'Fall Detection',
        status: _fallDetectionEnabled ? 'Enabled' : 'Disabled',
        passed: isFallDetectionActive,
      ),
      DiagnosticResult(
        name: 'Health Monitoring',
        status: _healthMonitoringEnabled ? 'Enabled' : 'Disabled',
        passed: isHealthMonitoringActive,
      ),
      DiagnosticResult(
        name: 'Environment Monitoring',
        status: _environmentMonitoringEnabled ? 'Enabled' : 'Disabled',
        passed: isEnvironmentMonitoringActive,
      ),
    ];
  }
}
