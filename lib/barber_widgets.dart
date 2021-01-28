import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/models/order_model.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*round button used in all parts of the app with dynamic title,
* height and width */
class RoundButtonWidget extends StatelessWidget {
  RoundButtonWidget(
      {this.title, this.onTap, this.height = 48, this.width = 254});
  final String title;
  final Function onTap;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 5),
            )
          ],
          color: kButtonColor,
          borderRadius: BorderRadius.circular(30),
        ),
        margin: EdgeInsets.only(
          bottom: 20,
        ),
        height: height,
        width: width,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

//text field widget used in all parts of the app
class TextFieldWidget extends StatelessWidget {
  TextFieldWidget({
    this.hintText,
    this.onChanged,
    this.obscureText = false,
    this.initialValue,
    this.maxLength,
    this.maxLines,
    this.controller,
    this.errorText,
  });

  final String hintText;
  final Function onChanged;
  final bool obscureText;
  final String initialValue;
  final int maxLength;
  final int maxLines;
  final TextEditingController controller;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.only(
        bottom: 20,
        left: 30,
        right: 30,
      ),
      child: TextFormField(
        maxLines: maxLines,
        initialValue: initialValue,
        maxLength: maxLength,
        controller: controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        onChanged: onChanged,
        obscureText: obscureText,
        decoration: InputDecoration(
          errorText: errorText,
          hintText: hintText,
          hintStyle: kTextFieldHintStyle,
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class BoxContainer extends StatelessWidget {
  BoxContainer(
      {this.width,
      this.height,
      this.margin,
      this.onTap,
      this.child,
      this.imageUrl,
      this.title});
  final double height;
  final double width;
  final EdgeInsetsGeometry margin;
  final Function onTap;
  final Widget child;
  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        height: height,
        width: width,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                title,
                style: kBoxContainerTextStyle,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: 180,
                decoration: BoxDecoration(
                  image: imageUrl == null
                      ? null
                      : DecorationImage(
                          image: AssetImage(
                            imageUrl,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 5),
            ),
          ],
          color: kBoxContainerColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}

class ServiceContainer extends StatelessWidget {
  ServiceContainer({this.onTap, this.child, this.name, this.url});

  final Function onTap;
  final Widget child;
  final String name;
  final String url;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Container(
              height: height * 0.12,
              width: width * 0.107,
              child: CachedNetworkImage(
                imageUrl: url,
              ),
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Text(
              name,
              style: kServiceContainerTextStyle,
            )
          ],
        ),
        margin: EdgeInsets.only(right: 10, left: 10),
        width: width * 0.347,
        decoration: BoxDecoration(
          color: kBoxContainerColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}

class DrawerButton extends StatelessWidget {
  DrawerButton({this.onTap});
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Icon(
          Icons.menu,
          color: kButtonColor,
        ),
      ),
    );
  }
}

class HorizontalRows extends StatelessWidget {
  HorizontalRows({this.children});

  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 145, //<- Here the height should be specific
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
  }
}

class PopUpContainer extends StatelessWidget {
  PopUpContainer({
    this.name,
    this.data,
    this.price,
    this.onTapEdit,
    this.url,
    this.onTapDelete,
  });
  final String name;
  final String data;
  final String price;
  final String url;

  final Function onTapEdit;
  final Function onTapDelete;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
//            0xff4D4A56
        ),
        width: width * 0.693,
        height: height * 0.55,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  height: height * 0.255,
                  width: width * 0.4,
                  child: CachedNetworkImage(
                    imageUrl: url,
                  ),
                ),
              ),
            ),
            Text(
              name,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            Text(
              '\$$price',
              style: TextStyle(
                fontSize: 22,
                color: kButtonColor,
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallActionButton(
                  title: 'delete',
                  onTap: onTapDelete,
                ),
                SizedBox(
                  width: 10,
                ),
                SmallActionButton(
                  title: 'edit',
                  onTap: onTapEdit,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ItemContainer extends StatelessWidget {
  ItemContainer({this.onTap, this.name, this.onLongPress, this.url});
  final Function onTap;
  final String name;
  final Function onLongPress;
  final String url;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5, top: 10),
        height: height * 0.3,
        width: width * 0.107,
        margin: EdgeInsets.only(bottom: 10, left: 10),
        decoration: BoxDecoration(
          color: kItemContainerColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              height: height * 0.12,
              width: width * 0.213,
              child: CachedNetworkImage(
                imageUrl: url,
              ),
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Text(
              name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PopUpServiceContainer extends StatelessWidget {
  PopUpServiceContainer({
    this.title,
    this.description,
    this.price,
    this.onTapEdit,
    this.onTapDelete,
    this.url,
    this.isDefault,
  });
  final String title;
  final String description;
  final String price;
  final Function onTapEdit;
  final Function onTapDelete;
  final String url;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: kPopUpServiceContainerTitleStyle,
                    ),
                    Text(
                      '\$$price',
                      style: kPopUpServiceContainerPriceStyle,
                    ),
                  ],
                ),
                Container(
                  height: height * 0.12,
                  width: width * 0.107,
                  child: CachedNetworkImage(
                    imageUrl: url,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Text(
              description,
              style: kPopUpServiceContainerDescriptionStyle.copyWith(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            isDefault
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmallActionButton(
                        title: 'delete',
                        onTap: onTapDelete,
                      ),
                      SizedBox(
                        width: width * 0.027,
                      ),
                      SmallActionButton(
                        title: 'edit',
                        onTap: onTapEdit,
                      ),
                    ],
                  ),
          ],
        ),
        height: 370,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
//            0xff7F7B78
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
      ),
    );
  }
}

class SmallActionButton extends StatelessWidget {
  SmallActionButton({this.title, this.onTap, this.width = 70});
  final String title;
  final Function onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        margin: EdgeInsets.symmetric(
          vertical: 10,
        ),
        height: height * 0.045,
        width: width,
        decoration: BoxDecoration(
          color: kButtonColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class ModalBottomSheetContainer extends StatelessWidget {
  ModalBottomSheetContainer(
      {this.onTapAdd,
      this.onChangedName,
      this.onChangedPrice,
      this.onTapImage});
  final Function onTapAdd;
  final Function onChangedName;
  final Function onChangedPrice;
  final Function onTapImage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Color(0xff19181e),
        child: Container(
          decoration: BoxDecoration(
            color: kItemContainerColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          height: 500,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Add product',
                style: kHeadingTextStyle,
              ),
              SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                hintText: 'product name',
                onChanged: onChangedName,
              ),
              TextFieldWidget(
                hintText: 'price',
                onChanged: onChangedPrice,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: SmallActionButton(
                    onTap: onTapImage,
                    title: 'image',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RoundButtonWidget(
                title: 'add',
                onTap: onTapAdd,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOrEditButton extends StatelessWidget {
  AddOrEditButton({this.onTap, this.title, this.icon = false});
  final Function onTap;
  final String title;
  final bool icon;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 10,
        ),
        height: height * 0.075,
        width: width * 0.387,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon
                ? Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.white,
                  )
                : Container(),
            SizedBox(
              width: width * 0.027,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 5),
            ),
          ],
          color: Color(0xffEB3E32),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key key,
    @required this.width,
    this.onTapLogOut,
  });

  final double width;
  final Function onTapLogOut;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.27,
      color: kBackgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: height * 0.045,
          ),
          GestureDetector(
            onTap: onTapLogOut,
            child: Container(
              height: height * 0.045,
              width: width,
              color: Colors.transparent,
              child: Center(
                child: Text(
                  'log out',
                  style: kServiceContainerTextStyle,
                ),
              ),
            ),
          ),
        ],
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

class BackGroundDesign extends StatelessWidget {
  BackGroundDesign({this.width, this.height});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/roundDesign2.png'),
        ),
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final OrderModel order;

  const OrderCard({
    Key key,
    @required this.order,
  })  : assert(order != null),
        super(key: key);

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    var date = widget.order.timeStamp.toDate();
    final passedDate = DateTime(date.year, date.month, date.day);
    final purchasedDate = DateFormat('yMMMEd').format(passedDate);

    return Container(
      decoration: BoxDecoration(
        color: kBoxContainerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: EdgeInsets.all(10),
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Order and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark_border,
                    color: kButtonColor,
                  ),
                  Text(
                    'Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                purchasedDate,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 5,
          ),

          //User email
          Row(
            children: [
              Text(
                widget.order.customerEmail,
                style: kOrderContainerStyle1,
              ),
            ],
          ),

          Divider(),

          //Product name and price
          ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: Text(
              widget.order.productName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '\$${widget.order.productPrice}',
              ),
            ),
          ),

          Divider(),

          //Address
          Row(
            children: [
              Icon(
                Icons.pin_drop,
                color: kButtonColor,
                size: 15,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                '${widget.order.shippingAddress}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 10,
          ),

          //Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('orders')
                      .doc(widget.order.stripTransactionId)
                      .update({
                    'completed': !widget.order.isCompleted,
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.order.isCompleted ? Colors.green : kButtonColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    widget.order.isCompleted ? 'Completed' : 'Not completed',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),

          SizedBox(
            height: 10,
          ),
          Text(
            widget.order.stripTransactionId,
            style: kOrderContainerStyle1,
          ),
        ],
      ),
    );
  }
}
