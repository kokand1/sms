import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';
import 'package:sms_github_proekt/setting.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:wakelock/wakelock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPreferences.init();
  
  runApp(const MyApp());
}

class MySharedPreferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  // Add more functions as needed
}

final TextEditingController numerStop = TextEditingController();
final TextEditingController telNumerInput = TextEditingController();
final TextEditingController smsMatnInput = TextEditingController();
final TextEditingController nechiSekundan = TextEditingController();
final TextEditingController nechiSekunGacha = TextEditingController();
int lastFourDigits = 0;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  Timer? _timer;
  bool isPlaying = false;
  final Random _random = Random();
  int countdown = 0; // Countdown in milliseconds
  int totalCountdown = 0; // Total countdown duration in milliseconds
  Timer? _countdownTimer;
  String currentPhoneNumber = '+998906280800';
  int sentSmsCount = 0;
  int sessionSmsCount = 0;

  @override
  void dispose() {
    // Release the wakelock and cancel timers when the app is disposed
    Wakelock.disable();
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    telNumerInput.text = await MySharedPreferences.getString('telNumerInput') ?? '';
    smsMatnInput.text = await MySharedPreferences.getString('smsMatnInput') ?? '';
    numerStop.text = await MySharedPreferences.getString('numerStop') ?? '';
    nechiSekundan.text = await MySharedPreferences.getString('nechiSekundan') ?? '';
    nechiSekunGacha.text = await MySharedPreferences.getString('nechiSekunGacha') ?? '';
   
  }

  Future<void> resetSentSmsCount() async {
    setState(() {
      sentSmsCount = 0;
     countdown =0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Bato', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: const Color.fromARGB(255, 3, 249, 52),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: const Icon(Icons.input),
              onTap: () {
                saveData();
                Navigator.push(context, MaterialPageRoute(builder: (context) => ikki()));
              },
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: resetSentSmsCount,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: ListView(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 3, 249, 52),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircularPercentIndicator(
                        backgroundColor: Colors.white,
                        progressColor: const Color.fromARGB(255, 3, 249, 52),
                        radius: 50,
                        lineWidth: 15,
                        percent: countdown > 0 && totalCountdown > 0
                            ? countdown / totalCountdown
                            : 0,
                        center: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (countdown / 1000).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text("%")
                          ],
                        ),
                      ),
                      Text(
                        "Sent: $sentSmsCount",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 3, 249, 52),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("is being sent"),
                      const SizedBox(height: 20),
                      Text(
                        getFormattedPhoneNumber(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      sessionSmsCount = 0;
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

    int delaySeconds = _random.nextInt(int.parse(nechiSekunGacha.text)) +
        int.parse(nechiSekundan.text);
    countdown = delaySeconds * 1000; // Convert seconds to milliseconds
    totalCountdown = countdown;

    int lastTickTime = DateTime.now().millisecondsSinceEpoch;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 11), (timer) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedTime = currentTime - lastTickTime;
      lastTickTime = currentTime;

      setState(() {
        countdown -= elapsedTime; // Subtract elapsed time since last tick
      });

      if (countdown <= 0) {
        timer.cancel();
      }
    });

    _timer = Timer(Duration(seconds: delaySeconds), () {
      if (isPlaying && sessionSmsCount < int.parse(numerStop.text)) {
        _sendSMSWithRandomDelay(phoneNumber, message);
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  Future<void> getPermission() async {
    await [Permission.sms].request();
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.sms.status.isGranted;
  }

  Future<void> sendSMS(String phoneNumber, String message,
      {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    );
    if (result == SmsStatus.sent) {
      setState(() {
        sentSmsCount++;
        sessionSmsCount++;
      });
      showSnackBar("Shu raqam $phoneNumber ga yuborildi");
    } else {
      showSnackBar("SMS yuborilmadi");
    }
  }

  Future<bool?> supportsCustomSim() async {
    return await BackgroundSms.isSupportCustomSim;
  }

  String getFormattedPhoneNumber() {
    if (currentPhoneNumber.isNotEmpty && currentPhoneNumber.length >= 4) {
      String lastFourDigits =
          currentPhoneNumber.substring(currentPhoneNumber.length - 4);
      return currentPhoneNumber.substring(0, currentPhoneNumber.length - 4) +
          '-' +
          lastFourDigits;
    }
    return currentPhoneNumber;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 249, 52),
      ),
    );
  }

  void saveData() {
    MySharedPreferences.saveString('telNumerInput', telNumerInput.text);
    MySharedPreferences.saveString('smsMatnInput', smsMatnInput.text);
    MySharedPreferences.saveString('numerStop', numerStop.text);
    MySharedPreferences.saveString('nechiSekundan', nechiSekundan.text);
    MySharedPreferences.saveString('nechiSekunGacha', nechiSekunGacha.text);
     MySharedPreferences.saveString('getFormattedPhoneNumber()', getFormattedPhoneNumber());

  }
}
