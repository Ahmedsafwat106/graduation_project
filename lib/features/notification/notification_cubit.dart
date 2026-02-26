import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_service.dart';
import 'NotificationState.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final ApiService apiService;

  NotificationCubit(this.apiService)
      : super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        emit(NotificationFailure("No token found"));
        return;
      }

      final notifications =
      await apiService.getAllNotifications(token);

      emit(NotificationLoaded(notifications));

    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }
}