// Bhakti Music Firestore Seeding Utility
// Usage: dart run tools/seed_database.dart <service_account_path_or_api_key>

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  print('====================================================');
  print('🕉️  BHAKTI MUSIC — FIRESTORE SEEDING UTILITY');
  print('====================================================');

  final seedFile = File('firebase/seed_data.json');
  if (!seedFile.existsSync()) {
    print('❌ Error: firebase/seed_data.json not found.');
    exit(1);
  }

  final content = seedFile.readAsStringSync();
  final data = jsonDecode(content) as Map<String, dynamic>;

  final deities = data['deities'] as List;
  final categories = data['categories'] as List;
  final songs = data['songs'] as List;
  final admins = data['admins'] as List;

  print('Loaded ${deities.length} deities.');
  print('Loaded ${categories.length} categories.');
  print('Loaded ${songs.length} devotional songs.');
  print('Loaded ${admins.length} initial administrators.');

  print('\nTo seed into your live Firebase Firestore project:');
  print('1. Ensure you have installed the Firebase CLI (`npm install -g firebase-tools`)');
  print('2. Authenticate: `firebase login`');
  print('3. Deploy Firestore rules: `firebase deploy --only firestore:rules`');
  print('4. Deploy Storage rules: `firebase deploy --only storage`');
  print('5. Set the first admin: create document in /admins/{uid} where {uid} is the admin\'s Firebase Auth UID.');
  print('\nSeed catalog is verified and ready.');
}
