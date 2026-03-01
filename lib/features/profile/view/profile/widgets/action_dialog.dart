import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showActionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Option 1
            InkWell(
              onTap: () {
                context.pop();
                context.push('/terms-of-service');
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    const Icon(Icons.description),
                    const SizedBox(width: 20),
                    const Text("Terms of Service"),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            InkWell(
              onTap: () {
                context.pop();
                context.push('/privacy-policy');
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip),
                    const SizedBox(width: 20),
                    const Text("Privacy Policy"),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
