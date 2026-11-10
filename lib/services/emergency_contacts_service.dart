import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactsService {
  EmergencyContactsService._();

  static final EmergencyContactsService instance = EmergencyContactsService._();

  CollectionReference<Map<String, dynamic>> get _contacts {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please log in to manage emergency contacts.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('emergencyContacts');
  }

  // Convert Firestore document into the format
  // already expected by the existing Emergency Contacts UI.
  Map<String, dynamic> _convertDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final createdAt = data['created_at'];

    return {
      'id': document.id,
      'name': data['name'] ?? '',
      'phone_number': data['phone_number'] ?? '',
      'relationship': data['relationship'] ?? '',
      'is_primary': data['is_primary'] == true ? 1 : 0,
      'created_at': createdAt is Timestamp
          ? createdAt.toDate().toIso8601String()
          : createdAt?.toString() ?? '',
    };
  }

  // ADD CONTACT
  Future<int> insertEmergencyContact(Map<String, dynamic> contact) async {
    final data = Map<String, dynamic>.from(contact);

    final id = data.remove('id')?.toString();

    if (id == null || id.isEmpty) {
      throw ArgumentError('Contact ID is required.');
    }

    final isPrimary = data['is_primary'] == true || data['is_primary'] == 1;

    final collection = _contacts;
    final existing = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    // Clear the previous primary contact.
    if (isPrimary) {
      for (final document in existing.docs) {
        batch.update(document.reference, {
          'is_primary': false,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    }

    batch.set(collection.doc(id), {
      'name': data['name'],
      'phone_number': data['phone_number'],
      'relationship': data['relationship'],
      'is_primary': isPrimary,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return 1;
  }

  // GET ALL CONTACTS
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final snapshot = await _contacts.get();

    final contacts = snapshot.docs.map(_convertDocument).toList();

    contacts.sort((a, b) {
      final primaryComparison = (b['is_primary'] as int).compareTo(
        a['is_primary'] as int,
      );

      if (primaryComparison != 0) return primaryComparison;

      return (a['name'] as String).toLowerCase().compareTo(
        (b['name'] as String).toLowerCase(),
      );
    });

    return contacts;
  }

  // GET PRIMARY CONTACT
  Future<Map<String, dynamic>?> getPrimaryEmergencyContact() async {
    final contacts = await getEmergencyContacts();

    for (final contact in contacts) {
      if (contact['is_primary'] == 1) {
        return contact;
      }
    }

    return null;
  }

  // UPDATE CONTACT
  Future<int> updateEmergencyContact(
    String id,
    Map<String, dynamic> contact,
  ) async {
    final data = Map<String, dynamic>.from(contact);

    data.remove('id');
    data.remove('created_at');

    final isPrimary = data['is_primary'] == true || data['is_primary'] == 1;

    final collection = _contacts;
    final existing = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    if (isPrimary) {
      for (final document in existing.docs) {
        if (document.id != id) {
          batch.update(document.reference, {
            'is_primary': false,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    batch.set(collection.doc(id), {
      'name': data['name'],
      'phone_number': data['phone_number'],
      'relationship': data['relationship'],
      'is_primary': isPrimary,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    return 1;
  }

  // SET PRIMARY CONTACT
  Future<int> setPrimaryEmergencyContact(String id) async {
    final collection = _contacts;

    final target = await collection.doc(id).get();

    if (!target.exists) return 0;

    final existing = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final document in existing.docs) {
      batch.update(document.reference, {
        'is_primary': document.id == id,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return 1;
  }

  // DELETE CONTACT
  Future<int> deleteEmergencyContact(String id) async {
    await _contacts.doc(id).delete();
    return 1;
  }
}
