import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_shop_admin/screens/manage_order_screen.dart';

final _fireStore = FirebaseFirestore.instance;

/// Example data as it might be returned by an external service
/// ...this is often a `Map` representing `JSON` or a `FireStore` document
Future<List<QueryDocumentSnapshot>> getOrderData(
    {int length, bool pending}) async {
  QuerySnapshot data = pending
      ? await _fireStore
          .collection('orders')
          .where('completed', isNotEqualTo: pending)
          .get()
      : await _fireStore
          .collection('orders')
          .where('completed', isNotEqualTo: pending)
          .get();

  return Future.delayed(Duration(seconds: 1), () {
    return List.generate(length, (int index) {
      if (index == 0 && orderCount == 0) {
        orderCount = 0;
      } else if (orderCount == (data.docs.length - 1)) {
        orderCount = 0;
      } else {
        orderCount++;
      }

      return data.docs[orderCount];
    });
  });
}

/// OrderModel has a constructor that can handle the `Map` data
/// ...from the server.
class OrderModel {
  String productId;
  String stripTransactionId;
  String customerEmail;
  String productName;
  String productPrice;

  String shippingAddress;

  var timeStamp;

  bool isCompleted;

  OrderModel({
    this.productId,
    this.stripTransactionId,
    this.customerEmail,
    this.timeStamp,
    this.shippingAddress,
    this.isCompleted,
    this.productName,
    this.productPrice,
  });

  factory OrderModel.fromServerMap(QueryDocumentSnapshot data) {
    return OrderModel(
      productId: data['productId'],
      stripTransactionId: data['StripTransactionId'],
      customerEmail: data['customerEmail'],
      timeStamp: data['timeStamp'],
      shippingAddress: data['ShippingAddress'],
      isCompleted: data['completed'],
      productName: data['productName'],
      productPrice: data['productPrice'],
    );
  }
}

/// OrdersModel controls a `Stream` of posts and handles
/// ...refreshing data and loading more posts
class OrdersModel {
  Stream<List<OrderModel>> stream;
  bool hasMore;

  bool _isLoading;
  List<QueryDocumentSnapshot> _data;
  StreamController<List<QueryDocumentSnapshot>> _controller;

  bool pending;

  OrdersModel({this.pending}) {
    _data = List<QueryDocumentSnapshot>();
    _controller = StreamController<List<QueryDocumentSnapshot>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<QueryDocumentSnapshot> postsData) {
      return postsData.map((QueryDocumentSnapshot postData) {
        return OrderModel.fromServerMap(postData);
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

    return getOrderData(length: 2, pending: pending).then((postsData) async {
      final fireStoreLength = pending
          ? await _fireStore
              .collection('orders')
              .where('completed', isNotEqualTo: pending)
              .get()
              .then((value) => value.docs.length)
          : await _fireStore
              .collection('orders')
              .where('completed', isNotEqualTo: pending)
              .get()
              .then((value) => value.docs.length);

      _isLoading = false;
      _data.addAll(postsData);
      hasMore = (_data.length < fireStoreLength);
      _controller.add(_data);
    });
  }
}
