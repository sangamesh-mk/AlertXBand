import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showContactSupport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'Support contact details will be configured before the '
          'official release of AlertXBand. '
          'For now, you can use the FAQs and device setup guide.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 23),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent, color: Colors.white, size: 35),
                  SizedBox(height: 14),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Find answers, learn how to use your wearable, '
                    'or report an issue.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'GET HELP',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 13),

            _buildSupportTile(
              context: context,
              icon: Icons.quiz_outlined,
              title: 'Frequently Asked Questions',
              subtitle: 'Find answers to common questions.',
              onTap: () => context.push('/faq'),
            ),

            _buildSupportTile(
              context: context,
              icon: Icons.watch_outlined,
              title: 'Device Setup Guide',
              subtitle: 'Learn how to set up your AlertXBand.',
              onTap: () => context.push('/device-setup'),
            ),

            _buildSupportTile(
              context: context,
              icon: Icons.build_outlined,
              title: 'Troubleshooting',
              subtitle: 'Find solutions to common device problems.',
              onTap: () => context.push('/troubleshooting'),
            ),

            const SizedBox(height: 15),

            const Text(
              'CONTACT US',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 13),

            _buildSupportTile(
              context: context,
              icon: Icons.support_agent,
              title: 'Contact Support',
              subtitle: 'Get assistance with AlertXBand.',
              onTap: () => _showContactSupport(context),
            ),

            _buildSupportTile(
              context: context,
              icon: Icons.bug_report_outlined,
              title: 'Report a Problem',
              subtitle: 'Tell us about an issue or unexpected behaviour.',
              onTap: () => context.push('/report-problem'),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'AlertXBand · Help & Support',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
