import 'package:test_task/domain/domain.dart';

class GetDependencyChain {
  final FirmwareRepository repository;

  GetDependencyChain(this.repository);

  List<String> execute(String firmwareId) {
    final updates = repository.getAllUpdates();
    return _calculateDependencyChain(updates, firmwareId);
  }

  List<String> _calculateDependencyChain(
    List<FirmwareUpdate> updates,
    String id,
  ) {
    final List<String> result = [];
    final Set<String> visitedIds = {};

    FirmwareUpdate? getUpdate(String id) {
      return updates.firstWhere((u) => u.id == id);
    }

    void collectChildren(String currentId) {
      if (visitedIds.contains(currentId)) return;
      visitedIds.add(currentId);

      final children = updates.where((i) => i.parentId == currentId).toList();
      for (final child in children) {
        result.add(child.id);
        collectChildren(child.id);
      }
    }

    FirmwareUpdate? current = getUpdate(id);
    if (current == null) return result;

    while (current!.parentId != null) {
      final parent = getUpdate(current.parentId!);
      if (parent == null) break;
      current = parent;
    }

    collectChildren(current.id);

    return result;
  }
}
