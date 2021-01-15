import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/screens/navigation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/barber_widgets.dart';

class SignupScreen extends StatefulWidget {
  static const id = 'Signup screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  String email;
  String password;
  bool showSpinner = false;

  void onChangedEmail(n) {
    email = n;
  }

  void onChangedPassword(n) {
    password = n;
  }

  /*If email and password are not equal to null user info email, password and
  uid is saved fireStore admin collection
  And screen is pushed to home screen*/
  void onTapSignup() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final uid = _auth.currentUser.uid;

      if (user != null) {
        await _fireStore.collection('admin').doc(uid).set({
          'email': email,
          'password': password,
          'uid': uid,
        });
        Navigator.pushNamed(context, NavigationScreen.id);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      showSpinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.045,
            ),
            //Back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: kButtonColor,
                  ),
                ],
              ),
            ),

            //Space for logo
            Container(
              height: height * 0.27,
              width: width * 0.48,
              color: Colors.black.withOpacity(0.5),
            ),

            SizedBox(
              height: height * 0.06,
            ),
            TextFieldWidget(
              hintText: 'email',
              onChanged: onChangedEmail,
              maxLines: 1,
            ),
            TextFieldWidget(
              hintText: 'password',
              onChanged: onChangedPassword,
              obscureText: true,
              maxLines: 1,
            ),
            SizedBox(
              height: height * 0.075,
            ),
            RoundButtonWidget(
              title: 'sign up',
              onTap: onTapSignup,
            ),
          ],
        ),
      ),
    );
  }
}
