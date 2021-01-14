import 'package:barber_shop_admin/barber_widgets.dart';
import 'package:barber_shop_admin/contants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'dart:math';

class EditServiceScreen extends StatefulWidget {
  EditServiceScreen(
      {this.name, this.description, this.price, this.docId, this.addService});
  final String name;
  final String description;
  final String price;
  final String docId;
  final bool addService;

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _fireStore = FirebaseFirestore.instance;

  TextEditingController nameController;
  TextEditingController priceController;
  TextEditingController descriptionController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    priceController = TextEditingController(text: widget.price);
    descriptionController = TextEditingController(text: widget.description);
    super.initState();
  }

  //Edits any changes
  void onTapSaveChanges() async {
    print('uploading');
    try {
      _fireStore.collection('services').doc(widget.docId).update({
        'description': descriptionController.text,
        'name': nameController.text,
        'price': priceController.text
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
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
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),

            //Back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Opens Drawer when tapped
                  BackButton()
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
            TextFieldWidget(
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
                    onTap: () {},
                  )),
            ),

            //Add service button
            AddServiceButton(
              onTap: widget.addService ? onTapAddService : onTapSaveChanges,
              title: widget.addService ? 'Add service' : 'Save changes',
              icon: false,
            ),
          ],
        ),
      ),
    );
  }
}
