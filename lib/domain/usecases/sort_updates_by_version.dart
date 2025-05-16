import 'dart:math';

import 'package:test_task/domain/domain.dart';

class SortUpdatesByVersion {
  final FirmwareRepository repository;

  SortUpdatesByVersion(this.repository);

  List<FirmwareUpdate> execute() {
    final sorted = repository.getAllUpdates();
    sorted.sort((a, b) => _parseAndCompareVersions(a.version, b.version));
    return sorted;
  }

  int _parseAndCompareVersions(String a, String b) {
    final partA = a.split('.');
    final partB = b.split('.');

    for (var i = 0; i < max(partA.length, partB.length); i++) {
      final aVal = i < partA.length ? int.tryParse(partA[i]) ?? 0 : 0;
      final bVal = i < partB.length ? int.tryParse(partB[i]) ?? 0 : 0;

      if (aVal != bVal) {
        return aVal.compareTo(bVal);
      }
    }
    return 0;
  }
}
