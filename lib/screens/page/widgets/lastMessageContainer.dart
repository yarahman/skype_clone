import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/message.dart';
import '../../../utilities/universal_data.dart';

class LastMessageContainer extends StatelessWidget {
  const LastMessageContainer(this.stream);
  final Stream<QuerySnapshot> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          var docsList = snapShot.data!.docs;

          if (docsList.isNotEmpty) {
            Message message =
                Message.formMap(docsList.last.data() as Map<String, dynamic>);
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                message.message!,
                style: const TextStyle(
                    fontSize: 14.0,
                    color: UniversalData.greyColor,
                    overflow: TextOverflow.ellipsis),
              ),
            );
          }
          return const Text(
            'no message',
            style: TextStyle(
                fontSize: 14.0,
                color: UniversalData.greyColor,
                overflow: TextOverflow.ellipsis),
          );
        }
        return const Text(
          '...',
          style: TextStyle(
              fontSize: 14.0,
              color: UniversalData.greyColor,
              overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
