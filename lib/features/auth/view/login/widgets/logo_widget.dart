import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/images/logo/logo.png',
            width: height * 0.26,
          ),
        ),
        Text(
          'ielectronyhub',
          style: TextStyle(
            fontSize: height * 0.05,
            fontWeight: FontWeight.w900,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: height * 0.02,
            fontWeight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
