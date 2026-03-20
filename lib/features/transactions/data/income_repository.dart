import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/core/data/base_repository.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';

class IncomeRepository implements BaseRepository<Income> {
  final FirebaseFirestore _firestore;
  final String _uid;

  IncomeRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/incomes');

  /// Convert Firestore Timestamps to ISO strings for json_serializable
  Map<String, dynamic> _docToMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = {...doc.data()!, 'id': doc.id};
    if (data['date'] is Timestamp) {
      data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
    }
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['recurringEndDate'] is Timestamp) {
      data['recurringEndDate'] =
          (data['recurringEndDate'] as Timestamp).toDate().toIso8601String();
    }
    return data;
  }

  Stream<List<Income>> watchMonthIncomes(String yearMonth) {
    final range = YearMonthRange.from(yearMonth);
    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('date', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Income.fromJson(_docToMap(d)))
            .where((i) => !i.isDeleted)
            .toList());
  }

  @override
  Stream<List<Income>> watchAll() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Income.fromJson(_docToMap(d)))
            .where((i) => !i.isDeleted)
            .toList());
  }

  @override
  Future<Income?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Income.fromJson(_docToMap(doc));
  }

  @override
  Future<void> add(Income income) async {
    await _collection.doc(income.id).set({
      ...income.toJson(),
      'date': Timestamp.fromDate(income.date.toUtc()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(Income income) async {
    await _collection.doc(income.id).update({
      ...income.toJson(),
      'date': Timestamp.fromDate(income.date.toUtc()),
    });
  }

  @override
  Future<void> softDelete(String id) async {
    await _collection.doc(id).update({'isDeleted': true});
  }

  @override
  Future<void> hardDelete(String id) async {
    await _collection.doc(id).delete();
  }

  /// Batch soft-delete multiple records at once.
  Future<void> softDeleteMany(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.update(_collection.doc(id), {'isDeleted': true});
    }
    await batch.commit();
  }
}
