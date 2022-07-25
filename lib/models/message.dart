import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderId;
  String? reciverId;
  String? type;
  String? message;
  Timestamp? timesStamp;
  String? imageUrl;

  Message(
      {this.senderId,
      this.reciverId,
      this.type,
      this.message,
      this.timesStamp});

  Message.imageMessage(
      {this.senderId,
      this.reciverId,
      this.imageUrl,
      this.message,
      this.type,
      this.timesStamp});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['senderId'] = senderId;
    map['reciverId'] = reciverId;
    map['type'] = type;
    map['message'] = message;
    map['timesStamp'] = timesStamp;
    return map;
  }

  Map<String, dynamic> toImageMap() {
    var map = <String, dynamic>{};

    map['senderId'] = senderId;
    map['reciverId'] = reciverId;
    map['type'] = type;
    map['message'] = message;
    map['timesStamp'] = timesStamp;
    map['imageUrl'] = imageUrl;
    return map;

  }

  Message.formMap(Map<String, dynamic> map) {
    senderId = map['senderId'];
    reciverId = map['reciverId'];
    type = map['type'];
    message = map['message'];
    timesStamp = map['timesStamp'];
    imageUrl = map['imageUrl'];
  }
}
