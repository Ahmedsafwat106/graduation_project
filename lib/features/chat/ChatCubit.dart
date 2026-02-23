import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'ChatState.dart';


class ChatCubit extends Cubit<ChatState> {
  final ApiService api;

  ChatCubit(this.api) : super(ChatInitial());

  Future<void> startConversation(
      int userId,
      int jobId,
      int companyId,
      ) async {

    emit(ChatLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final result = await api.startConversation(
        token,
        userId,
        jobId,
        companyId,
      );

      emit(ChatSuccess(result["message"] ?? "Conversation Started"));

    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> loadAllChats() async {

    emit(ChatLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final chats = await api.getAllChats(token);

      emit(ChatLoaded(chats));

    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }
}