import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firestore for profile CRUD.
/// Throws raw exceptions — the repository layer catches and maps them.
class ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Ensures a profile document exists for [uid].
  ///
  /// Uses a Firestore **transaction** for atomic read-then-write:
  /// - If document does NOT exist: creates it with defaults.
  /// - If document DOES exist: returns existing data without modification.
  ///
  /// Guarantees:
  /// - `created_at` is set ONCE on creation and never overwritten (immutable).
  /// - `onboarding_complete` is never regressed from `true` to `false`.
  /// - `schema_version` is included for future migrations.
  Future<Map<String, dynamic>> ensureProfile(String uid) async {
    final docRef = _firestore.collection('profiles').doc(uid);

    return _firestore.runTransaction<Map<String, dynamic>>((txn) async {
      final snapshot = await txn.get(docRef);

      if (!snapshot.exists) {
        // Document does not exist — create with defaults.
        final data = <String, dynamic>{
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'onboarding_complete': false,
          'schema_version': 1,
        };
        txn.set(docRef, data);
        // Return the shape we wrote (timestamps will resolve server-side).
        return {'onboarding_complete': false, 'schema_version': 1};
      }

      // Document exists — return as-is, never overwrite.
      return snapshot.data() ?? {'onboarding_complete': false};
    });
  }

  /// Fetches the profile document for [uid].
  /// Returns null if the document does not exist.
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snapshot = await _firestore.collection('profiles').doc(uid).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  /// Marks onboarding as complete for [uid].
  /// Uses update() to only modify specific fields without touching created_at.
  /// Falls back to set with merge if document doesn't exist (defensive).
  Future<void> markOnboardingComplete(String uid) async {
    final docRef = _firestore.collection('profiles').doc(uid);

    try {
      await docRef.update({
        'onboarding_complete': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        // Document doesn't exist — create it with onboarding already complete.
        await docRef.set({
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'onboarding_complete': true,
          'schema_version': 1,
        });
      } else {
        rethrow;
      }
    }
  }

  /// Signs out the current user.
  /// Centralized here so providers never call FirebaseAuth.instance directly.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
