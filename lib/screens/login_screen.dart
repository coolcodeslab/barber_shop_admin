import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/screens/navigation_screen.dart';
import 'package:barber_shop_admin/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/barber_widgets.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  String email;
  String password;
  bool passedVar;
  bool showSpinner = false;

  void onChangeEmail(n) {
    email = n;
  }

  void onChangedPassword(n) {
    password = n;
  }

  void onTapSignup() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  /*Checks the the users email and password and if it has a value
  the screen is pushed to HomeScreen.If the value is equal to null
  nothing will happen
   */
  void onTapLogin() async {
    setState(() {
      showSpinner = true;
    });
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (user != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NavigationScreen()));
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.045,
            ),

            //Space for the logo
            Container(
              height: height * 0.27,
              width: width * 0.48,
              color: Colors.black.withOpacity(0.5),
            ),

            SizedBox(
              height: height * 0.06,
            ),
            TextFieldWidget(
              hintText: 'Email',
              onChanged: onChangeEmail,
              maxLines: 1,
            ),
            TextFieldWidget(
              hintText: 'Password',
              onChanged: onChangedPassword,
              obscureText: true,
              maxLines: 1,
            ),
            SizedBox(
              height: height * 0.075,
            ),
            RoundButtonWidget(
              title: 'login',
              onTap: onTapLogin,
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
