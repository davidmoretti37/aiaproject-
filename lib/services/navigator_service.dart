import 'package:flutter/material.dart';

class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> push<T>(Route<T> route) {
    return navigatorKey.currentState!.push(route);
  }

  static Future<T?> pushMaterial<T>(Widget page) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }
}
