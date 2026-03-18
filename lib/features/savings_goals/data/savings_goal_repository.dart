import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';

class SavingsGoalRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  SavingsGoalRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/savingsGoals');

  Map<String, dynamic> _docToMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = {...doc.data()!, 'id': doc.id};
    if (data['targetDate'] is Timestamp) {
      data['targetDate'] =
          (data['targetDate'] as Timestamp).toDate().toIso8601String();
    }
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    return data;
  }

  Stream<List<SavingsGoal>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SavingsGoal.fromJson(_docToMap(d)))
            .toList());
  }

  Future<void> add(SavingsGoal goal) async {
    await _collection.doc(goal.id).set({
      ...goal.toJson(),
      'targetDate': goal.targetDate != null
          ? Timestamp.fromDate(goal.targetDate!)
          : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(SavingsGoal goal) async {
    await _collection.doc(goal.id).update({
      ...goal.toJson(),
      'targetDate': goal.targetDate != null
          ? Timestamp.fromDate(goal.targetDate!)
          : null,
    });
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
