import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DeviceSetupScreen extends StatelessWidget {
  const DeviceSetupScreen({super.key});

  static const List<Map<String, dynamic>> _steps = [
    {
      'number': '01',
      'title': 'Check the wearable hardware',
      'subtitle': 'Inspect the components before powering on.',
      'icon': Icons.memory,
      'details': [
        'Check the ESP8266 or ESP32 development board.',
        'Verify sensor connections and GPIO wiring.',
        'Inspect the GPS and GSM modules, if installed.',
        'Check that all connections are secure.',
        'Look for damaged wires, loose connections or overheating.',
      ],
    },
    {
      'number': '02',
      'title': 'Battery and power setup',
      'subtitle': 'Prepare the battery and power circuit safely.',
      'icon': Icons.battery_charging_full,
      'details': [
        'Use a compatible, undamaged Li-ion battery.',
        'Use a suitable 1S protection and charging circuit for a single-cell battery.',
        'Verify the voltage and current requirements of every module.',
        'Use an appropriate regulated power supply for the microcontroller and sensors.',
        'Ensure the modules share a common ground where required.',
        'Never connect a battery directly to a module unless its input supports that voltage.',
      ],
    },
    {
      'number': '03',
      'title': 'Power on the wearable',
      'subtitle': 'Check whether the hardware starts correctly.',
      'icon': Icons.power_settings_new,
      'details': [
        'Switch on the wearable using its power switch.',
        'Check the development board power indicator.',
        'Connect the board to your computer if serial debugging is needed.',
        'Open the Arduino IDE Serial Monitor.',
        'Verify that the firmware starts without errors.',
      ],
    },
    {
      'number': '04',
      'title': 'Verify the sensors',
      'subtitle': 'Test each connected sensor independently.',
      'icon': Icons.sensors,
      'details': [
        'Check the temperature and humidity sensor readings.',
        'Verify the MPU6050 accelerometer and gyroscope.',
        'Check the pulse sensor, if installed.',
        'Test the gas sensor, if included in your hardware version.',
        'Confirm that readings are changing appropriately.',
        'Calibrate thresholds before enabling automatic alerts.',
      ],
    },
    {
      'number': '05',
      'title': 'Configure GPS tracking',
      'subtitle': 'Verify satellite reception and location data.',
      'icon': Icons.location_on_outlined,
      'details': [
        'Connect the GPS module using the configured UART pins.',
        'Check that the GPS baud rate matches the firmware.',
        'Place the GPS antenna outdoors with a clear view of the sky.',
        'Wait for a valid satellite fix.',
        'Verify that latitude and longitude values are valid.',
        'Do not assume that receiving GPS serial data means a valid location fix.',
      ],
    },
    {
      'number': '06',
      'title': 'Configure SIM and GSM',
      'subtitle': 'Prepare cellular communication if your version uses GSM.',
      'icon': Icons.sim_card_outlined,
      'details': [
        'Insert an active, compatible SIM card.',
        'Verify that the SIM is enabled and has the required network service.',
        'Use a power supply that meets the GSM module voltage and peak-current requirements.',
        'Connect the GSM module ground to the controller ground.',
        'Check network registration using AT commands.',
        'Test SMS or calling functionality only after network registration succeeds.',
      ],
    },
    {
      'number': '07',
      'title': 'Connect the mobile application',
      'subtitle': 'Verify communication between hardware and app.',
      'icon': Icons.smartphone,
      'details': [
        'Open the AlertXBand mobile application.',
        'Check the configured communication method.',
        'Verify Wi-Fi or cellular connectivity as applicable.',
        'Confirm that the backend or IoT dashboard is configured.',
        'Check whether sensor readings are being received.',
        'Demo values in the app should not be mistaken for live hardware data.',
      ],
    },
    {
      'number': '08',
      'title': 'Test emergency features',
      'subtitle': 'Validate the safety workflow before real-world use.',
      'icon': Icons.health_and_safety_outlined,
      'details': [
        'Test the SOS button using a controlled test environment.',
        'Verify that the configured alert reaches its intended destination.',
        'Test fall detection with safe, controlled movements.',
        'Check false-positive and missed-event behaviour.',
        'Verify location information in the emergency alert.',
        'Never test by deliberately falling or placing yourself in danger.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Device Setup Guide'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.watch_outlined, color: Colors.white, size: 36),
                  SizedBox(height: 15),
                  Text(
                    'Set up your AlertXBand',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Follow these steps to configure and test your '
                    'wearable safety monitoring prototype.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'SETUP CHECKLIST',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            ..._steps.map((step) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 7,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
                  leading: Container(
                    height: 43,
                    width: 43,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    step['title'] as String,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      step['subtitle'] as String,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 8),
                    ...(step['details'] as List<String>).map((detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 17,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                detail,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 23,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Safety notice: AlertXBand is a prototype. '
                      'Do not depend on it as your only emergency '
                      'communication or medical monitoring system. '
                      'Verify all hardware and alert functions before testing.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'AlertXBand · Device Setup Guide',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
