import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/model/fees_model.dart';
import 'package:enrollease/model/payment_model.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/payment_breakdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentsPage extends StatefulWidget {
  final String balanceID;
  const PaymentsPage({required this.balanceID, super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late StreamController<List<Map<String, dynamic>>> paymentsController;
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
    paymentsController = StreamController<List<Map<String, dynamic>>>.broadcast();
    dates = List.generate(10, (i) {
      return DateTimeRange(
        start: DateTime(DateTime.now().year - (i + 1)),
        end: DateTime(
          DateTime.now().year - (i),
        ),
      );
    });
    selectedDate = dates.first;
    streamSource(paymentsController, selectedDate);
  }

  void streamSource(
    StreamController<List<Map<String, dynamic>>> streamController,
    DateTimeRange range,
  ) {
    if (streamController.isClosed) return;
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection('payments').where(
          'balanceAccID',
          isEqualTo: widget.balanceID,
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
          var data = snapshot.docs.map((doc) {
            final docData = doc.data();
            // dPrint('Data was: ${docData}');
            return {
              'id': docData['id'],
              'balanceAccID': docData['balanceAccID'],
              'or': docData['or'],
              'date': docData['date'],
              'amount': docData['amount'] == null ? null : FeesModel.fromMap(docData['amount']),
            };
          }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        title: Text(
          'Payments',
          style: CustomTextStyles.inknutAntiquaBlack(fontSize: 15, color: Colors.white),
        ),
        // leading: IconButton(
        //   onPressed: () => context.read<SideMenuDrawerController>().controlMenu(),
        //   icon: const Icon(CupertinoIcons.bars, size: 34),
        // ),
        centerTitle: true,
      ),
      backgroundColor: CustomColors.contentColor,
      body: Column(
        children: [
          const SizedBox(height: 10),
          overallTotal == null ? const SizedBox.shrink() : Text('You have a total pending balance of ${'P${NumberFormat('#,###').format(overallTotal)}'}'),
          const SizedBox(height: 10),
          Expanded(
              child: StreamBuilder(
                  stream: paymentsController.stream,
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
                            child: Text('No payments found.'),
                          )
                        : ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final thisData = data[i];
                              final amount = thisData['amount'] as FeesModel;
                              return ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => PaymentBreakdown(
                                      payment: Payment.fromMap(
                                        thisData['id'],
                                        thisData,
                                      ),
                                    ),
                                  );
                                },
                                iconColor: Colors.white,
                                titleTextStyle: titleTextStyle,
                                subtitleTextStyle: subtitleTextStyle,
                                leading: const Icon(Icons.receipt),
                                title: Text('${thisData['date']}'),
                                subtitle: Text('Total payment: ${amount.totalFormatted()}'),
                                trailing: const Icon(Icons.arrow_forward),
                              );
                            });
                  }))
        ],
      ),
    );
  }
}
