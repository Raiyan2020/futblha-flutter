import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/widgets/login_required_dialog.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/launch_url.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';

import '../../../application/core/utils/helpers/cache/cache_manager.dart';

@RoutePage()
class PlaygroundDetailsPage extends StatefulWidget {
  final PlaygroundModel playground;

  const PlaygroundDetailsPage({super.key, required this.playground});

  @override
  State<PlaygroundDetailsPage> createState() => _PlaygroundDetailsPageState();
}

class _PlaygroundDetailsPageState extends State<PlaygroundDetailsPage> {
  final bloc = locator<PlaygroundsBloc>();
  DateTime? _selectedDate;
  // int? _selectedRating;
  bool _isSubmittingRating = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Extract ID from playground name or use a default - you may need to pass ID differently
    // For now, we'll fetch details when date is selected
    _selectedDate = DateTime.now();
    _loadPlaygroundDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadPlaygroundDetails() {
    if (_selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      // Use playground ID directly from the model
      final playgroundId = _findPlaygroundId();
      if (playgroundId != null) {
        bloc.add(GetPlaygroundDetailsEvent(playgroundId: playgroundId, date: dateStr));
      }
    }
  }

  int? _findPlaygroundId() {
    // Use playground ID directly from the model
    return widget.playground.id;
  }

  // Future<void> _selectDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //     _loadPlaygroundDetails();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is PlaygroundsError) {
            context.showMessage(isError: true, state.message);
          } else if (state is PlaygroundsSuccess && _isSubmittingRating) {
            context.showMessage(isError: false, LocaleKeys.rating_submitted_successfully.tr());
            setState(() {
              // _selectedRating = null;
              _isSubmittingRating = false;
            });
            // Close bottom sheet if still open
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          final details = bloc.playgroundDetails;
          final playground = details?.playground;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Carousel
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildImageCarousel(playground),
                    ),
                    // Carousel Indicators
                    _buildCarouselIndicators(playground),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      10.heightBox(),
                      // Title and Price
                      Text(
                        playground?.name ?? widget.playground.name ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      8.heightBox(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${playground?.price ?? widget.playground.price ?? '0'} ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: context.brandOnSurface,
                              ),
                            ),
                            TextSpan(
                              text: LocaleKeys.kwd_hour.tr(),
                              style: const TextStyle(
                                color: AppColors.lightTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      20.heightBox(),
                      // // Date Selection
                      // GestureDetector(
                      //   onTap: _selectDate,
                      //   child: Container(
                      //     padding: EdgeInsets.all(12.w),
                      //     decoration: BoxDecoration(
                      //       color: AppColors.secondaryColor,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         const Icon(
                      //           Icons.calendar_today,
                      //           color: AppColors.primaryColor,
                      //           size: 20,
                      //         ),
                      //         12.widthBox(),
                      //         Text(
                      //           _selectedDate != null
                      //               ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                      //               : LocaleKeys.select_date.tr(),
                      //           style: const TextStyle(
                      //             color: AppColors.primaryDark,
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // 12.heightBox(),
                      // Location Button
                      GestureDetector(
                        onTap: _openGoogleMaps,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: context.chipBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: context.brandOnSurface,
                                size: 20,
                              ),
                              12.widthBox(),
                              Expanded(
                                child: Text(
                                  playground?.city ?? widget.playground.city ?? '',
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                LocaleKeys.get_directions.tr(),
                                style: TextStyle(
                                  color: context.brandOnSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              4.widthBox(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: context.brandOnSurface,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                      12.heightBox(),
                      // Ground Type Button
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: context.chipBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.grid_view, color: context.brandOnSurface, size: 20),
                            12.widthBox(),
                            Text(
                              playground != null
                                  ? '${playground.landType ?? ''} - ${playground.capacity ?? ''}'
                                  : '${widget.playground.landType ?? ''} - ${widget.playground.capacity ?? ''}',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      24.heightBox(),
                      // Facilities Section
                      Text(
                        LocaleKeys.facilities.tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      12.heightBox(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          border: Border.all(color: AppColors.primaryGrey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: state is PlaygroundsLoading
                            ? const LoadingWidget()
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.w,
                                  mainAxisSpacing: 1.h,
                                  childAspectRatio: 5,
                                ),
                                itemCount:
                                    playground?.facilities?.length ??
                                    widget.playground.facilities?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  final facility =
                                      playground?.facilities?[index] ??
                                      widget.playground.facilities?[index];
                                  return Row(
                                    children: [
                                      if (facility?.image != null && facility!.image!.isNotEmpty)
                                        Image.network(
                                          facility.image!,
                                          width: 18,
                                          height: 18,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.check_circle,
                                              color: context.brandOnSurface,
                                              size: 18,
                                            );
                                          },
                                        )
                                      else
                                        Icon(
                                          Icons.check_circle,
                                          color: context.brandOnSurface,
                                          size: 18,
                                        ),
                                      8.widthBox(),
                                      Expanded(
                                        child: Text(
                                          facility?.name ?? '',
                                          style: TextStyle(
                                            color: context.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      24.heightBox(),
                      // // Rating Section
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       LocaleKeys.rate_this_playground.tr(),
                      //       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      //     ),
                      //     TextButton(
                      //       onPressed: () {
                      //         if (CacheManager.instance.isGuestMode()) {
                      //           LoginRequiredDialog.show(context);
                      //           return;
                      //         }
                      //         _showRatingBottomSheet();
                      //       },
                      //       child: Text(
                      //         LocaleKeys.add_rating.tr(),
                      //         style: const TextStyle(
                      //           color: AppColors.primaryColor,
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // if (_selectedRating != null) ...[
                      //   8.heightBox(),
                      //   Row(
                      //     children: [
                      //       _buildRatingStars(_selectedRating!),
                      //       8.widthBox(),
                      //       Text(
                      //         '$_selectedRating/5',
                      //         style: const TextStyle(
                      //           color: AppColors.primaryDark,
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                      // 24.heightBox(),
                      // Description Section
                      if (playground?.description != null &&
                          widget.playground.description != '') ...[
                        Text(
                          LocaleKeys.description.tr(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        12.heightBox(),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: context.cardBackground,
                            border: Border.all(color: AppColors.primaryGrey),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            playground?.description ??
                                widget.playground.description ??
                                LocaleKeys.no_description_available.tr(),
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      32.heightBox(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlack.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (CacheManager.instance.isGuestMode()) {
                // Show login required dialog
                LoginRequiredDialog.show(context);
                return;
              }
              context.router.push(BookPlaygroundRoute(playground: widget.playground));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              LocaleKeys.book.tr(),
              style: const TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(PlaygroundModel? playground) {
    final currentPlayground = playground ?? widget.playground;
    final images = currentPlayground.images ?? [];
    final mainImage = currentPlayground.image;

    // Combine main image with additional images
    final allImages = <String>[];
    if (mainImage != null && mainImage.isNotEmpty) {
      allImages.add(mainImage);
    }
    if (images.isNotEmpty) {
      for (final imageModel in images) {
        final imageUrl = imageModel.url;
        if (imageUrl != null && imageUrl.isNotEmpty && !allImages.contains(imageUrl)) {
          allImages.add(imageUrl);
        }
      }
    }

    if (allImages.isEmpty) {
      return Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.mutedBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.image, color: context.brandOnSurface, size: 60),
      );
    }

    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.mutedBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: allImages.length == 1
            ? Image.network(
                allImages[0],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: context.mutedBackground,
                    child: Icon(Icons.image, color: context.brandOnSurface, size: 60),
                  );
                },
              )
            : PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    allImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: context.mutedBackground,
                        child: Icon(Icons.image, color: context.brandOnSurface, size: 60),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCarouselIndicators(PlaygroundModel? playground) {
    final currentPlayground = playground ?? widget.playground;
    final images = currentPlayground.images ?? [];
    final mainImage = currentPlayground.image;

    // Count total images
    final allImages = <String>[];
    if (mainImage != null && mainImage.isNotEmpty) {
      allImages.add(mainImage);
    }
    if (images.isNotEmpty) {
      for (final imageModel in images) {
        final imageUrl = imageModel.url;
        if (imageUrl != null && imageUrl.isNotEmpty && !allImages.contains(imageUrl)) {
          allImages.add(imageUrl);
        }
      }
    }

    if (allImages.length <= 1) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            allImages.length,
            (index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentImageIndex
                      ? AppColors.primaryColor
                      : AppColors.primaryGrey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildRatingStars(int rating) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: List.generate(
  //       5,
  //       (index) => Icon(
  //         index < rating ? Icons.star : Icons.star_border,
  //         size: 20,
  //         color: index < rating ? AppColors.primaryYellow : AppColors.primaryGrey,
  //       ),
  //     ),
  //   );
  // }

  Future<void> _openGoogleMaps() async {
    // Get playground from bloc details or use widget playground
    final currentPlayground = bloc.playgroundDetails?.playground ?? widget.playground;
    final latStr = currentPlayground.lat;
    final lngStr = currentPlayground.lng;

    if (latStr == null || lngStr == null || latStr.isEmpty || lngStr.isEmpty) {
      context.showMessage(isError: true, LocaleKeys.location_coordinates_not_available.tr());
      return;
    }

    try {
      final lat = double.tryParse(latStr);
      final lng = double.tryParse(lngStr);

      if (lat == null || lng == null) {
        context.showMessage(isError: true, LocaleKeys.invalid_location_coordinates.tr());
        return;
      }

      // Try to open Google Maps app first, fallback to web
      final success = await LaunchUrl.openMap(lat: lat, lng: lng);
      if (!success) {
        context.showMessage(isError: true, LocaleKeys.could_not_open_google_maps.tr());
      }
    } catch (e) {
      context.showMessage(
        isError: true,
        '${LocaleKeys.could_not_open_google_maps.tr()}: ${e.toString()}',
      );
    }
  }

  // void _showRatingBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => _RatingBottomSheet(
  //       bloc: bloc,
  //       initialRating: _selectedRating,
  //       initialIsSubmitting: _isSubmittingRating,
  //       onRatingChanged: (rating) {
  //         setState(() {
  //           _selectedRating = rating;
  //         });
  //       },
  //       onSubmissionStateChanged: (isSubmitting) {
  //         setState(() {
  //           _isSubmittingRating = isSubmitting;
  //         });
  //       },
  //       onSubmit: () {
  //         final playgroundId = _findPlaygroundId();
  //         if (playgroundId != null && _selectedRating != null) {
  //           setState(() {
  //             _isSubmittingRating = true;
  //           });
  //           bloc.add(AddRateEvent(playgroundId: playgroundId, rate: _selectedRating!));
  //         }
  //       },
  //     ),
  //   );
  // }
}

class _RatingBottomSheet extends StatefulWidget {
  final PlaygroundsBloc bloc;
  final int? initialRating;
  final bool initialIsSubmitting;
  final ValueChanged<int> onRatingChanged;
  final ValueChanged<bool> onSubmissionStateChanged;
  final VoidCallback onSubmit;

  const _RatingBottomSheet({
    required this.bloc,
    required this.initialRating,
    required this.initialIsSubmitting,
    required this.onRatingChanged,
    required this.onSubmissionStateChanged,
    required this.onSubmit,
  });

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet> {
  late int? _selectedRating;
  late bool _isSubmittingRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
    _isSubmittingRating = widget.initialIsSubmitting;
  }

  @override
  void didUpdateWidget(_RatingBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      _selectedRating = widget.initialRating;
    }
    if (widget.initialIsSubmitting != oldWidget.initialIsSubmitting) {
      _isSubmittingRating = widget.initialIsSubmitting;
    }
  }

  void _handleRatingChanged(int rating) {
    setState(() {
      _selectedRating = rating;
    });
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.rate_this_playground.tr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          24.heightBox(),
          _InteractiveRatingStars(
            selectedRating: _selectedRating,
            onRatingChanged: _handleRatingChanged,
          ),
          24.heightBox(),
          _RatingSubmitButton(
            bloc: widget.bloc,
            selectedRating: _selectedRating,
            isSubmittingRating: _isSubmittingRating,
            onSubmissionStateChanged: (isSubmitting) {
              setState(() {
                _isSubmittingRating = isSubmitting;
              });
              widget.onSubmissionStateChanged(isSubmitting);
            },
            onSubmit: widget.onSubmit,
          ),
        ],
      ),
    );
  }
}

class _InteractiveRatingStars extends StatelessWidget {
  final int? selectedRating;
  final ValueChanged<int> onRatingChanged;

  const _InteractiveRatingStars({required this.selectedRating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(
              index < (selectedRating ?? 0) ? Icons.star : Icons.star_border,
              size: 40,
              color: index < (selectedRating ?? 0)
                  ? AppColors.primaryYellow
                  : AppColors.primaryGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingSubmitButton extends StatelessWidget {
  final PlaygroundsBloc bloc;
  final int? selectedRating;
  final bool isSubmittingRating;
  final ValueChanged<bool> onSubmissionStateChanged;
  final VoidCallback onSubmit;

  const _RatingSubmitButton({
    required this.bloc,
    required this.selectedRating,
    required this.isSubmittingRating,
    required this.onSubmissionStateChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is PlaygroundsError && isSubmittingRating) {
          onSubmissionStateChanged(false);
        }
      },
      builder: (context, state) {
        final isLoading = state is PlaygroundsLoading && isSubmittingRating;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (selectedRating != null && !isLoading) ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: context.mutedBackground,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryWhite),
                    ),
                  )
                : Text(
                    LocaleKeys.submit_rating.tr(),
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
