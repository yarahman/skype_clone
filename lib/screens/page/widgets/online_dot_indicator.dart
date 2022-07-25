import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../resources/firebase_repository.dart';
import '../../../utilities/utilities.dart';
import '../../../enums/user_state.dart';

class OnlineDotIndicator extends StatelessWidget {
  OnlineDotIndicator(this.uid);

  FirebaseRepository repo = FirebaseRepository();
  String? uid;

  @override
  Widget build(BuildContext context) {
    getColor(int value) {
      switch (Utilities.numToState(value)) {
        case UserState.offLine:
          return Colors.red;
        case UserState.onLIne:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: repo.getUserStream(uid!),
        builder: (context, snapshots) {
          UserModel? userModel;
          if (snapshots.hasData && snapshots.data!.data() != null) {
            userModel = UserModel.formMap(
                snapshots.data!.data() as Map<String, dynamic>);
          } else {
            print('data is not added');
          }

          return Container(
            height: 10.0,
            width: 10.0,
            margin: const EdgeInsets.only(right: 8.0, top: 8.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: userModel == null
                    ? Colors.grey
                    : getColor(userModel.state!)),
          );
        });
  }
}
