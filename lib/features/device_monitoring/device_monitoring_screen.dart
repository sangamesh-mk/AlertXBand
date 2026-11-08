import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/device_service.dart';

class DeviceMonitoringScreen extends StatelessWidget {
  const DeviceMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DeviceService.instance,
      builder: (context, child) {
        final device = DeviceService.instance;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Device Control Centre'),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: 'Refresh demo status',
                onPressed: device.refreshStatus,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: device.refreshStatus,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _demoBanner(),

                const SizedBox(height: 16),

                _deviceCard(device),

                const SizedBox(height: 16),

                _sectionTitle('Device overview'),

                const SizedBox(height: 10),

                _overviewGrid(device),

                const SizedBox(height: 22),

                _sectionTitle('Module availability'),

                const SizedBox(height: 10),

                _moduleCard(
                  icon: Icons.memory,
                  title: 'ESP32 Controller',
                  subtitle: device.esp32Status,
                  available: device.isConnected,
                ),

                _moduleCard(
                  icon: Icons.location_on_outlined,
                  title: 'GPS Module',
                  subtitle: device.gpsStatus,
                  available: device.isConnected,
                ),

                _moduleCard(
                  icon: Icons.cell_tower,
                  title: 'GSM / SIM800L',
                  subtitle: device.gsmStatus,
                  available: false,
                ),

                _moduleCard(
                  icon: Icons.sensors,
                  title: 'Sensor Modules',
                  subtitle: device.sensorStatus,
                  available:
                      device.isConnected && device.masterMonitoringEnabled,
                ),

                const SizedBox(height: 22),

                _sectionTitle('Monitoring controls'),

                const SizedBox(height: 10),

                _controlPanel(device),

                const SizedBox(height: 22),

                _sectionTitle('Device diagnostics'),

                const SizedBox(height: 10),

                _diagnosticsCard(context, device),

                const SizedBox(height: 16),

                _lastUpdatedCard(device),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // DEMO MODE BANNER
  // --------------------------------------------------

  Widget _demoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEMO MODE ACTIVE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The information on this screen is simulated. '
                  'No physical AlertXBand device is currently connected.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DEVICE INFORMATION CARD
  // --------------------------------------------------

  Widget _deviceCard(DeviceService device) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.watch_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const Spacer(),

              _statusPill(
                device.isConnected ? 'DEMO ONLINE' : 'DEMO OFFLINE',
                device.isConnected ? AppColors.success : AppColors.danger,
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'AlertXBand Wearable',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Device ID: AXB-DEMO-001',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(Icons.battery_5_bar, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                '${device.batteryPercentage}% simulated battery',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: device.toggleDemoConnection,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(device.isConnected ? Icons.link_off : Icons.link),
              label: Text(
                device.isConnected ? 'Simulate Disconnect' : 'Simulate Connect',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DEVICE OVERVIEW GRID
  // --------------------------------------------------

  Widget _overviewGrid(DeviceService device) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _overviewCard(
          icon: Icons.battery_full,
          title: 'Battery',
          value: '${device.batteryPercentage}%',
          subtitle: 'Simulated',
          color: AppColors.success,
        ),

        _overviewCard(
          icon: Icons.memory,
          title: 'Controller',
          value: device.isConnected ? 'Online' : 'Offline',
          subtitle: 'ESP32 demo status',
          color: AppColors.primary,
        ),

        _overviewCard(
          icon: Icons.location_on,
          title: 'GPS',
          value: device.isConnected ? 'Available' : 'Offline',
          subtitle: 'Demo status',
          color: AppColors.secondary,
        ),

        _overviewCard(
          icon: Icons.cell_tower,
          title: 'GSM',
          value: 'Not configured',
          subtitle: 'SIM800L',
          color: AppColors.warning,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // INDIVIDUAL OVERVIEW CARD
  // --------------------------------------------------

  Widget _overviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 21),

          const SizedBox(height: 5),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MODULE AVAILABILITY
  // --------------------------------------------------

  Widget _moduleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 25),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            available ? Icons.check_circle : Icons.info_outline,
            color: available ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MONITORING CONTROL PANEL
  // --------------------------------------------------

  Widget _controlPanel(DeviceService device) {
    final canControl = device.isConnected && device.masterMonitoringEnabled;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _controlSwitch(
            title: 'Master Monitoring',
            subtitle: 'Enable or pause all monitoring functions',
            icon: Icons.power_settings_new,
            value: device.masterMonitoringEnabled,
            enabled: device.isConnected,
            onChanged: device.setMasterMonitoring,
          ),

          const Divider(height: 22),

          _controlSwitch(
            title: 'Fall Detection',
            subtitle: 'Monitor movement and fall events',
            icon: Icons.accessibility_new,
            value: device.fallDetectionEnabled,
            enabled: canControl,
            onChanged: device.setFallDetection,
          ),

          const Divider(height: 22),

          _controlSwitch(
            title: 'Health Monitoring',
            subtitle: 'Heart rate and blood oxygen monitoring',
            icon: Icons.favorite_outline,
            value: device.healthMonitoringEnabled,
            enabled: canControl,
            onChanged: device.setHealthMonitoring,
          ),

          const Divider(height: 22),

          _controlSwitch(
            title: 'Environment Monitoring',
            subtitle: 'Temperature, humidity and gas monitoring',
            icon: Icons.thermostat_outlined,
            value: device.environmentMonitoringEnabled,
            enabled: canControl,
            onChanged: device.setEnvironmentMonitoring,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo controls only. Changes are not sent '
                    'to the physical wearable.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Switch.adaptive(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeTrackColor: AppColors.success,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // DEVICE DIAGNOSTICS
  // --------------------------------------------------

  Widget _diagnosticsCard(BuildContext context, DeviceService device) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check the simulated device modules.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final results = await device.runDiagnostics();

                if (!context.mounted) return;

                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Demo Diagnostics'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: results.map((result) {
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              result.passed
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color: result.passed
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            title: Text(
                              result.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              result.status,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.health_and_safety_outlined),
              label: const Text('Run Demo Diagnostics'),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LAST UPDATED INFORMATION
  // --------------------------------------------------

  Widget _lastUpdatedCard(DeviceService device) {
    return Row(
      children: [
        const Icon(Icons.update, size: 17, color: AppColors.textSecondary),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            'Demo status updated: ${device.formattedLastUpdated}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // SECTION TITLE
  // --------------------------------------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // --------------------------------------------------
  // STATUS PILL
  // --------------------------------------------------

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
