import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/db_functions/fireStore.dart';
import 'package:barber_shop_admin/provider_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingsForTheDayScreen extends StatefulWidget {
  BookingsForTheDayScreen({this.date, this.completed, this.day});
  final String date;
  final bool completed;
  final String day;
  @override
  _BookingsForTheDayScreenState createState() =>
      _BookingsForTheDayScreenState();
}

class _BookingsForTheDayScreenState extends State<BookingsForTheDayScreen> {
  final _fireStore = FirebaseFirestore.instance;

  FireStoreDBFunctions fireStoreDBFunctions = FireStoreDBFunctions();
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.03,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                BackButton(
                  color: kButtonColor,
                ),
                Text(
                  widget.day,
                  style: kHeadingTextStyle.copyWith(
                      color: Colors.black.withOpacity(
                    0.8,
                  )),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _fireStore
                .collection('bookingDates')
                .doc(widget.date)
                .collection('time')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Theme(
                    data: ThemeData(accentColor: kButtonColor),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final dataLen = snapshot.data.docs.length;
              final data = snapshot.data.docs;

              return Expanded(
                child: ListView.builder(
                  itemCount: dataLen,
                  itemBuilder: (context, index) {
                    final time = data[index]['time'];
                    final name = data[index]['name'];
                    final service = data[index]['service'];
                    final fireStoreIndex = data[index]['index'];
                    final bookingId = data[index]['bookingId'];
                    final uid = data[index]['uid'];
                    bool isCompleted = data[index]['isCompleted'];
                    String mobileNo;
                    try {
                      mobileNo = data[index]['mobileNo'];
                    } catch (e) {
                      mobileNo = '';
                    }

                    return BookingSlots(
                      fromCompletedScreen: widget.completed,
                      onTapDelete: () {
                        onTapDelete(
                          bookingId: bookingId,
                          fireStoreIndex: fireStoreIndex,
                          uid: uid,
                        );

                        //Removes form booking from dataBase
                      },
                      onTapTick: () {
                        setState(() {
                          isCompleted = !isCompleted;
                        });

                        //Switches isCompleted
                        fireStoreDBFunctions.switchToCompleted(
                            date: widget.date,
                            index: fireStoreIndex.toString(),
                            isCompleted: isCompleted);
                      },
                      isCompleted: isCompleted,
                      name: name,
                      time: time,
                      service: service,
                      mobileNo: mobileNo,
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void onTapDelete({String bookingId, int fireStoreIndex, String uid}) {
    final bool isAndroid =
        Provider.of<ProviderData>(context, listen: false).isAndroid;
    //confirmation dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) => isAndroid
          ? AlertDialog(
              title: Text("Cancel Booking"),
              content: Text("Are you sure you want to cancel booking?"),
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
                    cancelBooking(
                      bookingId: bookingId,
                      fireStoreIndex: fireStoreIndex,
                      uid: uid,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text("Cancel Booking"),
              content: Text("Are you sure you want to cancel booking?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () {
                    cancelBooking(
                      bookingId: bookingId,
                      fireStoreIndex: fireStoreIndex,
                      uid: uid,
                    );
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

  void cancelBooking({int fireStoreIndex, String uid, String bookingId}) {
    fireStoreDBFunctions.deleteBookingFromDB(
        date: widget.date, index: fireStoreIndex.toString());

    //Removes form booking from userDataBase
    fireStoreDBFunctions.deleteBookingFromUsers(
      uid: uid,
      bookingId: bookingId,
    );
  }
}

class BookingSlots extends StatelessWidget {
  BookingSlots({
    this.onTapTick,
    this.onTapDelete,
    this.isCompleted,
    this.name,
    this.time,
    this.service,
    this.fromCompletedScreen,
    this.mobileNo,
  });
  final Function onTapTick;
  final Function onTapDelete;
  final bool isCompleted;
  final String name;
  final String time;
  final String service;
  final bool fromCompletedScreen;
  final String mobileNo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: kBoxContainerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      width: width * 0.667,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: kServiceContainerTextStyle.copyWith(
                      fontSize: 20,
                      color: Colors.black.withOpacity(
                        0.8,
                      )),
                ),
                Text(
                  mobileNo,
                  style:
                      kServiceContainerTextStyle.copyWith(color: Colors.grey),
                ),
                Text(
                  time,
                  style:
                      kServiceContainerTextStyle.copyWith(color: Colors.grey),
                ),
                Text(
                  service,
                  style:
                      kServiceContainerTextStyle.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          fromCompletedScreen
              ? Container()
              : Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onTapTick,
                        child: Container(
                          height: height * 0.06,
                          width: width * 0.107,
                          child: Icon(
                            Icons.check,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.053,
                      ),
                      GestureDetector(
                        onTap: onTapDelete,
                        child: Container(
                          height: height * 0.06,
                          width: width * 0.107,
                          child: Icon(
                            Icons.clear,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
