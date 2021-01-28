import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/models/order_model.dart';
import 'package:barber_shop_admin/provider_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

int orderCount = 0;

class ManageOrderScreen extends StatefulWidget {
  @override
  _ManageOrderScreenState createState() => _ManageOrderScreenState();
}

class _ManageOrderScreenState extends State<ManageOrderScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: height * 0.03,
          ),
          //Upcoming and completed Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TabBar(
              controller: tabController,
              isScrollable: false,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.5),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),

              //Title is passed
              tabs: <Widget>[
                Tab(
                  child: Text('pending'),
                ),
                Tab(
                  child: Text('completed'),
                ),
              ],
            ),
          ),

          //Upcoming and completed screens
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              //Upcoming screen
              TabBarScreens(
                pending: true,
              ),

              //Completed screen
              TabBarScreens(
                pending: false,
              ),
            ],
          ))
        ],
      ),
    );
  }
}

class TabBarScreens extends StatefulWidget {
  TabBarScreens({this.pending});

  final bool pending;

  @override
  _TabBarScreensState createState() => _TabBarScreensState();
}

class _TabBarScreensState extends State<TabBarScreens> {
  final scrollController = ScrollController();
  OrdersModel bookings;

  final _fireStore = FirebaseFirestore.instance;

  //Gets the date of current day not the time
  DateTime dateToday;

  //calling setState so that the page refreshes

  @override
  void initState() {
    setState(() {
      orderCount = 0;
    });

    if (widget.pending) {
      bookings = OrdersModel(pending: true);
    } else {
      bookings = OrdersModel(pending: false);
    }

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        bookings.loadMore();
      }
    });

    ///My code
    DateTime dateTime = DateTime.now();
    dateToday = DateTime(dateTime.year, dateTime.month, dateTime.day);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //calling setState the refresh the page

    return Container(
      color: kBackgroundColor,
      child: StreamBuilder(
        stream: bookings.stream,
        builder: (BuildContext _context, AsyncSnapshot _snapshot) {
          if (!_snapshot.hasData) {
            return Center(
                child: Theme(
                    data: ThemeData(
                      accentColor: kButtonColor,
                    ),
                    child: CircularProgressIndicator()));
          } else {
            return RefreshIndicator(
              color: kButtonColor,
              onRefresh: bookings.refresh,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                controller: scrollController,
                separatorBuilder: (context, index) => Container(),
                itemCount: _snapshot.data.length + 1,
                itemBuilder: (BuildContext _context, int index) {
                  if (index < _snapshot.data.length) {
                    return OrderCard(order: _snapshot.data[index]);
                  } else if (bookings.hasMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Theme(
                          data: ThemeData(
                            accentColor: kButtonColor,
                          ),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: Text('nothing more to load!')),
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  void onTapCompleted({String transactionId}) {
    final bool isAndroid =
        Provider.of<ProviderData>(context, listen: false).isAndroid;

    //confirmation dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) => isAndroid
          ? AlertDialog(
              title: Text("Order completed"),
              content: Text(
                  "Mark this order as completed?you wont be able to change this"),
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
                    completeOrder(transactionId: transactionId);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text("Order completed"),
              content: Text(
                  "Mark this order as completed? you wont be able to change this"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () {
                    completeOrder(transactionId: transactionId);
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

  void completeOrder({String transactionId}) {
    try {
      _fireStore.collection('orders').doc(transactionId).update({
        'completed': true,
      });
    } catch (e) {
      print(e);
    }
  }
}
