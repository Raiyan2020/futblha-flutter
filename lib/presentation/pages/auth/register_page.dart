import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/application/core/validations/validations.dart';
import 'package:futblha/data/models/request_model/auth/login/login_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart';
import 'package:futblha/presentation/widgets/app_text_field.dart';
import 'package:futblha/presentation/widgets/custom_elevated_button.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/custom_phone_field.dart';
import 'package:futblha/presentation/widgets/custom_scaffold.dart';
import 'package:futblha/presentation/widgets/custom_text.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import 'login_page.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bloc = locator<AuthenticationBloc>();
  final validator = AppValidator();
  final formState = GlobalKey<FormState>();
  final name = TextEditingController();
  final birthDate = TextEditingController();
  final number = TextEditingController();
  final numberWithoutCode = TextEditingController();
  String countryISOCode = 'KW';
  String countryCode = '965';
  bool agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return CustomScaffold(
      hasPadding: false,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.router.replace(const LoginRoute());
          } else if (state is AuthenticationError) {
            context.showMessage(isError: true, state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Top section with background and logo
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.auth_background),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Center(
                      child: Hero(
                        tag: 'logo',
                        child: SvgPicture.asset(AppAssets.logo, height: 100.h),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom section with form
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(430, 665),
                  painter: RPSCustomPainter(color: Theme.of(context).scaffoldBackgroundColor),
                  child: SizedBox(
                    height: screenHeight * 0.75,
                    child: InkWell(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: Form(
                            key: formState,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 45.h),
                                CustomText(
                                  LocaleKeys.create_account,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),
                                CustomText(
                                  LocaleKeys.sign_up_label,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 30.h),
                                // Name field
                                AppTextField(
                                  controller: name,
                                  labelKey: LocaleKeys.username,
                                  hintKey: LocaleKeys.username_hint,
                                  validator: validator.validatorRequired,
                                ),
                                SizedBox(height: 10.h),
                                // Birth Date field
                                CustomText(LocaleKeys.date_of_birth.tr()),
                                SizedBox(height: 5.h),
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AppTextField(
                                    controller: birthDate,
                                    hintKey: LocaleKeys.date_hint,
                                    userInput: false,
                                    validator: validator.validatorRequired,
                                    suffixIcon: IconButton(
                                      icon: SvgPicture.asset(AppAssets.ic_calender),
                                      onPressed: () => _selectDate(context),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                // Phone Number field
                                CustomText(LocaleKeys.mobile_number.tr()),
                                SizedBox(height: 5.h),
                                CustomPhoneField(
                                  key: Key(countryISOCode),
                                  controller: numberWithoutCode,
                                  hintText: '000 000 00',
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
                                // Terms & Conditions checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: agreeToTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          agreeToTerms = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.primaryColor,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            agreeToTerms = !agreeToTerms;
                                          });
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${LocaleKeys.agree.tr()} ',
                                                style: Theme.of(context).textTheme.titleLarge,
                                              ),
                                              TextSpan(
                                                text: LocaleKeys.terms_and_conditions.tr(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                // Create Account button
                                state is RegisterLoading
                                    ? const LoadingWidget()
                                    : CustomElevatedButton(
                                        title: LocaleKeys.create_account,
                                        onPressed: () {
                                          if (!agreeToTerms) {
                                            context.showMessage(
                                              isError: true,
                                              LocaleKeys.please_agree_to_terms.tr(),
                                            );
                                            return;
                                          }
                                          if (formState.currentState!.validate()) {
                                            bloc.add(
                                              RegisterEvent(
                                                LoginRequestModel(
                                                  name: name.text,
                                                  birthdate: birthDate.text,
                                                  phone: numberWithoutCode.text,
                                                  countryCode: '+$countryCode',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                SizedBox(height: 5.h),
                                // Login link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      LocaleKeys.already_have_account,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.router.back();
                                      },
                                      child: CustomText(
                                        LocaleKeys.sign_in,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ], // Closes Column children list
                            ), // Closes Column
                          ), // Closes Form
                        ), // Closes Padding
                      ), // Closes SingleChildScrollView
                    ), // Closes Column
                  ),
                ), // Closes Container
              ), // Closes Positioned
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        birthDate.text = DateFormat('yyyy-MM-dd', 'en').format(picked);
      });
    }
  }
}
