import 'package:enrollease/dev.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:flutter/material.dart';

class ProfilePic extends StatefulWidget {
  final double size;
  const ProfilePic({this.size = 80, super.key});

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> with AutomaticKeepAliveClientMixin {
  final auth = FirebaseAuthProvider();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipOval(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Container(
          color: Colors.blueGrey.shade200,
          padding: const EdgeInsets.all(5),
          child: FutureBuilder(
              future: auth.getProfilePic(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }
                final bytes = snapshot.data;
                dPrint(snapshot.data);
                return Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image(
                      fit: BoxFit.cover,
                      image: bytes != null ? MemoryImage(bytes) : const AssetImage(CustomLogos.editProfileImage) as ImageProvider,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
