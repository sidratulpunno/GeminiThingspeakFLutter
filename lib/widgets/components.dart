import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingspeak/util/storage.dart';

// Heading widgets
// ignore: must_be_immutable
class Heading extends StatelessWidget {
  late bool logoutButton;
  late BuildContext context;

  Heading(this.logoutButton);

  void _clearData() async {
    print('logout button pressed');

    // chnage status
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(StorageKeys.SAVE_STATUS, false);

    // back to setup page
    Navigator.pop(context);
    Navigator.pushNamed(context, '/setup');
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          const Center(
            child: Text(
              'Smart Farming',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
          ),
          const Spacer(),
          logoutButton
              ? Column(
                  children: [
                    IconButton(
                      onPressed: _clearData,
                      tooltip: 'Set new channel',
                      icon: const Icon(Icons.logout),
                    ),
                    const Text('Exit'),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }
}

// Sub heading widgets
// ignore: must_be_immutable
class SubHeading extends StatelessWidget {
  String title;

  SubHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 110.0, right: 8.0),
      child: Text(
        title,
        textScaleFactor: 1.5,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Card widgets
// ignore: must_be_immutable
class CardBuilder extends StatelessWidget {
  IconData logo;
  String heading;
  String state;

  CardBuilder(this.logo, this.heading, this.state);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10.0,
        child: Column(
          children: [
            ListTile(
              leading: Icon(logo, color: Colors.black),
              title: Center(
                child: Text(
                  heading,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            const Divider(
              indent: 20.0,
              endIndent: 20.0,
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                state,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                ),
              ),
            ),
            const SizedBox(
              height: 3,
            )
          ],
        ),
      ),
    );
  }
}
