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

  Map<String, dynamic>? _docToMap(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = doc.data();
    if (raw == null) return null;
    final data = {...raw, 'id': doc.id};

    // Timestamp → ISO8601 String (null-safe)
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    } else if (data['createdAt'] == null) {
      data['createdAt'] = DateTime.now().toIso8601String();
    }

    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] =
          (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    } else {
      data.remove('updatedAt');
    }

    return data;
  }

  Stream<List<SimulationEntry>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final entries = <SimulationEntry>[];
      for (final doc in snap.docs) {
        try {
          final map = _docToMap(doc);
          if (map == null) continue;
          final entry = SimulationEntry.fromJson(map);
          if (!entry.isDeleted) entries.add(entry);
        } catch (_) {
          // Skip malformed documents
        }
      }
      return entries;
    });
  }

  Future<SimulationEntry?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    final map = _docToMap(doc);
    if (map == null) return null;
    return SimulationEntry.fromJson(map);
  }

  Future<void> add(SimulationEntry simulation) async {
    final json = simulation.toJson();
    json.remove('id');
    json.remove('createdAt');
    json.remove('updatedAt');
    await _collection.doc(simulation.id).set({
      ...json,
      'isDeleted': false,
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
