import 'dart:convert';

/// Immutable data class representing a country in the trivia game.
class Country {
  final String name;
  final String isoCode; // lowercase 2-letter code, e.g. "us"

  const Country({
    required this.name,
    required this.isoCode,
  });

  /// Flag image URL built from the ISO code.
  String get flagUrl => 'http://flagcdn.com/w320/$isoCode.png';

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: (json['name'] as Map<String, dynamic>)['common'] as String,
      isoCode: (json['cca2'] as String).toLowerCase(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Country && other.isoCode == isoCode);

  @override
  int get hashCode => isoCode.hashCode;

  @override
  String toString() => 'Country(name: $name, isoCode: $isoCode)';

  /// Helper to parse a list of countries from a raw JSON array.
  static List<Country> listFromString(String rawJson) {
    final List<dynamic> data = json.decode(rawJson) as List<dynamic>;
    return data
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
