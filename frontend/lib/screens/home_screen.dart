import 'package:flutter/material.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  final user;

  HomeScreen({required this.user});

  final List users = [
    {"id": "user2", "name": "User 2"},
    {"id": "user3", "name": "User 3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats"), backgroundColor: Colors.green[300]),

      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    currentUserId: user['_id'],
                    receiverId: users[index]['id'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
