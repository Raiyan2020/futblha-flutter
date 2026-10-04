import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/cache/cache_manager.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/request_model/games/join_game_request_model.dart';
import 'package:futblha/data/models/response_model/games/game_members_response_model.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/playgrounds/playground_model.dart';
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/games/widgets/game_info_card.dart';
import 'package:futblha/presentation/pages/games/utils/game_formation_utils.dart';
import 'package:futblha/presentation/pages/games/widgets/game_players_pitch_section.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/playground_not_available_dialog.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class GameDetailsPage extends StatefulWidget {
  const GameDetailsPage({super.key, required this.bloc, this.isFromHistory = false});

  final GamesBloc bloc;
  final bool isFromHistory;

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  late final GamesBloc bloc = widget.bloc;
  bool _isChangingPosition = false;

  @override
  void initState() {
    super.initState();
    if (bloc.gameDetails?.id != null) {
      bloc.add(GetGameEvent(gameId: bloc.gameDetails!.id!, hardLoading: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: bloc,
      listener: _handleState,
      builder: (context, state) {
        final game = bloc.gameDetails;
        final members = bloc.gameMembers;

        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: Text(LocaleKeys.game_details.tr())),
            body: Center(child: Text(LocaleKeys.game_not_found.tr())),
          );
        }

        return PremiumLoadingStack(
          isLoading: state is GamesLoading,
          child: Scaffold(
            appBar: AppBar(title: Text(LocaleKeys.game_details.tr())),
            body: state is GetGameLoading
                ? const LoadingWidget()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                          child: GameInfoCard(
                            game: game,
                            onChatPressed: () => setState(() => game.unreadMessagesCount = 0),
                          ),
                        ),
                        if (game.gameStatus == 'players_completed' &&
                            game.booking?.paymentMethod == null &&
                            game.userPermission?.canBook == true)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                            child: _buildBookPlaygroundButton(context, game),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: GamePlayersPitchSection(
                            game: game,
                            members: members,
                            bloc: bloc,
                            isFromHistory: widget.isFromHistory,
                            userTeamIndex: _getUserTeamIndex(game),
                            onForfeitTap: () => _handleForfeitGame(context, game),
                            onJoinFromPosition: (coords, teamIndex, slotIndex) =>
                                _joinGameFromPosition(coords, teamIndex, slotIndex),
                            isChangingPosition: _isChangingPosition,
                            changePositionTeamIndex: _isChangingPosition
                                ? _getCurrentUserTeamIndex(members)
                                : null,
                            onChangePositionSlot: _isChangingPosition
                                ? (teamIndex, slotIndex) =>
                                      _changePositionFromSlot(teamIndex, slotIndex, game)
                                : null,
                          ),
                        ),
                        15.heightBox(),
                        if (game.userPermission?.canJoin == true &&
                            game.userPermission?.isMember != true)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: _buildJoinButton(context),
                          ),
                        if (game.userPermission?.isMember == true && !widget.isFromHistory)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                            child: _buildChangePositionButton(context, game),
                          ),
                        20.heightBox(),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleState(BuildContext context, GamesState state) {
    if (state is GamesError) {
      context.showMessage(isError: true, state.message);
      return;
    }
    if (state is JoinGameSuccess) {
      final game = bloc.gameDetails;
      if (game?.id != null) {
        bloc.add(GetGameEvent(gameId: game!.id!));
        final message = game.type == 'private'
            ? LocaleKeys.join_request_sent_successfully.tr()
            : LocaleKeys.successfully_joined_the_game.tr();
        context.showMessage(message);
      }
      return;
    }
    if (state is ChangePositionSuccess) {
      context.showMessage(LocaleKeys.position_changed_successfully.tr());
      return;
    }
    if (state is LeaveGameSuccess) {
      final game = bloc.gameDetails;
      if (game?.userPermission?.isCreator == true) {
        context.showMessage(LocaleKeys.forfeit_match.tr());
        context.router.pop(true);
      } else {
        bloc.add(GetGameEvent(gameId: game!.id!));
        context.showMessage(LocaleKeys.forfeit_match.tr());
      }
      return;
    }
    if (state is CheckBookingAvailableSuccess) {
      _handleCheckBookingAvailable(context, state);
    }
  }

  void _handleCheckBookingAvailable(BuildContext context, CheckBookingAvailableSuccess state) {
    final game = bloc.gameDetails;
    if (game?.id == null) {
      context.showMessage(isError: true, 'Game ID not found');
      return;
    }

    if (state.data.available == true) {
      final booking = game!.booking;
      if (booking?.playground != null &&
          booking?.bookingDate != null &&
          booking?.periods != null &&
          booking!.periods!.isNotEmpty) {
        final timeSlots = booking.periods!
            .map((period) => '${period.startTime ?? ''} - ${period.endTime ?? ''}')
            .where((slot) => slot.isNotEmpty && slot != ' - ')
            .join(', ');

        if (timeSlots.isNotEmpty && booking.bookingDate != null) {
          context.router.push(
            ConfirmBookingRoute(
              playground: booking.playground!,
              date: booking.bookingDate!,
              timeSlot: timeSlots,
              gameId: game.id!,
              skipUpdate: true,
            ),
          );
        } else if (booking.bookingDate == null) {
          context.showMessage(isError: true, 'Invalid booking date');
        } else {
          context.showMessage(isError: true, 'No time slots available');
        }
      } else {
        context.showMessage(isError: true, 'Booking data incomplete');
      }
    } else {
      PlaygroundNotAvailableDialog.show(
        context,
        playgroundName: game!.booking?.playground?.name ?? LocaleKeys.playground.tr(),
        onContinue: () => _navigateToChoosePlayground(context, game),
      );
    }
  }

  Widget _buildJoinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: ElevatedButton(
        onPressed: () => context.router.push(JoinGameRoute(gamesBloc: bloc)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
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
    );
  }

  Widget _buildChangePositionButton(BuildContext context, GameModel game) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: ElevatedButton(
        onPressed: () {
          if (_isChangingPosition) {
            setState(() => _isChangingPosition = false);
          } else {
            setState(() => _isChangingPosition = true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isChangingPosition ? AppColors.primaryGrey : AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _isChangingPosition ? LocaleKeys.cancel.tr() : LocaleKeys.change_position.tr(),
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBookPlaygroundButton(BuildContext context, GameModel game) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: ElevatedButton(
        onPressed: () {
          if (game.id == null) {
            context.showMessage(isError: true, 'Game ID not found');
            return;
          }
          bloc.add(CheckBookingAvailableEvent(gameId: game.id!));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          LocaleKeys.book_playground.tr(),
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Current user's team index (0 or 1) when they are a member, or null.
  int? _getCurrentUserTeamIndex(GameMembersResponseModel? members) {
    if (members == null) return null;
    final currentUserId = int.tryParse(CacheManager.instance.getUserId());
    if (currentUserId == null) return null;
    if (members.myTeamPlayers.any((p) => p.id == currentUserId)) return 0;
    if (members.opposingTeamPlayers.any((p) => p.id == currentUserId)) return 1;
    return null;
  }

  void _changePositionFromSlot(int teamIndex, int slotIndex, GameModel game) {
    if (game.id == null) {
      context.showMessage(isError: true, 'Game ID not found');
      return;
    }
    final totalPlayers = int.tryParse(game.playersTarget?.toString() ?? '0') ?? 0;
    final playersPerTeam = totalPlayers ~/ 2;
    final positionKey = getPositionKeyForSlotIndex(slotIndex, playersPerTeam);

    final isGoalkeeperSlot = slotIndex == 0;
    final goalkeeperClosed =
        (teamIndex == 0 && game.goalkeeperTeam1Close == true) ||
        (teamIndex == 1 && game.goalkeeperTeam2Close == true);
    if (isGoalkeeperSlot && goalkeeperClosed) {
      context.showMessage(isError: true, LocaleKeys.goalkeeper_position_filled.tr());
      return;
    }

    bloc.add(ChangePositionEvent(gameId: game.id!, position: positionKey, slotIndex: slotIndex));
    setState(() => _isChangingPosition = false);
  }

  void _handleForfeitGame(BuildContext context, GameModel game) {
    if (game.id == null) {
      context.showMessage(isError: true, 'Game ID not found');
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(LocaleKeys.forfeit_match.tr()),
        content: Text(
          game.userPermission?.isCreator == true
              ? LocaleKeys.forfeit_match_creator_confirmation.tr()
              : LocaleKeys.forfeit_match_confirmation.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(LeaveGameEvent(gameId: game.id!));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryRed),
            child: Text(LocaleKeys.forfeit_match.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToChoosePlayground(BuildContext context, GameModel game) async {
    final playground = await context.router.push<PlaygroundModel>(const PlaygroundSelectionRoute());
    if (playground != null && game.id != null) {
      context.router.push(BookPlaygroundRoute(playground: playground, gameId: game.id));
    }
  }

  /// Returns 0 if user must join creator team, 1 if opponent/other team, null if no restriction.
  /// my_diwanya: no restriction (same diwaniya, can join team 1 or 2).
  /// Public: if not creator's diwaniya, user can only join the other team (1).
  int? _getUserTeamIndex(GameModel game) {
    // my_diwanya games are between same diwaniya members – user can join either team
    if (game.type == 'my_diwanya') return null;

    final myId = locator<AuthenticationBloc>().myDiwaniya?.id;
    // Public: creator = team 0, other = team 1. Non-creator users only join team 1.
    if (game.type == 'public') {
      if (game.creatorDiwaniya?.id == myId) return 0;
      return 1;
    }
    if (myId == null) return null;
    if (game.creatorDiwaniya?.id == myId) return 0;
    if (game.opponentDiwaniya?.id == myId) return 1;
    return null;
  }

  void _joinGameFromPosition(Map<String, double> coords, int teamIndex, int slotIndex) {
    final game = bloc.gameDetails;
    if (game == null || game.id == null) return;

    final y = coords['y'] ?? 0.5;
    final isTopTeam = teamIndex == 0;

    String positionKey;
    if (isTopTeam) {
      if (y < 0.14) {
        positionKey = 'goal_keeper';
      } else if (y < 0.26) {
        positionKey = 'defender';
      } else if (y < 0.38) {
        positionKey = 'center';
      } else {
        positionKey = 'attacker';
      }
    } else {
      if (y >= 0.86) {
        positionKey = 'goal_keeper';
      } else if (y >= 0.74) {
        positionKey = 'defender';
      } else if (y >= 0.62) {
        positionKey = 'center';
      } else {
        positionKey = 'attacker';
      }
    }

    if (positionKey == 'goal_keeper') {
      final gkClosed = teamIndex == 0
          ? game.goalkeeperTeam1Close == true
          : game.goalkeeperTeam2Close == true;
      if (gkClosed) {
        if (context.mounted) {
          context.showMessage(isError: true, LocaleKeys.goalkeeper_position_filled.tr());
        }
        return;
      }
    }

    final isMyDiwanyaGame = game.type == 'my_diwanya';
    String? selectedTeam;
    if (isMyDiwanyaGame) {
      selectedTeam = teamIndex == 0 ? 'team_1' : 'team_2';
    }

    final request = JoinGameRequestModel(
      position: positionKey,
      my_diwanya_team: selectedTeam,
      slot_index: slotIndex,
    );
    bloc.add(JoinGameEvent(gameId: game.id!, request: request));
  }
}
