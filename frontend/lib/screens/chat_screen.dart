import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? receiverId;
  final String? receiverName;

  const ChatScreen({Key? key, this.receiverId, this.receiverName})
    : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SocketService socketService;
  late String currentUserId;
  late String currentUserName;
  List<dynamic> users = [];
  bool isLoading = true;
  List<dynamic> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Get current user ID
    currentUserId = (await ApiService.getUserId()) ?? '';
    final prefs = await SharedPreferences.getInstance();
    currentUserName = prefs.getString('user_name') ?? 'User';

    socketService = SocketService();

    // If receiverId is provided, load chat history and connect
    if (widget.receiverId != null) {
      _loadChatHistory();
      _connectSocket();
    } else {
      // Load list of users
      await _loadUsers();
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadUsers() async {
    try {
      final userList = await ApiService.getAllUsers();
      setState(() => users = userList);
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final chatMessages = await ApiService.getMessages(
        widget.receiverId ?? '',
      );
      setState(() => messages = chatMessages);
      _scrollToBottom();
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void _connectSocket() {
    socketService.connect(
      currentUserId,
      onMessageReceived: (message) {
        setState(() {
          messages.add(message);
        });
        _scrollToBottom();
      },
      onUserOnline: (userId) {
        print('User $userId is online');
      },
      onUserOffline: (userId) {
        print('User $userId is offline');
      },
    );

    // Join room for 1-on-1 chat
    if (widget.receiverId != null) {
      final roomId = [currentUserId, widget.receiverId!].toList()..sort();
      socketService.joinRoom(roomId.join('_'));
    }
  }

  void _sendMessage() async {
    if (messageController.text.isEmpty) return;

    final message = messageController.text;
    messageController.clear();

    // Save to database
    final result = await ApiService.sendMessage(
      receiverId: widget.receiverId ?? '',
      message: message,
    );

    if (result['success']) {
      // Send via Socket.io for real-time delivery
      final roomId = [currentUserId, widget.receiverId!].toList()..sort();
      socketService.sendMessage(
        currentUserId,
        widget.receiverId ?? '',
        message,
        roomId.join('_'),
      );

      // Add to local UI
      setState(() {
        messages.add({
          '_id': DateTime.now().toString(),
          'senderId': {'_id': currentUserId},
          'receiverId': {'_id': widget.receiverId},
          'message': message,
          'createdAt': DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
    }
  }

  void _selectUser(Map<String, dynamic> user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(receiverId: user['_id'], receiverName: user['name']),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Scroll logic here if using ScrollController
      }
    });
  }

  void _logout() async {
    socketService.disconnect();
    await ApiService.clearAuth();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue[700])),
      );
    }

    // Chat view
    if (widget.receiverId != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Text(widget.receiverName ?? 'Chat'),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg['senderId']['_id'] == currentUserId;
                        return MessageBubble(text: msg['message'], isMe: isMe);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue[700],
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Users list view
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Chats'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                'No users available',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    child: Text(
                      (user['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['name'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? ''),
                  onTap: () => _selectUser(user),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    socketService.disconnect();
    messageController.dispose();
    super.dispose();
  }
}
