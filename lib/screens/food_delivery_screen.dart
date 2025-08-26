import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ifood_agent_tool.dart';

class FoodDeliveryScreen extends StatefulWidget {
  final String category;
  final double latitude;
  final double longitude;

  const FoodDeliveryScreen({
    Key? key,
    required this.category,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends State<FoodDeliveryScreen> {
  final IfoodAgentTool _ifood = IfoodAgentTool();
  late Future<List<Restaurant>> _future;

  @override
  void initState() {
    super.initState();
    _future = _ifood.getRestaurantsByCategory(
      category: widget.category,
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color background = const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: const AssetImage('assets/profile.png'),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Resultados no iFood: ${widget.category}',
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),

            // Results
            Expanded(
              child: FutureBuilder<List<Restaurant>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _ErrorView(
                      error: snapshot.error.toString(),
                      onRetry: () {
                        setState(() {
                          _future = _ifood.getRestaurantsByCategory(
                            category: widget.category,
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                          );
                        });
                      },
                    );
                  }
                  final data = snapshot.data ?? const [];
                  if (data.isEmpty) {
                    return _EmptyView(onRetry: () {
                      setState(() {
                        _future = _ifood.getRestaurantsByCategory(
                          category: widget.category,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                        );
                      });
                    });
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final r = data[index];
                      final bool isFree = r.deliveryFee.toLowerCase().contains('grátis');
                      return Material(
                        elevation: 0.7,
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openDeeplink(r.deeplink),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: r.image.isNotEmpty
                                      ? Image.network(
                                          r.image,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 56,
                                          height: 56,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.restaurant,
                                            size: 32,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Text(
                                        r.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF222B45),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Row: rating, category, distance
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Color(0xFFFBC02D), size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            r.rating.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                                          ),
                                          const SizedBox(width: 10),
                                          if (r.category.isNotEmpty)
                                            Text(
                                              r.category,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[400],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          const SizedBox(width: 10),
                                          Text(
                                            r.distance,
                                            style: const TextStyle(fontSize: 15, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Row: delivery fee
                                      Row(
                                        children: [
                                          Text(
                                            isFree ? 'Grátis' : r.deliveryFee,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isFree ? const Color(0xFF2ECC71) : Colors.grey[700],
                                              fontWeight: isFree ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                          if (r.deliveryTime.isNotEmpty) ...[
                                            const SizedBox(width: 12),
                                            const Icon(Icons.timer_outlined, size: 16, color: Colors.black45),
                                            const SizedBox(width: 4),
                                            Text(
                                              r.deliveryTime,
                                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDeeplink(String deeplink) async {
    try {
      final uri = Uri.parse(deeplink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // fallback: try launching as web url if scheme is not supported
        if (deeplink.startsWith('ifood://')) {
          final web = _convertIfoodToWeb(deeplink);
          final webUri = Uri.parse(web);
          if (await canLaunchUrl(webUri)) {
            await launchUrl(webUri, mode: LaunchMode.externalApplication);
          }
        }
      }
    } catch (_) {
      // ignore for now
    }
  }

  String _convertIfoodToWeb(String deeplink) {
    // Basic conversion: ifood://restaurant/{id}?slug={slug} or ?name={name}
    try {
      final uri = Uri.parse(deeplink);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final id = pathSegments.last;
        final slug = uri.queryParameters['slug'];
        final name = uri.queryParameters['name'];
        if (slug != null && slug.isNotEmpty) {
          return 'https://www.ifood.com.br/delivery/$slug';
        }
        if (name != null && name.isNotEmpty) {
          // Fallback: just go to homepage (no direct mapping from name)
          return 'https://www.ifood.com.br/';
        }
        return 'https://www.ifood.com.br/';
      }
    } catch (_) {}
    return 'https://www.ifood.com.br/';
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            const Text('Nenhum restaurante encontrado', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({Key? key, required this.error, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Erro ao carregar restaurantes', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
