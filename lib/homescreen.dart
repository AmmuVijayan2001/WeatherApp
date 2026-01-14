import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/Provider/weatherprovieder.dart';
import 'package:weatherapp/custom_painter.dart';
import 'package:weatherapp/widgets/weatherInfo.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WeatherProvider>().fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (weatherProvider.error != null) {
            return Center(
              child: Text(
                weatherProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (weatherProvider.weather == null) {
            return const Center(child: Text("No weather data"));
          }

          final weather = weatherProvider.weather!;
          final formatteddate = DateFormat(
            'dd MM yyyy , hh:mm a',
          ).format(DateTime.now());

          return SingleChildScrollView(
            child: Column(
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
                                weather.cityName,
                                style: GoogleFonts.padauk(
                                  fontSize: 16,
                                  color: const Color(0xFF2D2B55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                formatteddate,
                                style: GoogleFonts.padauk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromARGB(
                                    255,
                                    105,
                                    105,
                                    105,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 45),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.description.toUpperCase(),
                              style: GoogleFonts.victorMono(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2B55),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Feels like ${(weather.tempfeelslike - 273.15).toStringAsFixed(1)}°C",
                                  style: GoogleFonts.padauk(
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
                                    context
                                        .read<WeatherProvider>()
                                        .fetchWeather();
                                  },
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${(weather.temperature - 273.15).toStringAsFixed(1)}°C",
                              style: GoogleFonts.cinzelDecorative(
                                fontSize: 60,
                                color: const Color(0xFF2D2B55),
                                fontWeight: FontWeight.w700,
                              ),
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
                        value: '${weather.humidity}%',
                        delay: 100,
                      ),
                      weatherInfoTile(
                        imagePath: 'assets/wind.png',
                        label: 'Wind Speed',
                        value: '${weather.windSpeed} m/s',
                        delay: 200,
                      ),
                      weatherInfoTile(
                        imagePath: 'assets/max_temp.png',
                        label: 'Max Temp',
                        value:
                            '${(weather.max_temp - 273.15).toStringAsFixed(1)}°C',
                        delay: 300,
                      ),
                      weatherInfoTile(
                        imagePath: 'assets/min_temp.png',
                        label: 'Min Temp',
                        value:
                            '${(weather.min_temp - 273.15).toStringAsFixed(1)}°C',
                        delay: 400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
