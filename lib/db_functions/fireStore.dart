import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final fireStore = FirebaseFirestore.instance;

class FireStoreDBFunctions {
  void deleteBookingFromDB({String date, String index}) async {
    try {
      await fireStore
          .collection('bookingDates')
          .doc(date)
          .collection('time')
          .doc(index)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  void deleteBookingFromUsers({String uid, String bookingId}) async {
    try {
      await fireStore
          .collection('users')
          .doc(uid)
          .collection('bookings')
          .doc(bookingId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  void switchToCompleted({String date, String index, bool isCompleted}) async {
    await fireStore
        .collection('bookingDates')
        .doc(date)
        .collection('time')
        .doc(index)
        .update({
      'isCompleted': isCompleted,
    });
  }
}
