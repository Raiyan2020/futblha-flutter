import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/utils/helpers/app_images/image_pick_crop_helper.dart';
import '../../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../widgets/app_size_boxes.dart';
import '../../widgets/snackbar_utill.dart';
import 'bloc/diwaniya_bloc.dart';
import '../../../data/models/request_model/diwaniya/create_diwaniya_request_model.dart';
import '../../../generated/locale_keys.g.dart';

@RoutePage()
class DiwaniyaSettingsPage extends StatefulWidget {
  const DiwaniyaSettingsPage({super.key, required this.bloc});
  final DiwaniyaBloc bloc;

  @override
  State<DiwaniyaSettingsPage> createState() => _DiwaniyaSettingsPageState();
}

class _DiwaniyaSettingsPageState extends State<DiwaniyaSettingsPage> {
  late final bloc = widget.bloc;
  File? _diwaniyaImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedType;

  @override
  void initState() {
    super.initState();
    bloc.add(GetDiwaniyaTypesEvent());
    // Load current diwaniya data
    final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
    if (diwaniya != null) {
      _nameController.text = diwaniya.name ?? '';
      _descriptionController.text = diwaniya.description ?? '';
      _selectedType = diwaniya.type;
    } else {
      // Fetch overview to get my diwaniya
      bloc.add(GetDiwaniyasOverviewEvent());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePickCropHelper.pickAndCropImage(
        context,
        shape: ImageCropShape.rectangle,
        lockSquareAspectRatio: true,
        maxWidth: 1080,
        maxHeight: 1080,
        toolbarTitle: 'Crop',
      );
      if (file != null) {
        setState(() => _diwaniyaImage = file);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  void _onSavePressed() {
    final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
    if (diwaniya?.id == null) {
      context.showMessage(isError: true, LocaleKeys.diwaniya_not_found.tr());
      return;
    }

    if (_nameController.text.isEmpty) {
      context.showMessage(isError: true, LocaleKeys.please_enter_diwaniya_name.tr());
      return;
    }
    if (_selectedType == null) {
      context.showMessage(isError: true, LocaleKeys.please_select_diwaniya_type.tr());
      return;
    }

    final request = CreateDiwaniyaRequestModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType!.toLowerCase(),
      image: _diwaniyaImage,
    );

    bloc.add(UpdateDiwaniyaEvent(diwaniyaId: diwaniya!.id!, request: request));
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        } else if (state is UpdateDiwaniyaSuccess) {
          context.router.maybePop(true);
          context.showMessage(LocaleKeys.diwaniya_updated_successfully.tr());
        } else if (state is DeleteDiwaniyaSuccess) {
          context.router.maybePop(true);
          context.showMessage(state.message);
        }
      },
      builder: (context, state) {
        final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
        final displayImage = _diwaniyaImage != null ? _diwaniyaImage!.path : diwaniya?.image;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlack),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(
              LocaleKeys.diwaniya_settings.tr(),
              style: const TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 130.w,
                        height: 130.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryWhite, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlack.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _diwaniyaImage != null
                              ? Image.file(_diwaniyaImage!, fit: BoxFit.cover)
                              : displayImage != null
                              ? Image.network(
                                  displayImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(AppAssets.ic_profile, fit: BoxFit.cover);
                                  },
                                )
                              : Image.asset(
                                  AppAssets.ic_profile,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.primaryLiteGrey,
                                      child: Icon(
                                        Icons.person,
                                        size: 48,
                                        color: AppColors.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryWhite,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                32.heightBox(),
                Text(
                  LocaleKeys.name.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.heightBox(),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(LocaleKeys.enter_diwaniya_name.tr()),
                ),
                20.heightBox(),
                Text(
                  LocaleKeys.description.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.heightBox(),
                TextFormField(
                  controller: _descriptionController,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  maxLines: 4,
                  decoration: _inputDecoration(LocaleKeys.describe_your_diwaniya.tr()),
                ),
                20.heightBox(),
                Text(
                  LocaleKeys.diwaniya_type.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.heightBox(),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryDark),
                  decoration: _inputDecoration(null),
                  items: bloc.diwaniyaTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type.key,
                          child: Text(
                            type.name ?? type.key ?? '',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedType = value);
                  },
                ),
                40.heightBox(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: state is DiwaniyaLoading ? null : _onSavePressed,
                    child: state is DiwaniyaLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryWhite),
                            ),
                          )
                        : Text(
                            LocaleKeys.save.tr(),
                            style: const TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                12.heightBox(),
                if (diwaniya?.userPermission?.isAdmin == true) ...[
                  Center(
                    child: TextButton(
                      onPressed: state is DiwaniyaLoading ? null : () => _showDeleteDiwaniyaDialog(context),
                      child: Text(
                        LocaleKeys.delete_diwaniya.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDiwaniyaDialog(BuildContext context) {
    final diwaniya = bloc.myDiwaniya ?? bloc.diwaniyaDetails;
    final diwaniyaId = diwaniya?.id;
    if (diwaniyaId == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.delete_diwaniya.tr()),
        content: Text(LocaleKeys.delete_diwaniya_confirmation.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocaleKeys.dismiss.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(DeleteDiwaniyaEvent(diwaniyaId: diwaniyaId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryRed),
            child: Text(LocaleKeys.delete.tr()),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.primaryWhite,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }
}
