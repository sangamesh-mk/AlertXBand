import 'package:flutter/material.dart';
import '../emergency_contacts/emergency_contacts_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../services/alert_service.dart';

class EmergencyAlertsScreen extends StatelessWidget {
  const EmergencyAlertsScreen({super.key});

  Future<void> _confirmSOS(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_rounded,
          color: AppColors.danger,
          size: 42,
        ),
        title: const Text('Activate SOS?'),
        content: const Text(
          'This will create a simulated emergency alert in AlertXBand. '
          'No SMS, phone call or emergency service will be contacted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm SOS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AlertService.instance.triggerSOS();
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Color _severityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.danger;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'SOS':
        return Icons.sos_rounded;
      case 'Fall Detection':
        return Icons.personal_injury_outlined;
      case 'Gas Sensor':
        return Icons.gas_meter_outlined;
      case 'Health':
        return Icons.favorite_outline_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = AlertService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final alerts = service.alerts;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSimulationNotice(),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyContactsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.contacts_outlined),
                    label: const Text('Manage Emergency Contacts'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _buildSOSCard(context, service),
                const SizedBox(height: 20),

                const Text(
                  'Emergency Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active Alerts',
                        '${service.activeAlertCount}',
                        Icons.notifications_active_outlined,
                        AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Critical Alerts',
                        '${service.criticalAlertCount}',
                        Icons.error_outline_rounded,
                        AppColors.danger,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alert History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (alerts.isNotEmpty)
                      TextButton(
                        onPressed: () => _showClearConfirmation(context),
                        child: const Text('Clear all'),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (alerts.isEmpty)
                  _buildEmptyState()
                else
                  ...alerts.map(
                    (alert) => _buildAlertCard(context, alert, service),
                  ),

                const SizedBox(height: 24),

                const Text(
                  'Test Alert System',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Generate simulated events to test the application.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),

                _buildTestButton(
                  icon: Icons.personal_injury_outlined,
                  title: 'Simulate Fall Detection',
                  color: AppColors.danger,
                  onPressed: service.simulateFallAlert,
                ),
                const SizedBox(height: 10),

                _buildTestButton(
                  icon: Icons.gas_meter_outlined,
                  title: 'Simulate Gas Warning',
                  color: AppColors.warning,
                  onPressed: service.simulateGasAlert,
                ),
                const SizedBox(height: 10),

                _buildTestButton(
                  icon: Icons.favorite_outline,
                  title: 'Simulate Health Alert',
                  color: AppColors.primary,
                  onPressed: service.simulateHealthAlert,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulationNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Simulation Mode: Alerts are generated locally for testing. '
              'Emergency messages are not transmitted.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSCard(BuildContext context, AlertService service) {
    final active = service.sosActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? [const Color(0xFFB71C1C), const Color(0xFFE53935)]
              : [const Color(0xFFD32F2F), const Color(0xFFEF5350)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.sos_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 10),
          Text(
            active ? 'SOS IS ACTIVE' : 'Emergency SOS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            active
                ? 'A simulated SOS event is active.'
                : 'Use this button to test the emergency trigger.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: active ? null : () => _confirmSOS(context),
              child: Text(
                active ? 'SOS ACTIVATED' : 'ACTIVATE SOS',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          if (active) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                final sos = service.alerts.where(
                  (alert) => alert.category == 'SOS' && !alert.isResolved,
                );

                if (sos.isNotEmpty) {
                  service.resolveAlert(sos.first.id);
                }
              },
              child: const Text(
                'Resolve simulated SOS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    AlertRecord alert,
    AlertService service,
  ) {
    final color = _severityColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_categoryIcon(alert.category), color: color, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  alert.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatTime(alert.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (alert.isResolved)
                      const Text(
                        'RESOLVED',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        alert.severity.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!alert.isResolved)
            IconButton(
              tooltip: 'Resolve alert',
              onPressed: () => service.resolveAlert(alert.id),
              icon: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textSecondary,
            size: 45,
          ),
          SizedBox(height: 12),
          Text(
            'No alerts yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your emergency events will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear alert history?'),
        content: const Text(
          'This will remove all simulated alerts from the current session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AlertService.instance.clearHistory();
    }
  }
}
