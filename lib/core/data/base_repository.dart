/// Base repository interface — BL-003: Only CRUD, no business rules.
abstract interface class BaseRepository<T> {
  Stream<List<T>> watchAll();
  Future<T?> getById(String id);
  Future<void> add(T entity);
  Future<void> update(T entity);
  Future<void> softDelete(String id); // BL-007: isDeleted: true
  Future<void> hardDelete(String id); // Only Cloud Functions use this
}
