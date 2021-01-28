import 'dart:io';

import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/provider_data.dart';
import 'package:barber_shop_admin/screens/add_or_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class ItemScreen extends StatefulWidget {
  static const id = 'item screen';
  ItemScreen({
    this.title,
    this.section1,
    this.section2,
    this.section3,
    this.section4,
  });
  final String title;
  final String section1;
  final String section2;
  final String section3;
  final String section4;

  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.045,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BackButton(
                  color: kButtonColor,
                ),
              ],
            ),
          ),

          //Heading
          Padding(
            padding: EdgeInsets.only(
              left: 20,
            ),
            child: Text(
              widget.title,
              style: kHeadingTextStyle,
            ),
          ),

          //TabBars
          Padding(
            padding: EdgeInsets.all(10),
            child: TabBar(
              indicator: CircleTabIndicator(color: Colors.black, radius: 4),
              controller: tabController,
              isScrollable: false,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.5),
              labelStyle: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),

              //Title is passed
              tabs: <Widget>[
                Tab(
                  child: Text(widget.section1),
                ),
                Tab(
                  child: Text(widget.section2),
                ),
                Tab(
                  child: Text(widget.section3),
                ),
                Tab(
                  child: Text(widget.section4),
                ),
              ],
            ),
          ),

          //Screens
          /*For each section title, section and collection is passed so it can get
          the relevant data and display the relevant items*/
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                /*Read the line before itemList State to have better understanding
                about what is being passed and why*/

                ItemList(
                  category: widget.title,
                  section: widget.section1,
                  collection: 'collection',
                ),

                /*Read the line before itemList State to have better understanding
                about what is being passed and why*/

                ItemList(
                  category: widget.title,
                  section: widget.section2,
                  collection: 'collection',
                ),

                /*Read the line before itemList State to have better understanding
                about what is being passed and why*/

                ItemList(
                  category: widget.title,
                  section: widget.section3,
                  collection: 'collection',
                ),

                /*
                Read the line before itemList State to have better understanding
                about what is being passed and why
                 */

                ItemList(
                  category: widget.title,
                  section: widget.section4,
                  collection: 'collection',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*Each section is a separate stateful widget

Category(collection), sections(documentID), collections(sub collection) is
passed when user navigates to different section */
class ItemList extends StatefulWidget {
  ItemList({this.section, this.category, this.collection});
  final String category;
  final String section;
  final String collection;

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final _fireStore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance.ref().child('images');
  final picker = ImagePicker();
  File _image;

  String productName;
  String productPrice;
  String itemDownloadUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*Check if the user is from the get started screen and if so it does not
      show the Floating action button*/
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pushNewScreen(
            context,
            screen: AddOrEditScreen(
              fromItemScreen: true,
              action: 'addProduct',
              collection: widget.category.toLowerCase(),
              section: widget.section,
            ),
            withNavBar: false,
          );
        },
        child: Icon(Icons.add),
        backgroundColor: kButtonColor,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(right: 10),
            color: kBackgroundColor,
            child: StreamBuilder<QuerySnapshot>(
              stream: _fireStore
                  .collection(widget.category.toLowerCase())
                  .doc(widget.section)
                  .collection(widget.collection)
                  .snapshots(),
              builder: (context, snapshot) {
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
                final products = snapshot.data.docs;
                return GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 80 / 100,
                  children: List.generate(
                    dataLength,
                    (index) {
                      /*Returns an item container

                      according to the index of the list item in
                      are taken from the FireStore*/
                      return ItemContainer(
                        name: products[index]['product name'],
                        url: products[index]['imageUrl'],
                        onTap: () {
                          onTapItemContainer(
                            name: products[index]['product name'],
                            price: products[index]['price'],
                            productId: products[index]['product id'],
                            url: products[index]['imageUrl'],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void onChangedProductName(n) {
    productName = n;
  }

  void onChangedProductPrice(n) {
    productPrice = n;
  }

  //When item container is Tapped  a dialog boc with a container pops up
  void onTapItemContainer({
    String name,
    String price,
    String productId,
    String url,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: PopUpContainer(
            name: name,
            price: price,
            url: url,
            onTapDelete: () {
              onTapDelete(name: name, productId: productId);
            },
            onTapEdit: () {
              Navigator.pop(context);
              pushNewScreen(
                context,
                screen: AddOrEditScreen(
                  action: 'editProduct',
                  collection: widget.category.toLowerCase(),
                  fromItemScreen: true,
                  productId: productId,
                  section: widget.section,
                  name: name,
                  price: price,
                  imageUrl: url,
                ),
                withNavBar: false,
              );
            },
          ),
        );
      },
    );
  }

  void onTapDelete({String name, String productId}) {
    final bool isAndroid =
        Provider.of<ProviderData>(context, listen: false).isAndroid;
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
                    deleteProduct(
                      productId: productId,
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text("Delete $name"),
              content: Text("Are you sure you want to delete $name?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () {
                    deleteProduct(
                      productId: productId,
                    );
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

  void onTapImage() async {
    print('picking image');
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(
      () {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      },
    );
    print('done');
  }

  void uploadToFireStore() async {
    try {
      final String productId = randomAlphaNumeric(9);
      await _fireStore
          .collection(widget.category.toLowerCase())
          .doc(widget.section)
          .collection(widget.collection)
          .doc(productId)
          .set({
        'product name': productName,
        'product id': productId,
        'price': productPrice,
        'imageUrl': itemDownloadUrl,
      });
    } catch (e) {
      print(e);
    }
  }

  /*Adds the product to the relevant section in the firebase list with a product
  name

  Nothing happens if the product name is null*/
  void onTapAddButton(File file) async {
    print('started uploading');
    final String r = randomAlphaNumeric(9);

    await _firebaseStorage.child('$r.jpg').putFile(file).then(
      (data) async {
        await data.ref.getDownloadURL().then(
              (value) => itemDownloadUrl = value,
            );
      },
    );
    uploadToFireStore();
    print('done');
    Navigator.pop(context);
  }

  //Modal bottom sheet pops up to add product
  void onPressedPlus() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ModalBottomSheetContainer(
        onChangedName: onChangedProductName,
        onTapAdd: () {
          onTapAddButton(_image);
        },
        onChangedPrice: onChangedProductPrice,
        onTapImage: onTapImage,
      ),
    );
  }

  /*Removes the relevant item (which is decided by the uid passed) from the
  relevant section list*/
  void deleteProduct({String productId}) async {
    print(productId);
    await _fireStore
        .collection(widget.category.toLowerCase())
        .doc(widget.section)
        .collection(widget.collection)
        .doc(productId)
        .delete();
  }
}
