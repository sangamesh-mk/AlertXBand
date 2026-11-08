import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Device',
    'Connectivity',
    'Safety',
    'Sensors',
  ];

  final List<Map<String, String>> _faqs = [
    {
      'category': 'Device',
      'question': 'What is AlertXBand?',
      'answer':
          'AlertXBand is a wearable safety monitoring prototype designed '
          'to support safety alerts, location tracking and health monitoring '
          'through connected hardware and a mobile application.',
    },
    {
      'category': 'Device',
      'question': 'How do I turn on my AlertXBand?',
      'answer':
          'Charge the wearable battery and use its power switch or power '
          'button, depending on your hardware version. Check the device '
          'indicator LEDs to confirm its power status.',
    },
    {
      'category': 'Connectivity',
      'question': 'Why is my wearable not connecting to the app?',
      'answer':
          'Check that the wearable is powered on, the configured Wi-Fi '
          'network is available, and the device firmware has the correct '
          'network and backend settings. Restart the device and check its '
          'serial monitor for connection errors.',
    },
    {
      'category': 'Connectivity',
      'question': 'Why is GPS location not updating?',
      'answer':
          'GPS may take time to obtain a satellite fix. Move outdoors to '
          'an open area, keep the GPS antenna facing the sky, and check '
          'the GPS module wiring and serial output.',
    },
    {
      'category': 'Connectivity',
      'question': 'Does the device require a SIM card?',
      'answer':
          'A SIM card is required when your hardware version uses a GSM '
          'module for cellular communication. The SIM must be active and '
          'compatible with the module and available network service.',
    },
    {
      'category': 'Safety',
      'question': 'How does the emergency SOS feature work?',
      'answer':
          'The SOS feature is designed to initiate an emergency alert '
          'workflow. Actual alert delivery depends on the configured '
          'firmware, communication network and backend integration. '
          'Do not rely on the prototype as your only emergency system.',
    },
    {
      'category': 'Safety',
      'question': 'How does fall detection work?',
      'answer':
          'Fall detection uses motion sensor readings to identify movement '
          'patterns that may indicate a fall. Thresholds and calibration '
          'must be tested carefully to reduce false alerts and missed events.',
    },
    {
      'category': 'Sensors',
      'question': 'Why are my sensor readings not changing?',
      'answer':
          'Check sensor wiring, power supply, GPIO assignments and firmware '
          'configuration. Also verify that the sensor is initialized '
          'correctly and that the application is receiving live data rather '
          'than demonstration values.',
    },
    {
      'category': 'Sensors',
      'question': 'Are health readings medically accurate?',
      'answer':
          'No. AlertXBand is a prototype and its sensor readings are not '
          'medical measurements or a substitute for professional medical '
          'equipment or medical advice.',
    },
    {
      'category': 'Device',
      'question': 'How long does the battery last?',
      'answer':
          'Battery life depends on battery capacity, sensor usage, GPS '
          'activity, cellular communication and power management. '
          'Actual runtime must be measured on your hardware prototype.',
    },
    {
      'category': 'Device',
      'question': 'How should I charge the wearable?',
      'answer':
          'Use the charging arrangement specified for your battery and '
          'protection circuit. Never charge a damaged or swollen battery, '
          'and do not leave a charging prototype unattended.',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_selectedCategory == 'All') return _faqs;

    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need some answers?',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Explore common questions about AlertXBand.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = _selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: faqs.isEmpty
                  ? const Center(child: Text('No questions available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                      itemCount: faqs.length,
                      itemBuilder: (context, index) {
                        final faq = faqs[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 11),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                15,
                                0,
                                15,
                                17,
                              ),
                              iconColor: AppColors.primary,
                              collapsedIconColor: AppColors.textSecondary,
                              title: Text(
                                faq['question']!,
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
                                    faq['answer']!,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.surface,
              child: const Text(
                'AlertXBand is a prototype. Features depend on '
                'hardware and software integration.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
