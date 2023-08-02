import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    final authinticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatsnapshots) {
          if (chatsnapshots.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!chatsnapshots.hasData || chatsnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No any messages'),
            );
          }

          if (chatsnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final loadedMessages = chatsnapshots.data!.docs;
          final msgCount = loadedMessages.length;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: msgCount,
            itemBuilder: (ctx, index) {
              final chatMsg = loadedMessages[index].data();
              final nextMsg = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentUserID = chatMsg['userID'];
              final nextUserID = nextMsg != null ? nextMsg['userID'] : null;

              final nextIsSameUser = currentUserID == nextUserID;

              if (nextIsSameUser) {
                return MessageBubble.next(
                    message: chatMsg['text'],
                    isMe: currentUserID == authinticatedUser!.uid);
              } else {
                return MessageBubble.first(
                    userImage: chatMsg['userImage'],
                    username: chatMsg['username'],
                    message: chatMsg['text'],
                    isMe: currentUserID == authinticatedUser!.uid);
              }
            },
          );
        });
  }
}
