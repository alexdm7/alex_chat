
import 'package:alex_chat/widgits/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';

class ChatMasseges extends StatefulWidget{
 const ChatMasseges({super.key});

  @override
  State<ChatMasseges> createState() => _ChatMassegesState();
}

class _ChatMassegesState extends State<ChatMasseges> {
  void stupPuchNotivgation ()async{

    final fcm =FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token=await fcm.getToken();
    fcm.subscribeToTopic('chat');

  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final authctionUser= FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore
            .instance.collection('chat')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),
        builder: (cxt, chatSnapshots) {
      if(chatSnapshots.connectionState == ConnectionState.waiting){
        return Center(child:CircularProgressIndicator(),);
      }
      if(!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty){
         return Center(child: Text('no masseges'),);
      }
      if(chatSnapshots.hasError){
        return Center(child: Text('ohhhhhhhhhh'),);
      }
      final loadedmasseges=chatSnapshots.data!.docs;
      return ListView.builder(
        padding: const EdgeInsets.only(

          left: 13,
          right:13 ,
          bottom:40 ,


        ),
          reverse: true,

          itemCount: loadedmasseges.length,
          itemBuilder: (ctx, index) {
          final chatMassege=loadedmasseges[index].data();
          final nextChatMassege=index+1 < loadedmasseges.length
          ? loadedmasseges[index+1].data()
              :null;
          final crrentMassegeUserId=chatMassege['userId'];
          final nextMassegeUserId=
              nextChatMassege != null ? nextChatMassege['userId']:null;
          final nextUserSame=nextMassegeUserId == crrentMassegeUserId;
          if(nextUserSame){
            return MessageBubble.next(message: chatMassege['text'],
                isMe: authctionUser.uid==crrentMassegeUserId);
          }else{
            return MessageBubble.first(
                userImage: chatMassege['userImage'],
                username: chatMassege['username'],
                message: chatMassege['text'],
                isMe: authctionUser.uid==crrentMassegeUserId);
          }
          }

          );


        },);




  }
}