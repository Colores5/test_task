import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_task/core/enums/update_type/update_type.dart';
import 'package:test_task/presentation/bloc/first_screen_bloc/firmware_bloc.dart';
import 'package:test_task/presentation/pages/second_screen/second_screen.dart';

class FirmwareListScreen extends StatefulWidget {
  const FirmwareListScreen({super.key});

  @override
  State<FirmwareListScreen> createState() => _FirmwareListScreenState();
}

class _FirmwareListScreenState extends State<FirmwareListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список обновлений'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DependencyGraphScreen(),
                ),
              );
              context.read<FirmwareBloc>().add(ResetFiltersEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.warning),
            onPressed:
                () => context.read<FirmwareBloc>().add(
                  CheckCyclicDependenciesEvent(),
                ),
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
                          context.read<FirmwareBloc>().add(
                            ApplyFiltersEvent(type: selected ? type : null),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed:
                        () => context.read<FirmwareBloc>().add(
                          ResetFiltersEvent(),
                        ),
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
                builder: (context, state) {
                  final allTags =
                      context
                          .read<FirmwareBloc>()
                          .state
                          .updates
                          ?.expand((u) => u.tags)
                          .toSet()
                          .toList();
                  return Row(
                    children: [
                      ...allTags!.map(
                        (tag) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FilterChip(
                            label: Text(tag),
                            selected: false,
                            onSelected: (selected) {
                              context.read<FirmwareBloc>().add(
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
                        () => context.read<FirmwareBloc>().add(
                          SortByDateEvent(ascending: true),
                        ),
                    child: Text('Дата (↑)'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed:
                        () => context.read<FirmwareBloc>().add(
                          SortByDateEvent(ascending: false),
                        ),
                    child: Text('Дата (↓)'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed:
                        () => context.read<FirmwareBloc>().add(
                          SortByVersionEvent(),
                        ),
                    child: const Text('Сортировать по версии'),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<FirmwareBloc, FirmwareState>(
            builder: (context, state) {
              if (state is FirmwareLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FirmwareFailureState) {
                return Center(child: Text('Ошибка: ${state.extencion}'));
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
                                          '${child.type.name} - v.${child.version} - Дата: ${DateFormat('dd.MM.yyyy').format(child.date)} ${child.tags.isNotEmpty ? '- Теги: ${child.tags.join(', ')}' : ''}',
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
              return Expanded(child: Center(child: Text('Пусто')));
            },
          ),
        ],
      ),
    );
  }
}
