import 'package:flutter/material.dart';
import 'package:sms_github_proekt/main.dart';

class ikki extends StatefulWidget {
  const ikki({super.key});

  @override
  State<ikki> createState() => _ikkiState();
}

class _ikkiState extends State<ikki> {
  bool remember = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Checkbox(
          mouseCursor: MaterialStateMouseCursor.clickable,
          value: remember,
          onChanged: (value) {
            setState(() {
              remember = value!;
            });
          },
          fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Color.fromARGB(255, 21, 187, 2); // Selected
              }
              return Colors.white; // Unselected
            },
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 249, 52),
        automaticallyImplyLeading: false,
        title: const Text("fill in the blanks"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 231, 236, 240),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                width: 80,
                height: 30,
                child: const Center(child: Text("save")),
              ),
              onTap: () {
                if (remember) {
                  saveData();
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: telNumerInput,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 249, 52), width: 1),
                ),
                labelText: "Number",
              ),
              onChanged: (value) {
                if (value.length >= 4) {
                  lastFourDigits = int.tryParse(value.substring(value.length - 4)) ?? 0;
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
                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 249, 52), width: 1),
                ),
                labelText: "Text",
              ),
              minLines: 5,
              maxLines: null,
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.phone,
              controller: numerStop,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 249, 52), width: 1),
                ),
                labelText: "Enter stop number",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nechiSekundan,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 249, 52), width: 1),
                ),
                labelText: "Min seconds",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nechiSekunGacha,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 3, 249, 52), width: 1),
                ),
                labelText:
                "Max seconds",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  void saveData() {
    MySharedPreferences.saveString('telNumerInput', telNumerInput.text);
    MySharedPreferences.saveString('smsMatnInput', smsMatnInput.text);
    MySharedPreferences.saveString('numerStop', numerStop.text);
    MySharedPreferences.saveString('nechiSekundan', nechiSekundan.text);
    MySharedPreferences.saveString('nechiSekunGacha', nechiSekunGacha.text);
  }
}
