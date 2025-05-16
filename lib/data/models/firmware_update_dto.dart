import 'package:test_task/core/enums/update_type/update_type.dart';
import 'package:test_task/domain/domain.dart';

class FirmwareUpdateDTO {
  final String id;
  final String title;
  final UpdateType type;
  final String version;
  final DateTime date;
  final String? parentId;
  final List<String> dependencies;
  final List<String> tags;

  FirmwareUpdateDTO({
    required this.id,
    required this.title,
    required this.type,
    required this.version,
    required this.date,
    this.parentId,
    this.dependencies = const [],
    this.tags = const [],
  });

  FirmwareUpdate toEntity() {
    return FirmwareUpdate(
      id: id,
      title: title,
      type: type,
      version: version,
      date: date,
      parentId: parentId,
      dependencies: dependencies,
      tags: tags,
    );
  }
}
