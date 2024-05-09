import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

void main() {
  runApp(MyaApp());
}

class MyaApp extends StatefulWidget {
  const MyaApp({super.key});

  @override
  State<MyaApp> createState() => _MyaAppState();
}

class _MyaAppState extends State<MyaApp> {
  final TextEditingController phonecontroler = TextEditingController();
  final TextEditingController smscontroler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("sms"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: phonecontroler,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 1),
                    ),
                    hintText: "number"),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: smscontroler,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 1),
                    ),
                    hintText: "matn"),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.send),
            onPressed: () async {
              if (await ispermessionGranted()) {

                if((await supportCustomsim)!){
                  for(int i = 0; i <= 1; i++){
                    await Future.delayed(const Duration(seconds: 1)).then((value)
                     {if(phonecontroler.text.isNotEmpty || smscontroler.text.isNotEmpty){
                      sensms(phonecontroler.text, smscontroler.text);
                    }});
                  }
                }else{
                 
                }

              } else {
                getpermission();
              }
            }),
      ),
    );
  }

  getpermission() async => await [Permission.sms].request();
  Future<bool> ispermessionGranted() async =>
      await Permission.sms.status.isGranted;
  sensms(String phoneNumber, String message, {int? simSlot}) async {
    var resalt = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (resalt == SmsStatus.sent) {
      print("sent");
    } else {
      print("eror");
    }
    ;
  }

  Future<bool?> get supportCustomsim async =>
      await BackgroundSms.isSupportCustomSim;
}
