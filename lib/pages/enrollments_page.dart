import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/dev.dart';
import 'package:enrollease/model/enrollment_form_model.dart';
import 'package:enrollease/model/enrollment_status_enum.dart';
import 'package:enrollease/model/gender_enum.dart';
import 'package:enrollease/pages/enroll_form_page.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/custom_loading_dialog.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/custom_button.dart';
import 'package:enrollease/widgets/stream_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnrollmentsPage extends StatefulWidget {
  final String uid;
  const EnrollmentsPage({required this.uid, super.key});

  @override
  State<EnrollmentsPage> createState() => _EnrollFormPageState();
}

class _EnrollFormPageState extends State<EnrollmentsPage> {
  final db = FirebaseFirestore.instance;

  Stream<List<EnrollmentFormModel>> getEnrollments() async* {
    final ref = db.collection('enrollment_forms').where('parentsUserId', isEqualTo: widget.uid);
    await for (final snapshot in ref.snapshots()) {
      final result = <EnrollmentFormModel>[];
      if (snapshot.docs.isNotEmpty) {
        for (final snapshot in snapshot.docs) {
          result.add(EnrollmentFormModel.fromMap(snapshot.data()));
        }
      }
      yield result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        title: Text(
          'ENROLLMENTS',
          style: CustomTextStyles.inknutAntiquaBlack(fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => context.read<SideMenuDrawerController>().controlMenu(),
          icon: const Icon(CupertinoIcons.bars, size: 34),
        ),
        centerTitle: true,
      ),
      backgroundColor: CustomColors.contentColor,
      body: SafeArea(
        child: StreamBuilder(
            stream: getEnrollments(),
            builder: (context, snapshot) {
              if (streamHandler(snapshot) != null) {
                return streamHandler(snapshot)!;
              }
              final enrollments = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                      child: snapshot.data!.isEmpty
                          ? const Center(
                              child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No enrollments found.',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('Tap button below to enroll a new pupil.')
                              ],
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: enrollments.length,
                              itemBuilder: (context, i) {
                                final enrollment = enrollments[i];
                                dPrint(enrollment.toString());
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      switch (enrollment.status) {
                                        case EnrollmentStatus.approved:
                                          showDialog(context: context, builder: (context) => ApprovedEnrollmentDialog(pupil: '${enrollment.firstName} ${enrollment.middleName} ${enrollment.lastName}'));
                                          break;
                                        case EnrollmentStatus.disapproved:
                                          showDialog(context: context, builder: (context) => DisapprovedEnrollmentDialog(enrollmentID: enrollment.regNo, pupil: '${enrollment.firstName} ${enrollment.middleName} ${enrollment.lastName}'));
                                          break;
                                        case EnrollmentStatus.pending:
                                          showDialog(context: context, builder: (context) => const PendingEnrollmentDialog());
                                          break;
                                      }
                                    },
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    tileColor: Colors.white.withOpacity(0.7),
                                    leading: Icon(enrollment.gender == Gender.male ? Icons.man : Icons.woman),
                                    title: Text('${enrollment.firstName} ${enrollment.lastName}'),
                                    subtitle: Text(enrollments[i].regNo),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: getEnrollmentStatusColor(enrollments[i].status),
                                      ),
                                      child: Text(
                                        enrollments[i].status.formalName(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Nav.push(context, const EnrollFormPage());
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: CustomColors.appBarColor),
                                Text(
                                  'Enroll a new pupil',
                                  style: TextStyle(color: CustomColors.appBarColor),
                                ),
                              ],
                            )),
                      ],
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }

  Color getEnrollmentStatusColor(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.approved:
        return Colors.green;
      case EnrollmentStatus.disapproved:
        return Colors.red;
      case EnrollmentStatus.pending:
        return Colors.amber;
    }
  }
}

class ApprovedEnrollmentDialog extends StatelessWidget {
  final String pupil;
  const ApprovedEnrollmentDialog({required this.pupil, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enrollment approved!',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              '$pupil is official enrolled.\nPlease see "school fees" section to view pending balance.',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.blueAccent,
                  colorTxt: Colors.white,
                  txtSize: 16,
                  btnTxt: 'Ok',
                  onTap: () {
                    Nav.pop(context);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PendingEnrollmentDialog extends StatelessWidget {
  const PendingEnrollmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enrollment pending...',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 5),
            const Text(
              'Please wait for the registrar to take action on your enrollment.',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.blueAccent,
                  colorTxt: Colors.white,
                  txtSize: 16,
                  btnTxt: 'Ok',
                  onTap: () {
                    Nav.pop(context);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DisapprovedEnrollmentDialog extends StatelessWidget {
  final String pupil;
  final String enrollmentID;
  const DisapprovedEnrollmentDialog({required this.pupil, required this.enrollmentID, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enrollment disapproved...',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              'Sorry, $pupil wasn\'t enrolled. Please contact the registrar for more info.',
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
                  colorBg: Colors.redAccent,
                  colorTxt: Colors.white,
                  txtSize: 16,
                  btnTxt: 'Delete',
                  onTap: () async {
                    showLoadingDialog(context, 'Deleting enrollment...');
                    await FirebaseFirestore.instance.collection('enrollment_forms').doc(enrollmentID).delete();
                    if (!context.mounted) return;
                    Nav.pop(context);
                    Nav.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                CustomBtn(
                  vertical: 10,
                  horizontal: 20,
                  colorBg: Colors.blueAccent,
                  colorTxt: Colors.white,
                  txtSize: 16,
                  btnTxt: 'Ok',
                  onTap: () {
                    Nav.pop(context);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
