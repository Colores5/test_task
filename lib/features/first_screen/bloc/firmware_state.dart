part of 'firmware_bloc.dart';

abstract class FirmwareState extends Equatable {
  final List<FirmwareUpdate> updates;
  final Map<String?, List<FirmwareUpdate>>? updatesGroupedByParentId;
  final bool hasCyclicDependencies;
  final List<String>? dependencyChain;

  const FirmwareState({
    required this.updates,
    this.updatesGroupedByParentId,
    this.hasCyclicDependencies = false,
    this.dependencyChain,
  });

  @override
  List<Object> get props => [
    updates,
    updatesGroupedByParentId ?? {},
    hasCyclicDependencies,
    dependencyChain ?? [],
  ];
}

class FirmwareInitial extends FirmwareState {
  const FirmwareInitial({
    required super.updates,
    super.updatesGroupedByParentId,
    super.hasCyclicDependencies,
    super.dependencyChain,
  });
}

class FirmwareLoadingState extends FirmwareState {
  const FirmwareLoadingState({required super.updates});
}

class FirmwareLoadedState extends FirmwareState {
  const FirmwareLoadedState({
    required super.updates,
    super.updatesGroupedByParentId,
    super.hasCyclicDependencies,
    super.dependencyChain,
  });

  @override
  List<Object> get props => [
    updates,
    updatesGroupedByParentId ?? {},
    hasCyclicDependencies,
    dependencyChain ?? [],
  ];
}

class FirmwareFailureState extends FirmwareState {
  final Object? extencion;

  const FirmwareFailureState({required this.extencion, required super.updates});

  @override
  List<Object> get props => [extencion ?? ''];
}
