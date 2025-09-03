import '../integrations/actions_android.dart';

class IntentRouter {
  static void routeIntent(String intent, Map<String, dynamic> entities) {
    switch (intent) {
      case 'open_app':
        if (entities.containsKey('package_name')) {
          ActionsAndroid.openApp(entities['package_name']);
        }
        break;
      case 'open_deep_link':
        if (entities.containsKey('url')) {
          ActionsAndroid.openDeepLink(entities['url']);
        }
        break;
      default:
        print("Unknown intent: $intent");
    }
  }
}
