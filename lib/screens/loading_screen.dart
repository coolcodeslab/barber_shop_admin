import 'package:barber_shop_admin/screens/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barber_shop_admin/screens/login_screen.dart';
import 'package:barber_shop_admin/screens/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  static const id = 'loading page';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    assignUser();
  }

  String uid;

  /* Gets the current users uid when app is opened and assigns it to uid var
  If user has logged out the value will be equal to null
   */
  void assignUser() async {
    try {
      uid = _auth.currentUser.uid;
      print("success");
    } catch (e) {
      print("its a null");
      uid = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    /*Checks if uid has a value and if there is then screen is pushed to
    home screen.If uid == null Screen is Pushed to Login screen*/
    return uid == null ? LoginScreen() : NavigationScreen();
  }
}
