import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../device_monitoring/monitoring_centre_screen.dart';
import '../gps_tracking/gps_tracking_screen.dart';
import '../emergency_alerts/emergency_alerts_screen.dart';
import '../settings/settings_screen.dart';
import 'home_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Home',
    'Monitoring Centre',
    'GPS Tracking',
    'Emergency Alerts',
    'Settings & Profile',
  ];

  void _openMonitoring() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              centerTitle: false,
            ),

      // IndexedStack preserves the state of each tab.
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0: Home
          HomeDashboardScreen(onViewAll: _openMonitoring),

          // 1: Monitoring Centre
          const MonitoringCentreScreen(),

          // 2: GPS Tracking
          const GpsTrackingScreen(),

          // 3: Emergency Alerts
          const EmergencyAlertsScreen(),

          // 4: Settings and Profile
          const SettingsScreen(),
        ],
      ),

      // Main bottom navigation.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        elevation: 3,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(
              Icons.monitor_heart_rounded,
              color: AppColors.primary,
            ),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
            ),
            label: 'Location',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(
              Icons.notifications_rounded,
              color: AppColors.primary,
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
