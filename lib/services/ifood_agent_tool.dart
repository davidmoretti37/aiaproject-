import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Model representing a restaurant (customize fields as needed)
class Restaurant {
  final String id;
  final String name;
  final String image;
  final String deeplink;
  final double rating;
  final String distance;
  final String deliveryFee;
  final String deliveryTime;
  final String category;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.deeplink,
    required this.rating,
    required this.distance,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      deeplink: json['deeplink'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      distance: json['distance'] ?? '',
      deliveryFee: json['deliveryFee'] ?? '',
      deliveryTime: json['deliveryTime'] ?? '',
      category: json['category'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

/// Tool/service to fetch real iFood restaurant data by category and location
class IfoodAgentTool {
  /// Fetches restaurants from iFood by category and location.
  /// You must fill in the endpoint, headers, and parsing logic based on iFood's web/mobile API.
  Future<List<Restaurant>> getRestaurantsByCategory({
    required String category,
    required double latitude,
    required double longitude,
  }) async {
    print('[IFOOD][DEBUG] Entered getRestaurantsByCategory with category="$category", latitude=$latitude, longitude=$longitude');

    // Generate simple UUID-like IDs (no dependency)
    String _s4(math.Random r) => r.nextInt(0x10000).toRadixString(16).padLeft(4, '0');
    String _uuid() {
      final r = math.Random();
      return '${_s4(r)}${_s4(r)}-${_s4(r)}-${_s4(r)}-${_s4(r)}-${_s4(r)}${_s4(r)}${_s4(r)}';
    }

    final deviceId = _uuid();
    final sessionId = _uuid();

    // Headers based on working Python v2 implementation
    final headers = {
      'accept': 'application/json, text/plain, */*',
      'accept-language': 'pt-BR,pt;q=1',
      'app_version': '9.119.1',
      'browser': 'Mac OS',
      'cache-control': 'no-cache, no-store',
      'content-type': 'application/json',
      'country': 'BR',
      'dnt': '1',
      'experiment_details':
          '{ "default_merchant": { "model_id": "search-rerank-endpoint", "recommendation_filter": "AVAILABLE_FOR_SCHEDULING_FIXED", "available_for_scheduling_recommended_limit": 5, "engine": "sagemaker", "backend_experiment_id": "v4", "query_rewriter_rule": "merchant-names", "second_search": true, "force_similar_search_disabled": true, "similar_search": { "open_merchants_threshold": 5, "max_similar_merchants": 5 } } }',
      'experiment_variant': 'default_merchant',
      'gps-latitude': latitude.toString(),
      'gps-longitude': longitude.toString(),
      'origin': 'https://www.ifood.com.br',
      'platform': 'Desktop',
      'priority': 'u=1, i',
      'referer': 'https://www.ifood.com.br/',
      'sec-ch-ua': '"Chromium";v="137", "Not/A)Brand";v="24"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"macOS"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-site',
      'test_merchants': 'undefined',
      'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
      'x-client-application-key': '41a266ee-51b7-4c37-9e9d-5cd331f280d5',
      'x-device-model': 'Macintosh Chrome',
      'x-ifood-device-id': deviceId,
      'x-ifood-session-id': sessionId,
    };

    // Payload and params mirroring Python v2
    final payload = {
      "supported-headers": ["OPERATION_HEADER"],
      "supported-cards": [
        "MERCHANT_LIST",
        "CATALOG_ITEM_LIST",
        "CATALOG_ITEM_LIST_V2",
        "CATALOG_ITEM_LIST_V3",
        "FEATURED_MERCHANT_LIST",
        "CATALOG_ITEM_CAROUSEL",
        "CATALOG_ITEM_CAROUSEL_V2",
        "CATALOG_ITEM_CAROUSEL_V3",
        "BIG_BANNER_CAROUSEL",
        "IMAGE_BANNER",
        "MERCHANT_LIST_WITH_ITEMS_CAROUSEL",
        "SMALL_BANNER_CAROUSEL",
        "NEXT_CONTENT",
        "MERCHANT_CAROUSEL",
        "MERCHANT_TILE_CAROUSEL",
        "SIMPLE_MERCHANT_CAROUSEL",
        "INFO_CARD",
        "MERCHANT_LIST_V2",
        "ROUND_IMAGE_CAROUSEL",
        "BANNER_GRID",
        "MEDIUM_IMAGE_BANNER",
        "MEDIUM_BANNER_CAROUSEL",
        "RELATED_SEARCH_CAROUSEL",
        "ADS_BANNER"
      ],
      "supported-actions": [
        "catalog-item",
        "item-details",
        "merchant",
        "page",
        "card-content",
        "last-restaurants",
        "webmiddleware",
        "reorder",
        "search",
        "groceries",
        "home-tab"
      ],
      "feed-feature-name": "",
      "faster-overrides": ""
    };

    final params = {
      'alias': 'SEARCH_RESULTS_MERCHANT_TAB_GLOBAL',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'channel': 'IFOOD',
      'size': '20',
      'term': category,
    };

    final uri = Uri.https('marketplace.ifood.com.br', '/v2/cardstack/search/results', params);

    try {
      // Perform POST as per working implementation
      final response = await http.post(uri, headers: headers, body: jsonEncode(payload));
      print('[IFOOD][DEBUG] 🌐 Request URL: ${uri.toString()}');
      print('[IFOOD][DEBUG] 📊 Response Status: ${response.statusCode}');
      print('[IFOOD][DEBUG] 📏 Response Length: ${response.body.length}');
      print('[IFOOD][DEBUG] 🔑 Device ID: $deviceId');
      print('[IFOOD][DEBUG] 🔑 Session ID: $sessionId');

      if (response.statusCode != 200) {
        print('[IFOOD][DEBUG] HTTP ERROR: ${response.statusCode}');
        print('[IFOOD][DEBUG] Response body (first 500): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        return [];
      }

      // Parse JSON
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('[IFOOD][DEBUG] ❌ JSON decode error: $e');
        return [];
      }

      // Helper formatters
      String formatImageUrl(String imageUrl) {
        if (imageUrl.isEmpty) return '';
        const base = 'https://static-images.ifood.com.br/image/upload';
        if (imageUrl.startsWith(':resolution/')) {
          return '$base/t_medium${imageUrl.substring(11)}';
        } else if (imageUrl.startsWith('http')) {
          return imageUrl;
        } else {
          return '$base/t_medium/$imageUrl';
        }
      }

      String createDeeplinkFromAction(String action, String id, String name) {
        try {
          if (action.contains('merchant?')) {
            final qs = action.split('merchant?')[1];
            final parts = qs.split('&');
            final map = <String, String>{};
            for (final p in parts) {
              if (p.contains('=')) {
                final kv = p.split('=');
                map[kv[0]] = Uri.decodeComponent(kv[1]);
              }
            }
            if (map.containsKey('identifier') && map.containsKey('slug')) {
              final identifier = map['identifier']!;
              final slug = Uri.encodeComponent(map['slug']!);
              return 'ifood://restaurant/$identifier?slug=$slug';
            }
            if (map.containsKey('identifier')) {
              final identifier = map['identifier']!;
              final encName = Uri.encodeComponent(name);
              return 'ifood://restaurant/$identifier?name=$encName';
            }
          }
        } catch (_) {}
        final encName = Uri.encodeComponent(name);
        return 'ifood://restaurant/$id?name=$encName';
      }

      // Extract restaurants
      final List<Restaurant> results = [];
      if (data is Map && data['sections'] is List) {
        final sections = data['sections'] as List;
        for (final section in sections) {
          if (section is Map && section['type'] == 'CARDS' && section['cards'] is List) {
            for (final card in section['cards']) {
              if (card is Map && card['cardType'] == 'MERCHANT_LIST_V2') {
                final contents = card['data']?['contents'];
                if (contents is List) {
                  for (final item in contents) {
                    if (item is Map && (item['available'] == true)) {
                      final id = (item['id'] ?? '').toString();
                      final name = (item['name'] ?? '').toString();
                      if (id.isEmpty || name.isEmpty) continue;

                      final deliveryInfo = item['deliveryInfo'] as Map? ?? {};
                      final fee = (deliveryInfo['fee'] ?? 0);
                      final timeMin = (deliveryInfo['timeMinMinutes'] ?? 0);
                      final timeMax = (deliveryInfo['timeMaxMinutes'] ?? 0);

                      final deliveryFeeFormatted = (fee is num && fee > 0)
                          ? 'R\$ ${(fee / 100).toStringAsFixed(2)}'.replaceAll('.', ',')
                          : 'Grátis';

                      String deliveryTimeFormatted = 'Consultar';
                      if (timeMin is num && timeMax is num && timeMin > 0 && timeMax > 0) {
                        deliveryTimeFormatted = '${timeMin.toInt()}-${timeMax.toInt()} min';
                      }

                      final distanceVal = (item['distance'] ?? 0);
                      String distanceFormatted = 'N/A';
                      if (distanceVal is num && distanceVal > 0) {
                        distanceFormatted = '${distanceVal.toStringAsFixed(1)} km';
                      }

                      final imageUrl = formatImageUrl((item['imageUrl'] ?? '').toString());
                      final rating = ((item['userRating'] ?? 0) as num).toDouble();
                      final categoryStr = (item['mainCategory'] ?? 'Restaurante').toString();
                      final action = (item['action'] ?? '').toString();
                      final deeplink = createDeeplinkFromAction(action, id, name);

                      results.add(
                        Restaurant(
                          id: id,
                          name: name,
                          image: imageUrl,
                          deeplink: deeplink,
                          rating: rating,
                          distance: distanceFormatted,
                          deliveryFee: deliveryFeeFormatted,
                          deliveryTime: deliveryTimeFormatted,
                          category: categoryStr,
                          latitude: latitude,
                          longitude: longitude,
                        ),
                      );
                    }
                  }
                }
              }
            }
          }
        }
      }

      print('[IFOOD][DEBUG] ✅ Parsed ${results.length} restaurants');
      return results;
    } catch (e) {
      print('[IFOOD][DEBUG] Exception occurred: $e');
      rethrow;
    }
  }
}
