import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List chats;

  ChatLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatSuccess extends ChatState {
  final String message;

  ChatSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatFailure extends ChatState {
  final String message;

  ChatFailure(this.message);

  @override
  List<Object?> get props => [message];
}