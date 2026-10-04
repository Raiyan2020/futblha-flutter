import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/data/models/response_model/general/banner_model.dart';
import 'package:futblha/application/core/utils/helpers/launch_url.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/id_encryption.dart';

import '../../../widgets/app_size_boxes.dart';
import '../../../widgets/custom_loading_widget.dart';

class HomeBannerWidget extends StatefulWidget {
  const HomeBannerWidget(this.generalBloc, {super.key});
  final GeneralBloc generalBloc;

  @override
  State<HomeBannerWidget> createState() => _HomeBannerWidgetState();
}

class _HomeBannerWidgetState extends State<HomeBannerWidget> {
  final PageController _pageController = PageController();
  late GeneralBloc generalBloc = widget.generalBloc;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  int? _lastBannerCount;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int bannerCount) {
    // Only auto-scroll if there's more than one banner
    if (bannerCount <= 1) {
      _autoScrollTimer?.cancel();
      _autoScrollTimer = null;
      return;
    }

    // Only restart timer if banner count changed
    if (_lastBannerCount == bannerCount && _autoScrollTimer != null) {
      return;
    }

    _lastBannerCount = bannerCount;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      final nextPage = (_currentPage + 1) % bannerCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _resetAutoScroll(int bannerCount) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _startAutoScroll(bannerCount);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GeneralBloc, GeneralState>(
      bloc: generalBloc,
      listener: (context, state) {},
      onInitState: (bloc) {
        // Home data is fetched by HomePage, no need to fetch here
      },
      builder: (context, state) {
        final banners = generalBloc.homeData?.banners ?? [];

        if (state is GeneralLoading && banners.isEmpty) {
          return SizedBox(
            height: 160.h,
            child: const LoadingWidget(),
          );
        }

        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        // Start auto-scroll when banners are available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAutoScroll(banners.length);
        });

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: 160.h,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  // Reset timer when user manually swipes
                  _resetAutoScroll(banners.length);
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return _buildBannerItem(banners[index]);
                },
              ),
            ),
            Padding(padding: const EdgeInsets.all(8.0), child: _buildPageIndicator(banners.length)),
          ],
        );
      },
    );
  }

  void _handleBannerTap(BannerModel banner) {
    if (banner.url == null || banner.url!.isEmpty) return;

    final link = banner.url!;
    final uri = Uri.tryParse(link);

    if (uri == null) {
      // If URI parsing fails, try to open as external URL anyway
      LaunchUrl.openUrl(link);
      return;
    }

    // Check if it's a deep link to futblha.com/diwaniya
    if (uri.host == 'futblha.com' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'diwaniya') {
      // Handle as deep link - navigate to diwaniya details
      if (uri.pathSegments.length > 1) {
        final encryptedDiwaniyaId = uri.pathSegments[1];
        try {
          final diwaniyaId = IdEncryption.decrypt(encryptedDiwaniyaId);
          // Navigate to diwaniya details page
          if (mounted) {
            context.router.push(DiwaniyaDetailsRoute(diwaniyaId: diwaniyaId.toString()));
          }
        } catch (e) {
          debugPrint('Failed to decrypt diwaniya ID from banner link: $e');
          // If decryption fails, try to open as external URL
          LaunchUrl.openUrl(link);
        }
      } else {
        // Invalid deep link format, open as external URL
        LaunchUrl.openUrl(link);
      }
    } else {
      // Open as external URL
      LaunchUrl.openUrl(link);
    }
  }

  Widget _buildBannerItem(BannerModel banner) {
    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primaryColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Full background image
              if (banner.image != null && banner.image!.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    banner.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.secondaryColor,
                        child: const Center(
                          child: Icon(Icons.image, color: AppColors.primaryColor),
                        ),
                      );
                    },
                  ),
                ),
              // Overlay with text
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: (MediaQuery.of(context).size.width * 0.5) - 20.w,
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.9)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (banner.title != null && banner.title!.isNotEmpty)
                        Text(
                          banner.title!,
                          textAlign: .center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (banner.description != null && banner.description!.isNotEmpty) ...[
                        8.heightBox(),
                        Text(
                          banner.description!,
                          textAlign: .center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int bannerCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        bannerCount,
        (index) => Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? AppColors.primaryColor : Colors.white.withOpacity(0.5),
            border: Border.all(
              color: _currentPage == index ? AppColors.primaryColor : AppColors.primaryColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
