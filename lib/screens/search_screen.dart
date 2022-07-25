import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import '../models/user_model.dart';
import '../resources/firebase_repository.dart';
import '../utilities/universal_data.dart';
import '../widgets/custom_tile.dart';
import './chat_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/searchScreen';
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseRepository repository = FirebaseRepository();
  var query = '';
  final textController = TextEditingController();
  List<UserModel> userList = [];

  @override
  void initState() {
    User currentUser = repository.getCurrentUser();

    repository.fetchAllUser(currentUser).then((allUserList) {
      setState(() {
        userList = allUserList;
      });
    });
    super.initState();
  }

//this is out app bar widget(app bar must need a PREDERREDSIZEWIDGET);
  PreferredSizeWidget gradientAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 40),
      child: NewGradientAppBar(
        gradient: UniversalData.appBarGradient,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: textController,
                onChanged: (val) {
                  setState(() {
                    query = val;
                  });
                },
                cursorColor: UniversalData.whiteColor,
                cursorHeight: 30.0,
                cursorWidth: 4.0,
                style: const TextStyle(
                    color: UniversalData.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                      color: UniversalData.hintTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        textController.clear();
                      });
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: UniversalData.whiteColor,
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Widget buildSuggestion(BuildContext context, String queary) {
    final List<UserModel> suggestionList = queary.isEmpty
        ? []
        : userList.where((user) {
            String getUserName = user.userName!.toLowerCase();
            String getName = user.name!.toLowerCase();
            String qeuary = query.toLowerCase();
            bool matchUserName = getUserName.contains(qeuary);
            bool matchName = getName.contains(qeuary);

            return matchUserName || matchName;
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        UserModel searchedUser = UserModel(
            uid: suggestionList[index].uid,
            userName: suggestionList[index].userName,
            name: suggestionList[index].name,
            profilePhoto: suggestionList[index].profilePhoto);

        return CustomTile(
            mini: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:(context) => ChatScreen(
                        reciver: searchedUser,
                      ),
                ),
              );
            },
            leading: CircleAvatar(
                backgroundColor: UniversalData.greyColor,
                backgroundImage: NetworkImage(searchedUser.profilePhoto!)),
            title: Text(
              searchedUser.userName!,
              style: const TextStyle(
                  fontSize: 20.0, color: UniversalData.whiteColor),
            ),
            subtitle: Text(
              searchedUser.name!,
              style: const TextStyle(
                  color: UniversalData.greyColor, fontWeight: FontWeight.bold),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalData.screenColor,
      appBar: gradientAppBar(context),
      body: buildSuggestion(context, query),
    );
  }
}
