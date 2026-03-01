import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  AppToast._();

  static const Duration _defaultDuration = Duration(seconds: 3);

  static void success(String title, {String? description, Duration? duration}) {
    _show(
      type: ToastificationType.success,
      title: title,
      description: description,
      duration: duration,
    );
  }

  static void error(String title, {String? description, Duration? duration}) {
    _show(
      type: ToastificationType.error,
      title: title,
      description: description,
      duration: duration,
    );
  }

  static void warning(String title, {String? description, Duration? duration}) {
    _show(
      type: ToastificationType.warning,
      title: title,
      description: description,
      duration: duration,
    );
  }

  static void info(String title, {String? description, Duration? duration}) {
    _show(
      type: ToastificationType.info,
      title: title,
      description: description,
      duration: duration,
    );
  }

  static void _show({
    required ToastificationType type,
    required String title,
    String? description,
    Duration? duration,
  }) {
    toastification.dismissAll(delayForAnimation: false);
    toastification.show(
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: duration ?? _defaultDuration,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: description != null
          ? Text(description, maxLines: 3, overflow: TextOverflow.ellipsis)
          : null,
      showIcon: true,
      showProgressBar: true,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  static void dismissAll() {
    toastification.dismissAll();
  }

  static void dismissById(String id) {
    toastification.dismissById(id);
  }
}
