import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/sensor_simulator_service.dart';
import '../../services/sensor_history_service.dart';

enum SensorMetric { heartRate, spo2, temperature, humidity, gas, acceleration }

class SensorAnalyticsPanel extends ConsumerStatefulWidget {
  const SensorAnalyticsPanel({super.key});

  @override
  ConsumerState<SensorAnalyticsPanel> createState() =>
      _SensorAnalyticsPanelState();
}

class _SensorAnalyticsPanelState extends ConsumerState<SensorAnalyticsPanel> {
  final List<SensorModel> _history = [];

  SensorMetric _selectedMetric = SensorMetric.heartRate;
  int _selectedHours = 1;

  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();

    // Load previously saved readings from SQLite.
    _loadStoredHistory();

    // Listen for incoming live sensor readings.
    ref.listenManual(sensorReadingsProvider, (previous, next) {
      next.whenData((reading) {
        if (!mounted) return;

        setState(() {
          _addReading(reading);
        });
      });
    }, fireImmediately: true);
  }

  // --------------------------------------------------
  // LOAD HISTORY FROM SQLITE
  // --------------------------------------------------

  Future<void> _loadStoredHistory() async {
    try {
      final records = await SensorHistoryService.instance.getHistory(
        limit: 50000,
      );

      final storedReadings = records.map(_fromDatabaseRow).toList();

      if (!mounted) return;

      setState(() {
        for (final reading in storedReadings) {
          _addReading(reading);
        }

        // Arrange readings from oldest to newest.
        _history.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

        _isLoadingHistory = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load sensor history: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // CONVERT DATABASE ROW TO SENSOR MODEL
  // --------------------------------------------------

  SensorModel _fromDatabaseRow(Map<String, dynamic> row) {
    return SensorModel(
      // DHT22
      temperature: (row['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (row['humidity'] as num?)?.toDouble() ?? 0,

      // MAX30102
      heartRate: (row['heart_rate'] as num?)?.toInt() ?? 0,
      spo2: (row['spo2'] as num?)?.toInt() ?? 0,

      // MQ-2
      mq2RawAdc: (row['mq2_raw_adc'] as num?)?.toInt() ?? 0,

      // MPU6050
      accelerationMagnitudeG: (row['acceleration_g'] as num?)?.toDouble() ?? 0,
      gyroMagnitudeDps: (row['gyro_dps'] as num?)?.toDouble() ?? 0,

      // Device and GPS
      deviceConnected: (row['device_connected'] as num?)?.toInt() == 1,
      gpsAvailable: (row['gps_available'] as num?)?.toInt() == 1,
      fallDetected: (row['fall_detected'] as num?)?.toInt() == 1,

      // Sensor availability
      temperatureValid: (row['temperature_valid'] as num?)?.toInt() == 1,
      humidityValid: (row['humidity_valid'] as num?)?.toInt() == 1,
      healthSignalValid: (row['health_signal_valid'] as num?)?.toInt() == 1,
      mq2Available: (row['mq2_available'] as num?)?.toInt() == 1,
      motionSensorAvailable: (row['motion_available'] as num?)?.toInt() == 1,

      updatedAt:
          DateTime.tryParse(row['recorded_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // --------------------------------------------------
  // ADD READING WITHOUT DUPLICATES
  // --------------------------------------------------

  void _addReading(SensorModel reading) {
    final alreadyExists = _history.any(
      (item) => item.updatedAt.isAtSameMomentAs(reading.updatedAt),
    );

    if (alreadyExists) return;

    _history.add(reading);

    // Keep the latest 50,000 readings in memory.
    if (_history.length > 50000) {
      _history.removeAt(0);
    }
  }

  // --------------------------------------------------
  // FILTER HISTORY
  // --------------------------------------------------

  List<SensorModel> get _filteredHistory {
    final cutoff = DateTime.now().subtract(Duration(hours: _selectedHours));

    return _history
        .where((reading) => reading.updatedAt.isAfter(cutoff))
        .toList();
  }

  // --------------------------------------------------
  // METRIC TITLE
  // --------------------------------------------------

  String get _metricTitle {
    switch (_selectedMetric) {
      case SensorMetric.heartRate:
        return 'Heart Rate';

      case SensorMetric.spo2:
        return 'SpO₂';

      case SensorMetric.temperature:
        return 'Temperature';

      case SensorMetric.humidity:
        return 'Humidity';

      case SensorMetric.gas:
        return 'MQ-2 Raw ADC';

      case SensorMetric.acceleration:
        return 'Acceleration';
    }
  }

  // --------------------------------------------------
  // METRIC UNIT
  // --------------------------------------------------

  String get _metricUnit {
    switch (_selectedMetric) {
      case SensorMetric.heartRate:
        return 'BPM';

      case SensorMetric.spo2:
        return '%';

      case SensorMetric.temperature:
        return '°C';

      case SensorMetric.humidity:
        return '% RH';

      case SensorMetric.gas:
        return 'ADC';

      case SensorMetric.acceleration:
        return 'g';
    }
  }

  // --------------------------------------------------
  // SENSOR VALIDATION
  // --------------------------------------------------

  bool _isValid(SensorModel reading) {
    switch (_selectedMetric) {
      case SensorMetric.heartRate:
      case SensorMetric.spo2:
        return reading.healthSignalValid;

      case SensorMetric.temperature:
        return reading.temperatureValid;

      case SensorMetric.humidity:
        return reading.humidityValid;

      case SensorMetric.gas:
        return reading.mq2Available;

      case SensorMetric.acceleration:
        return reading.motionSensorAvailable;
    }
  }

  // --------------------------------------------------
  // GET SELECTED SENSOR VALUE
  // --------------------------------------------------

  double _value(SensorModel reading) {
    switch (_selectedMetric) {
      case SensorMetric.heartRate:
        return reading.heartRate.toDouble();

      case SensorMetric.spo2:
        return reading.spo2.toDouble();

      case SensorMetric.temperature:
        return reading.temperature;

      case SensorMetric.humidity:
        return reading.humidity;

      case SensorMetric.gas:
        return reading.mq2RawAdc.toDouble();

      case SensorMetric.acceleration:
        return reading.accelerationMagnitudeG;
    }
  }

  // --------------------------------------------------
  // MAIN UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final history = _filteredHistory;

    final validReadings = history.where(_isValid).toList();

    final values = validReadings.map(_value).toList();

    final minimum = values.isEmpty ? null : values.reduce(math.min);

    final maximum = values.isEmpty ? null : values.reduce(math.max);

    final average = values.isEmpty
        ? null
        : values.reduce((a, b) => a + b) / values.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),

        const Text(
          'Sensor Analytics',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Trends and statistics from recorded readings.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),

        const SizedBox(height: 16),

        _buildMetricSelector(),

        const SizedBox(height: 12),

        _buildTimeFilters(),

        const SizedBox(height: 16),

        _buildChart(values),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _statCard('Minimum', minimum)),
            const SizedBox(width: 8),
            Expanded(child: _statCard('Average', average)),
            const SizedBox(width: 8),
            Expanded(child: _statCard('Maximum', maximum)),
          ],
        ),

        const SizedBox(height: 26),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reading History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            Text(
              '${history.length} records',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_isLoadingHistory)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildHistory(history),
      ],
    );
  }

  // --------------------------------------------------
  // METRIC SELECTOR
  // --------------------------------------------------

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SensorMetric>(
          value: _selectedMetric,
          isExpanded: true,
          items: SensorMetric.values.map((metric) {
            return DropdownMenuItem(
              value: metric,
              child: Text(_metricLabel(metric)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedMetric = value);
            }
          },
        ),
      ),
    );
  }

  String _metricLabel(SensorMetric metric) {
    switch (metric) {
      case SensorMetric.heartRate:
        return 'Heart Rate (MAX30102)';

      case SensorMetric.spo2:
        return 'SpO₂ (MAX30102)';

      case SensorMetric.temperature:
        return 'Temperature (DHT22)';

      case SensorMetric.humidity:
        return 'Humidity (DHT22)';

      case SensorMetric.gas:
        return 'Gas Sensor ADC (MQ-2)';

      case SensorMetric.acceleration:
        return 'Acceleration (MPU6050)';
    }
  }

  // --------------------------------------------------
  // TIME FILTERS
  // --------------------------------------------------

  Widget _buildTimeFilters() {
    return Row(
      children: [
        for (final hours in [1, 6, 24])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                label: Text('${hours}h'),
                selected: _selectedHours == hours,
                onSelected: (_) {
                  setState(() => _selectedHours = hours);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: _selectedHours == hours
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --------------------------------------------------
  // CHART
  // --------------------------------------------------

  Widget _buildChart(List<double> values) {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_metricTitle ($_metricUnit)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: values.length < 2
                ? const Center(
                    child: Text(
                      'Collecting readings...\n'
                      'At least 2 valid readings needed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: _LineChartPainter(
                      values: values,
                      lineColor: AppColors.primary,
                    ),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STATISTICS
  // --------------------------------------------------

  Widget _statCard(String label, double? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            value == null ? '—' : value.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          Text(
            _metricUnit,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // READING HISTORY
  // --------------------------------------------------

  Widget _buildHistory(List<SensorModel> history) {
    final recent = history.reversed.take(15).toList();

    if (recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(22),
        child: Center(
          child: Text(
            'No readings recorded yet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < recent.length; i++) ...[
            _historyRow(recent[i]),

            if (i != recent.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _historyRow(SensorModel reading) {
    final valid = _isValid(reading);
    final value = valid ? _value(reading) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.history, size: 19, color: AppColors.textSecondary),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              TimeOfDay.fromDateTime(reading.updatedAt).format(context),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          Text(
            value == null
                ? 'Unavailable'
                : '${value.toStringAsFixed(1)} $_metricUnit',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// LINE CHART PAINTER
// --------------------------------------------------

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _LineChartPainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    const leftPadding = 8.0;
    const rightPadding = 8.0;
    const topPadding = 12.0;
    const bottomPadding = 12.0;

    final chartWidth = size.width - leftPadding - rightPadding;

    final chartHeight = size.height - topPadding - bottomPadding;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);

    final range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Horizontal grid lines.
    for (int i = 0; i <= 3; i++) {
      final y = topPadding + chartHeight * i / 3;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = leftPadding + chartWidth * i / (values.length - 1);

      final normalized = (values[i] - minValue) / range;

      final y = topPadding + chartHeight * (1 - normalized);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    // Highlight the latest reading.
    final lastX = leftPadding + chartWidth;

    final lastY =
        topPadding + chartHeight * (1 - (values.last - minValue) / range);

    canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
