import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;
  bool isConnected = false;
  bool isSocketReady = false;

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
      isSocketReady = true;
      print('Socket connected');
      // Notify server that user is online
      socket?.emit("userJoined", userId);
    });

    socket?.on("receiveMessage", (data) {
      print('Message received from socket: $data');
      try {
        if (data is Map) {
          onMessageReceived(Map<String, dynamic>.from(data));
        } else {
          onMessageReceived({"message": data.toString()});
        }
      } catch (e) {
        print('Error processing message: $e');
      }
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
      isSocketReady = false;
      print('Socket disconnected');
    });

    socket?.connect();
  }

  void joinRoom(String roomId) {
    // Wait a bit to ensure socket is ready
    Future.delayed(Duration(milliseconds: 500), () {
      if (isSocketReady) {
        socket?.emit("joinRoom", roomId);
        print('Joined room: $roomId');
      } else {
        print('Socket not ready yet, retrying...');
        joinRoom(roomId);
      }
    });
  }

  void sendMessage(
    String senderId,
    String receiverId,
    String message,
    String roomId,
  ) {
    if (isSocketReady && isConnected) {
      socket?.emit("sendMessage", {
        "senderId": senderId,
        "receiverId": receiverId,
        "message": message,
        "roomId": roomId,
      });
      print('Message sent via socket: $message');
    } else {
      print(
        'Socket not ready. isSocketReady: $isSocketReady, isConnected: $isConnected',
      );
    }
  }

  void disconnect() {
    if (socket != null) {
      socket?.disconnect();
      isSocketReady = false;
    }
    isConnected = false;
  }
}
