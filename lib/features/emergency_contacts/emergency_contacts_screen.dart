import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/database_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final DatabaseService _database = DatabaseService.instance;

  List<Map<String, dynamic>> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // LOAD CONTACTS
  Future<void> _loadContacts() async {
    try {
      final contacts = await _database.getEmergencyContacts();

      if (!mounted) return;

      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load contacts: $e')));
    }
  }

  // ADD / EDIT CONTACT
  Future<void> _showContactForm({Map<String, dynamic>? contact}) async {
    final isEditing = contact != null;

    // Capture the messenger before any asynchronous gap.
    final messenger = ScaffoldMessenger.of(context);

    final nameController = TextEditingController(
      text: contact?['name']?.toString() ?? '',
    );

    final phoneController = TextEditingController(
      text: contact?['phone_number']?.toString() ?? '',
    );

    final relationshipController = TextEditingController(
      text: contact?['relationship']?.toString() ?? '',
    );

    bool isPrimary = contact?['is_primary'] == 1;
    bool saving = false;

    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  isEditing
                      ? 'Edit Emergency Contact'
                      : 'Add Emergency Contact',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter the contact name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            hintText: 'e.g. +919876543210',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final phone = (value ?? '').replaceAll(
                              RegExp(r'[\s-]'),
                              '',
                            );

                            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
                              return 'Enter a valid phone number';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: relationshipController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Relationship',
                            hintText: 'e.g. Parent, Friend',
                            prefixIcon: Icon(Icons.people_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter the relationship';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isPrimary,
                          activeColor: AppColors.primary,
                          title: const Text(
                            'Set as primary contact',
                            style: TextStyle(fontSize: 13),
                          ),
                          subtitle: const Text(
                            'Only one primary contact is allowed.',
                            style: TextStyle(fontSize: 11),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              isPrimary = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),

                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() => saving = true);

                            try {
                              final normalizedPhone = phoneController.text
                                  .trim()
                                  .replaceAll(RegExp(r'[\s-]'), '');

                              final data = {
                                'name': nameController.text.trim(),
                                'phone_number': normalizedPhone,
                                'relationship': relationshipController.text
                                    .trim(),
                                'is_primary': isPrimary ? 1 : 0,
                              };

                              if (isEditing) {
                                await _database.updateEmergencyContact(
                                  contact['id'].toString(),
                                  data,
                                );
                              } else {
                                final duplicate = _contacts.any(
                                  (existing) =>
                                      existing['phone_number'] ==
                                      normalizedPhone,
                                );

                                if (duplicate) {
                                  setDialogState(() => saving = false);

                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'This phone number is already registered.',
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                await _database.insertEmergencyContact({
                                  'id': DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                                  ...data,
                                });
                              }

                              // Ensure the dialog still exists.
                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              await _loadContacts();

                              if (!mounted) return;

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Contact updated successfully'
                                        : 'Emergency contact added successfully',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (dialogContext.mounted) {
                                setDialogState(() => saving = false);
                              }

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Unable to save contact: $e'),
                                ),
                              );
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'Save Changes' : 'Add Contact'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      relationshipController.dispose();
    }
  }

  // SET PRIMARY CONTACT
  Future<void> _setPrimary(Map<String, dynamic> contact) async {
    try {
      await _database.setPrimaryEmergencyContact(contact['id'].toString());

      await _loadContacts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${contact['name']} is now your primary contact.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update primary contact: $e')),
      );
    }
  }

  // DELETE CONTACT
  Future<void> _deleteContact(Map<String, dynamic> contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Are you sure you want to delete ${contact['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _database.deleteEmergencyContact(contact['id'].toString());

      await _loadContacts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to delete contact: $e')));
    }
  }

  // MAIN SCREEN
  @override
  Widget build(BuildContext context) {
    final primaryContacts = _contacts
        .where((contact) => contact['is_primary'] == 1)
        .toList();

    final otherContacts = _contacts
        .where((contact) => contact['is_primary'] != 1)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Contact'),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContacts,
              child: _contacts.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        _buildInformationCard(),

                        const SizedBox(height: 22),

                        if (primaryContacts.isNotEmpty) ...[
                          _buildSectionTitle('Primary Contact'),

                          const SizedBox(height: 10),

                          ...primaryContacts.map(
                            (contact) => _buildContactCard(contact),
                          ),

                          const SizedBox(height: 22),
                        ],

                        if (otherContacts.isNotEmpty) ...[
                          _buildSectionTitle('Other Contacts'),

                          const SizedBox(height: 10),

                          ...otherContacts.map(
                            (contact) => _buildContactCard(contact),
                          ),
                        ],

                        const SizedBox(height: 20),

                        Text(
                          '${_contacts.length} contact(s) registered',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  // INFORMATION CARD
  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'These contacts will be used by the AlertXBand emergency '
              'notification system. SMS and app notifications are not '
              'connected yet.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // CONTACT CARD
  Widget _buildContactCard(Map<String, dynamic> contact) {
    final isPrimary = contact['is_primary'] == 1;

    final contactName = contact['name'].toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? AppColors.primary : AppColors.border,
          width: isPrimary ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  contactName.isNotEmpty
                      ? contactName.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      contact['relationship'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (isPrimary)
                const Chip(
                  label: Text(
                    'PRIMARY',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Color(0xFFE5F1FF),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showContactForm(contact: contact);
                  } else if (value == 'delete') {
                    _deleteContact(contact);
                  } else if (value == 'primary') {
                    _setPrimary(contact);
                  }
                },
                itemBuilder: (context) => [
                  if (!isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Text('Set as primary'),
                    ),

                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit contact'),
                  ),

                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete contact',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 22),

          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 17,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  contact['phone_number'].toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),

              if (!isPrimary)
                TextButton(
                  onPressed: () => _setPrimary(contact),
                  child: const Text(
                    'Make Primary',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 70),

        const Icon(
          Icons.contacts_outlined,
          size: 75,
          color: AppColors.textSecondary,
        ),

        const SizedBox(height: 18),

        const Text(
          'No Emergency Contacts',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Add trusted people who can be notified during an emergency.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: FilledButton.icon(
            onPressed: () => _showContactForm(),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add First Contact'),
          ),
        ),
      ],
    );
  }
}
