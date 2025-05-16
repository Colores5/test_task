import 'package:test_task/core/enums/update_type/update_type.dart';
import 'package:test_task/domain/domain.dart';

class FilterUpdates {
  final FirmwareRepository repository;

  FilterUpdates(this.repository);

  List<FirmwareUpdate> execute(UpdateType? type, List<String>? tags) {
    final updates = repository.getAllUpdates();
    return updates.where((update) {
      final typeMatch = type == null || update.type == type;
      final tagsMatch =
          tags == null || update.tags.any((tag) => tags.contains(tag));
      return typeMatch && tagsMatch;
    }).toList();
  }
}
