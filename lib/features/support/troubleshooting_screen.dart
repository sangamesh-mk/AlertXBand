import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TroubleshootingScreen extends StatelessWidget {
  const TroubleshootingScreen({super.key});

  static const List<Map<String, dynamic>> _issues = [
    {
      'category': 'Power & Battery',
      'icon': Icons.battery_alert_outlined,
      'problem': 'Wearable is not turning on',
      'cause':
          'Battery may be discharged, wiring may be loose, or the power supply may be insufficient.',
      'solutions': [
        'Check whether the battery is charged.',
        'Inspect the battery connector and power switch.',
        'Verify battery polarity and protection board connections.',
        'Check whether the development board power LED turns on.',
        'If available, measure the supply voltage with a multimeter.',
      ],
    },
    {
      'category': 'Power & Battery',
      'icon': Icons.battery_1_bar_outlined,
      'problem': 'Battery drains too quickly',
      'cause':
          'GPS, GSM communication, sensors and display modules may consume significant power.',
      'solutions': [
        'Check for unnecessary modules remaining powered.',
        'Inspect the circuit for short circuits or overheating.',
        'Reduce unnecessary sensor polling and display updates.',
        'Check the battery capacity and condition.',
        'Measure actual operating current to identify excessive consumption.',
      ],
    },
    {
      'category': 'Connectivity',
      'icon': Icons.wifi_off_outlined,
      'problem': 'Wi-Fi is not connecting',
      'cause':
          'Incorrect credentials, weak signal or firmware configuration problems.',
      'solutions': [
        'Verify the Wi-Fi network name and password.',
        'Check whether the hotspot or router is active.',
        'Confirm that the selected network is supported by the board.',
        'Restart the microcontroller.',
        'Check the serial monitor for connection errors.',
      ],
    },
    {
      'category': 'Connectivity',
      'icon': Icons.sim_card_alert_outlined,
      'problem': 'SIM800L is not registering',
      'cause':
          'The SIM may be inactive, network coverage may be unavailable, or the power supply may be inadequate.',
      'solutions': [
        'Verify that the SIM is active and compatible with the module.',
        'Check antenna connections.',
        'Check SIM insertion and SIM PIN settings.',
        'Use an appropriate regulated power supply that supports GSM current peaks.',
        'Check network registration using AT+CREG?.',
        'Check signal quality using AT+CSQ.',
      ],
    },
    {
      'category': 'Location',
      'icon': Icons.gps_off_outlined,
      'problem': 'GPS is showing no location',
      'cause': 'The GPS module may not have acquired a satellite fix.',
      'solutions': [
        'Move outdoors to an open area.',
        'Position the GPS antenna with a clear view of the sky.',
        'Check GPS TX and RX wiring.',
        'Verify the configured UART pins and baud rate.',
        'Wait for satellite acquisition.',
        'Check whether valid latitude and longitude values are received.',
      ],
    },
    {
      'category': 'Sensors',
      'icon': Icons.sensors_off_outlined,
      'problem': 'Sensor readings are not changing',
      'cause':
          'Incorrect wiring, sensor initialization failure or firmware configuration issues.',
      'solutions': [
        'Check the sensor power and ground connections.',
        'Verify the GPIO pin assignments.',
        'Check I2C addresses using an I2C scanner when applicable.',
        'Verify that the correct sensor library is installed.',
        'Inspect the serial monitor for sensor initialization errors.',
        'Test each sensor separately before integrated testing.',
      ],
    },
    {
      'category': 'Sensors',
      'icon': Icons.personal_injury_outlined,
      'problem': 'Fall detection gives false alerts',
      'cause':
          'Motion thresholds may be incorrectly configured or the sensor may not be calibrated.',
      'solutions': [
        'Check MPU6050 wiring and communication.',
        'Verify accelerometer and gyroscope readings.',
        'Calibrate the sensor while it is stationary.',
        'Review the fall detection thresholds.',
        'Test using controlled, safe movements.',
        'Avoid enabling automatic emergency alerts until validation is complete.',
      ],
    },
    {
      'category': 'Application',
      'icon': Icons.sync_problem_outlined,
      'problem': 'App is not receiving live readings',
      'cause':
          'The hardware, network, backend or data stream may not be configured correctly.',
      'solutions': [
        'Verify that the wearable is powered on.',
        'Check the hardware network connection.',
        'Confirm that the backend or IoT platform is connected.',
        'Verify the configured data stream or virtual pin assignments.',
        'Check whether the app is displaying demo values instead of live data.',
      ],
    },
    {
      'category': 'Emergency Alerts',
      'icon': Icons.sos_outlined,
      'problem': 'SOS alert is not being delivered',
      'cause':
          'The alert communication path may be disconnected or incorrectly configured.',
      'solutions': [
        'Check the SOS button and its GPIO connection.',
        'Verify the GSM or Wi-Fi connection.',
        'Confirm that the alert destination is configured.',
        'Check backend or messaging service connectivity.',
        'Test alert delivery in a controlled environment.',
        'Never rely on an unverified prototype for emergency assistance.',
      ],
    },
  ];

  Widget _buildIssueCard(Map<String, dynamic> issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
        leading: Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            issue['icon'] as IconData,
            color: AppColors.warning,
            size: 22,
          ),
        ),
        title: Text(
          issue['problem'] as String,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            issue['category'] as String,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        children: [
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Possible cause',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 7),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              issue['cause'] as String,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recommended solutions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...(issue['solutions'] as List<String>).asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 21,
                    width: 21,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Troubleshooting'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    color: Colors.white,
                    size: 37,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Having a problem?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Find possible causes and practical solutions '
                          'for common AlertXBand issues.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'COMMON PROBLEMS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            ..._issues.map(_buildIssueCard),

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
                  Icon(Icons.info_outline, color: AppColors.warning, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'These suggestions are intended for prototype '
                      'testing. Disconnect power before changing wiring. '
                      'Use appropriate battery protection and regulated '
                      'power supplies.',
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

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'AlertXBand · Troubleshooting Guide',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
