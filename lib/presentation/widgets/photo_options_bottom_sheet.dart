import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../application/config/design_system/app_colors.dart';
import '../../application/config/design_system/app_theme_colors.dart';
import '../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../generated/locale_keys.g.dart';
import 'app_size_boxes.dart';

/// Bottom sheet shown when tapping an existing photo: change it or remove it.
void showPhotoOptionsBottomSheet(
  BuildContext context, {
  required String title,
  required VoidCallback onChange,
  required VoidCallback onRemove,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: sheetContext.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: sheetContext.mutedBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                title,
                style: TextStyle(
                  color: sheetContext.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _PhotoOptionTile(
              icon: Icons.photo_library_outlined,
              label: LocaleKeys.change_photo.tr(),
              color: sheetContext.brandOnSurface,
              backgroundColor: sheetContext.chipBackground,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onChange();
              },
            ),
            _PhotoOptionTile(
              icon: Icons.delete_outline,
              label: LocaleKeys.remove_photo.tr(),
              color: AppColors.primaryRed,
              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onRemove();
              },
            ),
            12.heightBox(),
          ],
        ),
      ),
    ),
  );
}

/// "Photo will be removed when you save · Undo" hint shown under the avatar.
class PhotoRemovalHint extends StatelessWidget {
  const PhotoRemovalHint({super.key, required this.onUndo});

  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: context.textSecondary),
          6.widthBox(),
          Text(
            LocaleKeys.photo_will_be_removed.tr(),
            style: TextStyle(color: context.textSecondary, fontSize: 13),
          ),
          TextButton(
            onPressed: onUndo,
            style: TextButton.styleFrom(
              foregroundColor: context.brandOnSurface,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              LocaleKeys.undo.tr(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
