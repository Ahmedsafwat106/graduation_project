import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);

  @override
  List<Object?> get props => [token];
}

// ===== بعد التصحيح =====
class ProfileLoaded extends AuthState {
  final Map<String, dynamic> user;
  ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class CompanyProfileLoaded extends AuthState {
  final Map<String, dynamic> data;
  CompanyProfileLoaded(this.data);

  @override
  List<Object?> get props => [data];
}
