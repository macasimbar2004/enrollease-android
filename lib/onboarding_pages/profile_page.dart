import 'package:enrollease/dev.dart';
import 'package:enrollease/model/user_model.dart';
import 'package:enrollease/onboarding_pages/calendar_page.dart';
import 'package:enrollease/states_management/side_menu_drawer_controller.dart';
import 'package:enrollease/utils/colors.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/nav.dart';
import 'package:enrollease/utils/text_styles.dart';
import 'package:enrollease/widgets/change_contact_dialog.dart';
import 'package:enrollease/widgets/change_email_dialog.dart';
import 'package:enrollease/widgets/change_name_dialog.dart';
import 'package:enrollease/widgets/change_pass_dialog.dart';
import 'package:enrollease/widgets/custom_toast.dart';
import 'package:enrollease/widgets/profile_pic.dart';
import 'package:enrollease/widgets/stream_common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({required this.userId, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authProvider = FirebaseAuthProvider();
  void reload() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'PROFILE',
          style: CustomTextStyles.inknutAntiquaBlack(
            fontSize: 15,
            color: Colors.white,
          ), // Example of passing values
        ),
      ),
      backgroundColor: CustomColors.contentColor,
      body: StreamBuilder(
          stream: authProvider.fetchAndListenToUserData(),
          builder: (context, snapshot) {
            if (streamHandler(snapshot) != null) {
              return streamHandler(snapshot)!;
            }
            dPrint(snapshot.data.toString());
            final user = UserModel.fromMap(snapshot.data!);
            return BuildProfilePage(user, widget.userId, reload);
          }),
    );
  }
}

Future<PlatformFile?> getImage() async {
  FilePickerResult? img = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.custom,
    allowedExtensions: [
      'png',
      'jpg',
      'jpeg',
      'png',
      'gif',
    ],
  );
  if (img != null) {
    PlatformFile? file = img.files.firstOrNull;
    if (file != null) {
      return file;
    }
  }
  return null;
}

class BuildProfilePage extends StatefulWidget {
  final UserModel user;
  final String userID;
  final void Function() reload;
  const BuildProfilePage(this.user, this.userID, this.reload, {super.key});

  @override
  State<BuildProfilePage> createState() => _BuildProfilePageState();
}

class _BuildProfilePageState extends State<BuildProfilePage> {
  bool profileTapped = false;
  bool loading = false;
  final authProvider = FirebaseAuthProvider();
  final scrollController = ScrollController();
  final titleTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  final subtitleTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  void toggleLoading() => setState(() {
        loading = !loading;
      });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (loading) return;
                            toggleLoading();
                            final file = await getImage();
                            if (file != null) {
                              final result = await FirebaseAuthProvider().changeProfilePic(widget.userID, file);
                              if (result != null) {
                                if (!context.mounted) return;
                                DelightfulToast.showError(context, 'Error', result);
                              }
                              widget.reload();
                            }
                            toggleLoading();
                          },
                          child: const ProfilePic(),
                        ),
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: SingleChildScrollView(
                              child: Text(
                                widget.user.userName,
                                softWrap: true,
                                style: CustomTextStyles.customInknutAntiquaStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.indigo.shade300.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            if (loading) return;
                            toggleLoading();
                            final result = await showDialog(context: context, builder: (context) => ChangeNameDialog(widget.user.uid, oldName: widget.user.userName));
                            if (!context.mounted) return;
                            if (result is String) {
                              DelightfulToast.showError(context, 'Error', result);
                            } else if (result is bool && result) {
                              widget.reload();
                              DelightfulToast.showInfo(context, 'Info', 'Name updated successfully.');
                            }
                            toggleLoading();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              'Change name',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 30),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onTap: () async {
                        if (loading) return;
                        toggleLoading();
                        final num = await showDialog(context: context, builder: (context) => ChangeContactNumberDialog(widget.user.uid, oldContactNo: widget.user.contactNumber));
                        if (!context.mounted) return;
                        if (num is String) {
                          DelightfulToast.showError(context, 'Error', num);
                        } else if (num is bool && num) {
                          widget.reload();
                          DelightfulToast.showInfo(context, 'Info', 'Number updated successfully.');
                        }
                        toggleLoading();
                      },
                      iconColor: Colors.white,
                      titleTextStyle: titleTextStyle,
                      subtitleTextStyle: subtitleTextStyle,
                      leading: const Icon(Icons.numbers),
                      title: Text('${widget.user.contactNumber.substring(0, 3)} ${widget.user.contactNumber.substring(3, 6)} ${widget.user.contactNumber.substring(6, 10)} ${widget.user.contactNumber.substring(10)}'),
                      subtitle: const Text('Tap to change'),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onTap: () async {
                        if (loading) return;
                        toggleLoading();
                        final email = await showDialog(context: context, builder: (context) => ChangeEmailDialog(widget.user.uid, oldEmail: widget.user.email));
                        if (!context.mounted) return;
                        if (email is String) {
                          DelightfulToast.showError(context, 'Error', email);
                        } else if (email is bool && email) {
                          widget.reload();
                          DelightfulToast.showInfo(context, 'Info', 'Email updated successfully.');
                        }
                        toggleLoading();
                      },
                      iconColor: Colors.white,
                      titleTextStyle: titleTextStyle,
                      subtitleTextStyle: subtitleTextStyle,
                      leading: const Icon(Icons.mail),
                      title: Text(widget.user.email),
                      subtitle: const Text('Tap to change'),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onTap: () async {
                        if (loading) return;
                        toggleLoading();
                        final passResult = await showDialog(
                            context: context,
                            builder: (context) => ChangePassDialog(
                                  widget.user.uid,
                                ));
                        if (!context.mounted) return;
                        if (passResult is String) {
                          DelightfulToast.showError(context, 'Error', passResult);
                        } else if (passResult is bool && passResult) {
                          widget.reload();
                          DelightfulToast.showInfo(context, 'Info', 'Password updated successfully.');
                        }
                        toggleLoading();
                      },
                      iconColor: Colors.white,
                      titleTextStyle: titleTextStyle,
                      subtitleTextStyle: subtitleTextStyle,
                      leading: const Icon(Icons.lock),
                      title: const Text('Change password'),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.white,
                      indent: 10,
                      endIndent: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'System',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onTap: () => Nav.push(context, const SchoolCalendarPage()),
                      iconColor: Colors.white,
                      titleTextStyle: titleTextStyle,
                      subtitleTextStyle: subtitleTextStyle,
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('School Calendar'),
                      subtitle: const Text('View upcoming events'),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
