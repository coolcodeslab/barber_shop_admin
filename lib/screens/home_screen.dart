import 'package:barber_shop_admin/contants.dart';
import 'package:barber_shop_admin/screens/login_screen.dart';
import 'package:barber_shop_admin/screens/settings_screen.dart';
import 'package:barber_shop_admin/screens/edit_service_screen.dart';
import 'package:barber_shop_admin/screens/item_screen.dart';
import 'package:barber_shop_admin/screens/navigation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'home screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
          title: 'get started',
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
          title: 'products',
          section1: 'sec1',
          section2: 'sec2',
          section3: 'sec5',
          section4: 'sec4',
        ),
      ),
    );
  }

  //Editing services
  void onTapEdit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          addService: true,
        ),
      ),
    );
  }

  //Adding services
  void onTapAddService() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditServiceScreen(addService: true)));
  }

  //Deleting services
  void onTapDelete({String docId}) async {
    print('deleting');
    await _fireStore.collection('services').doc(docId).delete();
    print('done');
  }

  /*When service container is tapped a dialog box pops up with the name
  description and price passed

  This zooms in the relevant service and gives the user a better view*/
  void onTapServiceContainer(
      {String name, String description, String price, String docId}) {
    //Popup Dialog box
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
            onTapDelete: () {
              print('enable delete');
//              onTapDelete(docId: docId);
              Navigator.pop(context);
            },
            onTapEdit: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditServiceScreen(
                    description: description,
                    name: name,
                    price: price,
                    docId: docId,
                    addService: false,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void onTapLogOut() {
    _auth.signOut();
    pushNewScreen(context, screen: LoginScreen(), withNavBar: false);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: CustomDrawer(
          width: width,
          onTap: onTapLogOut,
        ),
        backgroundColor: kBackgroundColor,
        //Custom drawer

        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),

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
            //Heading
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Hey',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Derek',
                style: kHeadingTextStyle,
              ),
            ),

            //Divider
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 250,
                padding: EdgeInsets.only(left: 10),
                child: Divider(
                  color: Colors.white.withOpacity(0.5),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 10,
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),

            //Horizontal Rows which displays Get started and Product containers
            HorizontalRows(
              children: [
                SizedBox(
                  width: 10,
                ),
                BoxContainer(
                  margin: EdgeInsets.only(right: 20),
                  height: height * 0.15,
                  width: width * 0.38,
                  title: 'Get Started',
                  imageUrl: null,
                  onTap: onTapGetStarted,
                ),
                BoxContainer(
                  height: height * 0.15,
                  width: width * 0.38,
                  imageUrl: null,
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
                      onTap: () {
                        onTapServiceContainer(
                          name: serviceList[index]['name'],
                          description: serviceList[index]['description'],
                          price: serviceList[index]['price'],
                          docId: serviceList[index]['docId'],
                        );
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
                      child: CircularProgressIndicator(),
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
                          );
                        },
                        name: serviceList[index]['name'],
                      ),
                    ),
                  );
                }),

            //Add service button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AddServiceButton(
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
}
