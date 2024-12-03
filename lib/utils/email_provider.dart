import 'dart:convert';
import 'package:enrollease/dev.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const serviceId = 'service_fu003qm';
const templateId = 'template_pmmet1b';
const userId = 'CWwCkiWFJJkqjm1XP';

final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

class EmailProvider {
  Future<void> _sendEmail({
    required String email,
    required String userName,
    required String subject,
    required String message,
  }) async {
    final data = {
      'template_id': templateId,
      'service_id': serviceId,
      'user_id': userId,
      'accessToken': 'RPTnLqVdGO35prIyA_Yw5',
      'template_params': {
        'subject': subject,
        'message': message,
        'to_email': email,
      },
    };
    final response = await http.post(
      url,
      headers: {'origin': 'http://localhost', 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    dPrint(response.body);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Email sent successfully');
      }
    } else {
      if (kDebugMode) {
        print('Failed to send email. Status code: ${response.statusCode}');
      }
    }
  }

  Future<String?> sendLoginAlert({
    required String email,
    required String userName,
  }) async {
    dPrint(email);
    dPrint(userName);
    late Position location;
    try {
      final testLocation = await _determinePosition();
      if (testLocation == null) {
        return '';
      } else {
        location = testLocation;
      }
    } catch (e) {
      dPrint(e);
      return 'Unknown Error';
    }

    late String locationAddress;
    if (kIsWeb) {
      final locationTemp = await getCurrentLocation(location);
      locationAddress = '${locationTemp['display_name']}';
    } else {
      List<Placemark> placemark = await placemarkFromCoordinates(location.latitude, location.longitude);
      Placemark place = placemark[0];
      locationAddress = '${place.street}, ${place.locality}, ${place.subAdministrativeArea} ${place.postalCode}, ${place.administrativeArea}, ${place.country}';
    }
    await _sendEmail(
      email: email,
      userName: userName,
      subject: 'Login Alert',
      message: 'You logged in at:\n\n$locationAddress',
    );
    return null;
  }

  Future<Map<String, dynamic>> getCurrentLocation(Position location) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json'),
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      return {'error': response.body};
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<String?> sendOTP({required String email, required String otp, required String userName}) async {
    String message = 'Hello $userName,\n\nYour OTP code is: $otp\n\n'
        'Please do not share this code with anyone.\n\n'
        'Thank you,\nEnrollEase';
    await _sendEmail(
      email: email,
      userName: userName,
      subject: 'Your OTP',
      message: message,
    );
    return null;
  }
}
