import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/data/datasources/firmware_update_local_data_source.dart';
import 'package:test_task/data/repositories/firmware_repository_impl.dart';
import 'package:test_task/domain/usecases/check_cyclic_dependencies.dart';
import 'package:test_task/domain/usecases/filter_updates.dart';
import 'package:test_task/domain/usecases/get_dependency_chain.dart';
import 'package:test_task/domain/usecases/reset_filters.dart';
import 'package:test_task/domain/usecases/sort_updates_by_date.dart';
import 'package:test_task/domain/usecases/sort_updates_by_version.dart';
import 'package:test_task/presentation/bloc/second_screen_bloc/second_screen_bloc.dart';
import 'package:test_task/presentation/pages/first_screen/first_screen.dart';
import 'package:test_task/presentation/presentation.dart';

void main() {
  final localDataSource = FirmwareUpdateLocalDataSource();
  final repository = FirmwareRepositoryImpl(localDataSource);
  final getDependencyChain = GetDependencyChain(repository);
  final sortByDate = SortUpdatesByDate(repository);
  final sortByVersion = SortUpdatesByVersion(repository);
  final filterUpdates = FilterUpdates(repository);
  final checkCyclicDependencies = CheckCyclicDependencies(repository);
  final resetFilters = ResetFilters(repository: repository);
  final firmwareBloc = FirmwareBloc(
    resetFilters: resetFilters,
    checkCyclicDependencies: checkCyclicDependencies,
    getDependencyChain: getDependencyChain,
    sortUpdatesByDate: sortByDate,
    sortUpdatesByVersion: sortByVersion,
    filterUpdates: filterUpdates,
  );
  final secondScreenBloc = SecondScreenBloc(getAllUpdates: resetFilters);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => firmwareBloc),
        BlocProvider(create: (context) => secondScreenBloc),
      ],
      child: MaterialApp(
        home: FirmwareListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
