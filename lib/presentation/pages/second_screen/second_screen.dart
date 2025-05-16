import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:test_task/core/enums/update_type/update_type.dart';
import 'package:test_task/domain/domain.dart';
import 'package:test_task/presentation/bloc/second_screen_bloc/second_screen_bloc.dart';

class DependencyGraphScreen extends StatelessWidget {
  const DependencyGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Граф зависимостей'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SecondScreenBloc>().add(RefreshGraphEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<SecondScreenBloc, SecondScreenState>(
        builder: (context, state) {
          if (state is SecondScreenLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          if (state is SecondScreenError) {
            return Center(child: Text('Ошибка: ${state.error}'));
          }

          if (state is SecondScreenReady) {
            return _GraphVisualizer(graph: state.graph, updates: state.updates);
          }

          return const Center(child: Text('Инициализация...'));
        },
      ),
    );
  }
}

class _GraphVisualizer extends StatelessWidget {
  final Graph graph;
  final List<FirmwareUpdate> updates;

  const _GraphVisualizer({required this.graph, required this.updates});

  @override
  Widget build(BuildContext context) {
    final algorithm = FruchtermanReingoldAlgorithm(repulsionPercentage: 0.3);

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.01,
      maxScale: 5.6,
      child: GraphView(
        graph: graph,
        algorithm: algorithm,
        paint:
            Paint()
              ..color = Colors.grey[300]!
              ..strokeWidth = 1
              ..style = PaintingStyle.fill,
        builder: (Node node) {
          final id = node.key!.value as String;
          final update = updates.firstWhere(
            (u) => u.id == id,
            orElse:
                () => FirmwareUpdate(
                  id: id,
                  title: id,
                  type: UpdateType.OS,
                  version: 'Initial',
                  date: DateTime.now(),
                ),
          );

          Color getColorByType(UpdateType type) {
            switch (type) {
              case UpdateType.OS:
                return Colors.blue;
              case UpdateType.Feature:
                return Colors.green;
              case UpdateType.SecurityPatch:
                return Colors.orange;
              case UpdateType.BugFix:
                return Colors.red;
            }
          }

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: getColorByType(update.type),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  update.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (update.type != UpdateType.OS && update.version.isNotEmpty)
                  Text(
                    'v${update.version}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
