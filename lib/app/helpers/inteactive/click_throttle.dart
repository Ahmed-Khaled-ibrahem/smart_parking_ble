import 'dart:async';
import '../toast/app_toast.dart';

class ClickThrottler {
  final Duration duration;
  bool _ready = true;

  ClickThrottler({required this.duration});

  void call(Function action) {
    if (!_ready) {
      AppToast.warning('Please wait ${duration.inSeconds} Seconds before clicking again');
      return;
    }
    _ready = false;
    action();
    Timer(duration, () => _ready = true);
  }
}