import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

void main() {
  runApp(const MyaApp());
}

class MyaApp extends StatelessWidget {
  const MyaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController telNumerInput = TextEditingController();
  final TextEditingController smsMatnInput = TextEditingController();
  int lastFourDigits = 0;
  Timer? _timer;
  bool isPlaying = false;
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: telNumerInput,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1),
                ),
                hintText: "Number",
              ),
              onChanged: (value) {
                if (value.length >= 4) {
                  lastFourDigits = int.parse(value.substring(value.length - 4));
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: smsMatnInput,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1),
                ),
                hintText: "Text",
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () async {
          if (await isPermissionGranted()) {
            bool? customSimSupport = await supportsCustomSim();
            if (customSimSupport != null && customSimSupport) {
              toggleSMS();
            } else {
              // No custom SIM support
            }
          } else {
            getPermission();
          }
        },
      ),
    );
  }

  void toggleSMS() {
    if (isPlaying) {
      _timer?.cancel();
    } else {
      sendSMSPeriodically(smsMatnInput.text);
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void sendSMSPeriodically(String message) {
    String phoneNumber = telNumerInput.text;

    if (phoneNumber.length >= 4) {
      String lastFourDigitsStr = phoneNumber.substring(phoneNumber.length - 4);
      try {
        lastFourDigits = int.parse(lastFourDigitsStr);
      } catch (e) {
        print("Error parsing last four digits: $e");
        return;
      }
    } else {
      print("Phone number is too short");
      return;
    }

    _sendSMSWithRandomDelay(phoneNumber, message);
  }

  void _sendSMSWithRandomDelay(String phoneNumber, String message) {
    if (lastFourDigits > 9999) return;

    String incrementedNumber = (lastFourDigits + 1).toString().padLeft(4, '0');
    String newPhoneNumber = phoneNumber.replaceRange(
      phoneNumber.length - 4,
      phoneNumber.length,
      incrementedNumber,
    );

    sendSMS(newPhoneNumber, message);

    lastFourDigits++; // Increment the last four digits for the next SMS

    int delaySeconds = _random.nextInt(8) + 3; // Random delay between 3 and 10 seconds
    _timer = Timer(Duration(seconds: delaySeconds), () {
      if (isPlaying) {
        _sendSMSWithRandomDelay(phoneNumber, message);
      }
    });
  }

  getPermission() async => await [Permission.sms].request();

  Future<bool> isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  sendSMS(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      showSnackBar("Shu raqam $phoneNumber ga yuborildi");
    } else {
      showSnackBar("SMS yuborilmadi");
    }
  }

  Future<bool?> supportsCustomSim() async =>
      await BackgroundSms.isSupportCustomSim;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 24, 62, 25),
      ),
    );
  }
}
