import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/country.dart';

/// Responsible for making HTTP calls to the RestCountries API.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the full list of countries from the API.
  ///
  /// Returns a list of [Country] objects.
  /// Throws an [Exception] if the request fails.
  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse(
      '${ApiConstants.allCountriesEndpoint}?fields=${ApiConstants.fieldsQuery}',
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load countries (HTTP ${response.statusCode})',
      );
    }

    return Country.listFromString(utf8.decode(response.bodyBytes));
  }
}
