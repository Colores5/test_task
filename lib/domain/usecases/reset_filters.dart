import 'package:test_task/domain/domain.dart';

class ResetFilters {
  final FirmwareRepository repository;

  ResetFilters({required this.repository});

  List<FirmwareUpdate> execute() {
    return repository.getAllUpdates();
  }
}
