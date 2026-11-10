import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../services/device_service.dart';
import '../../services/sensor_simulator_service.dart';

class DeviceMonitoringScreen extends ConsumerWidget {
  const DeviceMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = DeviceService.instance;
    final mode = ref.watch(sensorDataModeProvider);

    return AnimatedBuilder(
      animation: device,
      builder: (context, child) {
        final simulationMode = mode == SensorDataMode.simulator;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Device Control Centre'),
            actions: [
              IconButton(
                tooltip: 'Refresh device status',
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
                _modeSelector(context, ref, simulationMode),

                const SizedBox(height: 16),

                _modeBanner(simulationMode),

                const SizedBox(height: 16),

                _deviceCard(device, simulationMode),

                const SizedBox(height: 20),

                _sectionTitle('Device overview'),

                const SizedBox(height: 10),

                _overviewGrid(device, simulationMode),

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
                  available:
                      device.isConnected &&
                      (simulationMode ||
                          device.gpsStatus.contains('Available')),
                ),

                _moduleCard(
                  icon: Icons.wifi,
                  title: 'Wi-Fi Communication',
                  subtitle: simulationMode
                      ? 'Simulation only'
                      : device.connectionType == 'wifi'
                      ? 'Connected through Wi-Fi'
                      : 'Not currently active',
                  available:
                      !simulationMode &&
                      device.isConnected &&
                      device.connectionType == 'wifi',
                ),

                _moduleCard(
                  icon: Icons.cell_tower,
                  title: 'GSM / SIM800L',
                  subtitle: device.gsmStatus,
                  available:
                      !simulationMode &&
                      device.isConnected &&
                      device.connectionType == 'gsm',
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

                _controlPanel(device, simulationMode),

                const SizedBox(height: 22),

                _sectionTitle('Device diagnostics'),

                const SizedBox(height: 10),

                _diagnosticsCard(context, device, simulationMode),

                const SizedBox(height: 16),

                _lastUpdatedCard(device, simulationMode),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // MODE SELECTOR
  // --------------------------------------------------

  Widget _modeSelector(
    BuildContext context,
    WidgetRef ref,
    bool simulationMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operating Mode',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Choose the source of sensor readings.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _modeButton(
                  label: 'Simulator',
                  icon: Icons.science_outlined,
                  selected: simulationMode,
                  onPressed: () {
                    DeviceService.instance.setSimulationMode(true);

                    ref.read(sensorDataModeProvider.notifier).useSimulator();
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _modeButton(
                  label: 'Real Hardware',
                  icon: Icons.watch_outlined,
                  selected: !simulationMode,
                  onPressed: () {
                    DeviceService.instance.setSimulationMode(false);

                    ref.read(sensorDataModeProvider.notifier).useHardware();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.white : AppColors.primary,
        backgroundColor: selected ? AppColors.primary : Colors.transparent,
        side: BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      ),
    );
  }

  // --------------------------------------------------
  // MODE BANNER
  // --------------------------------------------------

  Widget _modeBanner(bool simulationMode) {
    final color = simulationMode ? AppColors.warning : AppColors.primary;

    final title = simulationMode
        ? 'SIMULATOR MODE ACTIVE'
        : 'HARDWARE MODE SELECTED';

    final message = simulationMode
        ? 'Sensor readings and connection status are simulated. '
              'No physical wearable is required.'
        : 'The app is listening for live ESP32 telemetry through '
              'Firebase Realtime Database.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            simulationMode ? Icons.science_outlined : Icons.memory,
            color: color,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
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

  Widget _deviceCard(DeviceService device, bool simulationMode) {
    final status = simulationMode
        ? device.isConnected
              ? 'DEMO ONLINE'
              : 'DEMO OFFLINE'
        : device.isConnected
        ? 'HARDWARE ONLINE'
        : 'HARDWARE OFFLINE';

    final battery = device.reportedBatteryPercentage;

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
                status,
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
            'Device ID: ${device.deviceId}',
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
                battery == null
                    ? 'Battery: Waiting for telemetry'
                    : 'Battery: $battery%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (simulationMode) ...[
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
                  device.isConnected
                      ? 'Simulate Disconnect'
                      : 'Simulate Connect',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DEVICE OVERVIEW
  // --------------------------------------------------

  Widget _overviewGrid(DeviceService device, bool simulationMode) {
    final battery = device.reportedBatteryPercentage;

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
          value: battery == null ? '--' : '$battery%',
          subtitle: simulationMode ? 'Simulated battery' : 'ESP32 telemetry',
          color: AppColors.success,
        ),

        _overviewCard(
          icon: Icons.memory,
          title: 'Controller',
          value: device.isConnected ? 'Online' : 'Offline',
          subtitle: simulationMode ? 'ESP32 demo status' : 'Real ESP32 status',
          color: AppColors.primary,
        ),

        _overviewCard(
          icon: Icons.location_on,
          title: 'GPS',
          value: simulationMode
              ? device.isConnected
                    ? 'Available'
                    : 'Offline'
              : device.gpsStatus.contains('Available')
              ? 'Available'
              : 'Waiting',
          subtitle: 'NEO-6M',
          color: AppColors.secondary,
        ),

        _overviewCard(
          icon: Icons.cell_tower,
          title: 'Communication',
          value: device.connectionType.toUpperCase(),
          subtitle: simulationMode ? 'Simulator' : 'Wi-Fi / GSM',
          color: AppColors.warning,
        ),
      ],
    );
  }

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
  // MONITORING CONTROLS
  // --------------------------------------------------

  Widget _controlPanel(DeviceService device, bool simulationMode) {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    simulationMode
                        ? 'Simulator controls affect generated readings only.'
                        : 'These controls currently change app-side settings. '
                              'They are not yet sent to the physical ESP32.',
                    style: const TextStyle(
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

  Widget _diagnosticsCard(
    BuildContext context,
    DeviceService device,
    bool simulationMode,
  ) {
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
          Text(
            simulationMode
                ? 'Check the simulated device modules.'
                : 'Check the current hardware telemetry status.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
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
                      title: Text(
                        simulationMode
                            ? 'Simulator Diagnostics'
                            : 'Hardware Diagnostics',
                      ),
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
              label: Text(
                simulationMode
                    ? 'Run Simulator Diagnostics'
                    : 'Run Hardware Diagnostics',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LAST UPDATED
  // --------------------------------------------------

  Widget _lastUpdatedCard(DeviceService device, bool simulationMode) {
    return Row(
      children: [
        const Icon(Icons.update, size: 17, color: AppColors.textSecondary),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            '${simulationMode ? 'Simulator' : 'Device'} status updated: '
            '${device.formattedLastUpdated}',
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
  // SHARED UI
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
