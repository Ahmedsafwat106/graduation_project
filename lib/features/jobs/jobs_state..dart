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
