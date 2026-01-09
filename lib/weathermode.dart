class WeatherResponse {
  final String cityName;
  final String country;
  final double temperature;
  final int humidity;
  final String mainCondition;
  final String description;

  WeatherResponse({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.mainCondition,
    required this.description,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: json['main']['temp'],
      humidity: json['main']['humidity'],
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
    );
  }
}
