import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/provider_data.dart';
import 'package:barber_shop_admin/screens/login_screen.dart';
import 'package:barber_shop_admin/screens/add_or_edit_screen.dart';
import 'package:barber_shop_admin/screens/item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'home screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isAndroid;
  @override
  void initState() {
    isAndroid = Provider.of<ProviderData>(context, listen: false).isAndroid;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,

        //Custom drawer
        backgroundColor: kBackgroundColor,
        endDrawer: CustomDrawer(
          width: width,
          onTapLogOut: onTapLogOut,
        ),

        body: ListView(
          children: [
            SizedBox(
              height: height * 0.03,
            ),

            //Drawer button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DrawerButton(
                    onTap: () => _scaffoldKey.currentState.openEndDrawer(),
                  )
                ],
              ),
            ),

            //Admin heading
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Admin',
                style: kHeadingTextStyle,
              ),
            ),

            //Divider
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: width * 0.667,
                padding: EdgeInsets.only(left: 10),
                child: Divider(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

            SizedBox(
              height: height * 0.015,
            ),

            //Horizontal Rows which displays Get started and Product containers
            HorizontalRows(
              children: [
                SizedBox(
                  width: height * 0.015,
                ),

                //Get started Container
                BoxContainer(
                  margin: EdgeInsets.only(right: 20),
                  height: height * 0.15,
                  width: width * 0.38,
                  title: 'Get Started',
                  imageUrl: 'images/getStartedImage2.png',
                  onTap: onTapGetStarted,
                ),

                //Products Container
                BoxContainer(
                  height: height * 0.15,
                  width: width * 0.38,
                  imageUrl: 'images/products2.png',
                  title: 'Products',
                  onTap: onTapProducts,
                ),
              ],
            ),

            //Services heading
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'Services',
                style: kServicesTextStyle,
              ),
            ),

            /*Horizontal Rows which displays the service Containers from
                FireBase*/
            StreamBuilder(
              stream: _fireStore
                  .collection('services')
                  .where('up', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final dataLength = snapshot.data.docs.length;
                final serviceList = snapshot.data.docs;

                //Gets the data from service2collection and displays it
                return HorizontalRows(
                  children: List.generate(
                    dataLength,
                    (index) => ServiceContainer(
                      url: serviceList[index]['imageUrl'],
                      onTap: () {
                        onTapServiceContainer(
                            name: serviceList[index]['name'],
                            description: serviceList[index]['description'],
                            price: serviceList[index]['price'],
                            docId: serviceList[index]['docId'],
                            url: serviceList[index]['imageUrl'],
                            isDefault: serviceList[index]['isDefault']);
                      },
                      name: serviceList[index]['name'],
                    ),
                  ),
                );
              },
            ),

            /*Horizontal Rows which displays the service Containers from
                FireBase*/
            StreamBuilder(
                stream: _fireStore
                    .collection('services')
                    .where('up', isNotEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  //Checks if data is equal to null
                  if (!snapshot.hasData) {
                    return Center(
                      child: Theme(
                        data: ThemeData(
                          accentColor: kButtonColor,
                        ),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final dataLength = snapshot.data.docs.length;
                  final serviceList = snapshot.data.docs;

                  //Gets the data from service and displays it
                  return HorizontalRows(
                    children: List.generate(
                      dataLength,
                      (index) => ServiceContainer(
                        /*Passes the relevant data to the container when Tapped

                            Data is determined by the the index of the current item
                            in the list which chooses from the firebase services
                            collection list

                            Any data should be manually changed in Firebase
                            service collection*/
                        onTap: () {
                          onTapServiceContainer(
                            name: serviceList[index]['name'],
                            description: serviceList[index]['description'],
                            price: serviceList[index]['price'],
                            docId: serviceList[index]['docId'],
                            url: serviceList[index]['imageUrl'],
                            isDefault: serviceList[index]['isDefault'],
                          );
                        },
                        name: serviceList[index]['name'],
                        url: serviceList[index]['imageUrl'],
                      ),
                    ),
                  );
                }),

            //Add service button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AddOrEditButton(
                  icon: true,
                  onTap: onTapAddService,
                  title: 'Add service',
                ),
              ],
            ),

            //Add service button
          ],
        ),
      ),
    );
  }

  void onTapLogOut() {
    //confirmation dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) => isAndroid
          ? AlertDialog(
              title: Text("Log out"),
              content: Text("Are you sure you want to log out?"),
              actions: [
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Continue"),
                  onPressed: () {
                    logOut();
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text("Log out"),
              content: Text("Are you sure you want to log out?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () {
                    print('log out');
                    logOut();
                  },
                ),
                CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
    );
  }

  //Logs out user when logout button pressed in drawer
  void logOut() {
    _auth.signOut();
    pushNewScreen(
      context,
      screen: LoginScreen(),
      withNavBar: false,
    );
  }

  /*Passes the relevant sections that should be displayed in the tab bar
  and the heading

  These heading and sections are passes again to itemList widget where the
  data is retrieved from FireStore

  Be care with the values being passed because if you changed the value then
  the value should be changed in FireStore ass well!*/
  void onTapGetStarted() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemScreen(
          title: 'Get started',
          section1: 'all',
          section2: 'haircut',
          section3: 'beard',
          section4: 'trimming',
        ),
      ),
    );
  }

  /*Passes the relevant sections that should be displayed in the tab bar
  and the heading*/
  void onTapProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemScreen(
          title: 'Products',
          section1: 'Essentials',
          section2: 'Accessories',
          section3: 'Men',
          section4: 'Women',
        ),
      ),
    );
  }

  /*When service container is tapped a dialog box pops up with the name
  description and price passed

  This zooms in the relevant service and gives the user a better view*/
  void onTapServiceContainer({
    String name,
    String description,
    String price,
    String docId,
    String url,
    bool isDefault,
  }) {
    //Service description box
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: PopUpServiceContainer(
            title: name,
            description: description,
            price: price,
            url: url,
            isDefault: isDefault,
            onTapDelete: () {
              onTapDelete(name: name, docId: docId);
            },
            onTapEdit: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOrEditScreen(
                    action: 'editService',
                    description: description,
                    name: name,
                    price: price,
                    docId: docId,
                    imageUrl: url,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void onTapDelete({String name, String docId}) {
    //confirmation dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) => isAndroid
          ? AlertDialog(
              title: Text("Delete $name"),
              content: Text("Are you sure you want to delete $name?"),
              actions: [
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Continue"),
                  onPressed: () {
                    deleteService(docId: docId);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: new Text("Delete $name"),
              content: new Text("Are you sure you want to delete $name?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () {
                    deleteService(docId: docId);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
    );
  }

  //Deleting services in PopupServiceContainer
  void deleteService({String docId}) async {
    print('deleting');
    await _fireStore.collection('services').doc(docId).delete();
    print('done');
  }

  //Editing services
  void onTapEdit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditScreen(),
      ),
    );
  }

  //Pushes to EditOrAddScreen
  void onTapAddService() {
    pushNewScreen(
      context,
      screen: AddOrEditScreen(
        action: 'addService',
      ),
      withNavBar: false,
    );
  }
}
