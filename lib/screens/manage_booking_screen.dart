import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/screens/bookings_for_the_day_screen.dart';
import 'package:intl/intl.dart';

int bookingCount = 0;

class ManageBookingScreen extends StatefulWidget {
  @override
  _ManageBookingScreenState createState() => _ManageBookingScreenState();
}

class _ManageBookingScreenState extends State<ManageBookingScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Container(
      color: kBackgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: height * 0.03,
          ),
          //Upcoming and completed Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TabBar(
              controller: tabController,
              isScrollable: false,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.5),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),

              //Title is passed
              tabs: <Widget>[
                Tab(
                  child: Text('upcoming'),
                ),
                Tab(
                  child: Text('completed'),
                ),
              ],
            ),
          ),

          //Upcoming and completed screens
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              //Upcoming screen
              TabBarScreens(
                completed: false,
              ),

              //Completed screen
              TabBarScreens(
                completed: true,
              ),
            ],
          ))
        ],
      ),
    );
  }
}

class TabBarScreens extends StatefulWidget {
  TabBarScreens({this.completed});

  //Boolean which check if its from completed screen
  final bool completed;
  @override
  _TabBarScreensState createState() => _TabBarScreensState();
}

class _TabBarScreensState extends State<TabBarScreens> {
  final scrollController = ScrollController();
  BookingsModel bookings;

  final _fireStore = FirebaseFirestore.instance;

  //Gets the date of current day not the time
  DateTime dateToday;

  @override
  void initState() {
    ///My code
    DateTime dateTime = DateTime.now();
    dateToday = DateTime(dateTime.year, dateTime.month, dateTime.day);

    setState(() {
      bookingCount = 0;
    });

    bookings = BookingsModel(dateTime: dateToday, completed: widget.completed);

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        bookings.loadMore();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: StreamBuilder(
        stream: bookings.stream,
        builder: (BuildContext _context, AsyncSnapshot _snapshot) {
          if (!_snapshot.hasData) {
            return Center(
                child: Theme(
                    data: ThemeData(
                      accentColor: kButtonColor,
                    ),
                    child: CircularProgressIndicator()));
          } else {
            return RefreshIndicator(
              color: kButtonColor,
              onRefresh: bookings.refresh,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                controller: scrollController,
                separatorBuilder: (context, index) => Container(),
                itemCount: _snapshot.data.length + 1,
                itemBuilder: (BuildContext _context, int index) {
                  if (index < _snapshot.data.length) {
                    return DateContainer(booking: _snapshot.data[index]);
                  } else if (bookings.hasMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Theme(
                          data: ThemeData(
                            accentColor: kButtonColor,
                          ),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: Text('nothing more to load!')),
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class DateContainer extends StatefulWidget {
  final BookingModel booking;

  DateContainer({
    Key key,
    @required this.booking,
  })  : assert(booking != null),
        super(key: key);

  @override
  _DateContainerState createState() => _DateContainerState();
}

class _DateContainerState extends State<DateContainer> {
  final _fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    var dateTime = widget.booking.timeStamp.toDate();
    final passedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final bookingDate = DateFormat('yMMMEd').format(passedDate);

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        print(widget.booking.docStringDate);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingsForTheDayScreen(
              date: widget.booking.docStringDate,
              day: bookingDate,
              completed: false,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: kBoxContainerColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: height * 0.15,
        width: width * 0.667,
        child: Text(bookingDate,
            style: kServiceContainerTextStyle.copyWith(
              fontSize: 20,
              color: Colors.black.withOpacity(0.5),
            )),
      ),
    );

    ;
  }
}
