import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_task/test_task_app.dart';
import 'package:collection/collection.dart';

part 'firmware_event.dart';
part 'firmware_state.dart';

class FirmwareBloc extends Bloc<FirmwareEvent, FirmwareState> {
  final List<FirmwareUpdate> _updates;

  FirmwareBloc({required List<FirmwareUpdate> allUpdates})
    : _updates = allUpdates,
      super(FirmwareInitial(updates: allUpdates)) {
    on<InitEvent>(_onInit);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ResetFiltersEvent>(_onResetFilters);
    on<GetDependencyChainEvent>(_onGetDependencyChain);
    on<CheckCyclicDependenciesEvent>(_checkCyclicDependencies);
    on<SortByDateEvent>(_sortByDate);
    on<SortByVersionEvent>(_sortByVersion);

    add(InitEvent());
  }

  FutureOr<void> _onInit(InitEvent event, Emitter<FirmwareState> emit) {
    try {
      emit(
        FirmwareLoadedState(
          updates: _updates,
          updatesGroupedByParentId: _getGroupedUpdates(_updates),
        ),
      );
    } catch (e) {
      emit(FirmwareFailureState(extencion: e, updates: _updates));
    }
  }

  FutureOr<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(FirmwareLoadingState(updates: _updates));
    try {
      List<FirmwareUpdate> filteredUpdates = _updates.toList();
      if (event.type != null) {
        filteredUpdates =
            filteredUpdates.where((i) => i.type == event.type).toList();
      }
      if (event.tags != null && event.tags!.isNotEmpty) {
        filteredUpdates =
            filteredUpdates
                .where((i) => i.tags.any((tag) => event.tags!.contains(tag)))
                .toList();
      }
      emit(
        FirmwareLoadedState(
          updates: filteredUpdates,
          updatesGroupedByParentId: _getGroupedUpdates(filteredUpdates),
        ),
      );
    } catch (e) {
      emit(FirmwareFailureState(extencion: e.toString(), updates: _updates));
    }
  }

  FutureOr<void> _onResetFilters(
    ResetFiltersEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(
      FirmwareLoadedState(
        updates: _updates,
        updatesGroupedByParentId: _getGroupedUpdates(_updates),
      ),
    );
  }

  FutureOr<void> _onGetDependencyChain(
    GetDependencyChainEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(FirmwareLoadingState(updates: _updates));
    final chain = _getDependencyChain(event.id);
    emit(
      FirmwareLoadedState(
        updates: _updates,
        updatesGroupedByParentId: _getGroupedUpdates(_updates),
        dependencyChain: chain,
      ),
    );
  }

  List<String> _getDependencyChain(String id) {
    final List<String> result = [];
    final Set<String> visitedIds = {};

    FirmwareUpdate? getUpdate(String id) {
      return updates.firstWhere((u) => u.id == id);
    }

    void collectChildren(String currentId) {
      if (visitedIds.contains(currentId)) return;
      visitedIds.add(currentId);

      final children = updates.where((i) => i.parentId == currentId).toList();
      for (final child in children) {
        result.add(child.id);
        collectChildren(child.id);
      }
    }

    // Сначала ищем корневой элемент
    FirmwareUpdate? current = getUpdate(id);
    if (current == null) return result;

    while (current!.parentId != null) {
      final parent = getUpdate(current.parentId!);
      if (parent == null) break;
      current = parent;
    }

    // Теперь current — корень (OS), собираем цепочку вниз
    collectChildren(current.id);

    return result;
  }

  FutureOr<void> _sortByDate(
    SortByDateEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(FirmwareLoadingState(updates: _updates));
    try {
      final sorted = List<FirmwareUpdate>.from(state.updates);
      sorted.sort(
        (a, b) =>
            event.ascending
                ? a.date.compareTo(b.date)
                : b.date.compareTo(a.date),
      );
      emit(
        FirmwareLoadedState(
          updates: sorted,
          updatesGroupedByParentId: _getGroupedUpdates(sorted),
        ),
      );
    } catch (e) {
      emit(FirmwareFailureState(extencion: e.toString(), updates: _updates));
    }
  }

  FutureOr<void> _sortByVersion(
    SortByVersionEvent event,
    Emitter<FirmwareState> emit,
  ) {
    emit(FirmwareLoadingState(updates: _updates));
    try {
      final sorted = List<FirmwareUpdate>.from(state.updates);
      sorted.sort((a, b) => _parseAndCompareVersions(a.version, b.version));
      emit(
        FirmwareLoadedState(
          updates: sorted,
          updatesGroupedByParentId: _getGroupedUpdates(sorted),
        ),
      );
    } catch (e) {
      FirmwareFailureState(extencion: e.toString(), updates: _updates);
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
        hasCyclicDependencies: _hasCyclicDependencies(),
      ),
    );
  }

  Map<String?, List<FirmwareUpdate>> _getGroupedUpdates(
    List<FirmwareUpdate> updates,
  ) {
    return groupBy(updates, (update) => update.parentId);
  }

  int _parseAndCompareVersions(String a, String b) {
    final partA = a.split('.');
    final partB = b.split('.');

    for (var i = 0; i < max(partA.length, partB.length); i++) {
      final aVal = i < partA.length ? int.tryParse(partA[i]) ?? 0 : 0;
      final bVal = i < partB.length ? int.tryParse(partB[i]) ?? 0 : 0;

      if (aVal != bVal) {
        return aVal.compareTo(bVal);
      }
    }
    return 0;
  }

  bool _hasCyclicDependencies() {
    final visited = <String, bool>{};
    final recursionStack = <String, bool>{};

    for (final update in _updates) {
      if (_isCyclic(update.id, visited, recursionStack)) {
        return true;
      }
    }
    return false;
  }

  bool _isCyclic(
    String id,
    Map<String, bool> visited,
    Map<String, bool> recursionStack,
  ) {
    if (recursionStack[id] == true) return true;
    if (visited[id] == true) return false;

    visited[id] = true;
    recursionStack[id] = true;

    final update = _updates.firstWhere((u) => u.id == id);
    for (final depId in update.dependencies) {
      if (_isCyclic(depId, visited, recursionStack)) {
        return true;
      }
    }

    recursionStack[id] = false;
    return false;
  }
}
