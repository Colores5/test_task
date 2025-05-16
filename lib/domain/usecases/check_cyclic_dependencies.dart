import 'package:test_task/domain/domain.dart';

class CheckCyclicDependencies {
  final FirmwareRepository repository;

  CheckCyclicDependencies(this.repository);

  bool execute() {
    final updates = repository.getAllUpdates();
    return _hasCyclicDependencies(updates);
  }

  bool _hasCyclicDependencies(updates) {
    final visited = <String, bool>{};
    final recursionStack = <String, bool>{};

    for (final update in updates) {
      if (_isCyclic(updates, update.id, visited, recursionStack)) {
        return true;
      }
    }
    return false;
  }

  bool _isCyclic(
    List<FirmwareUpdate> updates,
    String id,
    Map<String, bool> visited,
    Map<String, bool> recursionStack,
  ) {
    if (recursionStack[id] == true) return true;
    if (visited[id] == true) return false;

    visited[id] = true;
    recursionStack[id] = true;

    final update = updates.firstWhere((u) => u.id == id);
    for (final depId in update.dependencies) {
      if (_isCyclic(updates, depId, visited, recursionStack)) {
        return true;
      }
    }
    recursionStack[id] = false;
    return false;
  }
}
