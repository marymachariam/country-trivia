/// API constants used throughout the application.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the RestCountries API (v3.1)
  static const String baseUrl = 'https://restcountries.com/v3.1';

  /// Endpoint to fetch all countries
  static const String allCountriesEndpoint = '$baseUrl/all';

  /// Flag CDN base URL — use the lowercase 2-letter ISO code
  /// Example: http://flagcdn.com/w320/us.png
  static const String flagBaseUrl = 'http://flagcdn.com/w320';

  /// Fields to request from the API (reduces payload size)
  static const String fieldsQuery = 'name,cca2,flags,population,region';
}
