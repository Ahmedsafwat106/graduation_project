import 'package:equatable/equatable.dart';

abstract class CvState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CvInitial extends CvState {}

class CvLoading extends CvState {}

class CvsLoaded extends CvState {
  final List cvs;
  CvsLoaded(this.cvs);

  @override
  List<Object?> get props => [cvs];
}

class CvSuccess extends CvState {
  final String message;
  CvSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CvFailure extends CvState {
  final String message;
  CvFailure(this.message);

  @override
  List<Object?> get props => [message];
}
