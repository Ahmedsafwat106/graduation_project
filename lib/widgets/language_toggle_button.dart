import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? color;

  const LanguageToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;
    final isArabic = currentLocale == 'ar';

    return Tooltip(
      message: isArabic ? 'Switch to English' : 'Switch to Arabic',
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (isArabic) {
            context.setLocale(const Locale('en'));
          } else {
            context.setLocale(const Locale('ar'));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: color ?? Colors.white,
                size: 24,
              ),
              const SizedBox(width: 4),
              Text(
                isArabic ? 'EN' : 'AR',
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
