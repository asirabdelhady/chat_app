
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/const_user.dart';
import '../models/message_model.dart';

List messages=[];

class FirebaseApi {

  static Future uploadMessage(String message) async {
    final chatCollection =
    FirebaseFirestore.instance.collection('chat');
    final newMessage = Message(
      name: USER,
      text: message,
      time: Timestamp.now(),
    );
    await chatCollection.add(newMessage.toJson());
  }

  static getMessages() {
    FirebaseFirestore.instance
        .collection('chat').get().then((value) {
      value.docs.forEach((element) {
        messages.add(element.data());
      });
    }).then((value) => print(messages));
  }
}