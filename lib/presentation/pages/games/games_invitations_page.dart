import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/scaffold_pading.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/playgrounds/booking_period_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';

@RoutePage()
class GamesInvitationsPage extends StatefulWidget {
  const GamesInvitationsPage({super.key});

  @override
  State<GamesInvitationsPage> createState() => _GamesInvitationsPageState();
}

class _GamesInvitationsPageState extends State<GamesInvitationsPage> {
  final bloc = locator<GamesBloc>();
  int _selectedTab = 0; // 0 = Receiving Games, 1 = Sending Games

  @override
  void initState() {
    super.initState();
    bloc.add(GetGameInvitationsEvent());
  }

  List<GameModel> _getCurrentGames() {
    if (_selectedTab == 0) {
      return bloc.gameInvitations?.receivingGames ?? [];
    } else {
      return bloc.gameInvitations?.sendingGames ?? [];
    }
  }

  GameInvitationStatus _getStatus(GameModel game) {
    final status = game.gameStatus?.toLowerCase() ?? '';
    if (status == 'pending') {
      return GameInvitationStatus.pending;
    } else if (status == 'accepting_players' || status.contains('waiting')) {
      return GameInvitationStatus.waitingOpposingTeam;
    } else if (status == 'accepted' || status == 'confirmed') {
      return GameInvitationStatus.accepted;
    } else if (status == 'rejected') {
      return GameInvitationStatus.rejected;
    }
    return GameInvitationStatus.pending;
  }
  //
  // String _formatDate(String? dateStr) {
  //   if (dateStr == null) return '';
  //   try {
  //     // Try parsing different date formats
  //     final date = DateTime.parse(dateStr);
  //     return DateFormat('dd MMM yyyy').format(date);
  //   } catch (e) {
  //     return dateStr;
  //   }
  // }

  String _formatTimePeriods(List<BookingPeriodModel>? periods) {
    if (periods == null || periods.isEmpty) return '';
    final first = periods.first;
    final last = periods.last;
    return '${first.startTime ?? ''} - ${last.endTime ?? ''}';
  }

  String _formatPlayers(dynamic target) {
    if (target == null) return 'N/A';
    return '${(target / 2).round()} ${LocaleKeys.vs.tr()} ${(target / 2).round()}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is GamesError) {
          context.showMessage(isError: true, state.message);
        } else if (state is AcceptGameSuccess) {
          context.showMessage(state.message);
        }
      },
      builder: (context, state) {
        final games = _getCurrentGames();

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.games_invitations.tr())),
          body: Column(
            children: [
              // Segmented Control
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        text: LocaleKeys.receiving_games.tr(),
                        isSelected: _selectedTab == 0,
                        onTap: () {
                          setState(() => _selectedTab = 0);
                          bloc.add(GetGameInvitationsEvent());
                        },
                      ),
                    ),
                    12.widthBox(),
                    Expanded(
                      child: _buildTabButton(
                        text: LocaleKeys.sending_games.tr(),
                        isSelected: _selectedTab == 1,
                        onTap: () {
                          setState(() => _selectedTab = 1);
                          bloc.add(GetGameInvitationsEvent());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Game Invitations List
              Expanded(
                child: state is GamesLoading && bloc.gameInvitations == null
                    ? const Center(child: CircularProgressIndicator())
                    : games.isEmpty
                    ? Center(
                        child: Text(
                          LocaleKeys.no_game_invitations_found.tr(),
                          style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          final game = games[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _buildInvitationCard(game),
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

  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.primaryLiteGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.primaryWhite : AppColors.primaryGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationCard(GameModel game) {
    final creatorDiwaniya = game.creatorDiwaniya;
    final opponentDiwaniya = game.opponentDiwaniya;
    final booking = game.booking;
    final periods = booking?.periods ?? [];

    return GestureDetector(
      onTap: () {
        if (game.id != null) {
          context.router.push(GameDetailsRoute(bloc: bloc..gameDetails = GameModel(id: game.id!)));
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlack.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Team Matchup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: creatorDiwaniya?.image != null
                          ? NetworkImage(creatorDiwaniya!.image!) as ImageProvider
                          : const AssetImage(AppAssets.ic_profile),
                      backgroundColor: AppColors.primaryLiteGrey,
                      onBackgroundImageError: (_, _) {},
                    ),
                    8.heightBox(),
                    Text(
                      creatorDiwaniya?.name ?? '',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                16.widthBox(),
                Text(
                  LocaleKeys.vs.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                16.widthBox(),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: opponentDiwaniya?.image != null
                          ? NetworkImage(opponentDiwaniya!.image!) as ImageProvider
                          : const AssetImage(AppAssets.ic_profile),
                      backgroundColor: AppColors.primaryLiteGrey,
                      onBackgroundImageError: (_, _) {},
                    ),
                    8.heightBox(),
                    Text(
                      opponentDiwaniya?.name ?? '',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            16.heightBox(),
            // Creator Information
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: Text(
                '${LocaleKeys.creator.tr()} : ${game.creatorName ?? ''}',
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
            10.heightBox(),
            // Game Details Row
            Container(
              padding: symmetricPadding(3, 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailBadge(
                    icon: Icons.calendar_today,
                    text: booking?.bookingDate?.toLocal().formatDateToCustomString() ?? '',
                  ),

                  _buildDetailBadge(icon: Icons.access_time, text: _formatTimePeriods(periods)),
                  _buildDetailBadge(icon: Icons.person, text: _formatPlayers(game.playersTarget)),
                ],
              ),
            ),
            // Status Badge (for sending games)
            if (_selectedTab == 1) ...[12.heightBox(), _buildStatusBadge(_getStatus(game))],
            // Action Buttons (for receiving games)
            if (_selectedTab == 0) ...[
              16.heightBox(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _handleAccept(game);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        LocaleKeys.accept.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  12.widthBox(),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _handleReject(game);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: AppColors.primaryRed, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        LocaleKeys.reject.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          6.widthBox(),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(GameInvitationStatus status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case GameInvitationStatus.waitingOpposingTeam:
        statusText = LocaleKeys.waiting_opposing_team.tr();
        statusColor = AppColors.primaryOrange;
        break;
      case GameInvitationStatus.accepted:
        statusText = LocaleKeys.accepted.tr();
        statusColor = AppColors.primaryColor;
        break;
      case GameInvitationStatus.pending:
        statusText = LocaleKeys.pending.tr();
        statusColor = AppColors.primaryOrange;
        break;
      case GameInvitationStatus.rejected:
        statusText = LocaleKeys.rejected.tr();
        statusColor = AppColors.primaryRed;
        break;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          statusText,
          textAlign: .center,
          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _handleAccept(GameModel game) {
    if (game.id != null) {
      bloc.add(AcceptGameEvent(gameId: game.id!));
    }
  }

  void _handleReject(GameModel game) {
    if (game.id != null) {
      bloc.add(RejectGameEvent(gameId: game.id!));
    }
  }
}

enum GameInvitationStatus { pending, waitingOpposingTeam, accepted, rejected }

class GameInvitation {
  final String team1Name;
  final String team1Image;
  final String team2Name;
  final String team2Image;
  final String creatorName;
  final String date;
  final String time;
  final String players;
  final GameInvitationStatus status;

  const GameInvitation({
    required this.team1Name,
    required this.team1Image,
    required this.team2Name,
    required this.team2Image,
    required this.creatorName,
    required this.date,
    required this.time,
    required this.players,
    required this.status,
  });
}
