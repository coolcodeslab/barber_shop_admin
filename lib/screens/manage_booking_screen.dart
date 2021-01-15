import 'package:barber_shop_admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop_admin/screens/bookings_for_the_day_screen.dart';
import 'package:intl/intl.dart';

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
    final double width = MediaQuery.of(context).size.width;
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
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
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
                fromCompletedScreen: false,
              ),

              //Completed screen
              TabBarScreens(
                fromCompletedScreen: true,
              ),
            ],
          ))
        ],
      ),
    );
  }
}

class TabBarScreens extends StatefulWidget {
  TabBarScreens({this.fromCompletedScreen});

  //Boolean which check if its from completed screen
  final bool fromCompletedScreen;
  @override
  _TabBarScreensState createState() => _TabBarScreensState();
}

class _TabBarScreensState extends State<TabBarScreens> {
  final _fireStore = FirebaseFirestore.instance;

  //Gets the date of current day not the time
  DateTime dateToday;

  @override
  void initState() {
    DateTime dateTime = DateTime.now();
    dateToday = DateTime(dateTime.year, dateTime.month, dateTime.day);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      color: kBackgroundColor,
      child: StreamBuilder<QuerySnapshot>(
        /*If boolean == true isLessThan is used in .where method in the stream

        If boolean == false isGreaterThanOrEqualTo is used in .where method
         in the stream*/
        stream: widget.fromCompletedScreen
            ? _fireStore
                .collection('bookingDates')
                .where(
                  'timeStamp',
                  isLessThan: dateToday,
                )
                .snapshots()
            : _fireStore
                .collection('bookingDates')
                .where(
                  'timeStamp',
                  isGreaterThanOrEqualTo: dateToday,
                )
                .snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          //TimeContainer list is returned in ListView
          List<Widget> dateContainers = [];

          final data = snapshots.data.docs;

          //Each TimeContainer is added to timeContainers list
          for (var eachDate in data) {
            //Each date in bookingDates collection
            final String docStringDate = eachDate.id;

            //Getting the current day and date
            final dateTime = eachDate['timeStamp'];
            var date = dateTime.toDate();
            final passedDate = DateTime(date.year, date.month, date.day);
            final day = DateFormat('yMMMEd').format(passedDate);
            print(day);

            //TimeContainer
            final timeContainer = DateContainer(
              docStringDate: docStringDate,
              fromCompletedScreen: widget.fromCompletedScreen,
              day: day,
            );

            //Adds the timeContainers
            dateContainers.add(timeContainer);
          }

          //Returns a listView
          return ListView(
            children: dateContainers,
          );
        },
      ),
    );
  }
}

class DateContainer extends StatefulWidget {
  DateContainer({this.docStringDate, this.fromCompletedScreen, this.day});
  final String docStringDate;
  final bool fromCompletedScreen;
  final String day;

  @override
  _DateContainerState createState() => _DateContainerState();
}

class _DateContainerState extends State<DateContainer> {
  final _fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      /*When tapped on each TimeContainer the name and fromCompletedScreen bool
       is passed to DayBookings screen */
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingsForTheDayScreen(
              date: widget.docStringDate,
              fromCompletedScreen: widget.fromCompletedScreen,
              day: widget.day,
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
        margin: EdgeInsets.all(10),
        height: height * 0.15,
        width: width * 0.667,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
              ),
              //Shows the date
              Text(
                widget.day,
                style: kServiceContainerTextStyle.copyWith(fontSize: 20),
              ),
              widget.fromCompletedScreen
                  //Shows the nothing if its from the completed screen
                  ? Text('')
                  //Shows the number of booking which are not completed
                  : StreamBuilder<QuerySnapshot>(
                      stream: _fireStore
                          .collection('bookingDates')
                          .doc(widget.docStringDate)
                          .collection('time')
                          .where('isCompleted', isEqualTo: false)
                          .snapshots(),
                      builder: (context, streamSnapshot) {
                        if (!streamSnapshot.hasData) {
                          //Shows zero if no data
                          return Text('No bookings');
                        }
                        //Gets the number of bookings
                        final noOfBookings =
                            streamSnapshot.data.docs.length.toString();
                        return Text(
                          '$noOfBookings bookings',
                          style: kServiceContainerTextStyle,
                        );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}
