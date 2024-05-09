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
    return MaterialApp(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text("sms"),centerTitle: true,
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
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1),
                ),
                hintText: "number",
              ),
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
                hintText: "matn",
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.send),
        onPressed: () async {
          if (await isPermissionGranted()) {
            bool? customSimSupport = await supportsCustomSim();
            if (customSimSupport != null && customSimSupport) {
              for (int i = 0; i < 1; i++) {
                await Future.delayed(const Duration(seconds: 1)).then((value) {
                  if (telNumerInput.text.isNotEmpty || smsMatnInput.text.isNotEmpty) {
                    sendSMS(telNumerInput.text, smsMatnInput.text);
                  }
                });
              }
            } else {
              // Özel sim desteği yoksa buraya bir işlem ekleyebilirsiniz.
            }
          } else {
            getPermission();
          }
        },
      ),
    );
  }

  getPermission() async => await [Permission.sms].request();

  Future<bool> isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  sendSMS(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      showSnackBar("SMS: Shu raqam $phoneNumber ga yuborildi");
  
    } else {
      showSnackBar("SMS yuborilmadi");
    }
  }

  Future<bool?> supportsCustomSim() async =>
      await BackgroundSms.isSupportCustomSim;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: 50),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 24, 62, 25),
      ),
    );
  }
}
