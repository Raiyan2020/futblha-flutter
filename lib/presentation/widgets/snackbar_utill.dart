import 'package:flutter/material.dart';
import '../../application/config/design_system/app_colors.dart';
import 'custom_text.dart';

enum MessagePosition { top, bottom, center, custom }

extension SnackBarExtension on BuildContext {
  void showMessage(
    String message, {
    bool isError = false,
    MessagePosition position = MessagePosition.bottom,
    Offset? customOffset, // in case user wants exact position
  }) {
    final overlay = Overlay.of(this);
    final entry = OverlayEntry(
      builder: (context) {
        // Decide alignment
        Alignment alignment;
        EdgeInsets margin;

        switch (position) {
          case MessagePosition.top:
            alignment = Alignment.topCenter;
            margin = const EdgeInsets.only(top: 50);
            break;
          case MessagePosition.center:
            alignment = Alignment.center;
            margin = EdgeInsets.zero;
            break;
          case MessagePosition.custom:
            alignment = Alignment.topLeft;
            margin = EdgeInsets.only(left: customOffset?.dx ?? 0, top: customOffset?.dy ?? 0);
            break;
          case MessagePosition.bottom:
            alignment = Alignment.bottomCenter;
            margin = const EdgeInsets.only(bottom: 50);
        }

        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              alignment: alignment,
              margin: margin,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: isError ? AppColors.primaryRed : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isError ? Icons.info_outline : Icons.check_circle_sharp, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: CustomText(
                          message,
                          maxLines: 3,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryWhite),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Insert into overlay
    overlay.insert(entry);

    // Auto-remove after duration
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}
