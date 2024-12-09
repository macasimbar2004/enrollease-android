import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/model/enrollment_form_model.dart';
import 'package:enrollease/model/fees_model.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/pages/payments_page.dart';
import 'package:enrollease/states_management/account_data_controller.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SchoolFeesPage extends StatefulWidget {
  const SchoolFeesPage({super.key});

  @override
  State<SchoolFeesPage> createState() => _SchoolFeesPageState();
}

class _SchoolFeesPageState extends State<SchoolFeesPage> {
  late StreamController<List<Map<String, dynamic>>> balancesController;
  late final List<DateTimeRange> dates;
  double? overallTotal;
  late DateTimeRange selectedDate;
  final titleTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  final subtitleTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  @override
  void initState() {
    super.initState();
    balancesController = StreamController<List<Map<String, dynamic>>>.broadcast();
    dates = List.generate(10, (i) {
      return DateTimeRange(
        start: DateTime(DateTime.now().year - (i + 1)),
        end: DateTime(
          DateTime.now().year - (i),
        ),
      );
    });
    selectedDate = dates.first;
    streamSource(balancesController, selectedDate);
  }

  void streamSource(
    StreamController<List<Map<String, dynamic>>> streamController,
    DateTimeRange range,
  ) {
    if (streamController.isClosed) return;
    final db = FirebaseFirestore.instance;
    final userID = context.read<AccountDataController>().currentUser!.uid;
    final collectionRef = db
        .collection('balance_accounts')
        .where('parentID', isEqualTo: userID)
        .where(
          'schoolYearStart',
          isGreaterThanOrEqualTo: range.start.year,
        )
        .where(
          'schoolYearStart',
          isLessThanOrEqualTo: range.end.year,
        );
    // final startOfYear = Timestamp.fromDate(DateTime(range.start.year, 1, 1));
    // final endOfYear = Timestamp.fromDate(DateTime(range.end.year, 12, 31, 23, 59, 59));

    // final collectionRef = db.collection('balance_accounts').where(
    //       'schoolYearStart',
    //       isGreaterThanOrEqualTo: startOfYear,
    //     )
    // .where(
    //   'schoolYearStart',
    //   isLessThanOrEqualTo: endOfYear,
    // );

    collectionRef.snapshots().listen(
      (snapshot) async {
        if (streamController.isClosed) return;

        try {
          // Use async mapping to handle await calls inside the listen
          var data = await Future.wait(snapshot.docs.map((doc) async {
            final docData = doc.data();
            // dPrint('Data was: ${docData}');

            // Fetch related documents asynchronously
            final parentDoc = await db.collection('users').doc(docData['parentID']).get();
            final pupilDoc = await db.collection('enrollment_forms').doc(docData['pupilID']).get();

            final parent = UserModel.fromMap(parentDoc.data() ?? {});
            final pupil = EnrollmentFormModel.fromMap(pupilDoc.data() ?? {});

            return {
              'id': doc.id,
              'schoolYearStart': docData['schoolYearStart'],
              'startingBalance': FeesModel.fromMap(docData['startingBalance']).toMap(),
              'remainingBalance': FeesModel.fromMap(docData['remainingBalance']).toMap(),
              'gradeLevel': docData['gradeLevel'],
              'parent': parent,
              'pupil': pupil,
              'tuitionDiscount': docData['tuitionDiscount'],
              'bookDiscount': docData['bookDiscount'],
            };
          }).toList());
          // data = data.where((e) {
          //   final parent = e['parent'] as UserModel;
          //   final pupil = e['pupil'] as EnrollmentFormModel;
          //   final pupilName = '${pupil.firstName}${pupil.middleName}${pupil.lastName}';
          //   return parent.userName.contains(searchQuery) || pupilName.contains(searchQuery);
          // }).toList();
          // Add mapped data to the stream
          streamController.add(data);
        } catch (error) {
          if (kDebugMode) {
            print('Error processing Firestore updates: $error');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error listening to Firestore updates: $error');
        }
      },
    );
  }

// for (final subData in data) {
//       final remainingBalance = FeesModel.fromMap(subData['remainingBalance']);
//       if (overallTotal != null) {
//         overallTotal = (overallTotal)! + remainingBalance.total();
//       } else {
//         overallTotal = remainingBalance.total();
//       }
//     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        title: Text(
          'BALANCES',
          style: CustomTextStyles.inknutAntiquaBlack(fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => context.read<SideMenuDrawerController>().controlMenu(),
          icon: const Icon(CupertinoIcons.bars, size: 34),
        ),
        centerTitle: true,
      ),
      backgroundColor: CustomColors.contentColor,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'School year: ',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.8),
                ),
                child: DropdownButton<DateTimeRange>(
                  borderRadius: BorderRadius.circular(20),
                  value: selectedDate,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  underline: const SizedBox.shrink(),
                  items: dates.map((e) {
                    return DropdownMenuItem<DateTimeRange>(
                      value: e,
                      child: Text(
                        '${DateFormat('yyyy').format(e.start)} - ${DateFormat('yyyy').format(e.end)}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDate = value;
                        streamSource(balancesController, selectedDate);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          overallTotal == null ? const SizedBox.shrink() : Text('You have a total pending balance of ${'P${NumberFormat('#,###').format(overallTotal)}'}'),
          const SizedBox(height: 10),
          Expanded(
              child: StreamBuilder(
                  stream: balancesController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null && !snapshot.hasError) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final data = snapshot.data!;
                    // updateOverallTotal(data);
                    return data.isEmpty
                        ? const Center(
                            child: Text('No balances found.'),
                          )
                        : ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final thisData = data[i];
                              final pupil = (thisData['pupil'] as EnrollmentFormModel);
                              // final remainingBalance = (thisData['remainingBalance'] as FeesModel);
                              final remainingBalance = FeesModel.fromMap(thisData['remainingBalance']);
                              return ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                onLongPress: () {
                                  showDialog(context: context, builder: (context) => BalanceBreakdownDialog(remainingBalance));
                                },
                                onTap: () => Nav.push(context, PaymentsPage(balanceID: thisData['id'])),
                                iconColor: Colors.white,
                                titleTextStyle: titleTextStyle,
                                subtitleTextStyle: subtitleTextStyle,
                                leading: const Icon(Icons.payment),
                                title: Text('${pupil.firstName} ${pupil.middleName} ${pupil.lastName}'),
                                subtitle: Text('Remaining: ${remainingBalance.totalFormatted()}'),
                                trailing: const Icon(Icons.arrow_forward),
                              );
                            });
                  }))
        ],
      ),
    );
  }
}

class BalanceBreakdownDialog extends StatelessWidget {
  final FeesModel remainingBalance;
  const BalanceBreakdownDialog(this.remainingBalance, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Remaining Balance breakdown',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text(
              'Aircon: P${remainingBalance.aircon}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              'Books: P${remainingBalance.books}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              'Entrance: P${remainingBalance.entrance}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              'Misc: P${remainingBalance.misc}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              'Others: P${remainingBalance.others}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              'Tuition: P${remainingBalance.tuition}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              'Watchman: P${remainingBalance.watchman}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.blueAccent,
                  colorTxt: Colors.white,
                  txtSize: 16,
                  btnTxt: 'Ok',
                  onTap: () => Nav.pop(context),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
