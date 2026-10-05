import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/config/design_system/app_theme_colors.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/scaffold_pading.dart';

class SearchFieldButton extends StatelessWidget {
  const SearchFieldButton({
    super.key,
    required this.onSubmit,
    required this.statusList,
    required this.onReset,
    required this.sortingList,
    required this.hint,
    required this.onChanged,
  });
  final Function onSubmit;
  final Function onReset;
  final List<SelectableChipModel> statusList;
  final List<SelectableChipModel> sortingList;
  final String hint;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return SearchDialog(
              onSubmit: onSubmit,
              statusList: statusList,
              onReset: onReset,
              sortingList: sortingList,
              hint: hint,
              onChanged: onChanged,
            );
          },
          barrierDismissible: true,
          barrierLabel: LocaleKeys.dismiss.tr(),
          transitionDuration: const Duration(milliseconds: 200),
          barrierColor: Colors.transparent,
          transitionBuilder: (context, animation1, animation2, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation1,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
      },
      child: SearchFormField(key: key, hint: hint, onChanged: onChanged),
    );
  }
}

class SearchFormField extends StatelessWidget {
  const SearchFormField({
    super.key,
    this.enabled = false,
    required this.hint,
    required this.onChanged,
  });
  final bool enabled;
  final String hint;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      hint: hint,
      enabled: enabled,
      borderRadius: 20,
      suffixIcon: const Icon(Icons.search),
      onChanged: onChanged,
    );
  }
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({
    super.key,
    required this.onSubmit,
    required this.statusList,
    required this.onReset,
    required this.sortingList,
    required this.hint,
    required this.onChanged,
  });
  final List<SelectableChipModel> statusList;
  final List<SelectableChipModel> sortingList;
  final Function onSubmit;
  final Function onReset;
  final String hint;
  final Function(String) onChanged;
  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: const Offset(0.0, 1),
          child: Opacity(opacity: _animation.value, child: child),
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 65,
          bottom: 300.h - MediaQuery.of(context).viewInsets.bottom,
        ),
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildSearchRow(context),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildExpansionTile(context, LocaleKeys.status, widget.statusList),
                  const SizedBox(height: 10),
                  _buildExpansionTile(context, LocaleKeys.sorting, widget.sortingList),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomElevatedButton(
            onPressed: () {
              widget.onSubmit();
              Navigator.pop(context);
            },
            title: LocaleKeys.submit,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchFormField(
            enabled: true,
            hint: widget.hint,
            onChanged: widget.onChanged,
          ),
        ),
        10.widthBox(),
        InkWell(
          onTap: () {
            widget.onReset();
            Navigator.pop(context);
          },
          child: Container(
            padding: symmetricPadding(6, 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGrey,
            ),
            child: const CustomText(
              'X',
              style: TextStyle(
                color: AppColors.primaryWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    String titleKey,
    List<SelectableChipModel> statuses,
  ) {
    return ExpansionTile(
      title: CustomText(
        titleKey.tr(),
        style: const TextStyle(
          color: AppColors.primaryWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      maintainState: true,
      dense: true,
      backgroundColor: AppColors.primaryColor,
      collapsedBackgroundColor: AppColors.primaryColor,
      iconColor: AppColors.primaryWhite,
      collapsedIconColor: AppColors.primaryWhite,
      collapsedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((model) {
        return SelectableChip(model: model);
      }).toList(),
    );
  }
}

class SelectableChip extends StatefulWidget {
  const SelectableChip({super.key, required this.model});
  final SelectableChipModel model;

  @override
  State<SelectableChip> createState() => _SelectableChipState();
}

class _SelectableChipState extends State<SelectableChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.model.onSelect(widget.model.isSelected);
        widget.model.isSelected = !widget.model.isSelected;
        setState(() {});
      },
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: symmetricPadding(7, 20),
          margin: symmetricPadding(5, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.model.isSelected
                ? AppColors.primaryYellow
                : context.cardBackground,
          ),
          child: CustomText(
            widget.model.label,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.model.isSelected
                  ? AppColors.primaryColor
                  : context.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class SelectableChipModel {
  final String label;
  bool isSelected;
  final Function(bool) onSelect;
  final int index;
  SelectableChipModel({
    required this.index,
    required this.label,
    this.isSelected = false,
    required this.onSelect,
  });
}
