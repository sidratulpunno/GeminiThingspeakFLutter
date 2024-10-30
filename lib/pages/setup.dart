import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingspeak/util/storage.dart';

import '../widgets/components.dart';

class Setup extends StatefulWidget {
  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  // from key
  final _dataFrom = GlobalKey<FormState>();

  // input field controller
  final channelTextController = TextEditingController();
  final fieldTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _changePage();
  }

  // chnage page if data saved
  void _changePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? status = prefs.getBool(StorageKeys.SAVE_STATUS);
    if (status != null && status) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/sub');
    }
  }

  // save data and change page
  void _saveData() async {
    if (_dataFrom.currentState!.validate()) {
      print('Valid');

      // save data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(StorageKeys.CHANNEL_ID, channelTextController.text);
      prefs.setInt(
          StorageKeys.FIELD_COUNT, int.parse(fieldTextController.text));
      prefs.setBool(StorageKeys.SAVE_STATUS, true);

      // change page
      Navigator.pop(context);
      Navigator.pushNamed(context, '/sub');
    } else {
      print('Invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            top: 32.0,
            bottom: 70.0,
            left: 16.0,
            right: 16.0,
          ),
          children: [
            Heading(false),
            SizedBox(
              height: 20.0,
            ),
            Form(
              key: _dataFrom,
              child: setForm(),
            )
          ],
        ),
      ),
    );
  }

  // from layout
  Widget setForm() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0),
      child: Column(
        children: [
          // channel id
          TextFormField(
            controller: channelTextController,
            decoration: const InputDecoration(
              labelText: 'Channel ID',
              hintText: 'Your Chennel ID (Eg: 1385093)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Channel ID cannot be empty!';
              if (value.contains(RegExp(r'[A-Z]')) ||
                  value.contains(RegExp(r'[a-z]')))
                return 'Channel ID must be number!';
              return null;
            },
          ),
          const SizedBox(
            height: 5.0,
          ),

          // number of field
          TextFormField(
            controller: fieldTextController,
            decoration: const InputDecoration(
              labelText: 'Total Field',
              hintText: 'No of Field: (Eg: 2)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'No of Field cannot be empty!';
              if (int.parse(value) == 0) return 'No of Field cannot be zero!';
              if (value.contains(RegExp(r'[A-Z]')) ||
                  value.contains(RegExp(r'[a-z]')))
                return 'No of Field must be number!';
              return null;
            },
          ),
          const SizedBox(
            height: 32.0,
          ),

          // button to save
          ElevatedButton(
            onPressed: _saveData,
            style: TextButton.styleFrom(minimumSize: Size(100.0, 40.0)),
            child: Text('Subscribe Channel'),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    channelTextController.dispose();
    fieldTextController.dispose();
    super.dispose();
  }
}
