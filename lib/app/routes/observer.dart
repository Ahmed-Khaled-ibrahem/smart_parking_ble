import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:flutter/widgets.dart';

class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver();

  void _sendScreenView(Route<dynamic>? route) {
    final screenName = route?.settings.name;
    if (screenName != null) {
      logApp('navigate to $screenName');
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _sendScreenView(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _sendScreenView(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _sendScreenView(previousRoute);
  }
}