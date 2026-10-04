import 'dart:ui';
import 'package:flutter/material.dart';
import '../../application/config/design_system/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color = AppColors.primaryColor, this.size = 36.0});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

class LoadingStackWidget extends StatelessWidget {
  const LoadingStackWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.color = AppColors.primaryColor,
    this.overlayColor,
    this.blur = 2.0,
  });

  final bool isLoading;
  final Widget child;
  final Color color;
  final Color? overlayColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // The main content
        IgnorePointer(ignoring: isLoading, child: child),

        // The loading overlay with transition
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: Container(
                      key: const ValueKey('loading_overlay'),
                      color: overlayColor ?? Colors.black.withOpacity(0.1),
                      child: LoadingWidget(color: color),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class PremiumLoadingStack extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const PremiumLoadingStack({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          // 1. Semi-transparent backdrop blur
          const AbsorbPointer(child: SizedBox.expand()),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4 * value, sigmaY: 4 * value),
                  child: Container(
                    color: Colors.black.withOpacity(0.2 * value),
                    child: Center(
                      // 2. The Loader Container (The "Card")
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 3. Custom Themed Loader
                            const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator.adaptive(strokeWidth: 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
