import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/core/data/base_repository.dart';
import 'package:savvy/features/budget/domain/models/budget_limit.dart';

class BudgetLimitRepository implements BaseRepository<BudgetLimit> {
  final FirebaseFirestore _firestore;
  final String _uid;

  BudgetLimitRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/budget_limits');

  Map<String, dynamic> _docToMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = {...doc.data()!, 'id': doc.id};
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    return data;
  }

  @override
  Stream<List<BudgetLimit>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BudgetLimit.fromJson(_docToMap(d)))
            .where((b) => !b.isDeleted)
            .toList());
  }

  @override
  Future<BudgetLimit?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return BudgetLimit.fromJson(_docToMap(doc));
  }

  @override
  Future<void> add(BudgetLimit limit) async {
    await _collection.doc(limit.id).set({
      ...limit.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(BudgetLimit limit) async {
    await _collection.doc(limit.id).update(limit.toJson());
  }

  /// Upsert: add if new id, update if exists.
  Future<void> upsert(BudgetLimit limit) async {
    final doc = await _collection.doc(limit.id).get();
    if (doc.exists) {
      await update(limit);
    } else {
      await add(limit);
    }
  }

  @override
  Future<void> softDelete(String id) async {
    await _collection.doc(id).update({'isDeleted': true});
  }

  @override
  Future<void> hardDelete(String id) async {
    await _collection.doc(id).delete();
  }
}
