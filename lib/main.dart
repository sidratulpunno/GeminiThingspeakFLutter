import 'package:flutter/material.dart';
import 'package:thingspeak/pages/control.dart';
import 'package:thingspeak/pages/gemini.dart';
import 'package:thingspeak/pages/setup.dart';
import 'package:thingspeak/pages/tp_sub.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'ThingSpeak Subscribe',
        // initialRoute: "/sub",
        routes: {
          "/": (context) => Setup(),
          "/setup": (context) => Setup(),
          "/sub": (context) => TpSub(),
          "/gemini": (context) => GenerativeAIScreen(),
          "/control": (context) => ControlScreen(),
        },
      ),
    );
