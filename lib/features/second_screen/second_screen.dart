import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/features/first_screen/bloc/firmware_bloc.dart';
import 'package:test_task/test_task_app.dart';

class DependencyGraphScreen extends StatefulWidget {
  const DependencyGraphScreen({super.key});

  @override
  State<DependencyGraphScreen> createState() => _DependencyGraphScreenState();
}

class _DependencyGraphScreenState extends State<DependencyGraphScreen> {
  final _bloc = FirmwareBloc(allUpdates: updates);
  String? _selectedUpdateTitle;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FirmwareBloc, FirmwareState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is FirmwareLoadedState && state.dependencyChain != null) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Зависисости для ${_selectedUpdateTitle}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Зависимости:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...(state.dependencyChain?.toSet().map(
                            (dep) => Text(dep),
                          ) ??
                          []),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Граф зависимостей')),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<FirmwareBloc, FirmwareState>(
                bloc: _bloc,
                builder: (context, state) {
                  if (state is FirmwareLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FirmwareFailureState) {
                    return Center(child: Text('Ошибка: ${state.extencion}'));
                  }

                  final groupedUpdates = state.updatesGroupedByParentId ?? {};
                  final osUpdates = groupedUpdates[null] ?? [];

                  return ListView.builder(
                    itemCount: osUpdates.length,
                    itemBuilder: (context, index) {
                      final os = osUpdates[index];
                      final children = groupedUpdates[os.id] ?? [];

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Text(
                            os.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${os.type} - ${os.version}'),
                          children:
                              children
                                  .map(
                                    (child) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: Text(child.title),
                                            subtitle: Text(
                                              '${child.type} - ${child.version}',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.account_tree,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedUpdateTitle =
                                                      child.title;
                                                });
                                                _bloc.add(
                                                  GetDependencyChainEvent(
                                                    id: child.id,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
