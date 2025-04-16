part of 'firmware_bloc.dart';

abstract class FirmwareEvent extends Equatable {
  const FirmwareEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends FirmwareEvent {}

class ApplyFiltersEvent extends FirmwareEvent {
  final UpdateType? type;
  final List<String>? tags;

  const ApplyFiltersEvent({this.type, this.tags});

  @override
  List<Object> get props => [type ?? '', tags ?? []];
}

class GetDependencyChainEvent extends FirmwareEvent {
  final String id;

  const GetDependencyChainEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class CheckCyclicDependenciesEvent extends FirmwareEvent {}

class SortByDateEvent extends FirmwareEvent {
  final bool ascending;

  const SortByDateEvent({required this.ascending});

  @override
  List<Object> get props => [ascending];
}

class SortByVersionEvent extends FirmwareEvent {}

class ResetFiltersEvent extends FirmwareEvent {}
