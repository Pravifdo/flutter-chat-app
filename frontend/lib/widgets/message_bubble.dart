import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(text),
      ),
    );
  }
}
