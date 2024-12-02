import 'dart:convert';
import 'dart:typed_data';

import 'package:enrollease/dev.dart';
import 'package:enrollease/utils/firebase_auth.dart';
import 'package:enrollease/utils/logos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePic extends StatefulWidget {
  final double size;
  const ProfilePic({this.size = 80, super.key});

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> with AutomaticKeepAliveClientMixin {
  final auth = FirebaseAuthProvider();
  Uint8List? bytes;

  Future<Uint8List?> getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPic = prefs.getString('profilePic');
    if (savedPic == null) {
      final data = await auth.getProfilePic();
      if (data != null) {
        prefs.setString('profilePic', base64Encode(data));
        return data;
      }
    } else {
      dPrint('loaded from cache');
      return base64Decode(savedPic);
    }
    return null;
  }

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
              future: getProfilePic(),
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
                if (bytes == null || bytes != snapshot.data) {
                  bytes = snapshot.data;
                }
                dPrint(snapshot.data);
                return Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image(
                      fit: BoxFit.cover,
                      image: bytes != null ? MemoryImage(bytes!) : const AssetImage(CustomLogos.editProfileImage) as ImageProvider,
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
