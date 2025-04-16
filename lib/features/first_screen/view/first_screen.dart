import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_task/features/first_screen/bloc/firmware_bloc.dart';
import 'package:test_task/test_task_app.dart';

class FirmwareListScreen extends StatefulWidget {
  const FirmwareListScreen({super.key});

  @override
  State<FirmwareListScreen> createState() => _FirmwareListScreenState();
}

class _FirmwareListScreenState extends State<FirmwareListScreen> {
  final _bloc = FirmwareBloc(allUpdates: updates);

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список обновлений'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DependencyGraphScreen(),
                  ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.warning),
            onPressed: () => _bloc.add(CheckCyclicDependenciesEvent()),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  ...UpdateType.values.map(
                    (type) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(type.name),
                        selected: false,
                        onSelected: (selected) {
                          _bloc.add(
                            ApplyFiltersEvent(type: selected ? type : null),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _bloc.add(ResetFiltersEvent()),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: BlocBuilder<FirmwareBloc, FirmwareState>(
                bloc: _bloc,
                builder: (context, state) {
                  final allTags =
                      _bloc.state.updates
                          .expand((u) => u.tags)
                          .toSet()
                          .toList();
                  return Row(
                    children: [
                      ...allTags.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FilterChip(
                            label: Text(tag),
                            selected: false,
                            onSelected: (selected) {
                              _bloc.add(
                                ApplyFiltersEvent(
                                  tags: selected ? [tag] : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed:
                        () => _bloc.add(SortByDateEvent(ascending: true)),
                    child: Text('Дата (↑)'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed:
                        () => _bloc.add(SortByDateEvent(ascending: false)),
                    child: Text('Дата (↓)'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed: () => _bloc.add(SortByVersionEvent()),
                    child: const Text('Сортировать по версии'),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<FirmwareBloc, FirmwareState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is FirmwareLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FirmwareFailureState) {
                return Center(child: Text('Error: ${state.extencion}'));
              }

              final groupedUpdates = state.updatesGroupedByParentId ?? {};
              final keyUpdates = groupedUpdates.keys.toList();

              if (state is FirmwareLoadedState) {
                if (!state.hasCyclicDependencies) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: keyUpdates.length,
                      itemBuilder: (context, index) {
                        final os = keyUpdates[index];

                        final children = groupedUpdates[os] ?? [];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ExpansionTile(
                            title: ListTile(title: Text(os ?? 'OS')),
                            children:
                                children
                                    .map(
                                      (child) => ListTile(
                                        title: Text(child.title),
                                        subtitle: Text(
                                          '${child.type.name} - v.${child.version} - Дата: ${DateFormat('dd.MM.yyyy').format(child.date)}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        );
                      },
                    ),
                  );
                }
              }
              return Expanded(
                child: Center(child: Text('Есть циклические зависимости')),
              );
            },
          ),
        ],
      ),
    );
  }
}
