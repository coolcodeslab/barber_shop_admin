import 'package:barber_shop_admin/constants.dart';
import 'package:barber_shop_admin/models/list.dart';
import 'package:barber_shop_admin/provider_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:barber_shop_admin/barber_widgets.dart';

/*Booking Calender screen which picks the selected time within 4 days*/
class ManageTimesScreen extends StatefulWidget {
  static const id = 'booking calender screen';

  @override
  _ManageTimesScreenState createState() => _ManageTimesScreenState();
}

class _ManageTimesScreenState extends State<ManageTimesScreen>
    with SingleTickerProviderStateMixin {
  TimeCountList timeCountList = TimeCountList();

  TabController tabController;

  DateTime dateToday = DateTime(DateTime.now().day);

  int today;
  int tomorrow;
  int dayAfterTomorrow;
  int fourthDay;
  DateTime day1;
  DateTime day2;
  DateTime day3;
  DateTime day4;

  void checkDates() {
    /*Gets today's time and decides tomorrow, day after and fourth day*/
    day1 = DateTime.now();
    day2 = DateTime(day1.year, day1.month, day1.day + 1);
    day3 = DateTime(day1.year, day1.month, day1.day + 2);
    day4 = DateTime(day1.year, day1.month, day1.day + 3);

    //Gets the number of the day today
    today = int.parse(DateFormat('d').format(day1));

    //Gets the number of the fourthDay from today
    tomorrow = int.parse(DateFormat('d').format(day2));

    //Gets the number of the thirdDay from today
    dayAfterTomorrow = int.parse(DateFormat('d').format(day3));

    //Gets the number of the fourthDay from today
    fourthDay = int.parse(DateFormat('d').format(day4));
  }

//  void onPressedFAB() {
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (context) => BookingScreen(
//          time: Provider.of<ProviderData>(context).time,
//          date: Provider.of<ProviderData>(context).day,
//          month: Provider.of<ProviderData>(context).month,
//          year: Provider.of<ProviderData>(context).year,
//          index: Provider.of<ProviderData>(context).index,
//          dateTime: Provider.of<ProviderData>(context).dateTime,
//        ),
//      ),
//    );
//  }

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);

    /*Checks all the dates and assign to var today,today,tomorrow,
    dayAfterTomorrow,fourthDay,thisMonth,thisYear*/
    checkDates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      //Next Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(Provider.of<ProviderData>(context, listen: false).day);
          print(Provider.of<ProviderData>(context, listen: false).month);
          print(Provider.of<ProviderData>(context, listen: false).year);
        },
      ),
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: height * 0.03,
              ),

              //Pick a time heading
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    BackButton(
                      color: kButtonColor,
                    ),
                    Text(
                      'Pick a time',
                      style: kHeadingTextStyle,
                    )
                  ],
                ),
              ),

              //Tab bar for today and other dates
              Padding(
                padding: EdgeInsets.all(10),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: CircleTabIndicator(color: Colors.white, radius: 4),
                  controller: tabController,
                  isScrollable: false,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.5),
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: <Widget>[
                    Tab(
                      child: Text('Today'),
                    ),
                    Tab(
                      child: Text(tomorrow.toString()),
                    ),
                    Tab(
                      child: Text(dayAfterTomorrow.toString()),
                    ),
                    Tab(
                      child: Text(fourthDay.toString()),
                    ),
                  ],
                ),
              ),
              Expanded(
                //Each screen for a date
                child: TabBarView(
                  controller: tabController,
                  children: <Widget>[
                    TimeSelectorScreen(
                      day: today,
                      dateTime: day1,
                    ),
                    TimeSelectorScreen(
                      day: tomorrow,
                      dateTime: day2,
                    ),
                    TimeSelectorScreen(
                      day: dayAfterTomorrow,
                      dateTime: day3,
                    ),
                    TimeSelectorScreen(
                      day: fourthDay,
                      dateTime: day4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimeSelectorScreen extends StatefulWidget {
  TimeSelectorScreen({
    this.day,
    this.dateTime,
  });

  /*Every time a Tab is tapped a future builder is created

  Provider Time, index and day are assigned when a TimeContainer is tapped

  Provider month and year are assigned at the init state of the
  TimeSelectorScreen

  Today variable is passed to run some checks in the initState, not assigned to
  anything*/

  final int day;

  final DateTime dateTime;

  @override
  _TimeSelectorScreenState createState() => _TimeSelectorScreenState();
}

class _TimeSelectorScreenState extends State<TimeSelectorScreen> {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  TimeCountList timeCountList = TimeCountList();

  final indexList = [];

  List<int> tapped = [];

  @override
  void initState() {
    /*Current month and Year are assigned to Provider month and year variable
    at the beginning from the dateTime variable passed in each day*/

    Provider.of<ProviderData>(context, listen: false).month =
        int.parse(DateFormat('M').format(widget.dateTime));
    Provider.of<ProviderData>(context, listen: false).year =
        int.parse(DateFormat('y').format(widget.dateTime));

    //new code below
    Provider.of<ProviderData>(context, listen: false).day =
        int.parse(DateFormat('d').format(widget.dateTime));
    //new code above

    Provider.of<ProviderData>(context, listen: false).dateTime =
        widget.dateTime;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fireStore
            .collection('bookingDates')
            .doc(
              '${widget.day}-${Provider.of<ProviderData>(context, listen: false).month}-${Provider.of<ProviderData>(context, listen: false).year}',
            )
            .collection('time')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          //document list of the future is assigned to data list
          final dataList = snapshot.data.docs;

          //Background of the screen
          return Container(
            color: kBackgroundColor,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 40 / 20,
              children: List.generate(
                /*length of the hard coded TimeContainers list is taken*/
                timeCountList.times.length,
                (index) {
                  bool exist;
                  String time;
                  int currentIndex;
                  try {
                    /*Pass the current index of the list to the
                    dataList and takes the value inside index_field

                    If the data list does not contain then it the whole app
                    will crash so a try catch block is added*/

                    currentIndex = dataList[index]['index'];

                    //Value taken is added to a indexList
                    indexList.add(currentIndex);

                    /*Checks if the index list contains the index and if so
                    the  isBooked and time value are taken*/

                    if (indexList.contains(index)) {
                      exist = dataList[index]['isBooked'];
                      time = dataList[index]['time'];
                    } else {
                      exist = timeCountList.times[index].booked;
                      time = timeCountList.times[index].time;
                    }
                  } catch (Exception) {
                    if (indexList.contains(index)) {
                      exist = true;
                      time = timeCountList.times[index].time;
                    } else {
                      exist = timeCountList.times[index].booked;
                      time = timeCountList.times[index].time;
                    }
                  }

                  return exist
                      //Time Containers
                      // Container returned if its booked
                      ? NewTimeContainer(
                          time: time,
                          color: Colors.black.withOpacity(0.2),
                          isBooked: true,
                        )

                      //Container returned if its not booked
                      : NewTimeContainer(
                          time: time,
                          color: tapped.contains(index)
                              ? Colors.green
                              : kBoxContainerColor,
                          onTap: () {
                            //new code below
                            this.setState(() {
                              if (tapped.contains(index)) {
                                tapped.remove(index);
                              } else {
                                tapped.add(index);
                              }
                              //new code above

//                              Provider.of<ProviderData>(context, listen: false)
//                                  .time = time;
//                              Provider.of<ProviderData>(context, listen: false)
//                                  .index = index;
//                              Provider.of<ProviderData>(context, listen: false)
//                                  .day = widget.day;
                            });
                          },
                        );
                },
              ),
            ),
          );
        });
  }
}

class NewTimeContainer extends StatelessWidget {
  NewTimeContainer({this.time, this.onTap, this.color, this.isBooked = false});

  final String time;
  final Function onTap;
  final Color color;
  final bool isBooked;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(color: isBooked ? Colors.black : Colors.white70),
          ),
        ),
        width: width * 0.027,
        margin: EdgeInsets.all(10),
      ),
    );
  }
}
