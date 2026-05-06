import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;
  bool isConnected = false;

  void connect(
    String userId, {
    required Function(Map<String, dynamic>) onMessageReceived,
    required Function(String) onUserOnline,
    required Function(String) onUserOffline,
  }) {
    socket = IO.io(
      "http://localhost:5000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket?.onConnect((_) {
      isConnected = true;
      print('Socket connected');
      // Notify server that user is online
      socket?.emit("userJoined", userId);
    });

    socket?.on("receiveMessage", (data) {
      print('Message received: $data');
      onMessageReceived(Map<String, dynamic>.from(data));
    });

    socket?.on("userOnline", (userId) {
      print('User online: $userId');
      onUserOnline(userId);
    });

    socket?.on("userOffline", (userId) {
      print('User offline: $userId');
      onUserOffline(userId);
    });

    socket?.onDisconnect((_) {
      isConnected = false;
      print('Socket disconnected');
    });

    socket?.connect();
  }

  void joinRoom(String roomId) {
    if (isConnected) {
      socket?.emit("joinRoom", roomId);
      print('Joined room: $roomId');
    }
  }

  void sendMessage(
    String senderId,
    String receiverId,
    String message,
    String roomId,
  ) {
    if (isConnected) {
      socket?.emit("sendMessage", {
        "senderId": senderId,
        "receiverId": receiverId,
        "message": message,
        "roomId": roomId,
      });
      print('Message sent: $message');
    }
  }

  void disconnect() {
    if (socket != null) {
      socket?.disconnect();
    }
    isConnected = false;
  }
}
