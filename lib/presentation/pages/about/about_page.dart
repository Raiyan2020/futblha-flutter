import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/custom_loading_widget.dart';
import '../../widgets/custom_text.dart';
// Import SettingsBloc and its related files
import '../../pages/settings/bloc/settings_bloc.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
// Import SettingsEntity

/// A page that displays about information with a title and content
@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.title,
    required this.content, // This content will be ignored, as we fetch from API
  });

  final String title;
  final String content; // This content will be ignored, as we fetch from API

  @override
  Widget build(BuildContext context) {
    final settingsBloc = locator<SettingsBloc>(); // Use SettingsBloc

    return Scaffold(
      appBar: AppBar(title: CustomText(title), centerTitle: true),
      body: CustomBlocConsumer<SettingsBloc, SettingsState>(
        // Change to SettingsBloc and SettingsState
        bloc: settingsBloc, // Use settingsBloc
        onInitState: (bloc) => bloc.add(GetSettingsEvent()), // Dispatch GetSettingsEvent
        listener: (context, state) {
          // Handle any specific listeners if needed
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const LoadingWidget();
          }
          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('${LocaleKeys.error.tr()} ${state.message}'), // Use state.message
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        settingsBloc.add(GetSettingsEvent()), // Dispatch GetSettingsEvent
                    child: Text(LocaleKeys.retry.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is SettingsLoaded) {
            // Check if this is the "About Fatbelha" page
            if (title == LocaleKeys.about_us || title == LocaleKeys.about_fatbelha.tr()) {
              return AboutFatbelhaContent(aboutUs: state.settings.aboutUs);
            }

            String displayedContent = '';
            if (title == LocaleKeys.terms_and_conditions) {
              // Assuming title matches
              displayedContent = state.settings.terms ?? '';
            } else if (title == LocaleKeys.privacy_policy) {
              // Assuming title matches
              displayedContent = state.settings.privacyPolicy ?? '';
            } else {
              displayedContent = 'Content not found for this title.';
            }
            return AboutContent(content: displayedContent);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// A widget that displays the about content in a styled container
class AboutContent extends StatelessWidget {
  const AboutContent({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Html(
              data: content,
              style: {
                "body": Style(
                  textAlign: TextAlign.justify,
                  fontSize: FontSize(Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16),
                  color: context.textPrimary,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the "About Fatbelha" page with logo and formatted content
class AboutFatbelhaContent extends StatelessWidget {
  const AboutFatbelhaContent({super.key, this.aboutUs});

  final String? aboutUs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo and Brand Name
          SvgPicture.asset(
            Theme.of(context).brightness == Brightness.dark
                ? AppAssets.white_logo
                : AppAssets.home_logo,
            width: 50.w,
            height: 50.h,
          ),
          30.heightBox(),
          // Content Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: aboutUs != null && aboutUs!.isNotEmpty
                ? Html(
                    data: aboutUs!,
                    style: {
                      "body": Style(
                        color: context.textPrimary,
                        fontSize: FontSize(14),
                        fontWeight: FontWeight.w400,
                        lineHeight: LineHeight(1.5),
                        textAlign: TextAlign.justify,
                      ),
                    },
                  )
                : const Text(
                    'Content not available',
                    style: TextStyle(
                      color: AppColors.lightTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
