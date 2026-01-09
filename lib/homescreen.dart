import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/weathermode.dart';
import 'constants.dart' as k;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  WeatherResponse? weather;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: -20,
                        left: -30,
                        child: CustomPaint(
                          size: const Size(350, 250),
                          painter: AbstractPainter(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 180),

                  Text(
                    weather!.cityName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    weather!.description,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(weather!.temperature - 273.15).toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
    );
  }

  Future<WeatherResponse?> getCurrentCityWeather(Position position) async {
    try {
      var uri =
          '${k.weatherApiUrl}lat=${position.latitude.toString()}&lon=${position.longitude.toString()}&appid=${k.apiKey}';
      var url = Uri.parse(uri);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        log('Weather Data: ${response.body}');
      }
    } catch (e) {
      log('Failed to fetch weather data');
    }
    return null;
  }

  Future<void> _getLocation() async {
    Position position = await _determinePosition();
    log('Location: ${position.latitude}, ${position.longitude}');
    weather = await getCurrentCityWeather(position);
    setState(() {
      isLoading = false;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}

class AbstractPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF2D2B55);
    final paint2 = Paint()..color = const Color(0xFFF36C6C);
    final paint3 = Paint()..color = const Color(0xFFF3B562);

    canvas.drawCircle(const Offset(220, 80), 100, paint1);
    canvas.drawCircle(const Offset(100, 60), 70, paint3);
    canvas.drawCircle(const Offset(80, 120), 80, paint2);

    // Drips
    canvas.drawRect(const Rect.fromLTWH(210, 140, 6, 60), paint1);
    canvas.drawRect(const Rect.fromLTWH(225, 150, 6, 80), paint1);

    canvas.drawRect(const Rect.fromLTWH(90, 130, 6, 50), paint2);
    canvas.drawRect(const Rect.fromLTWH(105, 140, 6, 70), paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
