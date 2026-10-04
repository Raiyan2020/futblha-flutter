import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/request_model/auth/login/login_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart';
import 'package:futblha/presentation/widgets/custom_elevated_button.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/custom_phone_field.dart';
import 'package:futblha/presentation/widgets/custom_scaffold.dart';
import 'package:futblha/presentation/widgets/custom_text.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import '../../../application/core/basecomponents/base_view_model_view.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final bloc = locator<AuthenticationBloc>();
  final number = TextEditingController();
  final numberWithoutCode = TextEditingController();
  String countryISOCode = 'KW';
  String countryCode = '965';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: CustomScaffold(
        hasPadding: false,
        body: CustomBlocConsumer<AuthenticationBloc, AuthenticationState>(
          bloc: bloc,
          listener: (context, state) {
            if (state is LoginSuccess) {
              context.router.replace(
                PinCodeVerificationRoute(
                  phoneNumber: numberWithoutCode.text,
                  countryCode: countryCode,
                ),
              );
            } else if (state is GuestLoginSuccess) {
              context.router.pushAndPopUntil(const LandingRoute(), predicate: (_) => false);
            } else if (state is AuthenticationError) {
              context.showMessage(isError: true, state.message);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAssets.auth_background),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Center(child: SvgPicture.asset(AppAssets.logo, height: 100.h)),
                          ),
                          SizedBox(height: 30.h),
                          CustomText(
                            'Welcome To FUTBLHA',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(430, 665),
                    painter: RPSCustomPainter(color: Theme.of(context).scaffoldBackgroundColor),
                    child: SizedBox(
                      height: screenHeight * 0.65,
                      child: InkWell(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 30.h),
                                CustomText(
                                  LocaleKeys.sign_in,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),
                                CustomText(
                                  LocaleKeys.sign_in_label,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 50.h),
                                CustomText(LocaleKeys.mobile_number.tr()),
                                SizedBox(height: 5.h),
                                CustomPhoneField(
                                  key: Key(countryISOCode),
                                  controller: numberWithoutCode,
                                  hintText: '00000000',
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
                                    if (phone?.completeNumber.isEmpty == true) {
                                      return LocaleKeys.required_field.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 15.h),
                                state is AuthLoading
                                    ? const LoadingWidget()
                                    : CustomElevatedButton(
                                        title: LocaleKeys.sign_in.tr(),
                                        onPressed: () {
                                          bloc.add(
                                            LoginEvent(
                                              LoginRequestModel(
                                                phone: numberWithoutCode.text,
                                                countryCode: '+$countryCode',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      LocaleKeys.dont_have_an_account,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.router.push(const RegisterRoute());
                                      },
                                      child: CustomText(
                                        LocaleKeys.create_account,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: CustomText(
                                        LocaleKeys.or,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      bloc.add(GuestLoginEvent());
                                    },
                                    child: CustomText(
                                      LocaleKeys.view_as_guest,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  final Color color;

  RPSCustomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(-10, 77.4719);
    path_0.cubicTo(-10, 77.4719, 135.895, 12.0001, 217, 12);
    path_0.cubicTo(298.105, 11.9999, 440, 77.4719, 440, 77.4719);
    path_0.lineTo(440, 684);
    path_0.lineTo(-10, 684);
    path_0.lineTo(-10, 77.4719);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xffF6FDFB).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(217, 13.5);
    path_1.cubicTo(257.265, 13.4999, 312.794, 29.7791, 358.407, 46.1475);
    path_1.cubicTo(381.181, 54.3201, 401.427, 62.4936, 415.979, 68.624);
    path_1.cubicTo(423.255, 71.689, 429.106, 74.2434, 433.137, 76.0303);
    path_1.cubicTo(435.152, 76.9236, 436.712, 77.6255, 437.768, 78.1035);
    path_1.cubicTo(438.047, 78.2302, 438.292, 78.3409, 438.5, 78.4355);
    path_1.lineTo(438.5, 682.5);
    path_1.lineTo(-8.5, 682.5);
    path_1.lineTo(-8.5, 78.4463);
    path_1.cubicTo(-8.28401, 78.3506, -8.02946, 78.2381, -7.7373, 78.1094);
    path_1.cubicTo(-6.65226, 77.6313, -5.04859, 76.9296, -2.97852, 76.0361);
    path_1.cubicTo(1.1619, 74.249, 7.16969, 71.695, 14.6328, 68.6299);
    path_1.cubicTo(29.5606, 62.499, 50.3077, 54.3246, 73.583, 46.1514);
    path_1.cubicTo(120.2, 29.7817, 176.731, 13.5001, 217, 13.5);
    path_1.close();

    Paint paint_1_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015;
    paint_1_stroke.color = AppColors.primaryColor;
    canvas.drawPath(path_1, paint_1_stroke);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = color;
    canvas.drawPath(path_1, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
