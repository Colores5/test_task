import 'package:test_task/core/enums/update_type/update_type.dart';

class FirmwareUpdate {
  final String id; // Уникальный ID (например, "android_13")
  final String title; // Название ("Android 13")
  final UpdateType type; // Тип: OS, Feature, SecurityPatch, BugFix
  final String version; // Версия ("13.0.0")
  final DateTime date; // Дата выхода
  final String? parentId; // ID родительской ОС (для группировки)
  final List<String> dependencies; // Зависимости (например, ["android_13"])
  final List<String> tags; // Теги (["Security", "AI"])

  FirmwareUpdate({
    required this.id,
    required this.title,
    required this.type,
    required this.version,
    required this.date,
    this.parentId,
    this.dependencies = const [],
    this.tags = const [],
  });
}
