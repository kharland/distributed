import 'dart:async';

/// A simple key-value store.
abstract class Database<K, V> {
  Iterable<K> get keys;

  /// Deletes all data from this database.
  void clear();

  /// Whether this database is empty.
  bool get isEmpty;

  /// Whether this [Database] contains and entry for [key].
  bool containsKey(K key);

  /// Associates [value] with [key].
  Future<V> insert(K key, V value);

  /// Associates [value] with [key].
  ///
  /// If a value already exists for [key] an Exception is thrown.
  Future<V> update(K key, V value);

  /// Returns the value associated with [key] or null if non exists.
  Future<V> get(K key);

  /// Remove the value associated with [key] if one exists.
  Future<V> remove(K key);

  /// Returns all records in the database that pass [filter].
  Future<Iterable<V>> where(bool filter(K key, V value));
}

/// A [Database] that holds all data in-memory.
class MemoryDatabase<K, V> implements Database<K, V> {
  final Map<K, V> _records = <K, V>{};

  @override
  Iterable<K> get keys => new List.unmodifiable(_records.keys);

  // TODO: implement isEmpty
  @override
  bool get isEmpty => _records.isEmpty;

  @override
  void clear() {
    _records.clear();
  }

  @override
  Future<V> get(K key) async => _records[key];

  @override
  bool containsKey(K key) => _records.containsKey(key);

  @override
  Future<V> insert(K key, V value) async {
    var oldValue = await get(key);
    if (oldValue != null) {
      throw new Exception('$key is already associated with $oldValue');
    }
    _records[key] = value;
    return value;
  }

  @override
  Future<V> update(K key, V value) async {
    if (await get(key) == null) {
      throw new Exception("No record associated with $key");
    }
    _records[key] = value;
    return value;
  }

  @override
  Future<V> remove(K key) async {
    if (await get(key) == null) {
      throw new Exception("No record associated with $key");
    } else {
      return _records.remove(key);
    }
  }

  @override
  Future<Iterable<V>> where(bool filter(K key, V value)) async {
    var results = <V>[];
    _records.forEach((K key, V value) {
      if (filter(key, value)) {
        results.add(value);
      }
    });
    return results;
  }
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException([this.message = '']);
}
