import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Acceptance of Terms',
      'content':
          'By accessing or using AlertXBand, you agree to these Terms '
          'and Conditions. If you do not agree, you should discontinue '
          'using the application.',
    },
    {
      'title': '2. About AlertXBand',
      'content':
          'AlertXBand is designed as a wearable safety monitoring '
          'platform. Depending on available hardware and software '
          'integrations, it may provide sensor monitoring, location '
          'tracking, device status and emergency alert features.',
    },
    {
      'title': '3. User Responsibilities',
      'content':
          'You are responsible for providing accurate account and '
          'emergency contact information, maintaining the security of '
          'your account and using the application responsibly. You '
          'should ensure that the wearable device is properly configured '
          'and maintained.',
    },
    {
      'title': '4. Device and Hardware Usage',
      'content':
          'Some application features depend on compatible wearable '
          'hardware, sensors, GPS modules, network connectivity and '
          'battery availability. Performance may vary depending on '
          'device configuration, environmental conditions and network '
          'availability.',
    },
    {
      'title': '5. Emergency Alerts and Notifications',
      'content':
          'AlertXBand may support SOS alerts, fall detection and '
          'emergency notifications. Alert delivery may be affected by '
          'network failures, device power, GPS availability, incorrect '
          'contact details or third-party service interruptions. '
          'Users should not rely on the application as their only '
          'means of emergency assistance.',
    },
    {
      'title': '6. Health and Safety Disclaimer',
      'content':
          'AlertXBand is not a medical device and does not provide '
          'medical diagnosis, treatment or professional medical advice. '
          'Sensor readings and automated alerts may be inaccurate or '
          'delayed. Consult qualified healthcare professionals for '
          'medical concerns.',
    },
    {
      'title': '7. Account Security',
      'content':
          'You are responsible for protecting your login credentials '
          'and notifying the support team of suspected unauthorized '
          'account access. Account security features depend on the '
          'authentication services actually implemented in the application.',
    },
    {
      'title': '8. Privacy and Personal Information',
      'content':
          'The collection and handling of personal information, sensor '
          'data and location information are described in the AlertXBand '
          'Privacy Policy. By using relevant features, you acknowledge '
          'that information may be processed as described in that policy.',
    },
    {
      'title': '9. Acceptable Use',
      'content':
          'You must not misuse the application, attempt unauthorized '
          'access, interfere with its operation, submit false emergency '
          'alerts intentionally or use the platform for unlawful purposes.',
    },
    {
      'title': '10. Service Availability',
      'content':
          'We may modify, suspend or discontinue application features '
          'for maintenance, upgrades, security reasons or technical '
          'limitations. Continuous and uninterrupted service is not '
          'guaranteed.',
    },
    {
      'title': '11. Limitation of Liability',
      'content':
          'To the extent permitted by applicable law, AlertXBand and '
          'its developers are not responsible for losses arising from '
          'network interruptions, inaccurate sensor readings, hardware '
          'failure, unavailable location services or delayed emergency '
          'notifications. Nothing in these terms excludes liability '
          'that cannot legally be excluded.',
    },
    {
      'title': '12. Changes to These Terms',
      'content':
          'These Terms and Conditions may be updated when application '
          'features, services or legal requirements change. Updated '
          'terms should be made available through the application.',
    },
    {
      'title': '13. Contact and Support',
      'content':
          'For questions about these Terms and Conditions, use the '
          'official AlertXBand Help and Support channel once it has '
          'been configured.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                  Icon(Icons.gavel_rounded, color: Colors.white, size: 38),
                  SizedBox(height: 15),
                  Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please read the terms governing your use of '
                    'the AlertXBand application and wearable services.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Draft version 1.0',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

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
                      'Preliminary development draft. These terms '
                      'must be reviewed against the actual services '
                      'and applicable laws before public release.',
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

            const SizedBox(height: 22),

            const Text(
              'Terms Overview',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Expand each section to read the terms.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 14),

            ..._sections.map(
              (section) => Container(
                margin: const EdgeInsets.only(bottom: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 15),
                  childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.textSecondary,
                  title: Text(
                    section['title']!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        section['content']!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                'AlertXBand • Your Safety. Our Intelligence.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
