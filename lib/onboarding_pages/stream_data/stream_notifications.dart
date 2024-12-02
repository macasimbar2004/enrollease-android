import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/widgets/custom_card.dart';
import 'package:enrollease/widgets/custom_list_tile.dart';
import 'package:flutter/material.dart';

class StreamNotifications extends StatelessWidget {
  final String documentID;
  const StreamNotifications({super.key, required this.documentID});

  @override
  Widget build(BuildContext context) {
    CollectionReference notificationData = FirebaseFirestore.instance.collection('notifications');
    return FutureBuilder<DocumentSnapshot>(
      future: notificationData.doc(documentID).get(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic>? data = snapshot.data?.data() as Map<String, dynamic>?;

          if (data != null) {
            final content = data['content'] ?? '';
            // Retrieve the timestamp and convert it to DateTime
            Timestamp timestamp = data['timestamp'] as Timestamp;
            DateTime dateTime = timestamp.toDate();

            // Initialize variables for date and time formatting
            String formattedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year} || ';

            // Format the time to display in AM/PM format
            if (dateTime.hour >= 12) {
              String period = 'PM';
              int hour = (dateTime.hour == 12) ? 12 : dateTime.hour - 12;
              formattedDate += '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
            } else {
              String period = 'AM';
              int hour = (dateTime.hour == 0) ? 12 : dateTime.hour;
              formattedDate += '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
            }

            return CustomCard(
              color: Colors.transparent,
              child: ExpandableListTile(
                imageUrl: '',
                title: '$content'
                    '\n\n$formattedDate',
                bgCustomColor: CustomColors.appBarColor,
              ),
            );
          } else {
            return const Text('No data available');
          }
        }
        return const Center(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ));
      }),
    );
  }
}

// testing
// class StreamNotifications extends StatefulWidget {
//   final String documentID;
//   const StreamNotifications({super.key, required this.documentID});

//   @override
//   State<StreamNotifications> createState() => _StreamNotificationsState();
// }

// class _StreamNotificationsState extends State<StreamNotifications> {
//   @override
//   Widget build(BuildContext context) {
//     return const CustomCard(
//       color: Colors.transparent,
//       child: ExpandableListTile(
//         imageUrl: '',
//         title:
//             'This is a longer text that will auto-expand to accommodate its content. '
//             'It demonstrates how the container dynamically adjusts its height based on the text.',
//       ),
//     );
//   }
// }
