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
class DeveloperApplyCountUpdated extends JobsState {
  final String userId;
  final int applyCount;
  DeveloperApplyCountUpdated({required this.userId, required this.applyCount});

  @override
  List<Object?> get props => [userId, applyCount];
}

class CompanyApplyCountUpdated extends JobsState {
  final int applyCount;
  final int newCount;
  CompanyApplyCountUpdated({required this.applyCount, required this.newCount});

  @override
  List<Object?> get props => [applyCount, newCount];
}
class ActiveJobsUpdated extends JobsState {
  final int active;
  final int companyId;
  ActiveJobsUpdated({required this.active, required this.companyId});

  @override
  List<Object?> get props => [active, companyId];
}

class StatusUpdatedForCompany extends JobsState {
  final String newStatus;
  final int countInterview;
  final int countAccepted;
  final int countRejected;
  final int countNew;
  StatusUpdatedForCompany({
    required this.newStatus,
    required this.countInterview,
    required this.countAccepted,
    required this.countRejected,
    required this.countNew,
  });

  @override
  List<Object?> get props => [
    newStatus,
    countInterview,
    countAccepted,
    countRejected,
    countNew,
  ];
}

class StatusUpdatedForDeveloper extends JobsState {
  final String newStatus;
  final int countAccepted;
  final int countRejected;
  final int countNew;
  final int countInterview;
  StatusUpdatedForDeveloper({
    required this.newStatus,
    required this.countAccepted,
    required this.countRejected,
    required this.countNew,
    required this.countInterview,
  });

  @override
  List<Object?> get props => [
    newStatus,
    countAccepted,
    countRejected,
    countNew,
    countInterview,
  ];
}