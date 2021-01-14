import 'package:barber_shop_admin/contants.dart';
import 'package:barber_shop_admin/screens/manage_times_screen.dart';
import 'package:barber_shop_admin/screens/login_screen.dart';
import 'package:barber_shop_admin/screens/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const id = 'settings screen';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;

  void onTapBooking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageTimesScreen(),
      ),
    );
  }

  void onTapLogOut() {
    _auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          BackButton(
            color: kButtonColor,
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              _auth.signOut();
              Navigator.pushNamed(context, LoginScreen.id);
            },
            child: Container(
              height: 40,
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Text(
                  'Log out',
                  style: kBoxContainerTextStyle,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({@required this.width, this.onTap, this.name});

  final double width;
  final Function onTap;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 50,
        child: Center(
          child: Text(
            name,
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Color(0xff4D4A56),
      ),
    );
  }
}
