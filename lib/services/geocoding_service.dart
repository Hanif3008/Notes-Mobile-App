import 'dart:convert';
import 'package:http/http.dart' as http;

/// Converts latitude/longitude coordinates into a concise human-readable
/// address using OpenStreetMap Nominatim with in-memory caching.
class GeocodingService {
  static final Map<String, String> _cache = {};
  static final Map<String, Future<String?>> _inFlight = {};

  static String? getCachedAddress(String latitude, String longitude) {
    final key = _buildKey(latitude, longitude);
    if (key == null) return null;
    return _cache[key];
  }

  static Future<String?> getAddressFromCoordinates(
    String latitude,
    String longitude,
  ) {
    final lat = double.tryParse(latitude.trim());
    final lng = double.tryParse(longitude.trim());
    if (lat == null || lng == null) return Future.value(null);

    final key = '${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    return _inFlight.putIfAbsent(key, () async {
      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?format=jsonv2&lat=$lat&lon=$lng&accept-language=id',
        );
        final res = await http
            .get(
              uri,
              headers: {
                'User-Agent': 'CatatankuApp/1.0',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 6));

        if (res.statusCode < 200 || res.statusCode >= 300) return null;

        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final formatted = _formatAddress(json);
        if (formatted != null && formatted.isNotEmpty) {
          _cache[key] = formatted;
        }
        return formatted;
      } catch (_) {
        return null;
      } finally {
        _inFlight.remove(key);
      }
    });
  }

  static String? _buildKey(String latitude, String longitude) {
    final lat = double.tryParse(latitude.trim());
    final lng = double.tryParse(longitude.trim());
    if (lat == null || lng == null) return null;
    return '${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
  }

  static String? _formatAddress(Map<String, dynamic> json) {
    final addr = json['address'];
    if (addr is Map<String, dynamic>) {
      final parts = <String>[];
      final road = addr['road'] ?? addr['pedestrian'] ?? addr['footway'];
      final area = addr['suburb'] ??
          addr['village'] ??
          addr['neighbourhood'] ??
          addr['hamlet'];
      final city =
          addr['city'] ?? addr['town'] ?? addr['county'] ?? addr['state_district'];

      for (final item in [road, area, city]) {
        final text = item?.toString().trim() ?? '';
        if (text.isNotEmpty && !parts.contains(text)) {
          parts.add(text);
        }
      }
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
    }

    final displayName = json['display_name']?.toString().trim() ?? '';
    if (displayName.isEmpty) return null;
    final segments = displayName.split(',').map((e) => e.trim()).toList();
    return segments.take(3).join(', ');
  }
}
