part of 'second_screen_bloc.dart';

abstract class SecondScreenState extends Equatable {
  const SecondScreenState();

  @override
  List<Object> get props => [];
}

class SecondScreenInitial extends SecondScreenState {}

class SecondScreenLoading extends SecondScreenState {}

class SecondScreenReady extends SecondScreenState {
  final Graph graph;
  final List<FirmwareUpdate> updates;

  const SecondScreenReady({required this.graph, required this.updates});

  @override
  List<Object> get props => [graph, updates];
}

class SecondScreenError extends SecondScreenState {
  final String error;

  const SecondScreenError({required this.error});

  @override
  List<Object> get props => [error];
}
