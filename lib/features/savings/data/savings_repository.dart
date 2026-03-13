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

  Stream<List<Savings>> watchMonthSavings(String yearMonth) {
    final range = YearMonthRange.from(yearMonth);
    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('date', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Savings.fromJson(_docToMap(d)))
            .where((s) => !s.isDeleted)
            .toList());
  }

  @override
  Stream<List<Savings>> watchAll() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Savings.fromJson(_docToMap(d)))
            .where((s) => !s.isDeleted)
            .toList());
  }

  @override
  Future<Savings?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Savings.fromJson(_docToMap(doc));
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
