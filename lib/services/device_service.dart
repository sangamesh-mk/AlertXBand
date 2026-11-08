import 'package:flutter/foundation.dart';

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

  // Demo device information
  bool _isConnected = true;
  final int _batteryPercentage = 85;
  DateTime _lastUpdated = DateTime.now();

  // Monitoring controls
  bool _masterMonitoringEnabled = true;
  bool _fallDetectionEnabled = true;
  bool _healthMonitoringEnabled = true;
  bool _environmentMonitoringEnabled = true;

  bool get isDemoMode => true;

  bool get isConnected => _isConnected;

  int get batteryPercentage => _batteryPercentage;

  bool get masterMonitoringEnabled => _masterMonitoringEnabled;

  bool get fallDetectionEnabled => _fallDetectionEnabled;

  bool get healthMonitoringEnabled => _healthMonitoringEnabled;

  bool get environmentMonitoringEnabled => _environmentMonitoringEnabled;

  DateTime get lastUpdated => _lastUpdated;

  String get formattedLastUpdated {
    final date = _lastUpdated.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  // Module status
  String get esp32Status =>
      _isConnected ? 'Online (simulated)' : 'Offline (simulated)';

  String get gpsStatus =>
      _isConnected ? 'Available (simulated)' : 'Unavailable';

  String get gsmStatus => 'Not configured';

  String get sensorStatus {
    if (!_isConnected) return 'Controller disconnected';

    if (!_masterMonitoringEnabled) return 'Monitoring paused';

    return 'Modules ready (simulated)';
  }

  // Simulated connection
  void toggleDemoConnection() {
    _isConnected = !_isConnected;

    if (!_isConnected) {
      _masterMonitoringEnabled = false;
      _fallDetectionEnabled = false;
      _healthMonitoringEnabled = false;
      _environmentMonitoringEnabled = false;
    }

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Master monitoring control
  void setMasterMonitoring(bool enabled) {
    if (!_isConnected) return;

    _masterMonitoringEnabled = enabled;

    if (!enabled) {
      _fallDetectionEnabled = false;
      _healthMonitoringEnabled = false;
      _environmentMonitoringEnabled = false;
    }

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Fall detection control
  void setFallDetection(bool enabled) {
    if (!_isConnected || !_masterMonitoringEnabled) return;

    _fallDetectionEnabled = enabled;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Health monitoring control
  void setHealthMonitoring(bool enabled) {
    if (!_isConnected || !_masterMonitoringEnabled) return;

    _healthMonitoringEnabled = enabled;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Environmental monitoring control
  void setEnvironmentMonitoring(bool enabled) {
    if (!_isConnected || !_masterMonitoringEnabled) return;

    _environmentMonitoringEnabled = enabled;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Refresh demo status
  Future<void> refreshStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Demo diagnostics
  Future<List<DiagnosticResult>> runDiagnostics() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _lastUpdated = DateTime.now();
    notifyListeners();

    return [
      DiagnosticResult(
        name: 'ESP32 Controller',
        status: _isConnected ? 'Simulated online' : 'Simulated offline',
        passed: _isConnected,
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
        status: _fallDetectionEnabled ? 'Enabled in demo' : 'Disabled in demo',
        passed: _fallDetectionEnabled,
      ),
      DiagnosticResult(
        name: 'Health Monitoring',
        status: _healthMonitoringEnabled
            ? 'Enabled in demo'
            : 'Disabled in demo',
        passed: _healthMonitoringEnabled,
      ),
      DiagnosticResult(
        name: 'Environment Monitoring',
        status: _environmentMonitoringEnabled
            ? 'Enabled in demo'
            : 'Disabled in demo',
        passed: _environmentMonitoringEnabled,
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
}
