import 'dart:io';
import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:barber_shop_admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:random_string/random_string.dart';

class AddOrEditScreen extends StatefulWidget {
  AddOrEditScreen({
    this.name,
    this.description,
    this.price,
    this.docId,
    this.fromItemScreen = false,
    this.productId,
    this.section,
    this.collection,
    this.imageUrl,
    this.action,
  });
  final String name;
  final String description;
  final String price;
  final String docId;

  final bool fromItemScreen;
  final String section;
  final String productId;
  final String collection;
  final imageUrl;
  final String action;

  @override
  _AddOrEditScreenState createState() => _AddOrEditScreenState();
}

class _AddOrEditScreenState extends State<AddOrEditScreen> {
  final _fireStore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance.ref().child('images');
  final picker = ImagePicker();
  File _image;

  TextEditingController nameController;
  TextEditingController priceController;
  TextEditingController descriptionController;
  String itemDownloadUrl;
  bool isLoading = false;
  bool error = false;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    priceController = TextEditingController(text: widget.price);
    descriptionController = TextEditingController(text: widget.description);
    itemDownloadUrl = widget.imageUrl;
    print(itemDownloadUrl);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: Theme(
        data: ThemeData(
          accentColor: kButtonColor,
        ),
        child: CircularProgressIndicator(),
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.03,
              ),

              //Back button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Opens Drawer when tapped
                    BackButton(
                      color: kButtonColor,
                    )
                  ],
                ),
              ),

              //Name text field
              TextFieldWidget(
                hintText: 'name',
                errorText: error ? 'please fill all the fields' : null,
                //Sets the initial value and the cursor to the end
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: nameController.text ?? "",
                    selection: TextSelection.collapsed(
                        offset: nameController.text?.length ?? 0),
                  ),
                ),
                maxLength: 50,
                maxLines: 1,
                onChanged: (n) {
                  nameController.text = n;
                  setState(() {
                    error = false;
                  });
                },
              ),

              //Description text field
              widget.fromItemScreen
                  ? Container()
                  : TextFieldWidget(
                      hintText: 'description',
                      errorText: error ? 'please fill all the fields' : null,
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: descriptionController.text ?? "",
                          selection: TextSelection.collapsed(
                              offset: descriptionController.text?.length ?? 0),
                        ),
                      ),
                      maxLength: 320,
                      maxLines: 10,
                      onChanged: (n) {
                        descriptionController.text = n;
                      },
                    ),

              //Price text field
              TextFieldWidget(
                hintText: 'price',
                errorText: error ? 'please fill all the fields' : null,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: priceController.text ?? "",
                    selection: TextSelection.collapsed(
                        offset: priceController.text?.length ?? 0),
                  ),
                ),
                maxLength: 10,
                maxLines: 1,
                onChanged: (n) {
                  priceController.text = n;
                  setState(() {
                    error = false;
                  });
                },
              ),

              //Image button
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: SmallActionButton(
                      title: 'image',
                      onTap: onTapImage,
                    )),
              ),

              //add/edit button
              button(),
            ],
          ),
        ),
      ),
    );
  }

  //checks condition and assigns button
  Widget button() {
    if (widget.action == 'addProduct') {
      //add product button
      return AddOrEditButton(
        icon: true,
        title: 'add product',
        onTap: () {
          upload(file: _image, function: addProduct);
        },
      );
    } else if (widget.action == 'editProduct') {
      //edit product button
      return AddOrEditButton(
        title: 'save changes',
        onTap: () {
          upload(file: _image, function: editItem);
        },
      );
    } else if (widget.action == 'addService') {
      //add service button
      return AddOrEditButton(
        icon: true,
        title: 'add service',
        onTap: () {
          upload(file: _image, function: addService);
        },
      );
    } else {
      //edit service button
      return AddOrEditButton(
        title: 'Save changes',
        onTap: () {
          upload(file: _image, function: editService);
        },
      );
    }
  }

  //Uploads the information to database
  void upload({File file, Function function}) async {
    print('uploading');
    setState(() {
      isLoading = true;
    });
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      print('returning');
      setState(() {
        error = true;
      });
    } else {
      print('started uploading');
      final String r = randomAlphaNumeric(9);

      try {
        await _firebaseStorage.child('$r.jpg').putFile(file).then(
          (data) async {
            await data.ref.getDownloadURL().then(
                  (value) => itemDownloadUrl = value,
                );
          },
        );
      } catch (e) {
        print(e);
      }

      print('got download url');
      function();
      print('done');
    }
    setState(() {
      isLoading = false;
    });
  }

  //Gets the image
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

  void addProduct() async {
    print(widget.collection);
    print(widget.productId);
    print(widget.section);

    try {
      final String productId = randomAlphaNumeric(9);
      await _fireStore
          .collection(widget.collection)
          .doc(widget.section)
          .collection('collection')
          .doc(productId)
          .set({
        'product name': nameController.text,
        'product id': productId,
        'price': priceController.text,
        'imageUrl': itemDownloadUrl,
      });
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  //On tap product save changes
  void editItem() async {
    print(widget.productId);
    print(widget.section);
    try {
      _fireStore
          .collection(widget.collection)
          .doc(widget.section)
          .collection('collection')
          .doc(widget.productId)
          .update({
        'price': priceController.text,
        'product name': nameController.text,
        'imageUrl': itemDownloadUrl,
      });
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  //Edits any changes
  void editService() async {
    try {
      _fireStore.collection('services').doc(widget.docId).update({
        'description': descriptionController.text,
        'name': nameController.text,
        'price': priceController.text,
        'imageUrl': itemDownloadUrl,
      });
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  //Adds new service
  void addService() async {
    //if length more than 10 it sets is is up = false
    bool isUp;
    var serviceDocs = await _fireStore.collection('services').get();
    var servicesLength = serviceDocs.docs.length;
    if (servicesLength > 10) {
      isUp = false;
    } else {
      isUp = true;
    }
    final String docId = randomAlphaNumeric(9);
    try {
      _fireStore.collection('services').doc(docId).set({
        'description': descriptionController.text,
        'name': nameController.text,
        'price': priceController.text,
        'docId': docId,
        'up': isUp,
        'imageUrl': itemDownloadUrl,
        'isDefault': false,
      });
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }
}
