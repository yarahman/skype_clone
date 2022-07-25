import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';
import '../utilities/utilities.dart';
import '../models/message.dart';
import '../constants/string.dart';
import '../providers/image_upload_provider.dart';
import '../models/contact.dart';
import '../enums/user_state.dart';

class FirebaseMethods {
  final firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();
  var userModel = UserModel();
  Reference? reference;

  User getCurrentUser() {
    User currentUser;
    currentUser = firebaseAuth.currentUser!;
    return currentUser;
  }

  Future<User> singInUser() async {
    GoogleSignInAccount? signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication signInAuthentication =
        await signInAccount!.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
      accessToken: signInAuthentication.accessToken,
      idToken: signInAuthentication.idToken,
    );

    UserCredential user =
        await firebaseAuth.signInWithCredential(authCredential);
    return user.user!;
  }

  Future<bool> authentication(User user) async {
    QuerySnapshot result = await fireStore
        .collection(USER_FIELD)
        .where('email', isEqualTo: user.email)
        .get();

    final List<QueryDocumentSnapshot> docss = result.docs;

    return docss.isEmpty ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async {
    var userName = Utilities.getUserName(currentUser.email!);
    final users = UserModel(
        uid: currentUser.uid,
        name: currentUser.displayName,
        email: currentUser.email,
        profilePhoto: currentUser.photoURL,
        userName: userName);

    fireStore
        .collection(USER_FIELD)
        .doc(currentUser.uid)
        .set(userModel.tomap(users));
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  // get and fetch userlist
  Future<List<UserModel>> fetchAllUser(User currentUser) async {
    List<UserModel> userList = [];

    QuerySnapshot querySnapshot = await fireStore.collection(USER_FIELD).get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserModel.formMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }

  Future<void> sendingMessageToDb(
    Message message,
    UserModel sender,
    UserModel reciver,
  ) async {
    var map = message.toMap();

    await fireStore
        .collection(MESSAGE_FIELD)
        .doc(message.senderId)
        .collection(message.reciverId!)
        .add(map);

    await addToContact(
        senderId: message.senderId!, reciverId: message.reciverId!);

    await fireStore
        .collection(MESSAGE_FIELD)
        .doc(message.reciverId!)
        .collection(message.senderId!)
        .add(map);
  }

  Future<void> addToContact(
      {required String senderId, required String reciverId}) async {
    Timestamp currentTime = Timestamp.now();
    await addToSenderContact(senderId, reciverId, currentTime);
    await addToReciverContact(senderId, reciverId, currentTime);
  }

  //* add a method to get the method
  DocumentReference getContactDocument(String of, String forContact) {
    return fireStore
        .collection(USER_FIELD)
        .doc(of)
        .collection('contacts')
        .doc(forContact);
  }

  //? this is sender method
  Future<void> addToSenderContact(
      String senderId, String reciverId, currentTime) async {
    DocumentSnapshot senderSanpShot =
        await getContactDocument(senderId, reciverId).get();

    if (!senderSanpShot.exists) {
      Contact contact = Contact(uid: reciverId, addOn: currentTime);

      var reciverMap = contact.toMap(contact);

      await getContactDocument(senderId, reciverId).set(reciverMap);
    }
  }

  //? this is reciver method
  Future<void> addToReciverContact(
      String senderId, String reciverId, currentTime) async {
    DocumentSnapshot reciverSnapShot =
        await getContactDocument(reciverId, senderId).get();

    if (!reciverSnapShot.exists) {
      Contact contact = Contact(uid: reciverId, addOn: currentTime);

      var senderMap = contact.toMap(contact);

      await getContactDocument(reciverId, senderId).set(senderMap);
    }
  }

  Future<String> uploadImageToStorage(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      await ref.putFile(image).whenComplete(() {});

      final url = await ref.getDownloadURL();

      // TaskSnapshot url =
      //     await task.whenComplete(() => reference!.getDownloadURL());
      return url;
    } catch (e) {
      print(e);
      return 'failed to send image. pleaes try again later';
    }
  }

  void setImage(String url, String senderId, String reciverId) async {
    Message message;

    message = Message.imageMessage(
        message: 'you send a image',
        imageUrl: url,
        senderId: senderId,
        reciverId: reciverId,
        type: 'image',
        timesStamp: Timestamp.now());

    var map = message.toImageMap();

    await fireStore
        .collection(MESSAGE_FIELD)
        .doc(message.senderId)
        .collection(message.reciverId!)
        .add(map);

    await fireStore
        .collection(MESSAGE_FIELD)
        .doc(message.reciverId!)
        .collection(message.senderId!)
        .add(map);
  }

  void uploadImage(File image, String senderId, String reciverId,
      ImageUploadProvider imageProvider) async {
    imageProvider.setToLoading();

    String url = await uploadImageToStorage(image);

    imageProvider.setToIdle();

    setImage(url, senderId, reciverId);
  }

  Future<UserModel> getUserDetailsById(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await fireStore.collection(USER_FIELD).doc(id).get();

      return UserModel.formMap(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return UserModel();
    }
  }

  Stream<QuerySnapshot> fetchAllContact(String senderId) {
    return fireStore
        .collection(USER_FIELD)
        .doc(senderId)
        .collection('contacts')
        .snapshots();
  }

  Stream<QuerySnapshot> getLastMessage(String senderId, String reciveId) {
    return fireStore
        .collection(MESSAGE_FIELD)
        .doc(senderId)
        .collection(reciveId)
        .orderBy('timesStamp')
        .snapshots();
  }

  Future<void> setUserState(String userId, UserState userState) async {
    int stateNum = Utilities.stateToNum(userState);

    await fireStore.collection(USER_FIELD).doc(userId).update({
      'state': stateNum,
    });
  }

  Stream<DocumentSnapshot<Map<String,dynamic>>> getUserStream(String userId) {
    return fireStore
        .collection(USER_FIELD)
        .doc(userId)
        .snapshots();
  }
}
