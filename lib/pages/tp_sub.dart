import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingspeak/util/data.dart';
import 'package:thingspeak/util/storage.dart';
import 'package:thingspeak/widgets/components.dart';

import '../valueState.dart';

class TpSub extends StatefulWidget {
  @override
  _TpSubState createState() => _TpSubState();
}

class _TpSubState extends State<TpSub> {
  // Logos
  static const IconData defaultLogo = Icons.mark_chat_read_outlined;
  static const IconData dateLogo = Icons.date_range;
  static const IconData timeLogo = Icons.timer;

  late int len;
  late Map<String, dynamic> jsonResponse;
  late final String url;
  Data currentData = Data();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _gemini() {
    Navigator.pushNamed(context, '/gemini');
  }

  void _control() {
    Navigator.pushNamed(context, '/control');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            ListView(
              padding: const EdgeInsets.only(
                top: 16.0,
                bottom: 100.0, // Adjust the padding to make space for buttons
                left: 16.0,
                right: 16.0,
              ),
              children: body(),
            ),
            // Positioned buttons at the bottom of the screen
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Update button
                  reload(),

                  // AI Suggestion button
                  aiSuggestionButton(),
                  control(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI build
  List<Widget> body() {
    List<Widget> components = [];

    // Heading & subheading
    components.add(SizedBox(height: 8.0));
    components.add(Heading(true));

    components.add(SizedBox(height: 16.0));

    if (currentData.status) {
      // Date and time card
      components.add(CardBuilder(dateLogo, 'Date', currentData.date));
      components.add(CardBuilder(timeLogo, 'Time', currentData.time));

      // All data card
      for (int i = 0; i < len && i < 8; i++) {
        if (jsonResponse['channel'][Data.keys[i]] != null) {
          String displayValue =
              jsonResponse['feeds'][0][Data.keys[i]].toString();

          // For the last three fields, convert 1 to "ON" and 0 to "OFF"
          if (i >= len - 3) {
            displayValue = displayValue == '1'
                ? 'ON'
                : displayValue == '0'
                    ? 'OFF'
                    : displayValue;
          }

          components.add(CardBuilder(
            defaultLogo,
            jsonResponse['channel'][Data.keys[i]],
            displayValue,
          ));
        }
      }
    } else {
      // Data being loaded
      components.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(64.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return components;
  }

  // Fetch data from cloud
  Future<void> _loadData() async {
    // get channel id and number of field
    if (!currentData.status) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      len = prefs.getInt(StorageKeys.FIELD_COUNT)!;
      String channelId = (prefs.getString(StorageKeys.CHANNEL_ID) ?? '1403127');

      url =
          'https://api.thingspeak.com/channels/${channelId}/feeds.json?results=1';
    }

    // http request
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        // parse JSON
        jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        // set data
        currentData.date = jsonResponse['feeds'][0]['created_at'].split('T')[0];
        currentData.time =
            jsonResponse['feeds'][0]['created_at'].split('T')[1].split('Z')[0];

        currentData.setLoaded();
        ValueState.value.clear();

        for (int i = 0; i < len && i < 8; i++) {
          // Check if the key exists in the jsonResponse['feeds'][0] object
          if (jsonResponse['feeds'][0].containsKey(Data.keys[i])) {
            ValueState.value.add(jsonResponse['feeds'][0][Data.keys[i]]);
            print(ValueState.value[i]);
          } else {
            // Handle the case where the key doesn't exist
            ValueState.value.add("1"); // Or use another default value
          }
        }
      });
    } else {
      // error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error while loading...'),
        ),
      );
    }
  }

  // Floating action button for reload data.
  Widget reload() {
    return FloatingActionButton.extended(
      elevation: 10.0,
      onPressed: _loadData,
      icon: Icon(Icons.update),
      label: const Text(
        'Update',
        style: TextStyle(fontSize: 10.0),
      ),
      foregroundColor: Colors.black,
      backgroundColor: Colors.deepPurple,
    );
  }

  Widget control() {
    return FloatingActionButton.extended(
      elevation: 10.0,
      onPressed: _control,
      icon: Icon(Icons.control_point),
      label: const Text(
        'Control',
        style: TextStyle(fontSize: 10.0),
      ),
      foregroundColor: Colors.black,
      backgroundColor: Colors.deepPurple,
    );
  }

  Widget aiSuggestionButton() {
    return FloatingActionButton.extended(
      elevation: 10.0,
      onPressed: _gemini,
      icon: Icon(Icons.lightbulb_outline),
      label: const Text(
        'AI Response',
        style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
      ),
      foregroundColor: Colors.black,
      backgroundColor: Colors.deepPurple,
    );
  }
}
