class WeatherResponse {
  final String cityName;
  final String country;
  final double temperature;
  final double tempfeelslike;
  final double max_temp;
  final double min_temp;
  final int humidity;
  final String mainCondition;
  final String description;
  final num windSpeed;
  WeatherResponse({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.mainCondition,
    required this.description,
    required this.windSpeed,
    required this.tempfeelslike,
    required this.max_temp,
    required this.min_temp,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: json['main']['temp'],
      tempfeelslike: json['main']['feels_like'],
      min_temp: json['main']['temp_min'],
      max_temp: json['main']['temp_max'],
      humidity: json['main']['humidity'],
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      windSpeed: json['wind']['speed'],
    );
  }
}
