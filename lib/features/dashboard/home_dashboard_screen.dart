import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../services/sensor_simulator_service.dart';
import '../../models/sensor_model.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorState = ref.watch(sensorReadingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: sensorState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to load sensor data: $error'),
            ),
          ),
          data: (sensor) => _buildDashboard(context, sensor),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, SensorModel sensor) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          _buildHeader(context),

          const SizedBox(height: 18),

          _buildDemoBanner(),

          const SizedBox(height: 20),

          _buildDeviceStatus(sensor),

          const SizedBox(height: 12),

          // Device Control Centre shortcut
          _buildDeviceControlShortcut(context),

          const SizedBox(height: 24),

          _buildSectionTitle('Live sensor overview', 'View all', onViewAll),

          const SizedBox(height: 12),

          _buildSensorGrid(context, sensor),

          const SizedBox(height: 24),

          _buildSectionTitle('Safety status', null),

          const SizedBox(height: 12),

          _buildSafetyStatus(sensor),

          const SizedBox(height: 24),

          _buildSectionTitle('Emergency assistance', null),

          const SizedBox(height: 12),

          _buildSosButton(context),

          const SizedBox(height: 14),

          const Center(
            child: Text(
              'AlertXBand • Your safety. Our intelligence.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AlertXBand',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Your personal safety companion',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // Notification Centre navigation
        IconButton(
          onPressed: () {
            context.push('/notifications');
          },
          icon: const Icon(Icons.notifications_outlined),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // DEMO MODE BANNER
  // --------------------------------------------------

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DA),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFFE2A3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, color: Color(0xFF986000)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DEMO MODE  •  Showing simulated readings',
              style: TextStyle(
                color: Color(0xFF805300),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // WEARABLE DEVICE STATUS
  // --------------------------------------------------

  Widget _buildDeviceStatus(SensorModel sensor) {
    final connected = sensor.deviceConnected;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Wearable device',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: connected
                          ? const Color(0xFF75F0B0)
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      connected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'AlertXBand',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            connected
                ? 'Device simulator is active'
                : 'Waiting for device connection',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 17),

          const Divider(color: Colors.white24),

          const Row(
            children: [
              Icon(Icons.sync, color: Colors.white70, size: 16),
              SizedBox(width: 7),
              Text(
                'Readings update automatically',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DEVICE CONTROL CENTRE SHORTCUT
  // --------------------------------------------------

  Widget _buildDeviceControlShortcut(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () {
          context.push('/device-monitoring');
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_remote_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Control Centre',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage device status, modules and diagnostics',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SECTION TITLE
  // --------------------------------------------------

  Widget _buildSectionTitle(
    String title,
    String? action, [
    VoidCallback? onTap,
  ]) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // --------------------------------------------------
  // LIVE SENSOR GRID
  // --------------------------------------------------

  Widget _buildSensorGrid(BuildContext context, SensorModel sensor) {
    final items = [
      _SensorInfo(
        title: 'Heart rate',
        value: '${sensor.heartRate}',
        unit: 'BPM',
        icon: Icons.favorite_rounded,
        color: AppColors.danger,
      ),
      _SensorInfo(
        title: 'SpO₂',
        value: '${sensor.spo2}',
        unit: '%',
        icon: Icons.bloodtype_rounded,
        color: AppColors.primary,
      ),
      _SensorInfo(
        title: 'Temperature',
        value: sensor.temperature.toStringAsFixed(1),
        unit: '°C',
        icon: Icons.thermostat_rounded,
        color: AppColors.warning,
      ),
      _SensorInfo(
        title: 'Humidity',
        value: sensor.humidity.toStringAsFixed(1),
        unit: '% RH',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF168C9C),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: item.color, size: 19),
                  const Spacer(),
                  const Icon(Icons.circle, color: AppColors.success, size: 7),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 3),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.unit,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // SAFETY STATUS
  // --------------------------------------------------

  Widget _buildSafetyStatus(SensorModel sensor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _statusRow(
            'Fall detection',
            sensor.fallDetected ? 'Fall detected' : 'No fall detected',
            sensor.fallDetected ? AppColors.danger : AppColors.success,
            Icons.accessibility_new,
          ),

          const Divider(height: 22),

          _statusRow(
            'GPS availability',
            sensor.gpsAvailable ? 'GPS available' : 'No GPS fix',
            sensor.gpsAvailable ? AppColors.success : AppColors.warning,
            Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String title, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),

        const SizedBox(width: 11),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // SOS BUTTON
  // --------------------------------------------------

  Widget _buildSosButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _showSosConfirmation(context),
        icon: const Icon(Icons.sos_rounded, size: 25),
        label: const Text(
          'SOS EMERGENCY',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _showSosConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.danger,
          size: 38,
        ),
        title: const Text('Emergency SOS'),
        content: const Text(
          'This is currently Demo Mode. No emergency call, SMS or '
          'notification will be sent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo only: SOS hardware integration is not active.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SENSOR INFORMATION MODEL
// --------------------------------------------------

class _SensorInfo {
  const _SensorInfo({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
}
