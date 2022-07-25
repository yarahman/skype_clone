import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModel{
  String? uid;
  String? name;
  String? email;
  String? userName;
  String? status;
  int? state;
  String? profilePhoto;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.userName,
      this.status,
      this.state,
      this.profilePhoto});

  Map<String, dynamic> tomap(UserModel user) {
    var data = <String, dynamic>{};
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['userName'] = user.userName;
    data['status'] = user.status;
    data['state'] = user.state;
    data['profilePhoto'] = user.profilePhoto;
    return data;
  }

  UserModel.formMap(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    name = mapData['name'];
    email = mapData['email'];
    userName = mapData['userName'];
    status = mapData['status'];
    state = mapData['state'];
    profilePhoto = mapData['profilePhoto'];
  }
}
