
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/const_user.dart';
import '../models/message_model.dart';
import '../remote/firebase_api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final controller = TextEditingController();
  String controllerMessage = '';

  void sendMessage() async{
    FocusScope.of(context).unfocus();
    await FirebaseApi.uploadMessage(controllerMessage);
    print('Message sent');
    controller.clear();
  }

  @override
  void initState() {
    FirebaseApi.getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);
    final Stream<QuerySnapshot> messages = FirebaseFirestore.instance.collection('chat').orderBy('time', descending: true ).snapshots();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
          chatBody(messages: messages, borderRadius: borderRadius, radius: radius),
            Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      labelText: 'Type your message',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 0),
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      controllerMessage = value;
                    }),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: controllerMessage.trim().isEmpty ? null : sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ],),
        ),
      ),
    );
  }
}

class chatBody extends StatelessWidget {
  const chatBody({
    Key? key,
    required this.messages,
    required this.borderRadius,
    required this.radius,
  }) : super(key: key);

  final Stream<QuerySnapshot<Object?>> messages;
  final BorderRadius borderRadius;
  final Radius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height-100,
      child: StreamBuilder(
        stream: messages,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Text('Something Went Wrong Try later');
              } else {
                final data = snapshot.requireData;
                return SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height-100,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        final bool isMe= data.docs[index]["name"]==USER;
                        return Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: <Widget>[
                            if (!isMe)
                              CircleAvatar(
                                  radius: 20, backgroundImage: NetworkImage('https://www.woolha.com/media/2020/03/flutter-circleavatar-radius.jpg')),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(data.docs[index]['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)),
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    margin: EdgeInsets.only(top: 5, bottom: 5, left: 16),
                                    constraints: BoxConstraints(maxWidth: 140),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.grey[300] : Colors.orange,
                                      borderRadius: isMe
                                          ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                                          : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          data.docs[index]['text'],
                                          style: TextStyle(color: isMe ? Colors.black : Colors.white),
                                          textAlign: isMe ? TextAlign.end : TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*Container(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(data.docs[index]['time'])),*/
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
