import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../config/design_system/app_colors.dart';

enum ImageCropShape { rectangle, circle }

class ImagePickCropHelper {
  static Future<File?> pickAndCropImage(
    BuildContext context, {
    ImageCropShape shape = ImageCropShape.rectangle,
    bool lockSquareAspectRatio = true,
    int compressQuality = 90,
    String? toolbarTitle,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;
      final path = result.files.first.path;
      if (path == null) return null;

      if (!context.mounted) return null;

      final cropStyle = shape == ImageCropShape.circle ? CropStyle.circle : CropStyle.rectangle;
      final aspectRatio = lockSquareAspectRatio
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : null;

      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        aspectRatio: aspectRatio,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: compressQuality,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle ?? 'Crop',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: AppColors.primaryWhite,
            activeControlsWidgetColor: AppColors.primaryColor,
            cropStyle: cropStyle,
            lockAspectRatio: lockSquareAspectRatio,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: toolbarTitle ?? 'Crop',
            cropStyle: cropStyle,
            aspectRatioLockEnabled: lockSquareAspectRatio,
            aspectRatioPickerButtonHidden: lockSquareAspectRatio,
          ),
          if (kIsWeb) WebUiSettings(context: context, presentStyle: WebPresentStyle.dialog),
        ],
      );

      // If user cancels cropping, keep the originally selected image.
      return File(cropped?.path ?? path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking/cropping image: $e');
      }
      return null;
    }
  }
}
