import 'package:equatable/equatable.dart';

abstract class ApplicationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ApplicationsInitial extends ApplicationsState {}

class ApplicationsLoading extends ApplicationsState {}

class ApplicationsLoaded extends ApplicationsState {
  final List applications;
  ApplicationsLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

class ApplicantsLoaded extends ApplicationsState {
  final List applicants;
  ApplicantsLoaded(this.applicants);

  @override
  List<Object?> get props => [applicants];
}

class ApplicationsSuccess extends ApplicationsState {
  final String message;
  ApplicationsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ApplicationsFailure extends ApplicationsState {
  final String message;
  ApplicationsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
