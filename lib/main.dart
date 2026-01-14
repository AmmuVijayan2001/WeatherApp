import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/Provider/weatherprovieder.dart';
import 'package:weatherapp/homescreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: Homescreen()),
    ),
  );
}
