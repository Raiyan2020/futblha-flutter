import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:share_plus/share_plus.dart';
import 'package:futblha/application/core/utils/id_encryption.dart';

@RoutePage()
class DiwaniyaDetailsPage extends StatefulWidget {
  final String diwaniyaId;
  final String? diwaniyaName;
  final String? diwaniyaRank;
  final String? description;
  final int levelReview;
  final int clearGame;
  final int wins;
  final int draws;
  final int loses;
  final String? imagePath;
  final bool isMember;

  const DiwaniyaDetailsPage({
    super.key,
    required this.diwaniyaId,
    this.diwaniyaName,
    this.diwaniyaRank,
    this.description,
    this.levelReview = 0,
    this.clearGame = 0,
    this.wins = 0,
    this.draws = 0,
    this.loses = 0,
    this.imagePath,
    this.isMember = false,
  });

  @override
  State<DiwaniyaDetailsPage> createState() => _DiwaniyaDetailsPageState();
}

class _DiwaniyaDetailsPageState extends State<DiwaniyaDetailsPage> {
  final bloc = locator<DiwaniyaBloc>();

  @override
  void initState() {
    super.initState();
    final diwaniyaIdInt = int.tryParse(widget.diwaniyaId);
    if (diwaniyaIdInt != null) {
      bloc.add(GetDiwaniyaEvent(diwaniyaId: diwaniyaIdInt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        } else if (state is JoinDiwaniyaSuccess) {
          // Show success message for join
          if (bloc.diwaniyaDetails != null) {
            context.showMessage(isError: false, state.message);
            // Refresh diwaniya details to update member status
            // final diwaniyaIdInt = int.tryParse(widget.diwaniyaId);
            // if (diwaniyaIdInt != null) {
            //   bloc.add(GetDiwaniyaEvent(diwaniyaId: diwaniyaIdInt));
            // }
            Navigator.of(context).pop(true);
          }
        }
      },
      builder: (context, state) {
        final diwaniya = bloc.diwaniyaDetails;
        final displayName = diwaniya?.name ?? widget.diwaniyaName ?? '';
        final displayRank = diwaniya?.rank != null
            ? '#${diwaniya!.rank}'
            : (widget.diwaniyaRank ?? '');
        final displayDescription = diwaniya?.description ?? widget.description;
        final displayWins = int.tryParse(diwaniya?.wins ?? '') ?? widget.wins;
        final displayDraws = int.tryParse(diwaniya?.draws ?? '') ?? widget.draws;
        final displayLoses = int.tryParse(diwaniya?.losses ?? '') ?? widget.loses;
        final displayIsMember = diwaniya?.userPermission?.isMember ?? widget.isMember;
        final displayImage = diwaniya?.image ?? widget.imagePath;

        return Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: state is DiwaniyaLoading
              ? const LoadingWidget()
              : Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 28.h),
                      padding: EdgeInsets.fromLTRB(25.w, 50.h, 25.w, 25.h),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.my_diwanya_background),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            30.heightBox(),
                            // Diwaniya Name
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            8.heightBox(),
                            // Rank
                            Text(
                              displayRank,
                              style: const TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            20.heightBox(),
                            // Description Box
                            if (displayDescription != null)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryWhite.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    displayDescription,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.primaryWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            20.heightBox(),
                            // Ratings
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        LocaleKeys.level_review.tr(),
                                        style: const TextStyle(
                                          color: AppColors.primaryWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStarRating(widget.levelReview),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        LocaleKeys.clean_game.tr(),
                                        style: const TextStyle(
                                          color: AppColors.primaryWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStarRating(widget.clearGame),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            20.heightBox(),
                            // Statistics Cards
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard('$displayWins', LocaleKeys.win.tr()),
                                  _buildStatCard('$displayDraws', LocaleKeys.draw.tr()),
                                  _buildStatCard('$displayLoses', LocaleKeys.lose.tr()),
                                ],
                              ),
                            ),
                            20.heightBox(),
                            // View Members Button
                            //  if (isMember)
                            _buildNavButton(
                              LocaleKeys.view_members.tr(),
                              onTap: () {
                                context.router.push(MembersRoute(bloc: bloc));
                              },
                            ),
                            15.heightBox(),
                          ],
                        ),
                      ),
                    ),

                    // Profile Picture
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.primaryWhite,
                      backgroundImage: displayImage != null
                          ? NetworkImage(displayImage) as ImageProvider
                          : const AssetImage(AppAssets.ic_profile),
                      onBackgroundImageError: (_, __) {},
                    ),

                    Positioned.directional(
                      top: 50.h,
                      end: 25.h,
                      textDirection: TextDirection.ltr,
                      child: IconButton(
                        onPressed: () => _shareDiwaniya(),
                        icon: const Icon(Icons.share, color: AppColors.primaryWhite),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar:
              !displayIsMember &&
                  state is! DiwaniyaLoading &&
                  diwaniya?.userPermission?.canJoin == true
              ? Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite.withValues(alpha: 0.1),
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
                        final diwaniyaIdInt = int.tryParse(widget.diwaniyaId);
                        if (diwaniyaIdInt != null) {
                          bloc.add(JoinDiwaniyaEvent(diwaniyaId: diwaniyaIdInt));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        LocaleKeys.join.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: index < rating
              ? AppColors.primaryYellow
              : AppColors.primaryWhite.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          constraints: BoxConstraints(minWidth: 60.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: AssetImage(AppAssets.score_background), fit: BoxFit.fill),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        4.heightBox(),
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryWhite.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _shareDiwaniya() {
    final diwaniya = bloc.diwaniyaDetails;
    final diwaniyaName = diwaniya?.name ?? widget.diwaniyaName ?? LocaleKeys.diwaniya_default.tr();
    final diwaniyaIdString = widget.diwaniyaId;
    final rank = diwaniya?.rank != null ? '#${diwaniya!.rank}' : (widget.diwaniyaRank ?? '');

    // Parse and encrypt the diwaniya ID before sharing
    final diwaniyaIdInt = int.tryParse(diwaniyaIdString);
    if (diwaniyaIdInt == null) return;

    final encryptedId = IdEncryption.encrypt(diwaniyaIdInt);

    // Create share message with diwaniya details
    final shareText =
        'Check out this Diwaniya: $diwaniyaName $rank\n\n'
        'Open in Futblha app:\n'
        'https://futblha.com/diwaniya/$encryptedId';

    SharePlus.instance.share(ShareParams(subject: 'Diwaniya', text: shareText));
  }
}
