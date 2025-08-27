import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_mate/data/cloud_api.dart';
import 'package:task_mate/data/local_store.dart';
import 'package:task_mate/data/todo_model.dart';
import 'package:uuid/uuid.dart';

class ToDoRepository {
  final _localStore = LocalStore();
  final _cloudApi = CloudApi();
  final _controller = StreamController<List<ToDo>>.broadcast();
  List<ToDo> _data = [];

  Stream<List<ToDo>> watch() => _controller.stream;

  /// Load local immediately, then try to refresh from cloud, merge, save.
  Future<void> loadData() async {
    _data = await _localStore.getData();
    _controller.add(_sorted(_data));
    try {
      final remoteData = await _cloudApi.getData();
      _mergeAndSave(remoteData);
    } catch (e) {
      debugPrint("Sync with Server failed. Use local data. Error: $e");
    }
  }

  Future<void> refresh() async {
    try {
      final remote = await _cloudApi.getData();
      _mergeAndSave(remote);
    } catch (e) {
      debugPrint("Sync with Server failed. Use local data. Error: $e");
    }
  }

  Future<void> add(String title, {int userId = 1}) async {
    final todo = ToDo(
      id: Uuid()
          .v4()
          .hashCode
          .abs(), //the server should set the id because I could look up the existing ids and choose one that is not used yet, but this is better handled by the database
      title: title,
      completed: false,
      userId: userId,
      pending: true,
    );
    _data = [..._data, todo];
    await _saveLocallyAndUpdateStream();
    _synchronizeWithCloud(todo, operation: _Operation.upsert);
  }

  Future<void> toggle(int id, bool completed) async {
    _data = _data.map((todo) => todo.id == id ? todo.copyWith(completed: completed, pending: true) : todo).toList();
    await _saveLocallyAndUpdateStream();
    _synchronizeWithCloud(_byId(id)!, operation: _Operation.upsert);
  }

  Future<void> rename(int id, String title) async {
    _data = _data.map((todo) => todo.id == id ? todo.copyWith(title: title, pending: true) : todo).toList();
    await _saveLocallyAndUpdateStream();
    _synchronizeWithCloud(_byId(id)!, operation: _Operation.upsert);
  }

  Future<void> remove(int id) async {
    final existing = _byId(id);
    if (existing == null) return;
    _data = _data.where((todo) => todo.id != id).toList();
    await _saveLocallyAndUpdateStream();
    _synchronizeWithCloud(existing, operation: _Operation.delete);
  }

  // --- internals ---

  ToDo? _byId(int id) {
    try {
      return _data.firstWhere((todo) => todo.id == id);
    } catch (_) {
      return null;
    }
  }

  void _mergeAndSave(List<ToDo> remote) async {
    final remoteById = {for (final remoteEntry in remote) remoteEntry.id: remoteEntry};

    final Map<int, ToDo> merged = {};

    // First, view local data and decide case-by-case
    for (final localEntry in _data) {
      final remoteEntry = remoteById[localEntry.id];

      if (remoteEntry == null) {
        if (localEntry.pending) {
          // New or edited locally but not yet pushed -> keep it
          merged[localEntry.id] = localEntry;
        } else {
          // Likely deleted remotely -> drop it (do not add to merged)
        }
      } else {
        // Exists on server
        if (localEntry.pending) {
          // Keep local pending changes (try to push after saving)
          merged[localEntry.id] = localEntry;
        } else {
          // Take server version and clear pending
          merged[localEntry.id] = remoteEntry.copyWith(pending: false);
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
    _data = merged.values.toList();
    await _saveLocallyAndUpdateStream();

    // Try to push any still-pending locals
    for (final todo in _data.where((t) => t.pending)) {
      _synchronizeWithCloud(todo, operation: _Operation.upsert);
    }
  }

  Future<void> _saveLocallyAndUpdateStream() async {
    await _localStore.setData(_data);
    _controller.add(_sorted(_data));
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

  void _synchronizeWithCloud(ToDo todo, {required _Operation operation}) async {
    try {
      if (operation == _Operation.upsert) {
        await _cloudApi.upsert(todo.copyWith(pending: false));
        _data = _data.map((entry) => entry.id == todo.id ? entry.copyWith(pending: false) : entry).toList();
        await _saveLocallyAndUpdateStream();
      } else {
        await _cloudApi.delete(todo.id);
      }
    } catch (_) {
      // remain pending; will retry on next refresh/loadData
    }
  }
}

enum _Operation { upsert, delete }
