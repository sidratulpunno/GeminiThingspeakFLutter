import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingspeak/util/data.dart';
import 'package:thingspeak/util/storage.dart';
import 'package:thingspeak/widgets/components.dart';

List<String> value = [];
String val0 = value[0];
String val1 = value[1];
String val2 = value[2];
String val3 = value[3];
String val4 = value[4];
String val5 = value[5];
String val6 = value[6];
String val7 = value[7];

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

    // Heading & ssub heading
    components.add(SizedBox(height: 8.0));
    components.add(Heading(true));

    components.add(SizedBox(height: 16.0));

    if (currentData.status) {
      // Date and time card
      components.add(CardBuilder(dateLogo, 'Date', currentData.date));
      components.add(CardBuilder(timeLogo, 'Time', currentData.time));

      // all data card
      for (int i = 0; i < len && i < 8; i++) {
        if (null != jsonResponse['channel'][Data.keys[i]]) {
          components.add(CardBuilder(
              defaultLogo,
              jsonResponse['channel'][Data.keys[i]],
              jsonResponse['feeds'][0][Data.keys[i]]));
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

        for (int i = 0; i < len && i < 8; i++) {
          // Check if the key exists in the jsonResponse['feeds'][0] object
          if (jsonResponse['feeds'][0].containsKey(Data.keys[i])) {
            value.add(jsonResponse['feeds'][0][Data.keys[i]]);
            print(value[i]);
            print(jsonResponse);
          } else {
            // Handle the case where the key doesn't exist
            value.add("N/A"); // Or use another default value
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
      label: Text('Update'),
      foregroundColor: Colors.black,
      backgroundColor: Colors.purple,
    );
  }

  Widget control() {
    return FloatingActionButton.extended(
      elevation: 10.0,
      onPressed: _control,
      icon: Icon(Icons.control_point),
      label: Text('Control'),
      foregroundColor: Colors.black,
      backgroundColor: Colors.purple,
    );
  }

  Widget aiSuggestionButton() {
    return FloatingActionButton.extended(
      elevation: 10.0,
      onPressed: _gemini,
      icon: Icon(Icons.lightbulb_outline),
      label: Text('AI Response'),
      foregroundColor: Colors.black,
      backgroundColor: Colors.purple,
    );
  }
}
