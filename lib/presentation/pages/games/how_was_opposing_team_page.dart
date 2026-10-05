import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/data/models/request_model/games/rate_game_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class HowWasOpposingTeamPage extends StatefulWidget {
  final String teamName;
  final String? teamImage;
  final int? gameId;

  const HowWasOpposingTeamPage({super.key, required this.teamName, this.teamImage, this.gameId});

  @override
  State<HowWasOpposingTeamPage> createState() => _HowWasOpposingTeamPageState();
}

class _HowWasOpposingTeamPageState extends State<HowWasOpposingTeamPage> {
  final bloc = locator<GamesBloc>();
  int _levelReviewRating = 0;
  int _cleanGameRating = 0;

  void _submitRating() {
    if (widget.gameId == null) {
      context.showMessage(isError: true, LocaleKeys.game_id_not_found.tr());
      return;
    }

    final request = RateGameRequestModel(
      levelRating: _levelReviewRating,
      cleanGameRating: _cleanGameRating,
    );

    bloc.add(RateGameEvent(gameId: widget.gameId!, request: request));
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is GamesError) {
          context.showMessage(isError: true, state.message);
        } else if (state is GamesSuccess) {
          Navigator.of(context).pop();
          context.showMessage(LocaleKeys.rating_submitted_successfully.tr());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.how_was_opposing_team.tr())),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: .spaceBetween,
              children: [
                // Team Profile Card
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      margin: EdgeInsets.only(top: 50.h),
                      decoration: BoxDecoration(
                        color: context.chipBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          50.heightBox(),
                          // Team Name
                          Text(
                            widget.teamName,
                            style: TextStyle(
                              color: context.brandOnSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          24.heightBox(),
                          // Level Review Section
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.level_review.tr(),
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                12.heightBox(),
                                _buildStarRating(
                                  rating: _levelReviewRating,
                                  onRatingChanged: (rating) {
                                    setState(() {
                                      _levelReviewRating = rating;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.heightBox(),
                          // Clean Game Section
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.clean_game.tr(),
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                12.heightBox(),
                                _buildStarRating(
                                  rating: _cleanGameRating,
                                  onRatingChanged: (rating) {
                                    setState(() {
                                      _cleanGameRating = rating;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile Picture (overlapping top)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.teamImage != null
                          ? NetworkImage(widget.teamImage!)
                          : AssetImage(AppAssets.ic_profile),
                      backgroundColor: context.mutedBackground,
                      onBackgroundImageError: (_, _) {},
                    ),
                  ],
                ),

                // Action Buttons
                Column(
                  children: [
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton(
                    //     onPressed: () {
                    //       // TODO: Implement repeat game logic
                    //       ScaffoldMessenger.of(
                    //         context,
                    //       ).showSnackBar(const SnackBar(content: Text('Repeat game requested')));
                    //     },
                    //     style: OutlinedButton.styleFrom(
                    //       padding: EdgeInsets.symmetric(vertical: 16.h),
                    //       side: const BorderSide(color: AppColors.primaryColor, width: 1),
                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //     ),
                    //     child: const Text(
                    //       'Repeat Game',
                    //       style: TextStyle(
                    //         color: AppColors.primaryColor,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // 16.heightBox(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _levelReviewRating > 0 && _cleanGameRating > 0 && state is! GamesLoading
                            ? _submitRating
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: AppColors.primaryLiteGrey,
                        ),
                        child: state is GamesLoading
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarRating({required int rating, required Function(int) onRatingChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 32,
              color: index < rating ? AppColors.primaryYellow : AppColors.primaryGrey,
            ),
          ),
        ),
      ),
    );
  }
}
