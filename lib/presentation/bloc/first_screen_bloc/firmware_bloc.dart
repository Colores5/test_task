import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:test_task/core/enums/update_type/update_type.dart';
import 'package:test_task/domain/domain.dart';

part 'firmware_event.dart';
part 'firmware_state.dart';

class FirmwareBloc extends Bloc<FirmwareEvent, FirmwareState> {
  final CheckCyclicDependencies checkCyclicDependencies;
  final GetDependencyChain getDependencyChain;
  final SortUpdatesByDate sortUpdatesByDate;
  final SortUpdatesByVersion sortUpdatesByVersion;
  final FilterUpdates filterUpdates;
  final ResetFilters resetFilters;

  FirmwareBloc({
    required this.resetFilters,
    required this.checkCyclicDependencies,
    required this.getDependencyChain,
    required this.sortUpdatesByDate,
    required this.sortUpdatesByVersion,
    required this.filterUpdates,
  }) : super(FirmwareInitial(updates: [])) {
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ResetFiltersEvent>(_onResetFilters);
    on<GetDependencyChainEvent>(_onGetDependencyChain);
    on<CheckCyclicDependenciesEvent>(_checkCyclicDependencies);
    on<SortByDateEvent>(_sortByDate);
    on<SortByVersionEvent>(_sortByVersion);

    add(ResetFiltersEvent());
  }

  FutureOr<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<FirmwareState> emit,
  ) {
    try {
      final sorted = filterUpdates.execute(event.type, event.tags);
      emit(
        FirmwareLoadedState(
          updates: sorted,
          updatesGroupedByParentId: _getGroupedUpdates(sorted),
        ),
      );
    } catch (e) {
      emit(FirmwareFailureState(extencion: e.toString()));
    }
  }

  FutureOr<void> _onResetFilters(
    ResetFiltersEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(
      FirmwareLoadedState(
        updates: resetFilters.execute(),
        updatesGroupedByParentId: _getGroupedUpdates(resetFilters.execute()),
      ),
    );
  }

  FutureOr<void> _onGetDependencyChain(
    GetDependencyChainEvent event,
    Emitter<FirmwareState> emit,
  ) {
    final chain = getDependencyChain.execute(event.id);
    emit(
      FirmwareLoadedState(
        updates: resetFilters.execute(),
        updatesGroupedByParentId: _getGroupedUpdates(resetFilters.execute()),
        dependencyChain: chain,
      ),
    );
  }

  FutureOr<void> _sortByDate(
    SortByDateEvent event,
    Emitter<FirmwareState> emit,
  ) {
    try {
      final sorted = sortUpdatesByDate.execute(event.ascending);
      emit(
        FirmwareLoadedState(
          updates: sorted,
          updatesGroupedByParentId: _getGroupedUpdates(sorted),
        ),
      );
    } catch (e) {
      emit(FirmwareFailureState(extencion: e.toString()));
    }
  }

  FutureOr<void> _sortByVersion(
    SortByVersionEvent event,
    Emitter<FirmwareState> emit,
  ) {
    try {
      final sorted = sortUpdatesByVersion.execute();
      emit(
        FirmwareLoadedState(
          updates: sorted,
          updatesGroupedByParentId: _getGroupedUpdates(sorted),
        ),
      );
    } catch (e) {
      FirmwareFailureState(extencion: e.toString());
    }
  }

  FutureOr<void> _checkCyclicDependencies(
    CheckCyclicDependenciesEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(
      FirmwareLoadedState(
        updates: state.updates,
        updatesGroupedByParentId: state.updatesGroupedByParentId,
        hasCyclicDependencies: checkCyclicDependencies.execute(),
      ),
    );
  }

  Map<String?, List<FirmwareUpdate>> _getGroupedUpdates(
    List<FirmwareUpdate> updates,
  ) {
    return groupBy(updates, (update) => update.parentId);
  }
}
