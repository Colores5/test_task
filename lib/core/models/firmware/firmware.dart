import 'package:test_task/test_task_app.dart';

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

final List<FirmwareUpdate> updates = [
  // Android 13 (OS + фичи/патчи)
  FirmwareUpdate(
    id: "android_13",
    title: "Android 13",
    type: UpdateType.OS,
    version: "13.0.0",
    date: DateTime(2022, 8, 15),
  ),
  FirmwareUpdate(
    id: "android_13_1",
    title: "Material You Colors",
    type: UpdateType.Feature,
    version: "13.1.0",
    date: DateTime(2022, 10, 1),
    parentId: "android_13",
    tags: ["UI", "Personalization"],
  ),
  FirmwareUpdate(
    id: "android_13_2",
    title: "Privacy Dashboard",
    type: UpdateType.Feature,
    version: "13.2.0",
    date: DateTime(2022, 11, 5),
    parentId: "android_13",
    tags: ["Security"],
  ),
  FirmwareUpdate(
    id: "android_13_3",
    title: "Google Assistant 2.0",
    type: UpdateType.Feature,
    version: "13.3.0",
    date: DateTime(2023, 1, 20),
    parentId: "android_13",
    tags: ["AI", "Voice"],
  ),
  FirmwareUpdate(
    id: "android_13_security_1",
    title: "January 2023 Security Patch",
    type: UpdateType.SecurityPatch,
    version: "13.4.0",
    date: DateTime(2023, 1, 5),
    parentId: "android_13",
    tags: ["Security"],
  ),

  // Android 12 (OS + фичи/патчи)
  FirmwareUpdate(
    id: "android_12",
    title: "Android 12",
    type: UpdateType.OS,
    version: "12.0.0",
    date: DateTime(2021, 10, 4),
  ),
  FirmwareUpdate(
    id: "android_12_1",
    title: "Material You",
    type: UpdateType.Feature,
    version: "12.1.0",
    date: DateTime(2021, 12, 15),
    parentId: "android_12",
    tags: ["UI"],
  ),
  FirmwareUpdate(
    id: "android_12_2",
    title: "Game Mode",
    type: UpdateType.Feature,
    version: "12.2.0",
    date: DateTime(2022, 2, 10),
    parentId: "android_12",
    tags: ["Gaming"],
  ),
  FirmwareUpdate(
    id: "android_12_security_1",
    title: "March 2022 Security Patch",
    type: UpdateType.SecurityPatch,
    version: "12.3.0",
    date: DateTime(2022, 3, 7),
    parentId: "android_12",
    tags: ["Security"],
  ),
  FirmwareUpdate(
    id: "android_12_bugfix_1",
    title: "Bluetooth Stability Fix",
    type: UpdateType.BugFix,
    version: "12.3.1",
    date: DateTime(2022, 3, 20),
    parentId: "android_12",
    tags: ["Connectivity"],
  ),

  // iOS 16 (OS + фичи/патчи)
  FirmwareUpdate(
    id: "ios_16",
    title: "iOS 16",
    type: UpdateType.OS,
    version: "16.0.0",
    date: DateTime(2022, 9, 12),
  ),
  FirmwareUpdate(
    id: "ios_16_1",
    title: "Lock Screen Customization",
    type: UpdateType.Feature,
    version: "16.1.0",
    date: DateTime(2022, 10, 24),
    parentId: "ios_16",
    tags: ["UI"],
  ),
  FirmwareUpdate(
    id: "ios_16_2",
    title: "Apple Music Sing",
    type: UpdateType.Feature,
    version: "16.2.0",
    date: DateTime(2022, 12, 13),
    parentId: "ios_16",
    tags: ["Music"],
  ),
  FirmwareUpdate(
    id: "ios_16_security_1",
    title: "January 2023 Security Update",
    type: UpdateType.SecurityPatch,
    version: "16.3.0",
    date: DateTime(2023, 1, 23),
    parentId: "ios_16",
    tags: ["Security"],
  ),

  // Windows 11 (OS + фичи/патчи)
  FirmwareUpdate(
    id: "windows_11",
    title: "Windows 11 22H2",
    type: UpdateType.OS,
    version: "22H2",
    date: DateTime(2022, 9, 20),
  ),
  FirmwareUpdate(
    id: "windows_11_1",
    title: "Taskbar Overflow",
    type: UpdateType.Feature,
    version: "22H2.1",
    date: DateTime(2022, 11, 8),
    parentId: "windows_11",
    tags: ["UI"],
  ),
  FirmwareUpdate(
    id: "windows_11_2",
    title: "DirectStorage 1.1",
    type: UpdateType.Feature,
    version: "22H2.2",
    date: DateTime(2023, 1, 10),
    parentId: "windows_11",
    tags: ["Gaming"],
  ),
  FirmwareUpdate(
    id: "windows_11_security_1",
    title: "KB5022303 Security Update",
    type: UpdateType.SecurityPatch,
    version: "22H2.3",
    date: DateTime(2023, 1, 31),
    parentId: "windows_11",
    tags: ["Security"],
  ),

  // Дополнительные обновления (без родительской OS)
  FirmwareUpdate(
    id: "samsung_oneui_5",
    title: "One UI 5.0",
    type: UpdateType.OS,
    version: "5.0.0",
    date: DateTime(2022, 10, 24),
  ),
  FirmwareUpdate(
    id: "samsung_oneui_5_1",
    title: "Enhanced Multitasking",
    type: UpdateType.Feature,
    version: "5.1.0",
    date: DateTime(2023, 2, 1),
    parentId: "samsung_oneui_5",
    tags: ["Productivity"],
  ),
  FirmwareUpdate(
    id: "pixel_feature_drop_1",
    title: "Pixel Feature Drop: March 2023",
    type: UpdateType.Feature,
    version: "1.0.0",
    date: DateTime(2023, 3, 6),
    parentId: "android_13",
    tags: ["Camera", "AI"],
  ),
  FirmwareUpdate(
    id: "macos_ventura",
    title: "macOS Ventura",
    type: UpdateType.OS,
    version: "13.0.0",
    date: DateTime(2022, 10, 24),
  ),
  FirmwareUpdate(
    id: "macos_ventura_1",
    title: "Stage Manager",
    type: UpdateType.Feature,
    version: "13.1.0",
    date: DateTime(2022, 12, 13),
    parentId: "macos_ventura",
    tags: ["Productivity"],
  ),
];
