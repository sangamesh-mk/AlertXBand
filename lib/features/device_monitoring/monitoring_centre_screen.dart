import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/sensor_simulator_service.dart';
import 'sensor_analytics_panel.dart';

enum MonitoringType { health, environment, motion }

class MonitoringCentreScreen extends ConsumerWidget {
  const MonitoringCentreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(sensorReadingsProvider);

    return readings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Sensor data error: $error')),
      data: (sensor) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _DemoBanner(),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Health',
            sensorNames: 'MAX30102',
            icon: Icons.favorite_rounded,
            available: sensor.healthSignalValid,
            onTap: () => _open(context, MonitoringType.health),
          ),
          _SectionCard(
            title: 'Environment',
            sensorNames: 'DHT22 + MQ-2',
            icon: Icons.thermostat_rounded,
            available:
                sensor.temperatureValid &&
                sensor.humidityValid &&
                sensor.mq2Available,
            onTap: () => _open(context, MonitoringType.environment),
          ),
          _SectionCard(
            title: 'Motion',
            sensorNames: 'MPU6050',
            icon: Icons.directions_run_rounded,
            available: sensor.motionSensorAvailable,
            onTap: () => _open(context, MonitoringType.motion),
          ),
          const SizedBox(height: 24),
          const SensorAnalyticsPanel(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _open(BuildContext context, MonitoringType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MonitoringDetailScreen(type: type),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DEMO MODE — All readings and availability are simulated.',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.sensorNames,
    required this.icon,
    required this.available,
    required this.onTap,
  });

  final String title;
  final String sensorNames;
  final IconData icon;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Icon(icon, color: AppColors.primary, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sensorNames),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              available ? Icons.check_circle : Icons.error_outline,
              color: available ? AppColors.success : AppColors.danger,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              available ? 'Available' : 'Check sensor',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class MonitoringDetailScreen extends ConsumerWidget {
  const MonitoringDetailScreen({super.key, required this.type});

  final MonitoringType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(sensorReadingsProvider);
    final title = switch (type) {
      MonitoringType.health => 'Health Monitoring',
      MonitoringType.environment => 'Environment Monitoring',
      MonitoringType.motion => 'Motion Monitoring',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: readings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Sensor data error: $error')),
        data: (sensor) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _DemoBanner(),
            const SizedBox(height: 16),
            ..._buildReadings(sensor),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReadings(SensorModel sensor) {
    switch (type) {
      case MonitoringType.health:
        return [
          _sensorAvailability('MAX30102', sensor.healthSignalValid),
          _reading(
            'Heart rate',
            sensor.healthSignalValid ? '${sensor.heartRate} BPM' : '—',
          ),
          _reading('SpO₂', sensor.healthSignalValid ? '${sensor.spo2} %' : '—'),
        ];
      case MonitoringType.environment:
        final dhtAvailable = sensor.temperatureValid && sensor.humidityValid;
        return [
          _sensorAvailability('DHT22', dhtAvailable),
          _reading(
            'Temperature',
            sensor.temperatureValid
                ? '${sensor.temperature.toStringAsFixed(1)} °C'
                : '—',
          ),
          _reading(
            'Humidity',
            sensor.humidityValid
                ? '${sensor.humidity.toStringAsFixed(1)} % RH'
                : '—',
          ),
          const SizedBox(height: 12),
          _sensorAvailability('MQ-2', sensor.mq2Available),
          _reading(
            'Gas sensor raw ADC',
            sensor.mq2Available ? '${sensor.mq2RawAdc}' : '—',
          ),
        ];
      case MonitoringType.motion:
        return [
          _sensorAvailability('MPU6050', sensor.motionSensorAvailable),
          _reading(
            'Acceleration',
            sensor.motionSensorAvailable
                ? '${sensor.accelerationMagnitudeG.toStringAsFixed(2)} g'
                : '—',
          ),
          _reading(
            'Gyroscope',
            sensor.motionSensorAvailable
                ? '${sensor.gyroMagnitudeDps.toStringAsFixed(1)} °/s'
                : '—',
          ),
          _reading(
            'Fall status',
            sensor.motionSensorAvailable
                ? (sensor.fallDetected ? 'Fall detected' : 'No fall detected')
                : '—',
          ),
        ];
    }
  }

  Widget _sensorAvailability(String sensorName, bool available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              sensorName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: available ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 6),
          Text(
            available ? 'Available' : 'Unavailable',
            style: TextStyle(
              fontSize: 12,
              color: available ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reading(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
