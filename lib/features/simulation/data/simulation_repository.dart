import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';

class SimulationRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  SimulationRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users/$_uid/simulations');

  Map<String, dynamic> _docToMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = {...doc.data()!, 'id': doc.id};
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] =
          (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    return data;
  }

  Stream<List<SimulationEntry>> watchAll() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SimulationEntry.fromJson(_docToMap(d)))
            .toList());
  }

  Future<SimulationEntry?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return SimulationEntry.fromJson(_docToMap(doc));
  }

  Future<void> add(SimulationEntry simulation) async {
    final json = simulation.toJson();
    json.remove('id');
    json.remove('createdAt');
    json.remove('updatedAt');
    await _collection.doc(simulation.id).set({
      ...json,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(SimulationEntry simulation) async {
    final json = simulation.toJson();
    json.remove('id');
    json.remove('createdAt');
    await _collection.doc(simulation.id).update({
      ...json,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDelete(String id) async {
    await _collection.doc(id).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
