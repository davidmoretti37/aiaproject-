import 'package:android_intent_plus/android_intent.dart';

class ActionsAndroid {
  static void openApp(String packageName) {
    final intent = AndroidIntent(
      action: 'action_view',
      package: packageName,
    );
    intent.launch();
  }

  static void openDeepLink(String url) {
    final intent = AndroidIntent(
      action: 'action_view',
      data: url,
    );
    intent.launch();
  }
}
