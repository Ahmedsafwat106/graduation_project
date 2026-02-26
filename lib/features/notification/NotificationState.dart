abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List notifications;
  NotificationLoaded(this.notifications);
}

class NotificationFailure extends NotificationState {
  final String message;
  NotificationFailure(this.message);
}