import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [
    {"text": "Hello!", "isMe": true},
    {"text": "Hi!", "isMe": false},
  ];

  final TextEditingController _controller = TextEditingController();

  void sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      messages.add({"text": _controller.text, "isMe": true});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: Text("Chat"), backgroundColor: Colors.green[300]),

      body: Column(
        children: [
          /// Messages
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  text: messages[index]['text'],
                  isMe: messages[index]['isMe'],
                );
              },
            ),
          ),

          /// Input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
