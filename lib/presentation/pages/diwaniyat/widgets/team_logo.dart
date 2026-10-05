import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

class TeamLogo extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const TeamLogo({super.key, required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.mutedBackground),
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, color: context.brandOnSurface, size: 30);
                    },
                  ),
                )
              : Icon(Icons.person, color: context.brandOnSurface, size: 30),
        ),
        8.heightBox(),
        SizedBox(
          width: 80.w,
          child: Text(
            name,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

