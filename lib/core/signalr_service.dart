import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _connection;

  Future<void> connect({
    required String token,
    required Function(Map<String, dynamic>) onMessageReceived,
  }) async {

    final hubUrl = "http://devjob.runasp.net/messageHub";

    _connection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      options: HttpConnectionOptions(
        accessTokenFactory: () async => token,
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect()
        .build();

    // 🔥 Listener للـ RPC: ReceiveMessage (زي ما الباك محدده)
    _connection!.on("ReceiveMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        onMessageReceived(data);
      }
    });

    await _connection!.start();
    print("🟢 SignalR Connected to messageHub");
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    print("🔴 SignalR Disconnected");
  }
}