import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.icon,
    this.press,
    this.visible = true, // todo make it false later
  });

  final String text, icon;
  final VoidCallback? press;
  final bool visible;


  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: AppColors.gray.withValues(alpha: 0.2),
        ),
        onPressed: press,
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 22,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text)),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
