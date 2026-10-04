import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/app_images/image_pick_crop_helper.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/data/models/request_model/diwaniya/create_diwaniya_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class CreateDiwaniyaPage extends StatefulWidget {
  const CreateDiwaniyaPage({super.key});

  @override
  State<CreateDiwaniyaPage> createState() => _CreateDiwaniyaPageState();
}

class _CreateDiwaniyaPageState extends State<CreateDiwaniyaPage> {
  final bloc = locator<DiwaniyaBloc>();
  File? _diwaniyaImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedType;

  @override
  void initState() {
    super.initState();
    bloc.add(GetDiwaniyaTypesEvent());
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

  void _onCreatePressed() {
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

    bloc.add(CreateDiwaniyaEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        } else if (state is DiwaniyaSuccess) {
          if (bloc.myDiwaniya != null) {
            context.showMessage(isError: false, LocaleKeys.diwaniya_created_successfully.tr());
            context.router.maybePop();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.create_diwaniya.tr())),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker Section
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryColor, width: 2),
                          color: AppColors.primaryLiteGrey,
                        ),
                        child: _diwaniyaImage != null
                            ? ClipOval(child: Image.file(_diwaniyaImage!, fit: BoxFit.cover))
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.landscape,
                                  color: AppColors.primaryWhite,
                                  size: 50,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryWhite, width: 3),
                            ),
                            child: Icon(Icons.add, color: AppColors.primaryWhite, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                32.heightBox(),
                // Name Field
                Text(LocaleKeys.name.tr()),
                6.heightBox(),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(LocaleKeys.enter_diwaniya_name.tr()),
                ),
                12.heightBox(),
                // Description Field
                Text(LocaleKeys.description.tr()),
                6.heightBox(),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration(LocaleKeys.write_description.tr()),
                ),
                12.heightBox(),
                // Diwaniya Type Field
                Text(LocaleKeys.diwaniya_type.tr()),
                6.heightBox(),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: _inputDecoration(LocaleKeys.select_type.tr()),
                  items: bloc.diwaniyaTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type.key,
                          child: Text(type.name ?? type.key ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedType = value);
                  },
                ),
                40.heightBox(),
                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: state is DiwaniyaLoading ? null : _onCreatePressed,
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
                            LocaleKeys.create.tr(),
                            style: const TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                20.heightBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }
}
