import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../resources/firebase_repository.dart';
import '../screens/home_screen.dart';
import '../utilities/universal_data.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  FirebaseRepository firebaseRepository = FirebaseRepository();
  var isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalData.screenColor,
      body: Stack(
        children: [
          logInButton(context),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget logInButton(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: UniversalData.whiteColor,
        highlightColor: UniversalData.greyColor,
        child: TextButton.icon(
            onPressed: () => performLogIn(context),
            icon: const Icon(
              Icons.login,
            ),
            label: const Text(
              'Log In',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            )),
      ),
    );
  }

  void performLogIn(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    firebaseRepository.signIn().then((user) {
      authenticateUser(context, user);
    });
  }

  void authenticateUser(BuildContext context, User user) {
    firebaseRepository.authentication(user).then((isNew) {
      setState(() {
        isLoading = false;
      });
      if (isNew) {
        firebaseRepository.addDataToDb(user).then((_) => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: ((context) => const HomeScreen()),
                ),
              )
            });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ((context) => const HomeScreen()),
          ),
        );
      }
    });
  }
}
