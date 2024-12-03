import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/dev.dart';
import 'package:enrollease/model/enrollment_form_model.dart';
import 'package:enrollease/model/enrollment_status_enum.dart';
import 'package:enrollease/model/gender_enum.dart';
import 'package:enrollease/pages/enroll_form_page.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_styles.dart';
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
    final ref = db.collection('enrollment_forms').where('parentsUserId', isEqualTo: widget.uid).where('status', isEqualTo: EnrollmentStatus.pending.name);
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
                                      // TODO: editable if rejected
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
                                        color: Colors.amber,
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
}
