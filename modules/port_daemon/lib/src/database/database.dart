import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/src/database/serializer.dart';

/// A very naive key-value store.
abstract class Database<K, V> {
  Iterable<K> get keys;

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

class RecordSerializer<K, V> {
  final String _keyValueDelimiter;
  final Serializer<K> _keySerializer;
  final Serializer<V> _valueSerializer;

  RecordSerializer(this._keySerializer, this._valueSerializer,
      {String keyValueDelimiter: '«'})
      : _keyValueDelimiter = keyValueDelimiter;

  String serialize(K key, V value) => <String>[
        _keySerializer.serialize(key),
        _keyValueDelimiter,
        _valueSerializer.serialize(value)
      ].join();

  Map<K, V> deserialize(String string) {
    var parts = string.split(_keyValueDelimiter);
    if (parts.length != 2) {
      throw new FormatException('Invalid format: $string');
    }
    var key = _keySerializer.deserialize(parts.first);
    var value = _valueSerializer.deserialize(parts.last);
    return <K, V>{key: value};
  }
}

/// A simple database that holds all data in-memory.
///
/// The contents can be written to disk via [save].
class MemoryDatabase<K, V> implements Database<K, V> {
  final File _file;
  final RecordSerializer<K, V> _serializer;
  final Map<K, V> _records = <K, V>{};

  MemoryDatabase(this._file, {RecordSerializer<K, V> recordSerializer})
      : _serializer = recordSerializer {
    if (!_file.existsSync()) {
      _file.createSync();
    }
    _file.readAsLinesSync().forEach((String entry) {
      var keyValuePair = _serializer.deserialize(entry);
      _records[keyValuePair.keys.single] = keyValuePair.values.single;
    });
  }

  @override
  Iterable<K> get keys => new List.unmodifiable(_records.keys);

  @override
  bool containsKey(K key) => _records.containsKey(key);

  @override
  Future<V> insert(K key, V value) async {
    var oldValue = await get(key);
    if (oldValue != null) {
      throw new Exception('$key is already associated with $oldValue');
    }
    _records[key] = value;
    save();
    return value;
  }

  @override
  Future<V> update(K key, V value) async {
    if (await get(key) == null) {
      throw new Exception("No record associated with $key");
    }
    _records[key] = value;
    save();
    return value;
  }

  @override
  Future<V> get(K key) async => _records[key];

  @override
  Future<V> remove(K key) async {
    if (_records.containsKey(key)) {
      var record = _records.remove(key);
      save();
      return record;
    }
    return null;
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

  void save() {
    var data = '';
    _records.forEach((K key, V value) {
      data += _serializer.serialize(key, value) + '\n';
    });
    _file.writeAsStringSync(data);
  }
}
