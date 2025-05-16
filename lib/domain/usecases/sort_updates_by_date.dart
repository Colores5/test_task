import 'package:test_task/domain/domain.dart';

class SortUpdatesByDate {
  final FirmwareRepository repository;

  SortUpdatesByDate(this.repository);

  List<FirmwareUpdate> execute(bool ascending) {
    final sorted = repository.getAllUpdates();
    sorted.sort(
      (a, b) => ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date),
    );
    return sorted;
  }
}
