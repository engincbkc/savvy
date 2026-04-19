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

  Stream<List<Expense>> watchMonthExpenses(String yearMonth) {
    final range = YearMonthRange.from(yearMonth);
    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('date', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromJson(_docToMap(d)))
            .where((e) => !e.isDeleted)
            .toList());
  }

  @override
  Stream<List<Expense>> watchAll() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Expense.fromJson(_docToMap(d)))
            .where((e) => !e.isDeleted)
            .toList());
  }

  @override
  Future<Expense?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Expense.fromJson(_docToMap(doc));
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

  Future<void> setSettled(String id, bool isSettled) async {
    await _collection.doc(id).update({'isSettled': isSettled});
  }

  Future<void> setMonthSettled(String id, String yearMonth, bool settled) async {
    await _collection.doc(id).update({'settledMonths.$yearMonth': settled});
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
