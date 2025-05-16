import 'package:test_task/domain/domain.dart';
import '../datasources/firmware_update_local_data_source.dart';

class FirmwareRepositoryImpl implements FirmwareRepository {
  final FirmwareUpdateLocalDataSource localDataSource;

  FirmwareRepositoryImpl(this.localDataSource);

  @override
  List<FirmwareUpdate> getAllUpdates() {
    final dtos = localDataSource.getUpdates();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
