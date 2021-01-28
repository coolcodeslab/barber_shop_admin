import 'package:barber_shop_admin/provider_data.dart';
import 'package:barber_shop_admin/screens/manage_times_screen.dart';
import 'package:barber_shop_admin/screens/item_screen.dart';
import 'package:barber_shop_admin/screens/loading_screen.dart';
import 'package:barber_shop_admin/screens/login_screen.dart';
import 'package:barber_shop_admin/screens/navigation_screen.dart';
import 'package:barber_shop_admin/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoadingScreen(),
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          SignupScreen.id: (context) => SignupScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          ItemScreen.id: (context) => ItemScreen(),
          ManageTimesScreen.id: (context) => ManageTimesScreen(),
          LoadingScreen.id: (context) => LoadingScreen(),
          NavigationScreen.id: (context) => NavigationScreen(),
        },
      ),
    );
  }
}
