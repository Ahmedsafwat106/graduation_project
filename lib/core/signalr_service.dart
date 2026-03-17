import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

class SignalRService {
  HubConnection? _connection;
  HubConnection? _jobConnection;

  Future<void> connect({
    required String token,
    required Function(Map<String, dynamic>) onMessageReceived,
    Function(int messageId)? onMessageDeleted,
    Function(int messageId, String newMessage)? onMessageUpdated,
    Function(int userId, int newCount)? onMessageCountUpdated,
  }) async {
    _connection = HubConnectionBuilder()
        .withUrl(
      "http://devjob.runasp.net/messageHub",
      options: HttpConnectionOptions(
        accessTokenFactory: () async => token,
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect()
        .build();

    _connection!.on("ReceiveMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        onMessageReceived(data);
      }
    });

    _connection!.on("DeleteMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        final messageId = data["MessageId"] ?? data["messageId"];
        if (messageId != null && onMessageDeleted != null) {
          onMessageDeleted(messageId);
        }
      }
    });

    _connection!.on("UpdateMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        final messageId = data["messageId"] ?? data["MessageId"];
        final newMessage = data["newMessage"] ?? data["NewMessage"] ?? "";
        if (messageId != null && onMessageUpdated != null) {
          onMessageUpdated(messageId, newMessage);
        }
      }
    });

    _connection!.on("updateMessageNumber", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        final userId = data["user"];
        final newCount = data["newMessage"];
        if (userId != null && newCount != null && onMessageCountUpdated != null) {
          onMessageCountUpdated(
            userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
            newCount is int ? newCount : int.tryParse(newCount.toString()) ?? 0,
          );
        }
      }
    });

    await _connection!.start();
    print("🟢 SignalR Connected to MessageHub");
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    print("🔴 SignalR MessageHub Disconnected");
  }

  Future<void> connectJobHub({
    required String token,
    Function(String userId, int applyCount)? onApplyCountForDeveloper,
    Function(int applyCount, int newCount)? onApplyCountForCompany,
    Function(int active, int companyId)? onActiveJobsUpdated,
    Function(Map<String, dynamic>)? onStatusUpdatedForCompany,
    Function(Map<String, dynamic>)? onStatusUpdatedForDeveloper,
  }) async {
    if (_jobConnection != null &&
        _jobConnection!.state == HubConnectionState.Connected) return;

    _jobConnection = HubConnectionBuilder()
        .withUrl(
      "http://devjob.runasp.net/jobHub",
      options: HttpConnectionOptions(
        accessTokenFactory: () async => token,
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect()
        .build();

    _jobConnection!.on("UpdateApplyCount", (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final data = arguments.first as Map<String, dynamic>;

      if (data.containsKey("ApplyCountForDeveloper") ||
          data.containsKey("applyCountForDeveloper")) {
        final userId = (data["user"] ?? data["User"] ?? "").toString();
        final count =
            data["ApplyCountForDeveloper"] ?? data["applyCountForDeveloper"] ?? 0;
        if (onApplyCountForDeveloper != null) {
          onApplyCountForDeveloper(
            userId,
            count is int ? count : int.tryParse(count.toString()) ?? 0,
          );
        }
      }

      if (data.containsKey("ApplyCountForCompany") ||
          data.containsKey("applyCountForCompany")) {
        final applyCount =
            data["ApplyCountForCompany"] ?? data["applyCountForCompany"] ?? 0;
        final newCount =
            data["newCountForCompany"] ?? data["NewCountForCompany"] ?? 0;
        if (onApplyCountForCompany != null) {
          onApplyCountForCompany(
            applyCount is int ? applyCount : int.tryParse(applyCount.toString()) ?? 0,
            newCount is int ? newCount : int.tryParse(newCount.toString()) ?? 0,
          );
        }
      }
    });

    _jobConnection!.on("ActiveJobs", (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final data = arguments.first as Map<String, dynamic>;
      final active = data["active"] ?? data["Active"] ?? 0;
      final companyId =
          data["compantId"] ?? data["companyId"] ?? data["CompanyId"] ?? 0;
      if (onActiveJobsUpdated != null) {
        onActiveJobsUpdated(
          active is int ? active : int.tryParse(active.toString()) ?? 0,
          companyId is int ? companyId : int.tryParse(companyId.toString()) ?? 0,
        );
      }
    });

    _jobConnection!.on("UpdateStatus", (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final data = arguments.first as Map<String, dynamic>;

      final hasCompanyFields =
          data.containsKey("countInterviewForCompany") ||
              data.containsKey("CountInterviewForCompany");

      final hasDeveloperFields =
          data.containsKey("countInterviewForDeveloper") ||
              data.containsKey("CountInterviewForDeveloper") ||
              data.containsKey("countAcceptedForDeveloper") ||
              data.containsKey("CountAcceptedForDeveloper");

      if (hasCompanyFields && onStatusUpdatedForCompany != null) {
        onStatusUpdatedForCompany(data);
      }

      if (hasDeveloperFields && onStatusUpdatedForDeveloper != null) {
        onStatusUpdatedForDeveloper(data);
      }
    });

    await _jobConnection!.start();
    print("🟢 SignalR Connected to JobHub");
  }

  Future<void> disconnectJobHub() async {
    await _jobConnection?.stop();
    print("🔴 SignalR JobHub Disconnected");
  }
}
