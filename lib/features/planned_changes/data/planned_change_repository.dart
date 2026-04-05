import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/features/planned_changes/domain/models/planned_change.dart';

class PlannedChangeRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  PlannedChangeRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/planned_changes');

  Map<String, dynamic> _docToMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = {...doc.data()!, 'id': doc.id};
    if (data['effectiveDate'] is Timestamp) {
      data['effectiveDate'] =
          (data['effectiveDate'] as Timestamp).toDate().toIso8601String();
    }
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    return data;
  }

  /// Watch all non-deleted planned changes for this user.
  Stream<List<PlannedChange>> watchAll() {
    return _collection
        .orderBy('effectiveDate', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PlannedChange.fromJson(_docToMap(d)))
            .where((c) => !c.isDeleted)
            .toList());
  }

  /// Watch planned changes for a specific parent (income/expense).
  Stream<List<PlannedChange>> watchForParent(String parentId) {
    return _collection
        .where('parentId', isEqualTo: parentId)
        .orderBy('effectiveDate', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PlannedChange.fromJson(_docToMap(d)))
            .where((c) => !c.isDeleted)
            .toList());
  }

  Future<PlannedChange?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return PlannedChange.fromJson(_docToMap(doc));
  }

  Future<void> save(PlannedChange change) async {
    await _collection.doc(change.id).set({
      ...change.toJson(),
      'effectiveDate': Timestamp.fromDate(change.effectiveDate.toUtc()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Soft-delete a planned change.
  Future<void> delete(String id) async {
    await _collection.doc(id).update({'isDeleted': true});
  }
}
