import 'dart:async';
import 'package:barber_shop_admin/screens/manage_booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;

/// Example data as it might be returned by an external service
/// ...this is often a `Map` representing `JSON` or a `FireStore` document
Future<List<QueryDocumentSnapshot>> getBookingData(
    {int length, DateTime dateTime, bool completed}) async {
  print(dateTime);
  QuerySnapshot data = completed
      ? await _fireStore
          .collection('bookingDates')
          .where('timeStamp', isLessThan: dateTime)
          .get()
      : await _fireStore
          .collection('bookingDates')
          .where('timeStamp', isGreaterThanOrEqualTo: dateTime)
          .orderBy('timeStamp')
          .get();

  return Future.delayed(Duration(seconds: 1), () {
    return List.generate(length, (int index) {
      if (index == 0 && bookingCount == 0) {
        bookingCount = 0;
      } else if (bookingCount == (data.docs.length - 1)) {
        bookingCount = 0;
      } else {
        bookingCount++;
      }

      return data.docs[bookingCount];
    });
  });
}

/// BookingModel has a constructor that can handle the `Map` data
/// ...from the server.
class BookingModel {
  var timeStamp;
  String docStringDate;

  BookingModel({
    this.timeStamp,
    this.docStringDate,
  });

  factory BookingModel.fromServerMap(QueryDocumentSnapshot data) {
    return BookingModel(
      timeStamp: data['timeStamp'],
      docStringDate: data.id,
    );
  }
}

/// BookingsModel controls a `Stream` of posts and handles
/// ...refreshing data and loading more posts
class BookingsModel {
  Stream<List<BookingModel>> stream;
  bool hasMore;

  bool _isLoading;
  List<QueryDocumentSnapshot> _data;
  StreamController<List<QueryDocumentSnapshot>> _controller;

  DateTime dateTime;
  bool completed;

  BookingsModel({this.dateTime, this.completed}) {
    _data = List<QueryDocumentSnapshot>();
    _controller = StreamController<List<QueryDocumentSnapshot>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<QueryDocumentSnapshot> postsData) {
      return postsData.map((QueryDocumentSnapshot postData) {
        return BookingModel.fromServerMap(postData);
      }).toList();
    });
    hasMore = true;
    refresh();
  }

  Future<void> refresh() {
    return loadMore(clearCachedData: true);
  }

  Future<void> loadMore({
    bool clearCachedData = false,
  }) {
    if (clearCachedData) {
      _data = List<QueryDocumentSnapshot>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    return getBookingData(length: 5, dateTime: dateTime, completed: completed)
        .then((postsData) async {
      final fireStoreLength = completed
          ? await _fireStore
              .collection('bookingDates')
              .where('timeStamp', isLessThan: dateTime)
              .get()
              .then((value) => value.docs.length)
          : await _fireStore
              .collection('bookingDates')
              .where('timeStamp', isGreaterThanOrEqualTo: dateTime)
              .get()
              .then((value) => value.docs.length);
      _isLoading = false;
      _data.addAll(postsData);
      hasMore = (_data.length < fireStoreLength);
      _controller.add(_data);
    });
  }
}
