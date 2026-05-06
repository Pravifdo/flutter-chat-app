import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://localhost:5000',<String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.emit("join", userrId); // Example user ID