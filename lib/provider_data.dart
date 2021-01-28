import 'package:flutter/material.dart';

//Not only Booking data But all the Provider is Changed
class ProviderData extends ChangeNotifier {
  String time;
  int index = 99;
  int day;
  int month;
  int year;
  DateTime dateTime;

  bool isAndroid;
  bool loginError;
  bool signUpError;
  bool showLogInSpinner;
  bool showSignUpSpinner;

  bool showLogInGoogleSignInSpinner;
  bool showSignUpGoogleSignInSpinner;
  bool showLogInAppleSignInSpinner;
  bool showSignUpAppleSignInSpinner;

  bool pending = false;
}
