import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/data/models/request_model/playgrounds/playground_filter_request_model.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/widgets/bottom_sheets/playground_filter_bottom_sheet.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class PlaygroundSelectionPage extends StatefulWidget {
  const PlaygroundSelectionPage({super.key});

  @override
  State<PlaygroundSelectionPage> createState() => _PlaygroundSelectionPageState();
}

class _PlaygroundSelectionPageState extends State<PlaygroundSelectionPage> {
  final playgroundsBloc = locator<PlaygroundsBloc>();
  final generalBloc = locator<GeneralBloc>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch playgrounds
    playgroundsBloc.add(const GetPlaygroundsEvent());
    // Fetch filter options if not already loaded
    if (generalBloc.cities.isEmpty) {
      generalBloc.add(GetCitiesEvent());
    }
    if (playgroundsBloc.capacities.isEmpty) {
      playgroundsBloc.add(GetCapacitiesEvent());
    }
    if (playgroundsBloc.facilities.isEmpty) {
      playgroundsBloc.add(GetFacilitiesEvent());
    }
    if (playgroundsBloc.landTypes.isEmpty) {
      playgroundsBloc.add(GetLandTypesEvent());
    }

    _searchController.addListener(() {
      final query = _searchController.text;
      if (query.isEmpty) {
        playgroundsBloc.add(const GetPlaygroundsEvent());
      } else {
        playgroundsBloc.add(
          GetPlaygroundsEvent(filters: PlaygroundFilterRequestModel(name: query)),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    PlaygroundFilterBottomSheet.show(context, playgroundsBloc, generalBloc);
  }

  void _clearFilters() {
    _searchController.clear();
    playgroundsBloc.add(const GetPlaygroundsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
      bloc: playgroundsBloc,
      listener: (context, state) {
        if (state is PlaygroundsError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.playgrounds.tr())),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.choose_playground.tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    12.heightBox(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onTapOutside: (_) => FocusScope.of(context).unfocus(),
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.search.tr(),
                              hintStyle: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.lightTextColor,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ),
                        12.widthBox(),
                        Stack(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: playgroundsBloc.hasActiveFilters()
                                    ? AppColors.primaryColor
                                    : context.chipBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: playgroundsBloc.hasActiveFilters()
                                    ? _clearFilters
                                    : _showFilterBottomSheet,
                                icon: Icon(
                                  Icons.filter_list,
                                  color: playgroundsBloc.hasActiveFilters()
                                      ? AppColors.primaryWhite
                                      : context.brandOnSurface,
                                  size: 24,
                                ),
                              ),
                            ),
                            if (playgroundsBloc.hasActiveFilters())
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state is PlaygroundsLoading && playgroundsBloc.playgrounds.isEmpty
                    ? const LoadingWidget()
                    : playgroundsBloc.playgrounds.isEmpty
                    ? Center(
                        child: Text(
                          LocaleKeys.no_playgrounds_found.tr(),
                          style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: playgroundsBloc.playgrounds.length,
                        itemBuilder: (context, index) {
                          final playground = playgroundsBloc.playgrounds[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _buildPlaygroundCard(playground),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaygroundCard(PlaygroundModel playground) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: playground.image != null && playground.image!.startsWith('http')
                ? Image.network(
                    playground.image!,
                    width: double.infinity,
                    height: 180.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180.h,
                        color: context.mutedBackground,
                        child: Icon(Icons.image, color: context.brandOnSurface),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: 180.h,
                    color: context.mutedBackground,
                    child: Icon(Icons.image, color: context.brandOnSurface),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playground.name ?? '',
                  style: TextStyle(
                    color: context.brandOnSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                12.heightBox(),
                Row(
                  children: [
                    const Icon(Icons.sports_soccer, size: 16, color: AppColors.lightTextColor),
                    8.widthBox(),
                    Expanded(
                      child: Text(
                        '${playground.landType ?? ''} - ${playground.capacity ?? ''}',
                        style: const TextStyle(
                          color: AppColors.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                8.heightBox(),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.lightTextColor),
                    8.widthBox(),
                    Text(
                      playground.city ?? '',
                      style: const TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    _buildRatingStars(4), // Default rating
                    8.widthBox(),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${playground.price ?? '0'} ',
                            style: TextStyle(
                              color: context.brandOnSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: LocaleKeys.kwd_hour.tr(),
                            style: TextStyle(
                              color: AppColors.lightTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                16.heightBox(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.router.pop(playground);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      LocaleKeys.confirm_this_playground.tr(),
                      style: const TextStyle(
                        color: AppColors.primaryWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: index < rating ? AppColors.primaryYellow : AppColors.primaryGrey,
        ),
      ),
    );
  }
}
