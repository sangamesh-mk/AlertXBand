import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Information We Collect',
      'content':
          'AlertXBand may collect account information such as your name, '
          'email address and phone number. Depending on enabled features, '
          'the application may also process wearable sensor readings, '
          'device information and emergency contact details.',
    },
    {
      'title': '2. Health and Sensor Data',
      'content':
          'The wearable device is designed to collect sensor readings '
          'such as temperature, heart rate, movement and other supported '
          'measurements. This information may be used to display monitoring '
          'information and identify potential safety events. Sensor readings '
          'are not a substitute for professional medical diagnosis.',
    },
    {
      'title': '3. Location Information',
      'content':
          'When location access is enabled, AlertXBand may process GPS '
          'coordinates to support location tracking and emergency assistance. '
          'Location collection should follow the permissions granted by '
          'the user and the application settings.',
    },
    {
      'title': '4. Emergency Contacts',
      'content':
          'You may provide emergency contact names and phone numbers. '
          'These details are intended to support emergency alert workflows. '
          'Please obtain appropriate permission before adding another '
          'person’s contact information.',
    },
    {
      'title': '5. How We Use Information',
      'content':
          'Information may be used to operate application features, display '
          'device status, monitor sensor readings, support emergency alerts, '
          'maintain account security, troubleshoot technical issues and '
          'improve application performance.',
    },
    {
      'title': '6. Data Sharing',
      'content':
          'Personal information should not be shared with third parties '
          'except where necessary to provide requested services, comply '
          'with applicable law, protect safety, or where you have provided '
          'appropriate consent. Any future third-party integrations must '
          'be disclosed clearly.',
    },
    {
      'title': '7. Data Security',
      'content':
          'We intend to use appropriate technical and organizational '
          'safeguards to protect information against unauthorized access, '
          'loss, misuse and disclosure. No digital system can guarantee '
          'absolute security.',
    },
    {
      'title': '8. Data Retention',
      'content':
          'Information should be retained only for as long as necessary '
          'for the purposes described in this policy or as required by '
          'applicable law. Actual retention and deletion procedures will '
          'depend on the implemented backend services.',
    },
    {
      'title': '9. Your Privacy Rights',
      'content':
          'Depending on applicable law, you may have rights to access, '
          'correct, update or request deletion of your personal information. '
          'You may also manage application permissions through your device '
          'settings.',
    },
    {
      'title': '10. Children’s Privacy',
      'content':
          'AlertXBand is not intended to collect personal information '
          'from children without appropriate authorization and safeguards. '
          'Any deployment involving children must implement suitable '
          'consent and privacy protections.',
    },
    {
      'title': '11. Changes to This Policy',
      'content':
          'This Privacy Policy may be updated as application features, '
          'backend services or legal requirements change. The updated '
          'version should be made available through the application.',
    },
    {
      'title': '12. Contact and Privacy Requests',
      'content':
          'For privacy questions, data access requests or deletion requests, '
          'please use the official AlertXBand support channel once it has '
          'been configured.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                    Icons.privacy_tip_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Learn how AlertXBand is designed to handle '
                    'your personal information, wearable data '
                    'and location information.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Policy template • Version 1.0',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is a preliminary policy template for the '
                      'development version of AlertXBand. It must be '
                      'reviewed and finalized against actual data '
                      'collection, backend services and applicable '
                      'privacy laws before public release.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Privacy Policy Overview',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Select a section to read more.',
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

            Center(
              child: Text(
                'AlertXBand • Your Safety. Our Intelligence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
