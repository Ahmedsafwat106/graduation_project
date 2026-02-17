import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileSuccess extends ProfileState {
  final String message;
  ProfileSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
