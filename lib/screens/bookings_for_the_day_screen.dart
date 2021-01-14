import 'package:barber_shop_admin/contants.dart';
import 'package:barber_shop_admin/db_functions/fireStore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingsForTheDayScreen extends StatefulWidget {
  BookingsForTheDayScreen({this.date, this.fromCompletedScreen});
  final String date;
  final bool fromCompletedScreen;
  @override
  _BookingsForTheDayScreenState createState() =>
      _BookingsForTheDayScreenState();
}

class _BookingsForTheDayScreenState extends State<BookingsForTheDayScreen> {
  final _fireStore = FirebaseFirestore.instance;

  FireStoreDBFunctions fireStoreDBFunctions = FireStoreDBFunctions();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          BackButton(
            color: kButtonColor,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _fireStore
                .collection('bookingDates')
                .doc(widget.date)
                .collection('time')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
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
                      onTap: widget.fromCompletedScreen
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
      {this.onTap,
      this.onTapDelete,
      this.isCompleted,
      this.name,
      this.time,
      this.service});
  final Function onTap;
  final Function onTapDelete;
  final bool isCompleted;
  final String name;
  final String time;
  final String service;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBoxContainerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: 250,
      height: 100,
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
                  onTap: onTap,
                  child: Container(
                    height: 40,
                    width: 40,
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
                  width: 20,
                ),
                GestureDetector(
                  onTap: onTapDelete,
                  child: Container(
                    height: 40,
                    width: 40,
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
