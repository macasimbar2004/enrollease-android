import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/dev.dart';
import 'package:enrollease/model/event_model.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SchoolCalendarPage extends StatefulWidget {
  const SchoolCalendarPage({super.key});

  @override
  State<SchoolCalendarPage> createState() => _SchoolCalendarPageState();
}

class _SchoolCalendarPageState extends State<SchoolCalendarPage> {
  late DateTime focusedDay;
  final currentYear = DateTime.now().year;
  final StreamController<List<EventModel>> eventsStreamController = StreamController<List<EventModel>>();
  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? selectedDay;
  DateTime? rangeStart;
  DateTime? rangeEnd;
  StreamSubscription? stream;
  final Map<DateTime, List<EventModel>> kEvents = {};

  @override
  void dispose() {
    eventsStreamController.close();
    stream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusedDay = DateTime.now();
    selectedDay = focusedDay;
    emitEventsForDay(selectedDay!);
  }

  void emitEventsForDay(DateTime day) {
    final db = FirebaseFirestore.instance;
    stream = db.collection('events').where('date', isEqualTo: day).snapshots().listen((snapshot) {
      dPrint('refreshed');
      final events = <EventModel>[];
      if (snapshot.docs.isNotEmpty) {
        for (final snapshot in snapshot.docs) {
          if (snapshot.data().isNotEmpty) {
            events.add(EventModel.fromMap(snapshot.data()));
          }
        }
      }
      eventsStreamController.add(events);
    });
    setState(() {});
  }

  // void emitEventsForRange(DateTime? start, DateTime? end) {
  //   final events = start != null && end != null
  //       ? getEventsForRange(start, end)
  //       : start != null
  //           ? getEventsForDay(start)
  //           : end != null
  //               ? getEventsForDay(end)
  //               : [];
  //   eventsStreamController.add(events);
  // }

  List<EventModel> getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  // List<EventModel> getEventsForRange(DateTime start, DateTime end) {
  //   // Implementation example
  //   final days = daysInRange(start, end);

  //   return [
  //     for (final d in days) ...getEventsForDay(d),
  //   ];
  // }

  void onDaySelected(DateTime sDay, DateTime fDay) {
    if (!isSameDay(sDay, selectedDay)) {
      setState(() {
        selectedDay = sDay;
        focusedDay = fDay;
        // rangeStart = null; // Important to clean those
        // rangeEnd = null;
        // rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      emitEventsForDay(selectedDay!);
    }
  }

  // void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   setState(() {
  //     selectedDay = null;
  //     focusedDay = focusedDay;
  //     rangeStart = start;
  //     rangeEnd = end;
  //     rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });

  // emitEventsForRange(start, end);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        title: Text(
          'SCHOOL CALENDAR',
          style: CustomTextStyles.inknutAntiquaBlack(fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Nav.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: CustomColors.contentColor,
      body: Column(
        children: [
          Card(
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.black),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar<EventModel>(
                  firstDay: DateTime(2015, 1, 1),
                  lastDay: DateTime(currentYear + 1, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  // rangeStartDay: rangeStart,
                  // rangeEndDay: rangeEnd,
                  calendarFormat: calendarFormat,
                  // rangeSelectionMode: rangeSelectionMode,
                  eventLoader: getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                      // outsideDaysVisible: false,
                      ),
                  onDaySelected: onDaySelected,
                  // onRangeSelected: onRangeSelected,
                  onFormatChanged: (format) {
                    if (calendarFormat != format) {
                      setState(() {
                        calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (fDay) {
                    focusedDay = fDay;
                  },
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Events',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: StreamBuilder(
                            stream: eventsStreamController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (snapshot.data == null || snapshot.data!.isEmpty) {
                                return const Text('No events for today.');
                              }
                              final events = snapshot.data!;
                              return ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, i) {
                                  final event = events[i];
                                  return ListTile(
                                    title: Text(event.title),
                                    subtitle: Text(event.date == null ? '--' : DateFormat('hh:mm a').format(events[i].date!)),
                                  );
                                },
                              );
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
