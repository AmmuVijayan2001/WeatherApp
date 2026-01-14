import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/constants.dart' as k;
import 'package:weatherapp/weathermode.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherResponse? weather;
  bool isLoading = false;
  String? error;

  Future<void> fetchWeather() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final position = await determinePosition();
      weather = await getWeatherData(position);
    } catch (e) {
      log('Error fetching weather data: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<WeatherResponse> getWeatherData(Position position) async {
    var uri =
        '${k.weatherApiUrl}lat=${position.latitude.toString()}&lon=${position.longitude.toString()}&appid=${k.apiKey}';
    var url = Uri.parse(uri);

    var response = await http.get(url);

    log('STATUS CODE: ${response.statusCode}');
    log('RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      log('Weather Data: ${response.body}');
      final data = jsonDecode(response.body);
      return WeatherResponse.fromJson(data);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<Position> determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
