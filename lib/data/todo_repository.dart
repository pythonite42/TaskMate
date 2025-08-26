import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_mate/data/cloud_api.dart';
import 'package:task_mate/data/local_store.dart';
import 'package:task_mate/data/todo_model.dart';
import 'package:uuid/uuid.dart';

class ToDoRepository {
  final _local = LocalStore();
  final _cloud = CloudApi();
  final _controller = StreamController<List<ToDo>>.broadcast();
  List<ToDo> _cache = [];

  Stream<List<ToDo>> watch() => _controller.stream;

  /// Load local immediately, then try to refresh from cloud, merge, save.
  Future<void> bootstrap() async {
    _cache = await _local.readAll();
    _controller.add(_sorted(_cache));
    try {
      final remote = await _cloud.fetchAll();
      _mergeAndSave(remote);
    } catch (e) {
      debugPrint("Sync with Server failed. Use local data. Error: $e");
    }
  }

  Future<void> refresh() async {
    try {
      final remote = await _cloud.fetchAll();
      _mergeAndSave(remote);
    } catch (e) {
      debugPrint("Sync with Server failed. Use local data. Error: $e");
    }
  }

  Future<void> add(String title, {int userId = 9}) async {
    final todo = ToDo(id: const Uuid().v4(), title: title, completed: false, userId: userId, pending: true);
    _cache = [..._cache, todo];
    await _persistAndEmit();
    _syncOne(todo, operation: _Operation.upsert);
  }

  Future<void> toggle(String id, bool completed) async {
    _cache = _cache.map((todo) => todo.id == id ? todo.copyWith(completed: completed, pending: true) : todo).toList();
    await _persistAndEmit();
    _syncOne(_byId(id)!, operation: _Operation.upsert);
  }

  Future<void> rename(String id, String title) async {
    _cache = _cache.map((todo) => todo.id == id ? todo.copyWith(title: title, pending: true) : todo).toList();
    await _persistAndEmit();
    _syncOne(_byId(id)!, operation: _Operation.upsert);
  }

  Future<void> remove(String id) async {
    final existing = _byId(id);
    if (existing == null) return;
    _cache = _cache.where((todo) => todo.id != id).toList();
    await _persistAndEmit();
    _syncOne(existing, operation: _Operation.delete);
  }

  // --- internals ---

  ToDo? _byId(String id) {
    try {
      return _cache.firstWhere((todo) => todo.id == id);
    } catch (_) {
      return null;
    }
  }

  void _mergeAndSave(List<ToDo> remote) async {
    final remoteById = {for (final remoteEntry in remote) remoteEntry.id: remoteEntry};

    final Map<String, ToDo> merged = {};

    // First, walk local cache and decide case-by-case
    for (final local in _cache) {
      final remoteEntry = remoteById[local.id];

      if (remoteEntry == null) {
        if (local.pending) {
          // New or edited locally but not yet pushed -> keep it
          merged[local.id] = local;
        } else {
          // Likely deleted remotely -> drop it (do not add to merged)
        }
      } else {
        // Exists on server
        if (local.pending) {
          // Keep local pending changes (we'll try to push after saving)
          merged[local.id] = local;
        } else {
          // Take server version and clear pending
          merged[local.id] = remoteEntry.copyWith(pending: false);
        }
      }
    }

    // Then, add any purely-remote items we didn't see locally (new from other devices)
    for (final remoteEntry in remote) {
      if (!merged.containsKey(remoteEntry.id)) {
        merged[remoteEntry.id] = remoteEntry.copyWith(pending: false);
      }
    }

    // Commit + emit
    _cache = merged.values.toList();
    await _persistAndEmit();

    // Try to push any still-pending locals
    for (final todo in _cache.where((t) => t.pending)) {
      _syncOne(todo, operation: _Operation.upsert);
    }
  }

  Future<void> _persistAndEmit() async {
    await _local.writeAll(_cache);
    _controller.add(_sorted(_cache));
  }

  List<ToDo> _sorted(List<ToDo> todos) {
    // Stable partitioning: preserves original order within each group.
    final List<ToDo> a = [];
    final List<ToDo> b = [];
    final List<ToDo> c = [];
    final List<ToDo> d = [];

    for (final todo in todos) {
      if (!todo.completed && todo.pending) {
        a.add(todo);
      } else if (!todo.completed && !todo.pending) {
        b.add(todo);
      } else if (todo.completed && todo.pending) {
        c.add(todo);
      } else {
        d.add(todo);
      }
    }

    return List.unmodifiable(<ToDo>[
      ...a, // incomplete + pending (most attention)
      ...b, // incomplete + synced
      ...c, // complete + pending (still syncing)
      ...d, // complete + synced
    ]);
  }

  void _syncOne(ToDo todo, {required _Operation operation}) async {
    try {
      if (operation == _Operation.upsert) {
        await _cloud.upsert(todo.copyWith(pending: false));
        _cache = _cache.map((entry) => entry.id == todo.id ? entry.copyWith(pending: false) : entry).toList();
        await _persistAndEmit();
      } else {
        await _cloud.delete(todo.id);
      }
    } catch (_) {
      // remain pending; will retry on next refresh/bootstrap
    }
  }
}

enum _Operation { upsert, delete }
