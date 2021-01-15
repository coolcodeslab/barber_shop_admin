import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/db_functions/fireStore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingsForTheDayScreen extends StatefulWidget {
  BookingsForTheDayScreen({this.date, this.fromCompletedScreen, this.day});
  final String date;
  final bool fromCompletedScreen;
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
    final double width = MediaQuery.of(context).size.width;
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
                  style: kHeadingTextStyle,
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

              return Expanded(
                child: ListView.builder(
                  itemCount: dataLen,
                  itemBuilder: (context, index) {
                    final time = snapshot.data.docs[index]['time'];
                    final name = snapshot.data.docs[index]['name'];
                    final service = snapshot.data.docs[index]['service'];
                    final fireStoreIndex = snapshot.data.docs[index]['index'];
                    final bookingId = snapshot.data.docs[index]['bookingId'];
                    final uid = snapshot.data.docs[index]['uid'];
                    bool isCompleted = snapshot.data.docs[index]['isCompleted'];

                    return BookingSlots(
                      onTapDelete: widget.fromCompletedScreen
                          ? () {}
                          : () {
                              print('deleting');

                              //Removes form booking from dataBase
                              fireStoreDBFunctions.deleteBookingFromDB(
                                  date: widget.date,
                                  index: fireStoreIndex.toString());

                              //Removes form booking from userDataBase
                              fireStoreDBFunctions.deleteBookingFromUsers(
                                  uid: uid, bookingId: bookingId);
                              print('done');
                            },
                      onTapTick: widget.fromCompletedScreen
                          ? () {}
                          : () {
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
}

class BookingSlots extends StatelessWidget {
  BookingSlots(
      {this.onTapTick,
      this.onTapDelete,
      this.isCompleted,
      this.name,
      this.time,
      this.service});
  final Function onTapTick;
  final Function onTapDelete;
  final bool isCompleted;
  final String name;
  final String time;
  final String service;

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
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: width * 0.667,
      height: height * 0.15,
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
                  style: kServiceContainerTextStyle.copyWith(fontSize: 20),
                ),
                Text(
                  time,
                  style: kServiceContainerTextStyle,
                ),
                Text(
                  service,
                  style: kServiceContainerTextStyle,
                ),
              ],
            ),
          ),
          Expanded(
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
