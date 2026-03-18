import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

/// Checks if the current user has completed onboarding.
@riverpod
Stream<bool> onboardingCompleted(Ref ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists) return false;
    return snap.data()?['onboardingCompleted'] == true;
  });
}

/// Marks onboarding as completed in Firestore.
Future<void> completeOnboarding() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
    {'onboardingCompleted': true},
    SetOptions(merge: true),
  );
}
