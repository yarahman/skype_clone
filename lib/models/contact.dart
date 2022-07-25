import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  Contact({this.uid, this.addOn});
  String? uid;
  Timestamp? addOn;

  Map toMap(Contact contact) {
    var data = <String, dynamic>{};
    data['uid'] = uid;
    data['addOn'] = addOn;
    return data;
  }

  Contact.formMap(Map<String, dynamic> map) {
    uid = map['uid'];
    addOn = map['addOn'];
  }
}
