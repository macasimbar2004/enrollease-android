import 'package:enrollease/dev.dart';
import 'package:enrollease/model/app_size.dart';
import 'package:enrollease/pages/stream_data/stream_notifications.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  final String userId;
  const NotificationPage({super.key, required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Stream<List<String>> _docIdsFuture;
  FirebaseAuthProvider auth = FirebaseAuthProvider();

  @override
  void initState() {
    super.initState();
    dPrint('id: ${widget.userId.toString()}');
    _docIdsFuture = auth.getDocId(context, widget.userId);
    auth.markNotificationsAsRead(context, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.appBarColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
            onPressed: () => context.read<SideMenuDrawerController>().controlMenu(),
            icon: const Icon(
              CupertinoIcons.bars,
              size: 34,
            )),
        title: Text(
          'NOTIFICATIONS',
          style: CustomTextStyles.inknutAntiquaBlack(
            fontSize: 15,
            color: Colors.white,
          ), // Example of passing values
        ),
      ),
      backgroundColor: CustomColors.contentColor,
      body: Center(
        child: StreamBuilder<List<String>>(
          stream: _docIdsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text(
                'Error loading data',
                style: TextStyle(color: Colors.white),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'No notifications yet',
                style: TextStyle(color: Colors.white),
              );
            } else {
              final docIds = snapshot.data!;
              return ListView.builder(
                itemCount: docIds.length,
                itemBuilder: (context, index) {
                  return StreamNotifications(
                    documentID: docIds[index],
                  );
                },
              );
            }
          },
        ),
      ),
    ));
  }
}
