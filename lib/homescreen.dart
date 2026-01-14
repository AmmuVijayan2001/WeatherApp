import 'dart:convert';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weatherapp/custom_painter.dart';
import 'package:weatherapp/weathermode.dart';
import 'package:weatherapp/widgets/weatherInfo.dart';
import 'constants.dart' as k;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  WeatherResponse? weather;
  bool isLoading = true;

  late AnimationController _animationController;

  bool showSearch = false;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatteddate = DateFormat(
      'dd MM yyyy , hh:mm a',
    ).format(DateTime.now());
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body:
          isLoading || weather == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Stack(
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
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blueAccent,
                              size: 35,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather!.cityName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF2D2B55),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  formatteddate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2D2B55),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 45),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather!.description,
                                style: GoogleFonts.victorMono(
                                  fontSize: 25,
                                  color: const Color(0xFF2D2B55),
                                ),
                              ),
                              Text(
                                "${(weather!.temperature - 273.15).toStringAsFixed(1)}°C",
                                style: GoogleFonts.cinzelDecorative(
                                  fontSize: 60,
                                  color: const Color(0xFF2D2B55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Feels like ${(weather!.tempfeelslike - 273.15).toStringAsFixed(1)}°C",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: const Color.fromARGB(
                                        255,
                                        105,
                                        105,
                                        105,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      _getLocation();
                                    },
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1.5,
                          ),
                      children: [
                        weatherInfoTile(
                          imagePath: 'assets/humidity.png',
                          label: 'Humidity',
                          value: '${weather!.humidity}%',
                          delay: 100,
                        ),
                        weatherInfoTile(
                          imagePath: 'assets/wind.png',
                          label: 'Wind Speed',
                          value: '${weather!.windSpeed} m/s',
                          delay: 200,
                        ),
                        weatherInfoTile(
                          imagePath: 'assets/max_temp.png',
                          label: 'Max Temp',
                          value:
                              '${(weather!.max_temp - 273.15).toStringAsFixed(1)}°C',
                          delay: 300,
                        ),
                        weatherInfoTile(
                          imagePath: 'assets/min_temp.png',
                          label: 'Min Temp',
                          value:
                              '${(weather!.min_temp - 273.15).toStringAsFixed(1)}°C',
                          delay: 400,
                        ),
                      ],
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
        final data = jsonDecode(response.body);
        return WeatherResponse.fromJson(data);
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
