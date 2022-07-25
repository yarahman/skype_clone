import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utilities/universal_data.dart';
import '../screens/page/chat_list_view.dart';
import '../resources/firebase_repository.dart';
import '../enums/user_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController? pageController;
  var _page = 0;
  FirebaseRepository repo = FirebaseRepository();
  String? currentUser;

  @override
  void initState() {
    User user = repo.getCurrentUser();
    currentUser = user.uid;
    repo.setUserState(currentUser!, UserState.onLIne);
    pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override 
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (currentUser != null) {
          repo.setUserState(currentUser!, UserState.onLIne);
        }
        break;
      case AppLifecycleState.inactive:
        if (currentUser != null) {
          repo.setUserState(currentUser!, UserState.offLine);
        }
        break;
      case AppLifecycleState.paused:
        if (currentUser != null) {
          repo.setUserState(currentUser!, UserState.waiting);
        }
        break;
      case AppLifecycleState.detached:
        if (currentUser != null) {
          repo.setUserState(currentUser!, UserState.offLine);
        }
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void onPageChnaged(int page) {
    setState(() {
      _page = page;
    });
  }

  void onNavigationChnage(int page) {
    pageController!.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalData.screenColor,
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChnaged,
        children: const [
          ChatListView(),
          Center(
            child: Text('call screen', style: TextStyle(color: Colors.white)),
          ),
          Center(
            child:
                Text('contrct screen', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: CupertinoTabBar(
          backgroundColor: UniversalData.screenColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat_sharp,
                  color: _page == 0
                      ? UniversalData.lightBule
                      : UniversalData.greyColor,
                ),
                label: 'chat'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.call,
                  color: _page == 1
                      ? UniversalData.lightBule
                      : UniversalData.greyColor,
                ),
                label: 'call'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.content_paste_search_outlined,
                  color: _page == 2
                      ? UniversalData.lightBule
                      : UniversalData.greyColor,
                ),
                label: 'contract'),
          ],
          currentIndex: _page,
          onTap: onNavigationChnage,
        ),
      ),
    );
  }
}
