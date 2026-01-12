import 'dart:convert';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/custom_painter.dart';
import 'package:weatherapp/weathermode.dart';
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
  late Animation<Offset> _avatarSlide;
  late Animation<Offset> _textfieldAnimation;

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

    _avatarSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _textfieldAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body:
          isLoading || weather == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(
                    height: 300,
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

                  const SizedBox(height: 50),

                  Text(
                    weather!.cityName,
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 40,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    weather!.description,
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 154, 152, 152),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(weather!.temperature - 273.15).toStringAsFixed(1)}°C",
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 64,
                      color: const Color(0xFF2D2B55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SlideTransition(
                          position: _avatarSlide,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showSearch = true;
                              });
                              _animationController.forward();
                            },
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF2D2B55),
                              child: Icon(Icons.search, color: Colors.amber),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showSearch)
                    Expanded(
                      child: SlideTransition(
                        position: _textfieldAnimation,
                        child: TextField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            hintText: "Enter city name",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _searchCity,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Future<void> _searchCity() async {
    final cityName = _cityController.text.trim();
    if (cityName.isEmpty) return;

    setState(() => isLoading = true);

    var uri = '${k.searchCity}q=$cityName&appid=${k.apiKey}';
    var url = Uri.parse(uri);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        weather = WeatherResponse.fromJson(data);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      log('Failed to find $cityName');
    }
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
