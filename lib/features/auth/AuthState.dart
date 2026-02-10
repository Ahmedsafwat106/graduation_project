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

// ==========================
// PROFILE LOADED
// ==========================
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

// ==========================
// JOBS LOADED
// ==========================
class JobsLoaded extends AuthState {
  final List jobs;
  JobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

// ==========================
// APPLICATIONS (DEVELOPER)
// ==========================
class ApplicationsLoaded extends AuthState {
  final List applications;
  ApplicationsLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

// ==========================
// APPLICANTS (COMPANY)
// ==========================
class ApplicantsLoaded extends AuthState {
  final List applicants;
  ApplicantsLoaded(this.applicants);

  @override
  List<Object?> get props => [applicants];
}


// ==========================
// CVS LOADED ✅ (برا لوحدها)
// ==========================
class CvsLoaded extends AuthState {
  final List cvs;
  CvsLoaded(this.cvs);

  @override
  List<Object?> get props => [cvs];
}


