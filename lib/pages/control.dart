import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thingspeak/valueState.dart';

class ControlScreen extends StatefulWidget {
  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool isLightOn = (ValueState.value[5] == '1') ? true : false;

  bool isFanOn = (ValueState.value[6] == '1') ? true : false;
  bool isWaterPumpOn = (ValueState.value[7] == '1') ? true : false;
  String light = ValueState.value[5];

  String fan = ValueState.value[6];

  String pump = ValueState.value[7];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Control Panel',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              buildControlCard('Light', isLightOn, Icons.lightbulb, (value) {
                setState(() {
                  isLightOn = value;
                  if (value == true) {
                    light = '1';
                  } else {
                    light = '0';
                  }
                  Future.delayed(Duration(seconds: 3), () {
                    print("Executed after 3 seconds");
                    postData(light, fan, pump);
                  });
                });
              }),
              SizedBox(height: 20),
              buildControlCard('Fan', isFanOn, Icons.ac_unit, (value) {
                setState(() {
                  isFanOn = value;
                  if (value == true) {
                    fan = '1';
                  } else {
                    fan = '0';
                  }
                  Future.delayed(Duration(seconds: 3), () {
                    print("Executed after 3 seconds");
                    postData(light, fan, pump);
                  });
                });
              }),
              SizedBox(height: 20),
              buildControlCard('Water Pump', isWaterPumpOn, Icons.water,
                  (value) {
                setState(() {
                  isWaterPumpOn = value;
                  if (value == true) {
                    pump = '1';
                  } else {
                    pump = '0';
                  }
                  Future.delayed(Duration(seconds: 3), () {
                    print("Executed after 3 seconds");
                    postData(light, fan, pump);
                  });
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildControlCard(String label, bool currentValue, IconData icon,
      Function(bool) onChanged) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.purple),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Switch(
              value: currentValue,
              onChanged: onChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> postData(
    String field6Value, String field7Value, String field8Value) async {
  // Define the URL with your API key and data fields
  final String url = 'https://api.thingspeak.com/update';

  try {
    // Make the POST request with the field data and API key as query parameters
    final response = await http.post(
      Uri.parse(
          '$url?api_key=N1EZQ2BAM3K85JRI&field1=${ValueState.value[0]}&field2=${ValueState.value[1]}&field3=${ValueState.value[2]}&field4=${ValueState.value[3]}&field5=${ValueState.value[4]}&field6=$field6Value&field7=$field7Value&field8=$field8Value'),
    );

    // Check the response status
    if (response.statusCode == 200) {
      print('Data posted successfully');
    } else {
      print('Failed to post data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while posting data: $e');
  }
}
