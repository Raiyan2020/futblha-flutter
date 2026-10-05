import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../../widgets/app_size_boxes.dart';
import '../../../widgets/custom_loading_widget.dart';

class PlaygroundsWidget extends StatelessWidget {
  const PlaygroundsWidget(this.generalBloc, {super.key});
  final GeneralBloc generalBloc;

  List<PlaygroundModel> _getPlaygrounds(GeneralBloc generalBloc) {
    // Use home API playgrounds data
    final playgrounds = generalBloc.homeData?.playgrounds ?? [];
    return playgrounds.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GeneralBloc, GeneralState>(
      bloc: generalBloc,
      listener: (context, state) {},
      builder: (context, state) {
        final playgrounds = _getPlaygrounds(generalBloc);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.playgrounds.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () => context.router.push(const PlaygroundsListRoute()),
                    child: Text(
                      LocaleKeys.see_all.tr(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            10.heightBox(),
            if (state is GeneralLoading && playgrounds.isEmpty)
              SizedBox(height: 220.h, child: const LoadingWidget())
            else if (playgrounds.isEmpty)
              const SizedBox.shrink()
            else
              SizedBox(
                height: 215.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: playgrounds.length,
                  itemBuilder: (context, index) {
                    return _buildPlaygroundCard(context, playgrounds[index]);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPlaygroundCard(BuildContext context, PlaygroundModel playground) {
    return GestureDetector(
      onTap: () {
        context.router.push(PlaygroundDetailsRoute(playground: playground));
      },
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 12.w),
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
                      height: 110.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 110.h,
                          color: context.mutedBackground,
                          child: Icon(Icons.image, color: context.brandOnSurface),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 110.h,
                      color: context.mutedBackground,
                      child: Icon(Icons.image, color: context.brandOnSurface),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    playground.name ?? '',
                    style: TextStyle(
                      color: context.brandOnSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.heightBox(),
                  Row(
                    children: [
                      const Icon(Icons.sports_soccer, size: 14, color: AppColors.lightTextColor),
                      4.widthBox(),
                      Expanded(
                        child: Text(
                          '${playground.landType ?? ''} - ${playground.capacity ?? ''}',
                          style: const TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  4.heightBox(),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.lightTextColor),
                      4.widthBox(),
                      Expanded(
                        child: Text(
                          playground.city ?? '',
                          style: const TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  4.heightBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildRatingStars(
                          double.parse(playground.rate?.toString() ?? '0').round(),
                        ),
                      ),
                      Text(
                        playground.price ?? '0',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.brandOnSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      1.widthBox(),
                      Text(
                        LocaleKeys.kwd_hour.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.brandOnSurface, fontSize: 14),
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
