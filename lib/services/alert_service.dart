import 'dart:async';

import 'package:flutter/foundation.dart';

import 'database_service.dart';

enum AlertSeverity { critical, warning, info }

class AlertRecord {
  final String id;
  final String title;
  final String description;
  final String category;
  final AlertSeverity severity;
  final DateTime createdAt;

  bool isResolved;

  String wifiStatus;
  String gsmStatus;
  String acknowledgementStatus;

  final double? latitude;
  final double? longitude;
  final bool gpsValid;

  AlertRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.createdAt,
    this.isResolved = false,
    this.wifiStatus = 'PENDING',
    this.gsmStatus = 'PENDING',
    this.acknowledgementStatus = 'PENDING',
    this.latitude,
    this.longitude,
    this.gpsValid = false,
  });

  // Convert event into SQLite format.
  Map<String, dynamic> toMap() {
    return {
      'event_id': id,
      'device_id': 'AXB-APP-SIMULATOR',
      'event_type': category,
      'severity': severity.name.toUpperCase(),
      'description': description,
      'timestamp': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'gps_valid': gpsValid ? 1 : 0,
      'wifi_status': wifiStatus,
      'gsm_status': gsmStatus,
      'acknowledgement_status': acknowledgementStatus,
      'is_resolved': isResolved ? 1 : 0,
    };
  }

  // Restore event from SQLite.
  factory AlertRecord.fromMap(Map<String, dynamic> map) {
    final severityName = map['severity']?.toString().toLowerCase() ?? 'info';

    final severity = AlertSeverity.values.firstWhere(
      (value) => value.name == severityName,
      orElse: () => AlertSeverity.info,
    );

    return AlertRecord(
      id: map['event_id'].toString(),
      title: _titleForCategory(map['event_type'].toString()),
      description: map['description']?.toString() ?? '',
      category: map['event_type'].toString(),
      severity: severity,
      createdAt:
          DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      isResolved: map['is_resolved'] == 1,
      wifiStatus: map['wifi_status']?.toString() ?? 'PENDING',
      gsmStatus: map['gsm_status']?.toString() ?? 'PENDING',
      acknowledgementStatus:
          map['acknowledgement_status']?.toString() ?? 'PENDING',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      gpsValid: map['gps_valid'] == 1,
    );
  }

  static String _titleForCategory(String category) {
    switch (category) {
      case 'SOS':
        return 'SOS Emergency Triggered';
      case 'Fall Detection':
        return 'Fall Detection Alert';
      case 'Gas Sensor':
        return 'Gas Level Warning';
      case 'Health':
        return 'Health Monitoring Alert';
      default:
        return 'Emergency Alert';
    }
  }
}

class AlertService extends ChangeNotifier {
  AlertService._() {
    _ready = _loadHistory();
  }

  static final AlertService instance = AlertService._();

  final DatabaseService _database = DatabaseService.instance;

  final List<AlertRecord> _alerts = [];

  late final Future<void> _ready;

  bool _sosActive = false;
  bool _initialized = false;

  // --------------------------------------------------
  // GETTERS
  // --------------------------------------------------

  List<AlertRecord> get alerts => List.unmodifiable(_alerts);

  bool get sosActive => _sosActive;

  bool get initialized => _initialized;

  int get activeAlertCount =>
      _alerts.where((alert) => !alert.isResolved).length;

  int get criticalAlertCount => _alerts
      .where(
        (alert) =>
            alert.severity == AlertSeverity.critical && !alert.isResolved,
      )
      .length;

  // --------------------------------------------------
  // INITIALIZE AND RESTORE HISTORY
  // --------------------------------------------------

  Future<void> initialize() => _ready;

  Future<void> _loadHistory() async {
    try {
      final records = await _database.getEmergencyEvents(limit: 1000);

      for (final record in records) {
        final alert = AlertRecord.fromMap(record);

        // Avoid duplicate records during initialization.
        final alreadyExists = _alerts.any(
          (existing) => existing.id == alert.id,
        );

        if (!alreadyExists) {
          _alerts.add(alert);
        }
      }

      _alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _updateSOSState();

      _initialized = true;

      notifyListeners();
    } catch (e) {
      debugPrint('Alert history loading failed: $e');
      _initialized = true;
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // CREATE EMERGENCY EVENTS
  // --------------------------------------------------

  void triggerSOS() {
    if (_sosActive) return;

    _sosActive = true;

    _addAlert(
      title: 'SOS Emergency Triggered',
      description:
          'Manual SOS was activated in simulation mode. '
          'No emergency message was sent.',
      category: 'SOS',
      severity: AlertSeverity.critical,
    );

    notifyListeners();
  }

  void simulateFallAlert() {
    _addAlert(
      title: 'Fall Detection Alert',
      description:
          'A simulated fall event was detected by the motion monitoring system.',
      category: 'Fall Detection',
      severity: AlertSeverity.critical,
    );

    notifyListeners();
  }

  void simulateGasAlert() {
    _addAlert(
      title: 'Gas Level Warning',
      description:
          'A simulated gas sensor reading exceeded the configured warning threshold.',
      category: 'Gas Sensor',
      severity: AlertSeverity.warning,
    );

    notifyListeners();
  }

  void simulateHealthAlert() {
    _addAlert(
      title: 'Health Monitoring Alert',
      description:
          'A simulated health reading requires attention. '
          'This is not a medical measurement.',
      category: 'Health',
      severity: AlertSeverity.warning,
    );

    notifyListeners();
  }

  // --------------------------------------------------
  // ADD EVENT AND SAVE TO DATABASE
  // --------------------------------------------------

  void _addAlert({
    required String title,
    required String description,
    required String category,
    required AlertSeverity severity,
    double? latitude,
    double? longitude,
    bool gpsValid = false,
  }) {
    final now = DateTime.now();

    final alert = AlertRecord(
      id: 'AXB-${now.microsecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
      severity: severity,
      createdAt: now,
      latitude: latitude,
      longitude: longitude,
      gpsValid: gpsValid,
    );

    _alerts.insert(0, alert);

    // Persist asynchronously without blocking the UI.
    unawaited(_saveAlert(alert));
  }

  Future<void> _saveAlert(AlertRecord alert) async {
    try {
      await _ready;

      await _database.insertEmergencyEvent(alert.toMap());

      debugPrint('Emergency event saved: ${alert.id}');
    } catch (e) {
      debugPrint('Emergency event save failed: $e');
    }
  }

  // --------------------------------------------------
  // COMMUNICATION STATUS
  // --------------------------------------------------

  Future<void> updateWifiStatus(String id, String status) async {
    const allowed = {'PENDING', 'SENT', 'FAILED', 'DELIVERED'};

    if (!allowed.contains(status)) return;

    final alert = _findAlert(id);
    if (alert == null) return;

    alert.wifiStatus = status;

    await _updateDatabase(id, {'wifi_status': status});

    notifyListeners();
  }

  Future<void> updateGsmStatus(String id, String status) async {
    const allowed = {'PENDING', 'SENT', 'FAILED', 'DELIVERED'};

    if (!allowed.contains(status)) return;

    final alert = _findAlert(id);
    if (alert == null) return;

    alert.gsmStatus = status;

    await _updateDatabase(id, {'gsm_status': status});

    notifyListeners();
  }

  Future<void> acknowledgeAlert(String id) async {
    final alert = _findAlert(id);
    if (alert == null) return;

    alert.acknowledgementStatus = 'ACKNOWLEDGED';

    await _updateDatabase(id, {'acknowledgement_status': 'ACKNOWLEDGED'});

    notifyListeners();
  }

  Future<void> _updateDatabase(String id, Map<String, dynamic> updates) async {
    try {
      await _ready;

      await _database.updateEmergencyEvent(id, updates);
    } catch (e) {
      debugPrint('Emergency event update failed: $e');
    }
  }

  AlertRecord? _findAlert(String id) {
    for (final alert in _alerts) {
      if (alert.id == id) return alert;
    }

    return null;
  }

  // --------------------------------------------------
  // RESOLVE EVENTS
  // --------------------------------------------------

  void resolveAlert(String id) {
    final alert = _findAlert(id);

    if (alert == null || alert.isResolved) return;

    alert.isResolved = true;

    if (alert.category == 'SOS') {
      _updateSOSState();
    }

    unawaited(_updateDatabase(id, {'is_resolved': 1}));

    notifyListeners();
  }

  void simulateTemperatureAlert() {
    _addAlert(
      title: 'High Temperature Warning',
      description:
          'A simulated temperature reading exceeded the configured '
          'software testing threshold. This is not a real measurement.',
      category: 'Temperature',
      severity: AlertSeverity.warning,
    );

    notifyListeners();
  }

  void resolveAllAlerts() {
    for (final alert in _alerts) {
      alert.isResolved = true;
    }

    _sosActive = false;

    unawaited(_resolveAllInDatabase());

    notifyListeners();
  }

  Future<void> _resolveAllInDatabase() async {
    try {
      await _ready;

      for (final alert in _alerts) {
        await _database.resolveEmergencyEvent(alert.id);
      }
    } catch (e) {
      debugPrint('Resolving emergency events failed: $e');
    }
  }

  void _updateSOSState() {
    _sosActive = _alerts.any(
      (alert) => alert.category == 'SOS' && !alert.isResolved,
    );
  }

  // --------------------------------------------------
  // CLEAR HISTORY
  // --------------------------------------------------

  void clearHistory() {
    _alerts.clear();
    _sosActive = false;

    unawaited(_clearDatabaseHistory());

    notifyListeners();
  }

  Future<void> _clearDatabaseHistory() async {
    try {
      await _ready;

      await _database.deleteAllEmergencyEvents();

      debugPrint('Emergency event history cleared.');
    } catch (e) {
      debugPrint('Clearing emergency history failed: $e');
    }
  }
}
