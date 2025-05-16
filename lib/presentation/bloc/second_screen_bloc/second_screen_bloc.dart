import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graphview/GraphView.dart';
import 'package:test_task/domain/domain.dart';

part 'second_screen_event.dart';
part 'second_screen_state.dart';

class SecondScreenBloc extends Bloc<SecondScreenEvent, SecondScreenState> {
  final ResetFilters getAllUpdates;
  SecondScreenBloc({required this.getAllUpdates})
    : super(SecondScreenInitial()) {
    on<BuildGraphEvent>(_onBuildGraph);
    on<RefreshGraphEvent>(_onRefreshGraph);

    add(BuildGraphEvent());
  }

  FutureOr<void> _onRefreshGraph(
    RefreshGraphEvent event,
    Emitter<SecondScreenState> emit,
  ) async {
    if (state is SecondScreenReady) {
      final currentState = state as SecondScreenReady;
      emit(SecondScreenLoading());
      try {
        final Graph graph = _rebuildGraph(
          currentState.updates,
          currentState.graph,
        );
        emit(SecondScreenReady(graph: graph, updates: currentState.updates));
      } catch (e) {
        emit(SecondScreenError(error: e.toString()));
      }
    }
  }

  FutureOr<void> _onBuildGraph(
    BuildGraphEvent event,
    Emitter<SecondScreenState> emit,
  ) async {
    emit(SecondScreenLoading());
    try {
      final Graph graph = _buildGraph(getAllUpdates.execute());
      emit(SecondScreenReady(graph: graph, updates: getAllUpdates.execute()));
    } catch (e) {
      emit(SecondScreenError(error: e.toString()));
    }
  }

  Graph _buildGraph(List<FirmwareUpdate> updates) {
    final graph = Graph();
    final nodes = <String, Node>{};

    for (final update in updates) {
      nodes[update.id] = Node.Id(update.id);
      graph.addNode(nodes[update.id]!);
    }

    for (final update in updates) {
      if (update.parentId != null && nodes.containsKey(update.parentId)) {
        graph.addEdge(nodes[update.parentId]!, nodes[update.id]!);
      }

      for (final depId in update.dependencies) {
        if (nodes.containsKey(depId)) {
          graph.addEdge(nodes[depId]!, nodes[update.id]!);
        }
      }
    }
    return graph;
  }

  Graph _rebuildGraph(List<FirmwareUpdate> updates, Graph graph) {
    final nodes = <String, Node>{};

    graph.nodes.clear();
    graph.edges.clear();

    for (final update in updates) {
      nodes[update.id] = Node.Id(update.id);
      graph.addNode(nodes[update.id]!);
    }

    for (final update in updates) {
      if (update.parentId != null && nodes.containsKey(update.parentId)) {
        graph.addEdge(nodes[update.parentId]!, nodes[update.id]!);
      }

      for (final depId in update.dependencies) {
        if (nodes.containsKey(depId)) {
          graph.addEdge(nodes[depId]!, nodes[update.id]!);
        }
      }
    }
    FruchtermanReingoldAlgorithm(repulsionPercentage: 0.3).init(graph);
    return graph;
  }
}
