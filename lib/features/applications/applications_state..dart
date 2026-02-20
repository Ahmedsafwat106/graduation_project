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
class ApplicantCountLoaded extends ApplicationsState {
  final Map<String, dynamic> counts;

  ApplicantCountLoaded(this.counts);

  @override
  List<Object?> get props => [counts];
}

class ApplicantsScreenLoaded extends ApplicationsState {
  final List applicants;
  final Map<String, dynamic> counts;

  ApplicantsScreenLoaded({
    required this.applicants,
    required this.counts,
  });

  @override
  List<Object?> get props => [applicants, counts];
}

class ApplicantHistoryScreenLoaded extends ApplicationsState {
  final List history;
  final Map<String, dynamic> counts;

  ApplicantHistoryScreenLoaded({
    required this.history,
    required this.counts,
  });

  @override
  List<Object?> get props => [history, counts];
}