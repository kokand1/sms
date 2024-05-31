import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  String phoneNumber = '';
  String smsText = '';
  String stopNumber = '';
  String minSeconds = '';
  String maxSeconds = '';

  void updatePhoneNumber(String value) {
    phoneNumber = value;
    notifyListeners();
  }

  void updateSmsText(String value) {
    smsText = value;
    notifyListeners();
  }

  void updateStopNumber(String value) {
    stopNumber = value;
    notifyListeners();
  }

  void updateMinSeconds(String value) {
    minSeconds = value;
    notifyListeners();
  }

  void updateMaxSeconds(String value) {
    maxSeconds = value;
    notifyListeners();
  }
}
