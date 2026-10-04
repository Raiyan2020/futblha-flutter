import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../application/config/design_system/app_colors.dart';

class CustomConfirmationBottomSheet extends StatelessWidget {
  final String? iconPath;
  final String message;
  final String? submitButtonText;
  final String? cancelButtonText;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;

  const CustomConfirmationBottomSheet({
    super.key,
    this.iconPath,
    required this.message,
    this.submitButtonText,
    this.cancelButtonText,
    this.onSubmit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconPath != null
              ? Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: SvgPicture.asset(
                    iconPath!,
                    height: 60,
                    width: 60,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primaryDarkGrey, BlendMode.srcIn),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 32),
          Text(
            message,
            textAlign: TextAlign.center, // Center the text
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryBlack,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: onCancel != null,
                // Show the "Cancel" button only if isSuccess is false
                child: Expanded(
                    child: ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.borderGrey),
                        ),
                      ),
                      child: Visibility(
                        visible: cancelButtonText?.isNotEmpty == true,
                        child: Text(
                          cancelButtonText ?? '',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primaryBlack,
                                  ),
                        ),
                      ),
                    )),
              ),
              onCancel != null ? const SizedBox(width: 16) : const SizedBox.shrink(),
              Visibility(
                visible: onSubmit != null,
                child: Expanded(
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Visibility(
                      visible: submitButtonText?.isNotEmpty == true,
                      child: Text(
                        submitButtonText ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryWhite,
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
