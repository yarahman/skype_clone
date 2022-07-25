import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_meet/models/user_model.dart';
import 'package:we_meet/screens/chat_screen.dart';

import '../../resources/firebase_repository.dart';
import '../../utilities/universal_data.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utilities/utilities.dart';
import '../../widgets/custom_tile.dart';
import '../../screens/search_screen.dart';
import '../../models/contact.dart';
import './widgets/lastMessageContainer.dart';
import './widgets/online_dot_indicator.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  String userId = '';
  String initials = '';
  FirebaseRepository repo = FirebaseRepository();

  @override
  void initState() {
    User currentUser = repo.getCurrentUser();
    setState(() {
      userId = currentUser.uid;
      initials = Utilities.initials(currentUser.displayName!);
    });
    super.initState();
  }

  Widget customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_on),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(SearchScreen.routeName);
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded))
      ],
      centertile: true,
      title: UserCircle(initials),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalData.screenColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 20),
          child: customAppBar(context)),
      floatingActionButton: const NewChatButton(),
      body: ChatListContainer(userId),
    );
  }
}

class UserCircle extends StatelessWidget {
  const UserCircle(this.initals);
  final String initals;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: const Color.fromARGB(255, 43, 43, 43)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              initals,
              style: const TextStyle(
                  color: UniversalData.lightBule,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12.0,
              width: 12.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color.fromARGB(255, 43, 43, 43)),
                  color: UniversalData.userActiveColor),
            ),
          )
        ],
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  const NewChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50.0,
        height: 50.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: UniversalData.floatingButtonGradient,
        ),
        child: const Icon(
          Icons.edit,
          color: UniversalData.whiteColor,
        ));
  }
}

class ChatListContainer extends StatelessWidget {
  ChatListContainer(this.currentUserId);
  final String currentUserId;

  FirebaseRepository repo = FirebaseRepository();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: repo.fatchAllContact(currentUserId),
        builder: (buildContext, snapShot) {
          if (snapShot.hasData) {
            var docList = snapShot.data!.docs;

            if (docList.isEmpty) {
              return const Center(
                child: Text('no user found \n please sender message to users'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: docList.isEmpty ? 0 : docList.length,
              itemBuilder: ((context, index) {
                Contact contact = Contact.formMap(
                    docList[index].data() as Map<String, dynamic>);
                return ViewLayout(contact, currentUserId);
              }),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: UniversalData.whiteColor,
            ),
          );
        },
      ),
    );
  }
}

class ViewLayout extends StatelessWidget {
  ViewLayout(this.contact, this.currentUserId);
  final Contact contact;
  final String currentUserId;

  FirebaseRepository repo = FirebaseRepository();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: repo.getUserDetalsById(contact.uid ?? ''),
      builder: (context, snapshot) {
        UserModel? user = snapshot.data;
        if (snapshot.hasData) {
          return CustomTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    reciver: user,
                  ),
                ),
              );
            },
            title: Text(
              user!.name!,
              style: const TextStyle(
                  fontSize: 19.0, color: UniversalData.whiteColor),
            ),
            subtitle: LastMessageContainer(
              repo.fatchLastMessage(currentUserId, contact.uid!),
            ),
            leading: Container(
              constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: UniversalData.greyColor,
                    backgroundImage: NetworkImage(user.profilePhoto!),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: OnlineDotIndicator(contact.uid)),
                ],
              ),
            ),
            mini: false,
          );
        }
        return Container();
      },
    );
  }
}
