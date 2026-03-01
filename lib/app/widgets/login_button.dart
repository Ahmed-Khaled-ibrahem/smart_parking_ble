import 'package:flutter/material.dart';

Widget loginButton({
  required String text,
  required Widget icon,
  required VoidCallback onPressed,
  required double width,
  required Color foregroundColor,
  required Color backgroundColor,
  required double height,
}) {
  return Padding(
    padding: const EdgeInsets.all(6.0),
    child: SizedBox(
      width: width * 0.8,
      height: height * 0.06,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
