import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/custom_elevated_button.dart';
import 'package:futblha/presentation/widgets/custom_scaffold.dart';
import 'package:futblha/presentation/widgets/custom_text.dart';
import 'package:futblha/presentation/widgets/custom_toolbar.dart';

import '../../../data/models/enums/position_enum.dart';

@RoutePage()
class EditPositionsPage extends StatefulWidget {
  final List<String>? initialPositions;
  final bool? initialIsJocker;

  const EditPositionsPage({super.key, this.initialPositions, this.initialIsJocker});

  @override
  State<EditPositionsPage> createState() => _EditPositionsPageState();
}

class _EditPositionsPageState extends State<EditPositionsPage> {
  List<String> _selectedPositions = [];
  bool _isJocker = false;

  List<Map<String, dynamic>> get _positions {
    final topPositions = [0.20, 0.40, 0.60, 0.80];
    return Position.selectablePositions.asMap().entries.map((entry) {
      final index = entry.key;
      final position = entry.value;
      return {
        'key': position.key,
        'name': position.displayName,
        'top': index < topPositions.length ? topPositions[index] : 0.20,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedPositions = widget.initialPositions ?? [];
    _isJocker = widget.initialIsJocker ?? false;
  }

  void _selectPosition(String position) {
    if (_isJocker) {
      return; // Don't allow position selection if Jocker is selected
    }
    setState(() {
      if (_selectedPositions.contains(position)) {
        _selectedPositions.remove(position);
      } else {
        _selectedPositions.add(position);
      }
    });
  }

  void _toggleJocker(bool? value) {
    setState(() {
      _isJocker = value ?? false;
      if (_isJocker) {
        _selectedPositions.clear(); // Clear position selection when Jocker is selected
        _selectedPositions.add(Position.jocker.key);
      } else {
        _selectedPositions.remove(Position.jocker.key);
      }
    });
  }

  void _onSavePressed() {
    // Return the selected positions and jocker status
    Navigator.of(context).pop({'positions': _selectedPositions, 'isJocker': _isJocker});
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      hasPadding: false,
      appBar: CustomAppBar(title: LocaleKeys.edit_positions.tr()),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.h),
              // Select Position Label
              CustomText(
                LocaleKeys.select_skilled_position,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10.h),
              // Soccer Field with Position Buttons
              Container(
                height: 310.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(AppAssets.grass_profile),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Soccer field lines (simplified representation)
                    CustomPaint(painter: _SoccerFieldPainter(), child: Container()),
                    // Position Buttons
                    ..._positions.map((position) {
                      // Show all positions as selected in UI when Jocker is selected
                      final isSelected = _isJocker || _selectedPositions.contains(position['key']);
                      return Positioned(
                        left: 20.w,
                        right: 20.w,
                        top: (position['top'] as double) * 300.h - 20.h,
                        child: GestureDetector(
                          onTap: () => _selectPosition(position['key'] as String),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryWhite.withValues(alpha: .4),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withValues(alpha: 0.8)
                                    : AppColors.primaryWhite.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.primaryDarkGrey.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: CustomText(
                                position['name'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primaryWhite
                                      : AppColors.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              // Jocker Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isJocker,
                    onChanged: _toggleJocker,
                    activeColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleJocker(!_isJocker),
                      child: CustomText(
                        LocaleKeys.jocker_all_positions,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              // Save Button
              CustomElevatedButton(title: LocaleKeys.save_button, onPressed: _onSavePressed),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for soccer field lines
class _SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryWhite.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.15, paint);

    // Penalty box (top)
    final topPenaltyBox = Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height * 0.25);
    canvas.drawRect(topPenaltyBox, paint);

    // Penalty box (bottom)
    final bottomPenaltyBox = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.75,
      size.width * 0.6,
      size.height * 0.25,
    );
    canvas.drawRect(bottomPenaltyBox, paint);

    // Goal area (top)
    final topGoalArea = Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, size.height * 0.12);
    canvas.drawRect(topGoalArea, paint);

    // Goal area (bottom)
    final bottomGoalArea = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.88,
      size.width * 0.4,
      size.height * 0.12,
    );
    canvas.drawRect(bottomGoalArea, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
