import 'package:test_task/domain/domain.dart';

abstract class FirmwareRepository {
  List<FirmwareUpdate> getAllUpdates();
}
