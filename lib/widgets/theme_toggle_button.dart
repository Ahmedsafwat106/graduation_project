import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/theme/theme_cubit.dart';

/// A sun/moon animated icon button that toggles the global app theme.
///
/// Drop it into any AppBar or overlay — it reads + writes [ThemeCubit]
/// which is provided at the root of the widget tree.
class ThemeToggleButton extends StatelessWidget {
  /// [color] overrides the icon color (defaults to white — ideal for gradient
  /// headers; pass a dark color when placed on a light background).
  final Color? color;

  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return Tooltip(
          message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: IconButton(
              key: ValueKey(isDark),
              icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: color ?? Colors.white,
                size: 26,
              ),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
          ),
        );
      },
    );
  }
}
