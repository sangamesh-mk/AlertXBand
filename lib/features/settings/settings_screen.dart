import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _fallAlertsEnabled = true;
  bool _healthAlertsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            _buildProfileCard(),

            const SizedBox(height: 25),

            // ACCOUNT
            _sectionTitle('Account'),

            _settingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              subtitle: 'Manage your profile details',
              onTap: () => context.push('/personal-information'),
            ),

            _settingsTile(
              icon: Icons.security_rounded,
              title: 'Account & Security',
              subtitle: 'Password, login and account security',
              onTap: () => context.push('/account-security'),
            ),

            _settingsTile(
              icon: Icons.emergency_outlined,
              title: 'Emergency Contacts',
              subtitle: 'Manage your emergency contacts',
              onTap: () => context.push('/emergency-contacts'),
            ),

            const SizedBox(height: 20),

            // SAFETY PREFERENCES
            _sectionTitle('Safety Preferences'),

            _switchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Receive application notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),

            _switchTile(
              icon: Icons.accessibility_new_rounded,
              title: 'Fall Detection Alerts',
              subtitle: 'Enable fall-related alert preferences',
              value: _fallAlertsEnabled,
              onChanged: (value) {
                setState(() => _fallAlertsEnabled = value);
              },
            ),

            _switchTile(
              icon: Icons.favorite_border_rounded,
              title: 'Health Alerts',
              subtitle: 'Enable health-related alert preferences',
              value: _healthAlertsEnabled,
              onChanged: (value) {
                setState(() => _healthAlertsEnabled = value);
              },
            ),

            _switchTile(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: 'Location preference for the application',
              value: _locationEnabled,
              onChanged: (value) {
                setState(() => _locationEnabled = value);
              },
            ),

            const SizedBox(height: 20),

            // DEVICE & APPLICATION
            _sectionTitle('Device & Application'),

            _settingsTile(
              icon: Icons.watch_outlined,
              title: 'My Wearable Device',
              subtitle: 'Device information and connection',
              onTap: () => context.push('/device-monitoring'),
            ),

            _settingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How AlertXBand handles your information',
              onTap: () => context.push('/privacy-policy'),
            ),

            _settingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About AlertXBand',
              subtitle: 'Application information and version',
              onTap: _showAboutDialog,
            ),

            const SizedBox(height: 20),

            // CONTACT US
            _sectionTitle('Contact Us'),

            _settingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Get assistance with AlertXBand',
              onTap: () => context.push('/help-support'),
            ),

            _settingsTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              subtitle: 'Rules and conditions for using AlertXBand',
              onTap: () => context.push('/terms-conditions'),
            ),

            _settingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'App Permissions',
              subtitle: 'Manage location, notifications and device access',
              onTap: () => context.push('/app-permissions'),
            ),

            _settingsTile(
              icon: Icons.report_problem_outlined,
              title: 'Report a Problem',
              subtitle: 'Report bugs or technical issues',
              onTap: () => context.push('/report-problem'),
            ),

            const SizedBox(height: 25),

            // DEMO MODE
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DA),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFE2A3)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.science_outlined,
                    color: Color(0xFF986000),
                    size: 23,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Mode Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF805300),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Some features use simulated data. '
                          'Firebase and hardware integration are pending.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: Color(0xFF805300),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // EXIT GUEST MODE
            OutlinedButton.icon(
              onPressed: _confirmExitGuestMode,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Exit Guest Mode'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'AlertXBand v1.0.0',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 5),

            const Center(
              child: Text(
                'Your Safety. Our Intelligence.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Demo Account',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Exploring AlertXBand',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_user_outlined,
            color: Colors.white70,
            size: 25,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: _iconContainer(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: _iconContainer(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _iconContainer(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 21),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'AlertXBand',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Your Safety. Our Intelligence.',
      children: const [
        SizedBox(height: 12),
        Text(
          'An AI-powered wearable safety monitoring '
          'application designed to support personal safety, '
          'health monitoring and emergency assistance.',
        ),
      ],
    );
  }

  void _confirmExitGuestMode() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Exit Guest Mode?'),
          content: const Text(
            'You will return to the login screen. '
            'Your saved contacts and alert history will remain on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.go('/login');
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
