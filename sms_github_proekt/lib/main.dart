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
      debugShowCheckedModeBanner: false,
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
  int countdown = 0;
  Timer? _countdownTimer;
  String currentPhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:   Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.next_plan),
            SizedBox(width: 10,),
            Text(
                        '${getIncrementedPhoneNumber()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
          ],
        ),

        backgroundColor: Color.fromARGB(255, 3, 249, 52),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10,top: 15),
          child: Text(
                      ' $countdown',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
              minLines: 5,
              maxLines: null,
            ),
            const SizedBox(height: 20),
            if (isPlaying)
              Column(
                children: [
                 
                
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
        onPressed: () async {
          if (await isPermissionGranted()) {
            bool? customSimSupport = await supportsCustomSim();
            if (customSimSupport != null && customSimSupport) {
              toggleSMS();
            } else {
              showSnackBar("Custom SIM support not available");
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
      pauseSMS();
    } else {
      resumeSMS();
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void pauseSMS() {
    _timer?.cancel();
    _countdownTimer?.cancel();
  }

  void resumeSMS() {
    sendSMSPeriodically(smsMatnInput.text);
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

    setState(() {
      currentPhoneNumber = newPhoneNumber;
    });

    sendSMS(newPhoneNumber, message);

    lastFourDigits++;

    int delaySeconds = _random.nextInt(20) + 3;
    countdown = delaySeconds;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
      });

      if (countdown <= 0) {
        timer.cancel();
      }
    });

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

  String getIncrementedPhoneNumber() {
    String incrementedPhoneNumber = '';

    if (currentPhoneNumber.isNotEmpty && int.tryParse(currentPhoneNumber) != null) {
      incrementedPhoneNumber = (int.parse(currentPhoneNumber) + 1).toString();
    } else {
      // Handle the case where the currentPhoneNumber is not valid.
      incrementedPhoneNumber = 'Invalid';
    }

    return incrementedPhoneNumber;
  }

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
