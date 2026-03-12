import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/core/data/base_repository.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';

class SavingsRepository implements BaseRepository<Savings> {
  final FirebaseFirestore _firestore;
  final String _uid;

  SavingsRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/savings');

  Stream<List<Savings>> watchMonthSavings(String yearMonth) {
    final range = YearMonthRange.from(yearMonth);
    return _collection
        .where('isDeleted', isEqualTo: false)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('date', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Savings.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Stream<List<Savings>> watchAll() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Savings.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Future<Savings?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Savings.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> add(Savings savings) async {
    await _collection.doc(savings.id).set({
      ...savings.toJson(),
      'date': Timestamp.fromDate(savings.date.toUtc()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(Savings savings) async {
    await _collection.doc(savings.id).update({
      ...savings.toJson(),
      'date': Timestamp.fromDate(savings.date.toUtc()),
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
}
