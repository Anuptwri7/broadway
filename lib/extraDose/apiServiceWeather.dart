import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class ApiServices {
  Future<List<WeatherModel>?> fetchWeather(double latitude, double longitude, String apiKey) async {
    final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

    final Uri uri = Uri.parse('${baseUrl}?lat=${latitude}&lon=${longitude}&appid=${apiKey}');

    final response = await http.get(uri);
    log(response.body.toString());
    log('https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${apiKey}');
    if (response.statusCode == 200) {
      log(response.body.toString());
      final Map<String, dynamic> data = json.decode(response.body);
      final WeatherModel weather = WeatherModel.fromJson(data);

      return [weather];
    } else {
      return null;
    }
  }

}