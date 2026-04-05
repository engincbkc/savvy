import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/providers/firebase_providers.dart';
import 'package:savvy/features/planned_changes/data/planned_change_repository.dart';
import 'package:savvy/features/planned_changes/domain/models/planned_change.dart';

part 'planned_change_provider.g.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

@riverpod
PlannedChangeRepository plannedChangeRepository(Ref ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) throw StateError('User not authenticated');
  return PlannedChangeRepository(
    firestore: ref.watch(firestoreProvider),
    uid: uid,
  );
}

// ─── All PlannedChanges ─────────────────────────────────────────────────────

@riverpod
Stream<List<PlannedChange>> allPlannedChanges(Ref ref) {
  return ref.watch(plannedChangeRepositoryProvider).watchAll();
}

// ─── PlannedChanges for a specific parent ──────────────────────────────────

@riverpod
Stream<List<PlannedChange>> plannedChangesForParent(
  Ref ref,
  String parentId,
) {
  return ref
      .watch(plannedChangeRepositoryProvider)
      .watchForParent(parentId);
}
