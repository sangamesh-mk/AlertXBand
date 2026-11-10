import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _biometricEnabled = false;

  void _showDemoMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ChangePasswordDialog(
          onPasswordValidated: () {
            Navigator.of(dialogContext).pop();

            _showDemoMessage(
              'Password validation successful. '
              'Actual password changes require Firebase Authentication.',
            );
          },
        );
      },
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showDemoMessage(
        'Sign out will be enabled after authentication integration.',
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11, top: 22),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account & Security'),
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
                  Icon(Icons.security, color: Colors.white, size: 37),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your account security',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Manage your account and security preferences.',
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

            _sectionTitle('Account information'),

            _settingsCard([
              _settingsTile(
                icon: Icons.email_outlined,
                title: 'Email Address',
                subtitle: 'Manage your registered email',
                onTap: () => _showDemoMessage(
                  'Email management will be available after Firebase integration.',
                ),
              ),
              const Divider(height: 1, indent: 70),
              _settingsTile(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                subtitle: 'Manage your registered phone number',
                onTap: () => _showDemoMessage(
                  'Phone verification will be available after backend integration.',
                ),
              ),
            ]),

            _sectionTitle('Password & authentication'),

            _settingsCard([
              _settingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: _showChangePasswordDialog,
              ),
              const Divider(height: 1, indent: 70),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                secondary: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Biometric Login',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text(
                  'Use fingerprint or face authentication',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                value: _biometricEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                  _showDemoMessage(
                    'Biometric authentication requires device authentication integration.',
                  );
                },
              ),
            ]),

            _sectionTitle('Privacy & security'),

            _settingsCard([
              _settingsTile(
                icon: Icons.devices_outlined,
                title: 'Active Sessions',
                subtitle: 'Review devices signed into your account',
                onTap: () => _showDemoMessage(
                  'Session management requires backend integration.',
                ),
              ),
              const Divider(height: 1, indent: 70),
              _settingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Security Verification',
                subtitle: 'Manage additional verification methods',
                onTap: () => _showDemoMessage(
                  'Additional verification will be configured with Firebase.',
                ),
              ),
            ]),

            _sectionTitle('Account actions'),

            _settingsCard([
              _settingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out from your current account',
                iconColor: AppColors.danger,
                onTap: _confirmSignOut,
              ),
              const Divider(height: 1, indent: 70),
              _settingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently request account deletion',
                iconColor: AppColors.danger,
                onTap: () => _showDemoMessage(
                  'Account deletion will be implemented with backend support.',
                ),
              ),
            ]),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
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
                      'Demo mode: Account changes, biometric '
                      'authentication, session management and '
                      'deletion are not connected to a live backend.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

// Separate password dialog widget.
// It owns and disposes its controllers safely.

class _ChangePasswordDialog extends StatefulWidget {
  final VoidCallback onPasswordValidated;

  const _ChangePasswordDialog({required this.onPasswordValidated});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          onPressed: onVisibilityToggle,
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      validator: validator,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onPasswordValidated();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(
                label: 'Current password',
                controller: _currentController,
                visible: _showCurrent,
                onVisibilityToggle: () {
                  setState(() {
                    _showCurrent = !_showCurrent;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              _passwordField(
                label: 'New password',
                controller: _newController,
                visible: _showNew,
                onVisibilityToggle: () {
                  setState(() {
                    _showNew = !_showNew;
                  });
                },
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Use at least 8 characters';
                  }
                  if (value == _currentController.text) {
                    return 'New password must be different';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              _passwordField(
                label: 'Confirm new password',
                controller: _confirmController,
                visible: _showConfirm,
                onVisibilityToggle: () {
                  setState(() {
                    _showConfirm = !_showConfirm;
                  });
                },
                validator: (value) {
                  if (value != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }
}
