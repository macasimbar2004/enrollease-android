import 'package:enrollease/onboarding_pages/enroll_form_page.dart';
import 'package:enrollease/onboarding_pages/home_page.dart';
import 'package:enrollease/onboarding_pages/message_page.dart';
import 'package:enrollease/onboarding_pages/notice_board_page.dart';
import 'package:enrollease/onboarding_pages/notification_page.dart';
import 'package:enrollease/onboarding_pages/profile_page.dart';
import 'package:enrollease/onboarding_pages/school_fees_page.dart';
import 'package:flutter/material.dart';

List<Widget> screens = [
  const HomePage(),
  const EnrollFormPage(),
  const MessagePage(),
  const NoticeBoardPage(),
  const SchoolFeesPage(),
  const NotificationPage(),
  const ProfilePage()
];