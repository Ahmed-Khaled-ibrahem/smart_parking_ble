import 'package:flutter/material.dart';

void logApp(String? message) {
  final time = DateTime.now().toIso8601String().substring(11, 19);
  debugPrint('🟢 [APP][$time] $message');
}