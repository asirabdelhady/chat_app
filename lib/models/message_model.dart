import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String? name;
  final Timestamp time;
  final String? text;

  Message({required this.name, required this.text, required this.time});

  static Message fromJson(Map<String, dynamic> json)=>
      Message(
          name: json['name'],
          text: json['text'],
          time: json['time'],
      );

  Map<String, dynamic> toJson()=> {
    'name':name,
    'text':text,
    'time':time,
  };
}