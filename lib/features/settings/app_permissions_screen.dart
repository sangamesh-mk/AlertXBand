import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppPermissionsScreen extends StatelessWidget {
  const AppPermissionsScreen({super.key});

  static const List<Map<String, dynamic>> _permissions = [
    {
      'title': 'Location',
      'subtitle': 'GPS tracking and emergency location sharing',
      'icon': Icons.location_on_outlined,
      'purpose':
          'Allows AlertXBand to access location information when '
          'location features are enabled. This supports live tracking '
          'and sharing your location during emergency situations.',
      'required': true,
    },
    {
      'title': 'Notifications',
      'subtitle': 'SOS alerts, fall alerts and device notifications',
      'icon': Icons.notifications_active_outlined,
      'purpose':
          'Allows the application to display emergency alerts, '
          'device connection updates, fall detection notifications '
          'and other important information.',
      'required': true,
    },
    {
      'title': 'Bluetooth',
      'subtitle': 'Connect to compatible wearable devices',
      'icon': Icons.bluetooth_outlined,
      'purpose':
          'May be required for discovering and communicating with '
          'compatible Bluetooth-enabled wearable devices.',
      'required': false,
    },
    {
      'title': 'Nearby Devices',
      'subtitle': 'Discover and connect to nearby devices',
      'icon': Icons.devices_outlined,
      'purpose':
          'Allows the application to discover and communicate with '
          'nearby compatible devices where supported by the hardware.',
      'required': false,
    },
    {
      'title': 'Camera',
      'subtitle': 'Profile image and supported camera features',
      'icon': Icons.camera_alt_outlined,
      'purpose':
          'May be used when you choose to capture a profile image '
          'or use a future camera-based application feature.',
      'required': false,
    },
    {
      'title': 'Background Activity',
      'subtitle': 'Support monitoring when the app is not open',
      'icon': Icons.sync_outlined,
      'purpose':
          'Some monitoring and location features may require '
          'background execution. Availability depends on device '
          'settings, operating-system restrictions and battery policies.',
      'required': false,
    },
  ];

  void _showPermissionInfo(
    BuildContext context,
    Map<String, dynamic> permission,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(permission['title'] as String),
        content: Text(
          permission['purpose'] as String,
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 11),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _permissionCard(
    BuildContext context,
    Map<String, dynamic> permission,
  ) {
    final isRequired = permission['required'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            permission['icon'] as IconData,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          permission['title'] as String,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                permission['subtitle'] as String,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                isRequired ? 'CORE PERMISSION' : 'OPTIONAL PERMISSION',
                style: TextStyle(
                  color: isRequired
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: 'Permission information',
          onPressed: () => _showPermissionInfo(context, permission),
          icon: const Icon(Icons.info_outline, color: AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Permissions'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Manage App Permissions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Understand why AlertXBand may need access '
                    'to certain features on your device.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            _sectionTitle('Essential Permissions'),

            ..._permissions
                .where((item) => item['required'] == true)
                .map((item) => _permissionCard(context, item)),

            _sectionTitle('Additional Permissions'),

            ..._permissions
                .where((item) => item['required'] == false)
                .map((item) => _permissionCard(context, item)),

            const SizedBox(height: 15),

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
                  Icon(Icons.info_outline, color: AppColors.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Permission status and operating-system settings '
                      'integration will be enabled during backend and '
                      'device integration. This screen currently '
                      'provides permission information only.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'AlertXBand • Your Safety. Our Intelligence.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
