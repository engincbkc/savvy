import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/core/data/base_repository.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';

class ExpenseRepository implements BaseRepository<Expense> {
  final FirebaseFirestore _firestore;
  final String _uid;

  ExpenseRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/expenses');

  Stream<List<Expense>> watchMonthExpenses(String yearMonth) {
    final range = YearMonthRange.from(yearMonth);
    return _collection
        .where('isDeleted', isEqualTo: false)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('date', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Stream<List<Expense>> watchAll() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Future<Expense?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Expense.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> add(Expense expense) async {
    await _collection.doc(expense.id).set({
      ...expense.toJson(),
      'date': Timestamp.fromDate(expense.date.toUtc()), // BL-006
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(Expense expense) async {
    await _collection.doc(expense.id).update({
      ...expense.toJson(),
      'date': Timestamp.fromDate(expense.date.toUtc()),
    });
  }

  @override
  Future<void> softDelete(String id) async {
    await _collection.doc(id).update({'isDeleted': true}); // BL-007
  }

  @override
  Future<void> hardDelete(String id) async {
    await _collection.doc(id).delete();
  }
}
