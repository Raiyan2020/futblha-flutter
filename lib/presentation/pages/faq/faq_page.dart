import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/generated/locale_keys.g.dart';
// Import flutter_bloc
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_loading_widget.dart'; // Import for LoadingWidget
// Import FaqBloc and its related files
import 'bloc/faq_bloc.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
// Import FaqEntity

@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({super.key, required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final faqBloc = locator<FaqBloc>(); // Use FaqBloc
    return Scaffold(
      appBar: AppBar(title: CustomText(title), centerTitle: true),
      body: CustomBlocConsumer<FaqBloc, FaqState>(
        // Change to FaqBloc and FaqState
        bloc: faqBloc,
        onInitState: (bloc) {
          bloc.add(GetFaqsEvent()); // Dispatch GetFaqsEvent
        },
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FaqLoading) {
            return const LoadingWidget(); // Show loading indicator
          }
          if (state is FaqError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  CustomText(state.message), // Use state.message
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        faqBloc.add(GetFaqsEvent()), // Dispatch GetFaqsEvent
                    child: CustomText(
                      LocaleKeys.retry.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is FaqLoaded) {
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
                    ...state.faqs.map(
                      (e) => ExpansionTile(
                        title: CustomText(
                          e.question ?? '',
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(e.answer ?? '', maxLines: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink(); // Initial state or other unhandled states
        },
      ),
    );
  }
}
