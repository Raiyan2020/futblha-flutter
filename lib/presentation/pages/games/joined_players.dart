import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/game_player_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

@RoutePage()
class JoinedPlayersPage extends StatefulWidget {
  const JoinedPlayersPage({super.key, required this.gameId, required this.bloc});
  final int gameId;
  final GamesBloc bloc;

  @override
  State<JoinedPlayersPage> createState() => _JoinedPlayersPageState();
}

class _JoinedPlayersPageState extends State<JoinedPlayersPage> {
  late final bloc = widget.bloc;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    bloc.add(GetGameMembersEvent(gameId: widget.gameId));
  }

  bool _isCreator(GamePlayerModel player, GameModel? game) {
    // Check if player name matches creator name
    return player.name == game?.creatorName;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is GamesError) {
          context.showMessage(isError: true, state.message);
        } else if (state is DeleteGameMemberSuccess) {
          context.showMessage(LocaleKeys.player_deleted_successfully.tr());
        }
      },
      builder: (context, state) {
        final game = bloc.gameDetails;
        final members = bloc.gameMembers;
        final myTeam = members?.myTeamPlayers ?? [];
        final opposingTeam = members?.opposingTeamPlayers ?? [];
        final totalPlayers = int.tryParse(game?.playersTarget?.toString() ?? '0') ?? 0;
        final joinedPlayers = (game?.playersJoines ?? 0);
        final isMember = game?.userPermission?.isMember == true;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(title: Text(LocaleKeys.players_joined.tr())),
          body: state is GamesLoading && members == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header with count
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Center(
                        child: Text(
                          '$joinedPlayers/$totalPlayers',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Team labels with VS in format: — My Team — Vs — Opposing Team —
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(height: 1.5, color: AppColors.primaryBlack),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Text(
                                    isMember ? LocaleKeys.my_team.tr() : LocaleKeys.team_1.tr(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(height: 1.5, color: AppColors.primaryBlack),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              LocaleKeys.vs.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(height: 1.5, color: AppColors.primaryBlack),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Text(
                                    isMember
                                        ? LocaleKeys.opposing_team.tr()
                                        : LocaleKeys.team_2.tr(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(height: 1.5, color: AppColors.primaryBlack),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.heightBox(),
                    // Two columns of players
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // My Team column
                              Expanded(child: _buildTeamColumn(myTeam, game, true)),
                              12.widthBox(),
                              // Opposing Team column
                              Expanded(child: _buildTeamColumn(opposingTeam, game, false)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTeamColumn(List<GamePlayerModel> players, GameModel? game, bool isMyTeam) {
    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Text(
            'No players yet',
            style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: players.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildPlayerCard(player, index + 1, game, isMyTeam),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerCard(
    GamePlayerModel player,
    int playerNumber,
    GameModel? game,
    bool isMyTeam,
  ) {
    final isCreator = _isCreator(player, game);
    final canDelete = game?.userPermission?.isCreator == true;

    return Container(
      padding: EdgeInsets.all(10.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLiteGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Number badge and action (Creator/X)
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor.withValues(alpha: .5),
                      spreadRadius: 1,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Player number badge
                    Text(
                      '#$playerNumber',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Creator badge or Delete button
                    if (isCreator)
                      Text(
                        LocaleKeys.creator.tr(),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (canDelete && isMyTeam)
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmation(player);
                        },
                        child: Icon(Icons.close, color: AppColors.primaryRed, size: 20),
                      )
                    else if (canDelete && !isMyTeam)
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmation(player);
                        },
                        child: Icon(Icons.close, color: AppColors.primaryRed, size: 20),
                      )
                    else
                      const SizedBox(width: 20),
                  ],
                ),
              ),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryWhite,
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryLiteGrey, spreadRadius: 2, blurRadius: 5),
                  ],
                ),
                child: ClipOval(
                  child: player.image != null
                      ? Image.network(
                          player.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, color: AppColors.primaryColor, size: 30);
                          },
                        )
                      : Image.asset(
                          AppAssets.ic_profile,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, color: AppColors.primaryColor, size: 30);
                          },
                        ),
                ),
              ),
            ],
          ),
          8.heightBox(),
          // Player name
          Center(
            child: Text(
              player.name ?? '',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Position
          if (player.positionText != null) ...[
            4.heightBox(),
            Center(
              child: Text(
                player.positionText!,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(GamePlayerModel player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.delete.tr()),
        content: Text('Are you sure you want to remove ${player.name ?? 'this player'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (player.id != null) {
                bloc.add(DeleteGameMemberEvent(gameId: widget.gameId, userId: player.id!));
              }
            },
            child: Text(LocaleKeys.delete.tr(), style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}
