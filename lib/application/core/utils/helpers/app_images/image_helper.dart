import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/app_assets.dart';

class ImageHelper {
  static void showImageByUrl(
    BuildContext context, {
    required String imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
    BoxFit fit = BoxFit.contain,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => placeholder ?? const CircularProgressIndicator(),
            errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
            fit: fit,
          ),
        );
      },
    );
  }
  static Widget showImageWithNetwork({
    required String imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
    double? height = 48.0,
    double? width = 48.0,
  }) {
    return Image.network(
      imageUrl,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child; // If no progress event, display the image
        } else {
          return placeholder ?? imgPlaceholder(); // Display the placeholder during loading
        }
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return errorWidget ?? imgPlaceholder(); // Display the error widget if loading fails
      },
      height: height,
      width: width,
    );
  }
  static Widget showCachedImageWithNetwork({
    required String imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
    double? height = 48.0,
    double? width = 48.0,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => placeholder ?? imgPlaceholder(),//progressbar(),
      errorWidget: (context, url, error) => errorWidget ?? imgPlaceholder(),
      height: height,
      width: width,
    );
  }

  static Widget imgPlaceholder({double? height = 48.0, double? width = 48.0}) {
    return Builder(
      builder: (context) {
        return SvgPicture.asset(
          AppAssets.ic_invalid_password,
          width: width,
          height: height,
        );
      },
    );
  }
  static Widget progressbar({double? height = 40.0, double? width = 40.0}) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: width,
          height: height,
          child: const CircularProgressIndicator(
            // Add any additional properties you may need for CircularProgressIndicator
            strokeWidth: 3.0, // Example: Set the stroke width
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Example: Set the color
          ),
        );
      },
    );
  }

}
