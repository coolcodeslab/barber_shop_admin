import 'dart:io';

import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/screens/edit_service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    final double width = MediaQuery.of(context).size.width;
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
              indicator: CircleTabIndicator(color: Colors.white, radius: 4),
              controller: tabController,
              isScrollable: false,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
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

  void onChangedProductName(n) {
    productName = n;
  }

  void onChangedProductPrice(n) {
    productPrice = n;
  }

  void onTapEdit({String productId, String name, String price, String url}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrAddScreen(
          collection: widget.category.toLowerCase(),
          fromItemScreen: true,
          productId: productId,
          section: widget.section,
          name: name,
          price: price,
          imageUrl: url,
        ),
      ),
    );
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
            onTapEdit: () {
              Navigator.pop(context);
              onTapEdit(
                productId: productId,
                name: name,
                price: price,
                url: url,
              );
            },
          ),
        );
      },
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
  void onLongPressItemContainer({String uid}) async {
    print(uid);
    await _fireStore
        .collection(widget.category.toLowerCase())
        .doc(widget.section)
        .collection(widget.collection)
        .doc(uid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      /*Check if the user is from the get started screen and if so it does not
      show the Floating action button*/
      floatingActionButton: widget.category == 'get started'
          ? null
          : FloatingActionButton(
              onPressed: onPressedPlus,
              child: Icon(Icons.add),
              backgroundColor: kButtonColor,
            ),
      body: Container(
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
                child: CircularProgressIndicator(),
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
                    //Passes the uid when pressed
                    onLongPress: () {
                      onLongPressItemContainer(uid: products[index].id);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
