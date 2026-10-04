import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/l10n.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/custom_elevated_button.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import 'package:futblha/data/models/request_model/auth/verify_otp_request_model.dart';
import 'package:futblha/application/config/app_assets.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../data/models/request_model/auth/login/login_request_model.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/custom_text.dart';
import 'bloc/authentication_bloc.dart';
import 'login_page.dart';

@RoutePage()
class PinCodeVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const PinCodeVerificationPage({super.key, required this.phoneNumber, required this.countryCode});

  @override
  State<PinCodeVerificationPage> createState() => _PinCodeVerificationPageState();
}

class _PinCodeVerificationPageState extends State<PinCodeVerificationPage> {
  TextEditingController textEditingController = TextEditingController();

  // ..text = "123456";
  final bloc = locator<AuthenticationBloc>();
  late StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  // Timer for resend OTP
  Timer? _resendTimer;
  int _resendCountdown = 30; // 30 seconds

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    _startResendTimer();
    super.initState();
  }

  @override
  void dispose() {
    errorController.close();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return CustomScaffold(
      key: scaffoldKey,
      hasPadding: false,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is VerifyOtpSuccess) {
            // Reset language from login response so app matches user preference
            final profileLanguage = bloc.user?.language;
            if (profileLanguage != null && (profileLanguage == 'ar' || profileLanguage == 'en')) {
              context.setLocale(profileLanguage == 'ar' ? L10n.langAr : L10n.langEn);
            }
            // Check if user has positions, if not navigate to complete profile page
            final userPositions = bloc.user?.positions;
            if (userPositions == null || userPositions.isEmpty) {
              context.router.pushAndPopUntil(const CompleteProfileRoute(), predicate: (_) => false);
            } else {
              context.router.pushAndPopUntil(const LandingRoute(), predicate: (_) => false);
            }
          } else if (state is LoginSuccess) {
            // Handle ResendOtpSuccess
            _startResendTimer(); // Restart timer when OTP is resent
            context.showMessage(
              LocaleKeys.otp_resend_success,
              position: MessagePosition.top,
            ); // Show success message
          } else if (state is AuthenticationError) {
            errorController.add(ErrorAnimationType.shake);
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
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 60.h),
                                CustomText(
                                  LocaleKeys.phone_number_verification,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),
                                CustomText(
                                  LocaleKeys.phone_number_verification_label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),
                                CustomText(
                                  '${widget.countryCode} ${widget.phoneNumber}',
                                  style: TextStyle(fontSize: 20, fontWeight: .bold),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                ),
                                SizedBox(height: 30.h),
                                // PIN Code field
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0.h,
                                      horizontal: 30.w,
                                    ),
                                    child: PinCodeTextField(
                                      appContext: context,
                                      pastedTextStyle: TextStyle(
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      length: 4,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly, // only 0-9 allowed
                                      ],
                                      obscureText: false,
                                      obscuringCharacter: '*',
                                      animationType: AnimationType.fade,
                                      validator: (v) {
                                        if (v != null && v.length < 4) {
                                          return "";
                                        } else {
                                          return null;
                                        }
                                      },
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        borderRadius: BorderRadius.circular(5),
                                        fieldHeight: 60.w,
                                        fieldWidth: 60.w,
                                        activeFillColor: hasError
                                            ? AppColors.textFieldColor
                                            : AppColors.textFieldColor,
                                        activeColor: AppColors.primaryColor,
                                        inactiveColor: AppColors.primaryColor,
                                        selectedColor: AppColors.textFieldColor,
                                        disabledColor: AppColors.textFieldColor,
                                        selectedFillColor: AppColors.textFieldColor,
                                        inactiveFillColor: AppColors.textFieldColor,
                                        errorBorderColor: AppColors.errorColor,
                                        borderWidth: 0,
                                        disabledBorderWidth: 0,
                                        selectedBorderWidth: 0,
                                        activeBorderWidth: 1,
                                        errorBorderWidth: 1,
                                        inactiveBorderWidth: 0,
                                        inActiveBoxShadow: const [
                                          BoxShadow(
                                            offset: Offset(0, 1),
                                            color: Colors.black12,
                                            blurRadius: 10,
                                          ),
                                        ],
                                        activeBoxShadow: const [
                                          BoxShadow(
                                            offset: Offset(0, 1),
                                            color: Colors.black12,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      cursorColor: AppColors.primaryColor,
                                      animationDuration: const Duration(milliseconds: 300),
                                      textStyle: const TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 20,
                                        height: 1.6,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      enableActiveFill: true,
                                      errorAnimationController: errorController,
                                      controller: textEditingController,
                                      keyboardType: TextInputType.number,
                                      boxShadows: const [
                                        BoxShadow(
                                          offset: Offset(0, 1),
                                          color: Colors.black12,
                                          blurRadius: 10,
                                        ),
                                      ],
                                      onCompleted: (v) {
                                        debugPrint("Completed");
                                      },
                                      onChanged: (value) {
                                        debugPrint(value);
                                        setState(() {
                                          currentText = value;
                                        });
                                      },
                                      beforeTextPaste: (text) {
                                        debugPrint("Allowing to paste $text");
                                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                        return true;
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                                  child: Text(
                                    hasError ? "" : "",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                // Continue button
                                state is VerifyOtpLoading
                                    ? const LoadingWidget()
                                    : CustomElevatedButton(
                                        onPressed: () {
                                          formKey.currentState?.validate();
                                          // conditions for validating
                                          if (currentText.length != 4) {
                                            errorController.add(
                                              ErrorAnimationType.shake,
                                            ); // Triggering error shake animation
                                            setState(() {
                                              hasError = true;
                                            });
                                          } else {
                                            setState(() {
                                              hasError = false;
                                            });
                                            // Dispatch VerifyOtpEvent
                                            bloc.add(
                                              VerifyOtpEvent(
                                                requestModel: VerifyOtpRequestModel(
                                                  phone: widget.phoneNumber,
                                                  activationCode: currentText,
                                                  countryCode: '+${widget.countryCode}',
                                                  // fcmDeviceId and buildVersion will be added in the BLoC
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        title: LocaleKeys.continue_button,
                                      ),
                                SizedBox(height: 14.h),
                                // Timer display
                                if (_resendCountdown > 0)
                                  CustomText(
                                    _formatTimer(_resendCountdown),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: .bold,
                                      color: AppColors.primaryColor,
                                    ),

                                    textAlign: TextAlign.center,
                                  ),
                                SizedBox(height: 14.h),
                                // Resend OTP link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      LocaleKeys.resend_otp_text,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    TextButton(
                                      onPressed: _resendCountdown > 0
                                          ? null
                                          : () {
                                              bloc.add(
                                                LoginEvent(
                                                  LoginRequestModel(
                                                    phone: widget.phoneNumber,
                                                    countryCode: '+${widget.countryCode}',
                                                  ),
                                                ),
                                              );
                                            },
                                      child: CustomText(
                                        LocaleKeys.resend_otp_button,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _resendCountdown > 0
                                              ? AppColors.lightTextColor
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
