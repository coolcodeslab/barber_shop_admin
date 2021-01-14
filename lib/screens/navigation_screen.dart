import 'package:barber_shop_admin/contants.dart';
import 'package:barber_shop_admin/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:barber_shop_admin/screens/manage_booking_screen.dart';

class NavigationScreen extends StatefulWidget {
  static const id = 'settings screen';

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  PersistentTabController persistentTabController;

  @override
  void initState() {
    persistentTabController = PersistentTabController();

    super.initState();
  }

  List<Widget> screens = [
    HomeScreen(),
    ManageBookingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: persistentTabController,
        screens: screens,
        navBarStyle: NavBarStyle.style6,
        backgroundColor: kBackgroundColor,
        items: [
          PersistentBottomNavBarItem(
            icon: Icon(Icons.home),
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.menu),
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
