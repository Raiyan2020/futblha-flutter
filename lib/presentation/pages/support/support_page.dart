import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/application/core/utils/helpers/launch_url.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/validations/validations.dart';
import '../../../data/models/request_model/contact/contact_model.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_loading_widget.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toolbar.dart';
import '../../widgets/scaffold_pading.dart';
import 'bloc/contact_bloc.dart';
import '../../pages/settings/bloc/settings_bloc.dart';
import '../../../domain/entities/settings_entity.dart';

@RoutePage()
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final contactBloc = locator<ContactBloc>();
  final settingsBloc = locator<SettingsBloc>();
  final validator = AppValidator();
  final formState = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final message = TextEditingController();

  SettingsEntity? _settingsEntity; // To store fetched settings

  @override
  void initState() {
    super.initState();
    settingsBloc.add(GetSettingsEvent()); // Dispatch event to fetch settings
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: LocaleKeys.contact_us.tr()),
      hasPadding: false,
      body: Padding(
        padding: symmetricPadding(0, 20),
        child: SingleChildScrollView(
          child: MultiBlocListener(
            // Use MultiBlocListener to listen to multiple blocs
            listeners: [
              BlocListener<ContactBloc, ContactState>(
                bloc: contactBloc,
                listener: (context, state) {
                  if (state is ContactSuccess) {
                    Navigator.pop(context);
                    context.showMessage(state.message);
                  } else if (state is ContactError) {
                    context.showMessage(isError: true, state.errorResultModel.message ?? '');
                  }
                },
              ),
              BlocListener<SettingsBloc, SettingsState>(
                bloc: settingsBloc,
                listener: (context, state) {
                  if (state is SettingsLoaded) {
                    setState(() {
                      _settingsEntity = state.settings; // Update state with fetched settings
                    });
                  } else if (state is SettingsError) {
                    // Handle settings error, maybe show a snackbar
                    context.showMessage(isError: true, state.message);
                  }
                },
              ),
            ],
            child: BlocBuilder<ContactBloc, ContactState>(
              // Keep ContactBloc for form submission
              bloc: contactBloc,
              builder: (context, state) {
                return Form(
                  key: formState,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo removed based on design
                      // Introductory Text
                      Padding(
                        padding: symmetricPadding(20, 20),
                        child: Column(
                          children: [
                            CustomText(
                              LocaleKeys.if_you_have_any_questions,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            4.heightBox(),
                            CustomText(
                              LocaleKeys.do_not_hesitate_to_contact,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      20.heightBox(),
                      // Name Field
                      AppTextField(
                        controller: name,
                        labelKey: LocaleKeys.name,
                        hintKey: LocaleKeys.enter_name,
                        validator: validator.validatorRequired,
                      ),
                      // Email Field
                      AppTextField(
                        controller: email,
                        labelKey: LocaleKeys.email_address,
                        hintKey: LocaleKeys.enter_your_email_address,
                        textInputType: TextInputType.emailAddress,
                        validator: validator.validatorEmail,
                      ),
                      // Message Field
                      AppTextField(
                        controller: message,
                        labelKey: LocaleKeys.message_reason_of_contact,
                        hintKey: LocaleKeys.write_your_message_here,
                        validator: validator.validatorRequired,
                        maxLines: 5,
                      ),
                      20.heightBox(),
                      // Send Button
                      state is ContactLoading
                          ? const LoadingWidget()
                          : CustomElevatedButton(
                              title: LocaleKeys.send,
                              onPressed: () {
                                if (formState.currentState!.validate()) {
                                  contactBloc.add(
                                    ContactSendEvent(
                                      ContactModel(
                                        name: name.text,
                                        email: email
                                            .text, // Using email as phone for backend compatibility
                                        message: message.text,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                      24.heightBox(),
                      // OR Separator
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.borderGrey, thickness: 1)),
                          12.widthBox(),
                          CustomText(
                            LocaleKeys.contact_us_label_2,
                            style: TextStyle(
                              color: AppColors.lightTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          12.widthBox(),
                          Expanded(child: Divider(color: AppColors.borderGrey, thickness: 1)),
                        ],
                      ),
                      24.heightBox(),
                      // Contact Methods
                      if (_settingsEntity != null)
                        Column(
                          children: [
                            // Email Contact Box
                            _buildContactBox(
                              icon: Icons.email_outlined,
                              text: _settingsEntity?.email ?? 'Trendhair@info.com',
                              onTap: () {
                                final email = _settingsEntity?.email ?? 'Trendhair@info.com';
                                launchUrl(Uri.parse('mailto:$email'));
                              },
                            ),
                            12.heightBox(),
                            // Phone Contact Box
                            _buildContactBox(
                              icon: Icons.phone_outlined,
                              text: _settingsEntity?.phone ?? '965 5464 7655',
                              onTap: () {
                                final phone =
                                    _settingsEntity?.phone?.replaceAll(' ', '') ?? '96554647655';
                                launchUrl(Uri.parse('tel:$phone'));
                              },
                            ),
                            24.heightBox(),
                          ],
                        ),
                      // Social Media Links
                      if (_settingsEntity != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialMediaButton(
                              url: _settingsEntity?.twitter,
                              assetPath: AppAssets.twitter,
                              color: AppColors.primaryBlack,
                              borderRadius: 25,
                            ),
                            16.widthBox(),
                            SocialMediaButton(
                              url: _settingsEntity?.instagram,
                              assetPath: AppAssets.instagram,
                              color: Colors.transparent,
                              borderRadius: 25,
                              gradient: true,
                            ),
                            16.widthBox(),
                            SocialMediaButton(
                              url: _settingsEntity?.tiktok,
                              assetPath: AppAssets.tiktok,
                              color: AppColors.primaryBlack,
                              borderRadius: 25,
                            ),
                          ],
                        ),
                      20.heightBox(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactBox({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            12.widthBox(),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialMediaButton extends StatelessWidget {
  final String? url;
  final String assetPath;
  final Color color;
  final double size;
  final EdgeInsets padding;
  final double borderRadius;
  final bool gradient;

  const SocialMediaButton({
    super.key,
    required this.url,
    required this.assetPath,
    this.color = const Color(0xFF000000),
    this.size = 50.0,
    this.padding = const EdgeInsets.all(10.0),
    this.borderRadius = 10.0,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        LaunchUrl.openUrl(url);
      },
      child: Container(
        height: size,
        width: size,
        padding: padding,
        decoration: BoxDecoration(
          color: gradient ? null : color,
          gradient: gradient
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFC93C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: SvgPicture.asset(
          assetPath,
          colorFilter: gradient ? null : const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
