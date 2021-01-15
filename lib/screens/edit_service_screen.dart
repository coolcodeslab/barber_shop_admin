import 'dart:io';

import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:barber_shop_admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'dart:math';

class EditOrAddScreen extends StatefulWidget {
  EditOrAddScreen({
    this.name,
    this.description,
    this.price,
    this.docId,
    this.addService = false,
    this.fromItemScreen = false,
    this.productId,
    this.section,
    this.collection,
    this.imageUrl,
  });
  final String name;
  final String description;
  final String price;
  final String docId;
  final bool addService;
  final bool fromItemScreen;
  final String section;
  final String productId;
  final String collection;
  final imageUrl;

  @override
  _EditOrAddScreenState createState() => _EditOrAddScreenState();
}

class _EditOrAddScreenState extends State<EditOrAddScreen> {
  final _fireStore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance.ref().child('images');
  final picker = ImagePicker();
  File _image;

  TextEditingController nameController;
  TextEditingController priceController;
  TextEditingController descriptionController;
  String itemDownloadUrl;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    priceController = TextEditingController(text: widget.price);
    descriptionController = TextEditingController(text: widget.description);
    itemDownloadUrl = widget.imageUrl;
    print(itemDownloadUrl);
    super.initState();
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

  //On tap product save changes
  void onTapItemScreenSaveChanges() async {
    print('uploading');
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
    print('done');
  }

  //Edits any changes
  void onTapSaveChanges() async {
    print('uploading');
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
    print('done');
  }

  //Adds new service
  void onTapAddService() async {
    /*Generates a random number and decides whether to set isUp bool to true or
     false*/
    Random random = new Random();
    int randomNumber = random.nextInt(2);

    bool isUp;

    if (randomNumber == 1) {
      print('true');
      isUp = true;
    } else {
      print('false');
      isUp = false;
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
      });
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  //Uploads the information to database
  void upload({File file, Function function}) async {
    print('started uploading');
    final String r = randomAlphaNumeric(9);

    await _firebaseStorage.child('$r.jpg').putFile(file).then(
      (data) async {
        await data.ref.getDownloadURL().then(
              (value) => itemDownloadUrl = value,
            );
      },
    );
    function();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
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
              },
            ),

            //Description text field
            widget.fromItemScreen
                ? Container()
                : TextFieldWidget(
                    hintText: 'description',
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
              },
            ),

            //Image button
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SmallActionButton(
                    title: 'image',
                    onTap: () {
                      onTapImage();
                    },
                  )),
            ),

            //Add service button
            widget.fromItemScreen
                ? AddOrEditButton(
                    onTap: () {
                      upload(
                        file: _image,
                        function: onTapItemScreenSaveChanges,
                      );
                    },
                    title: 'Save changes',
                    icon: false,
                  )
                : AddOrEditButton(
                    onTap: widget.addService
                        ? () {
                            upload(
                              file: _image,
                              function: onTapAddService,
                            );
                          }
                        : () {
                            upload(
                              file: _image,
                              function: onTapSaveChanges,
                            );
                          },
                    title: widget.addService ? 'Add service' : 'Save changes',
                    icon: false,
                  ),
          ],
        ),
      ),
    );
  }
}
