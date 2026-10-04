import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/playgrounds/bloc/playgrounds_bloc.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/data/models/request_model/playgrounds/playground_filter_request_model.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/widgets/bottom_sheets/playground_filter_bottom_sheet.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class PlaygroundsListPage extends StatefulWidget {
  const PlaygroundsListPage({super.key});

  @override
  State<PlaygroundsListPage> createState() => _PlaygroundsListPageState();
}

class _PlaygroundsListPageState extends State<PlaygroundsListPage> {
  final bloc = locator<PlaygroundsBloc>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc.add(const GetPlaygroundsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    final generalBloc = locator<GeneralBloc>();
    PlaygroundFilterBottomSheet.show(context, bloc, generalBloc);
  }

  void _clearFilters() {
    _searchController.clear();
    bloc.add(const GetPlaygroundsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.playgrounds.tr())),
      body: CustomBlocConsumer<PlaygroundsBloc, PlaygroundsState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is PlaygroundsError) {
            context.showMessage(isError: true, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            bloc.add(const GetPlaygroundsEvent());
                          } else {
                            bloc.add(
                              GetPlaygroundsEvent(
                                filters: PlaygroundFilterRequestModel(name: value),
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: LocaleKeys.search.tr(),
                          filled: true,
                          hintStyle: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: AppColors.lightTextColor, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                            color: bloc.hasActiveFilters()
                                ? AppColors.primaryColor
                                : AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: bloc.hasActiveFilters()
                                ? _clearFilters
                                : _showFilterBottomSheet,
                            icon: Icon(
                              Icons.filter_list,
                              color: bloc.hasActiveFilters()
                                  ? AppColors.primaryWhite
                                  : AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        if (bloc.hasActiveFilters())
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
              ),
              Expanded(
                child: state is PlaygroundsLoading
                    ? const LoadingWidget()
                    : bloc.playgrounds.isEmpty
                    ? Center(child: Text(LocaleKeys.no_playgrounds_found.tr()))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: bloc.playgrounds.length,
                        itemBuilder: (context, index) {
                          final playground = bloc.playgrounds[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _buildPlaygroundCard(playground),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaygroundCard(PlaygroundModel playground) {
    return GestureDetector(
      onTap: () {
        context.router.push(PlaygroundDetailsRoute(playground: playground));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: playground.image != null
                  ? Image.network(
                      playground.image!,
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 180.h,
                          color: AppColors.primaryLiteGrey,
                          child: const Icon(Icons.image, color: AppColors.primaryColor),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 180.h,
                      color: AppColors.primaryLiteGrey,
                      child: const Icon(Icons.image, color: AppColors.primaryColor),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playground.name ?? '',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
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
                      8.widthBox(),
                      _buildRatingStars(double.parse(playground.rate?.toString() ?? '0').round()),
                    ],
                  ),
                  8.heightBox(),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.lightTextColor),
                      8.widthBox(),
                      Expanded(
                        child: Text(
                          playground.city ?? '',
                          style: const TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Spacer(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${playground.price ?? '0'} ',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
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
                ],
              ),
            ),
          ],
        ),
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
          size: 12,
          color: index < rating ? AppColors.primaryYellow : AppColors.primaryGrey,
        ),
      ),
    );
  }
}
