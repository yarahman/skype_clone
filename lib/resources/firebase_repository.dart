import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './firebase_methods.dart';
import '../models/user_model.dart';
import '../models/message.dart';
import '../providers/image_upload_provider.dart';
import '../enums/user_state.dart';

class FirebaseRepository {
  FirebaseMethods firebaseMethods = FirebaseMethods();

  User getCurrentUser() => firebaseMethods.getCurrentUser();

  Future<User> signIn() => firebaseMethods.singInUser();

  Future<bool> authentication(User user) =>
      firebaseMethods.authentication(user);

  Future<void> addDataToDb(User user) => firebaseMethods.addDataToDb(user);

  Future<void> signOut() => firebaseMethods.signOut();

  Future<List<UserModel>> fetchAllUser(User user) =>
      firebaseMethods.fetchAllUser(user);

  Future<void> sendingMessageToDb(
    Message message,
    UserModel sender,
    UserModel reciver,
  ) =>
      firebaseMethods.sendingMessageToDb(message, sender, reciver);

  void uploadImageToStorage(File image, String senderId, String reciverId,
          ImageUploadProvider provider) =>
      firebaseMethods.uploadImage(image, senderId, reciverId, provider);

  Stream<QuerySnapshot> fatchAllContact(String senderId) =>
      firebaseMethods.fetchAllContact(senderId);

  Stream<QuerySnapshot> fatchLastMessage(String senderId, String reciverId) =>
      firebaseMethods.getLastMessage(senderId, reciverId);

  Future<UserModel> getUserDetalsById(String id) =>
      firebaseMethods.getUserDetailsById(id);

  Stream<DocumentSnapshot<Map<String,dynamic>>> getUserStream(String uid) =>
      firebaseMethods.getUserStream(uid);

  Future<void> setUserState(String userId, UserState userState) =>
      firebaseMethods.setUserState(userId, userState);
}
