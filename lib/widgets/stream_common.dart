import 'package:enrollease/dev.dart';
import 'package:flutter/material.dart';

Widget? streamHandler(AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  if (snapshot.hasError || snapshot.data == null) {
    dPrint(snapshot.error.toString());
    return Center(
      child: ErrorWidget.withDetails(message: snapshot.error.toString()),
    );
  }
  return null;
}
