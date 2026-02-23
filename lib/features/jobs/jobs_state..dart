import 'package:equatable/equatable.dart';

abstract class JobsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List jobs;
  JobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobActionSuccess extends JobsState {
  final String message;
  JobActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class JobsFailure extends JobsState {
  final String message;
  JobsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SkillsLoaded extends JobsState {
  final List<String> skills;

  SkillsLoaded(this.skills);

  @override
  List<Object?> get props => [skills];
}

class CompanyDashboardLoaded extends JobsState {
  final Map<String, dynamic> counts;
  final List jobs;

  CompanyDashboardLoaded({
    required this.counts,
    required this.jobs,
  });

  @override
  List<Object?> get props => [counts, jobs];
}
class DeveloperDashboardLoaded extends JobsState {
  final Map<String, dynamic> counts;
  final List jobs;

  DeveloperDashboardLoaded({
    required this.counts,
    required this.jobs,
  });

  @override
  List<Object?> get props => [counts, jobs];
}
class SavedJobsLoaded extends JobsState {
  final List jobs;

  SavedJobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}
