import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/presentation/widgets/app_date_picker.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_phone_field.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/helpers/app_images/image_pick_crop_helper.dart';
import '../../../application/core/validations/validations.dart';
import '../../../data/models/enums/position_enum.dart';
import '../../../data/models/request_model/auth/login/login_request_model.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_loading_widget.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toolbar.dart';
import '../auth/bloc/authentication_bloc.dart';
import 'widgets/profile_image_button.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final bloc = locator<AuthenticationBloc>();
  final validator = AppValidator();
  final formState = GlobalKey<FormState>();
  final name = TextEditingController();
  final number = TextEditingController();
  final numberWithoutCode = TextEditingController();
  final email = TextEditingController();
  final birthDate = TextEditingController();
  final positions = TextEditingController();
  String countryISOCode = 'KW';
  String countryCode = '965';
  File? _image;
  List<String> _selectedPositions = [];
  bool _isJocker = false;

  @override
  void initState() {
    super.initState();
    name.text = bloc.user?.name ?? '';
    number.text = bloc.user?.phone ?? '';
    final userCountryCode = bloc.user?.country_code;
    if (userCountryCode != null && userCountryCode.isNotEmpty) {
      countryCode = userCountryCode.replaceAll('+', '');
      try {
        countryISOCode = countries
            .firstWhere((element) => element.dialCode == countryCode)
            .code;
      } catch (e) {
        // country not found, fallback to KW
        countryISOCode = 'KW';
        countryCode = '965';
      }
    }
    numberWithoutCode.text =
        bloc.user?.phone?.replaceFirst(userCountryCode ?? '', '') ?? '';
    email.text = bloc.user?.email ?? '';

    // Initialize birth date from user data if available
    if (bloc.user?.birthdate != null && bloc.user!.birthdate!.isNotEmpty) {
      try {
        // Try to parse the birthdate and format it
        // API might return it in different formats (e.g., "1995-06-11" or "11 June 1995")
        final dateStr = bloc.user!.birthdate!;
        // Check if it's in ISO format (YYYY-MM-DD)
        if (dateStr.contains('-') && dateStr.length >= 10) {
          final date = DateTime.parse(dateStr.substring(0, 10));
          birthDate.text = DateFormat('dd MMMM yyyy', 'en').format(date);
        } else {
          // Use as is if already formatted
          birthDate.text = dateStr;
        }
      } catch (e) {
        // If parsing fails, use the raw string
        birthDate.text = bloc.user!.birthdate!;
      }
    } else {
      birthDate.text = '';
    }

    // Initialize positions from user data if available
    if (bloc.user?.positions != null && bloc.user!.positions!.isNotEmpty) {
      _selectedPositions = List<String>.from(bloc.user!.positions!);
      _isJocker = _selectedPositions.contains(
        Position.jocker.key,
      ); // If positions exist, user is not a jocker
    } else {
      _selectedPositions = [];
      _isJocker = false;
    }
    positions.text = _getPositionsDisplayText();
  }

  @override
  void dispose() {
    name.dispose();
    number.dispose();
    numberWithoutCode.dispose();
    email.dispose();
    birthDate.dispose();
    positions.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final DateTime? picked = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.primaryWhite,
              surface: context.cardBackground,
              onSurface: context.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        birthDate.text = DateFormat('dd MMMM yyyy', 'en').format(picked);
      });
    }
  }

  Future<void> _navigateToEditPositions() async {
    final result = await context.router.push(
      EditPositionsRoute(
        initialPositions: _selectedPositions,
        initialIsJocker: _isJocker,
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        _selectedPositions = List<String>.from(result['positions'] ?? []);
        _isJocker = result['isJocker'] ?? false;
        positions.text = _getPositionsDisplayText();
      });
    }
  }

  String _getPositionsDisplayText() {
    if (_isJocker) {
      return Position.jocker.displayName;
    }
    if (_selectedPositions.isEmpty) {
      return LocaleKeys.select_skilled_position.tr();
    }
    return Position.fromKeys(
      _selectedPositions,
    ).map((po) => po.displayName).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      hasPadding: true,
      appBar: const CustomAppBar(title: LocaleKeys.profile, actions: []),
      body: CustomBlocConsumer<AuthenticationBloc, AuthenticationState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is UpdateProfileSuccess) {
            Navigator.pop(context);
            context.showMessage(
              LocaleKeys.edit_personal_details_success_message.tr(),
            );
          } else if (state is AuthenticationError) {
            context.showMessage(isError: true, state.message);
          }
        },
        builder: (context, state) {
          if (state is GetProfileLoading) {
            return const LoadingWidget();
          }
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(_image!),
                              )
                            : const ProfileImageButton(clickable: false),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () async {
                              try {
                                final file =
                                    await ImagePickCropHelper.pickAndCropImage(
                                      context,
                                      shape: ImageCropShape.circle,
                                      lockSquareAspectRatio: true,
                                      maxWidth: 1080,
                                      maxHeight: 1080,
                                      toolbarTitle: 'Crop',
                                    );
                                if (file != null) {
                                  setState(() => _image = file);
                                }
                              } catch (e) {
                                // Handle error if needed
                                if (kDebugMode) {
                                  debugPrint('Error picking photo: $e');
                                }
                              }
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              color: context.brandOnSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  30.heightBox(),
                  AppTextField(
                    controller: name,
                    labelKey: LocaleKeys.username,
                    validator: validator.validatorRequired,
                  ),
                  5.heightBox(),
                  // Phone Field
                  const CustomText(LocaleKeys.mobile_number),
                  5.heightBox(),
                  CustomPhoneField(
                    key: Key(countryISOCode),
                    controller: numberWithoutCode,
                    initialCountryCode: countryISOCode,
                    onChanged: (PhoneNumber phone) {
                      number.text = phone.completeNumber;
                    },
                    onCountryChanged: (Country country) {
                      setState(() {
                        countryISOCode = country.code;
                        countryCode = country.dialCode;
                      });
                    },
                    validator: (PhoneNumber? phone) {
                      if (phone?.number.isEmpty == true || phone == null) {
                        return LocaleKeys.required_field.tr();
                      }
                      return null;
                    },
                  ),
                  // 10.heightBox(),
                  // E-mail Address (optional)
                  CustomText(
                    '${LocaleKeys.email_address.tr()}${LocaleKeys.optional.tr()}',
                  ),
                  5.heightBox(),
                  AppTextField(
                    controller: email,
                    hintKey: LocaleKeys.enter_your_email_address,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) return null;
                      return validator.validatorEmail(value.trim());
                    },
                  ),
                  4.heightBox(),
                  // Birth Date Field
                  CustomText(LocaleKeys.date_of_birth.tr()),
                  5.heightBox(),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AppTextField(
                      controller: birthDate,
                      hintKey: LocaleKeys.date_hint,
                      userInput: false,
                      suffixIcon: IconButton(
                        icon: SvgPicture.asset(AppAssets.ic_calender),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                  5.heightBox(),
                  // Positions Field
                  CustomText(LocaleKeys.positions),
                  5.heightBox(),
                  GestureDetector(
                    onTap: _navigateToEditPositions,
                    child: AppTextField(
                      controller: positions,
                      hintKey: LocaleKeys.select_skilled_position,
                      userInput: false,
                      suffixIcon: Icon(
                        Icons.edit,
                        color: context.brandOnSurface,
                      ),
                    ),
                  ),
                  20.heightBox(),
                  state is UpdateProfileLoading
                      ? const LoadingWidget()
                      : CustomElevatedButton(
                          title: LocaleKeys.save_button,
                          onPressed: () {
                            if (formState.currentState!.validate()) {
                              // Format birthdate for API (expects format like "1998-3-08" or "1998-11-29")
                              String? formattedBirthdate;
                              if (birthDate.text.isNotEmpty) {
                                try {
                                  // Parse the displayed date and format it for API
                                  final parsedDate = DateFormat(
                                    'dd MMMM yyyy',
                                    'en',
                                  ).parse(birthDate.text);
                                  formattedBirthdate =
                                      '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}';
                                } catch (e) {
                                  // If parsing fails, try to use as is or parse ISO format
                                  if (birthDate.text.contains('-')) {
                                    formattedBirthdate = birthDate.text;
                                  }
                                }
                              }

                              bloc.add(
                                UpdateProfileEvent(
                                  requestModel: LoginRequestModel(
                                    name: name.text,
                                    phone: numberWithoutCode.text,
                                    countryCode: '+$countryCode',
                                    email: email.text.trim().isEmpty
                                        ? null
                                        : email.text.trim(),
                                  ),
                                  image: _image,
                                  positions: _selectedPositions.isNotEmpty
                                      ? _selectedPositions
                                      : null,
                                  birthdate: formattedBirthdate,
                                ),
                              );
                            }
                          },
                        ),
                  10.heightBox(),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(LocaleKeys.delete_account.tr()),
                            content: Text(
                              LocaleKeys.delete_account_confirmation.tr(),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  LocaleKeys.cancel.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  LocaleKeys.delete.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  bloc.add(const LogoutEvent(apiRequest: true));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete, color: AppColors.primaryRed),
                    label: Text(
                      LocaleKeys.delete_account.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),

                  10.heightBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
