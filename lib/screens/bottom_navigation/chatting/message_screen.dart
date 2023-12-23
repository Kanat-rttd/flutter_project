import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oner/screens/bottom_navigation/chatting/chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildUserList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('user_info').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        final List<Widget> userListItems = [];
        final List<String> usersWithChats = [];

        snapshot.data!.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          final String userEmail = data['email'];
          final String userID = data['uid'];
          final String userName = '${data['firstName']} ${data['lastName']}';

          if (_auth.currentUser!.email != userEmail) {
            usersWithChats.add(userID);

            userListItems.add(
              ListTile(
                title: Text(userName), // Используем имя и фамилию вместо email
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        recieverUserEmail:
                            userName, // Используем имя и фамилию вместо email
                        recieverUserID: userID,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        });

        if (usersWithChats.isNotEmpty) {
          return ListView(children: userListItems);
        } else {
          return const Center(child: Text('Пока нет чатов'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        centerTitle: true,
      ),
      body: _buildUserList(),
    );
  }
}
