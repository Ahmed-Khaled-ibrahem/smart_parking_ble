import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/theme/app_theme.dart';

class AgreementWidget extends StatelessWidget {
  const AgreementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'By signing up, you agree to our',
                style: TextStyle(
                  color: AppColors.gray,
                  fontSize: height * 0.02,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  context.push('/terms-of-service');
                },
                child: Text(
                  "Terms of Service",
                  style: TextStyle(
                    color: AppColors.greenHover,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkOrange,
                    decorationThickness: 1.5,
                    fontSize: height * 0.02,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'and',
                style: TextStyle(
                  color: AppColors.gray,
                  fontSize: height * 0.02,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  context.push('/privacy-policy');
                },
                child: Text(
                  "Privacy Policy",
                  style: TextStyle(
                    color: AppColors.greenHover,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkOrange,
                    decorationThickness: 1.5,
                    fontSize: height * 0.02,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoolLinkButton extends StatefulWidget {
  final String text;
  // final VoidCallback onTap;

  const _CoolLinkButton({required this.text});

  @override
  State<_CoolLinkButton> createState() => _CoolLinkButtonState();
}

class _CoolLinkButtonState extends State<_CoolLinkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.darkOrange.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: AppColors.darkOrange,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.darkOrange.withValues(alpha: 0.7),
              decorationThickness: 1.5,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}


