part of 'second_screen_bloc.dart';

abstract class SecondScreenEvent extends Equatable {
  const SecondScreenEvent();

  @override
  List<Object> get props => [];
}

class BuildGraphEvent extends SecondScreenEvent {}

class RefreshGraphEvent extends SecondScreenEvent {}
