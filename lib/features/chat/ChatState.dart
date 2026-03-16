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
class ChatMessagesLoaded extends ChatState {
  final List messages;

  ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}
class ChatMessageDeleted extends ChatState {
  final int messageId;
  ChatMessageDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
class MessageCountUpdated extends ChatState {
  final int userId;
  final int newCount;
  MessageCountUpdated({required this.userId, required this.newCount});

  @override
  List<Object?> get props => [userId, newCount];
}