import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class SelectionWidget extends StatelessWidget {
  final String selectedTitle;
  final String selectedOption;
  final List<OptionButton> buttons;

  const SelectionWidget({super.key, 
    required this.selectedTitle,
    required this.selectedOption,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        ),
      ],
    );
  }
}

class OptionButton extends StatelessWidget {
  final String option;
  final String imagePath;
  final Function(String) onPressed;
  final bool selected;

  const OptionButton({super.key, 
    required this.option,
    required this.imagePath,
    required this.onPressed,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton(
          onPressed: () => onPressed(option),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              // Adjust the border radius as needed
              side: BorderSide(
                  color: context
                      .borderColor), // Adjust the border color as needed
            ),
            elevation: 0,
            backgroundColor: selected ? AppColors.primaryColor : context.cardBackground,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: selected
                        ? AppColors.primaryWhite
                        : context.textPrimary),
              ),
              SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.asset(imagePath,
                      colorFilter: ColorFilter.mode(
                          selected
                              ? AppColors.primaryWhite
                              : context.textPrimary,
                          BlendMode.srcIn))),
            ],
          ),
        ),
      ),
    );
  }
}
