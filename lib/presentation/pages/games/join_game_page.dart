import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/data/models/enums/position_enum.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/games/utils/game_formation_utils.dart';
import 'package:futblha/data/models/response_model/games/game_player_model.dart';
import 'package:futblha/data/models/request_model/games/join_game_request_model.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key, required this.gamesBloc});
  final GamesBloc gamesBloc;

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  late final bloc = widget.gamesBloc;
  Position? _selectedPosition;
  String? _selectedTeam; // 'team_1' or 'team_2'

  bool get _isMyDiwanyaGame => bloc.gameDetails?.type == 'my_diwanya';

  /// When user must join a specific team. Null = can choose (e.g. my_diwanya: either team).
  /// Public: if not creator's diwaniya, user can only join team_2.
  String? get _userTeamValue {
    final game = bloc.gameDetails;
    if (game == null) return null;
    // my_diwanya: between same diwaniya members – no pre-select, user picks team_1 or team_2
    if (game.type == 'my_diwanya') return null;

    final myId = locator<AuthenticationBloc>().myDiwaniya?.id;
    if (game.type == 'public') {
      if (game.creatorDiwaniya?.id == myId) return 'team_1';
      return 'team_2';
    }
    if (myId == null) return null;
    if (game.creatorDiwaniya?.id == myId) return 'team_1';
    if (game.opponentDiwaniya?.id == myId) return 'team_2';
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = bloc.gameDetails;
      if (game != null && _selectedTeam == null && _isMyDiwanyaGame) {
        final team = _userTeamValue;
        if (team != null) setState(() => _selectedTeam = team);
      }
    });
  }

  /// Players on the team the user is joining (for computing used slots).
  List<GamePlayerModel> _getTeamListForJoin() {
    final members = bloc.gameMembers;
    if (members == null) return [];
    final team = _isMyDiwanyaGame ? _selectedTeam : _userTeamValue;
    if (team == 'team_1') return members.myTeamPlayers;
    if (team == 'team_2') return members.opposingTeamPlayers;
    return [];
  }

  /// Positions available for selection. Goalkeeper is excluded when that team's
  /// goalkeeper slot is closed. Positions with no empty slot on the joining team are hidden.
  List<Position> get _selectablePositionsForJoin {
    final game = bloc.gameDetails;
    List<Position> positions = Position.selectablePositions;
    if (game == null) return positions;
    final gk1Closed = game.goalkeeperTeam1Close == true;
    final gk2Closed = game.goalkeeperTeam2Close == true;
    if (_isMyDiwanyaGame) {
      if (_selectedTeam == 'team_1' && gk1Closed) {
        positions = positions.where((p) => p != Position.goalKeeper).toList();
      } else if (_selectedTeam == 'team_2' && gk2Closed) {
        positions = positions.where((p) => p != Position.goalKeeper).toList();
      }
    } else {
      if (gk1Closed && gk2Closed) {
        positions = positions.where((p) => p != Position.goalKeeper).toList();
      }
    }

    final team = _isMyDiwanyaGame ? _selectedTeam : _userTeamValue;
    if (team == null) return positions;

    final playersPerTeam =
        (int.tryParse(game.playersTarget?.toString() ?? '0') ?? 0) ~/ 2;
    if (playersPerTeam <= 0) return positions;

    final teamList = _getTeamListForJoin();
    final usedSlotIndices = <int>{};
    for (final p in teamList) {
      if (p.slotIndex != null && p.slotIndex!.isNotEmpty) {
        final idx = int.tryParse(p.slotIndex!);
        if (idx != null && idx >= 0 && idx < playersPerTeam) {
          usedSlotIndices.add(idx);
        }
      }
    }

    return positions
        .where((p) => hasEmptySlotForPosition(p.key, playersPerTeam, usedSlotIndices))
        .toList();
  }

  void _joinGame() {
    if (_selectedPosition == null) {
      context.showMessage(isError: true, LocaleKeys.please_select_position.tr());
      return;
    }

    // For My Diwanya games, team selection is required
    if (_isMyDiwanyaGame && _selectedTeam == null) {
      context.showMessage(isError: true, LocaleKeys.please_select_team.tr());
      return;
    }

    final gameId = bloc.gameDetails?.id;
    if (gameId == null) {
      context.showMessage(isError: true, LocaleKeys.game_not_found.tr());
      return;
    }

    final positionKey = _selectedPosition!.key;
    if (positionKey.isEmpty) {
      context.showMessage(isError: true, LocaleKeys.invalid_position.tr());
      return;
    }

    // Block joining as goalkeeper when that team's slot is closed
    if (_selectedPosition == Position.goalKeeper) {
      final game = bloc.gameDetails;
      if (_isMyDiwanyaGame && _selectedTeam != null) {
        final gkClosed = _selectedTeam == 'team_1'
            ? game?.goalkeeperTeam1Close == true
            : game?.goalkeeperTeam2Close == true;
        if (gkClosed) {
          context.showMessage(isError: true, LocaleKeys.goalkeeper_position_filled.tr());
          return;
        }
      } else if (game?.goalkeeperTeam1Close == true && game?.goalkeeperTeam2Close == true) {
        context.showMessage(isError: true, LocaleKeys.goalkeeper_position_filled.tr());
        return;
      }
    }

    final game = bloc.gameDetails;
    final playersPerTeam = game != null
        ? (int.tryParse(game.playersTarget?.toString() ?? '0') ?? 0) ~/ 2
        : 4;

    final teamList = _getTeamListForJoin();
    final usedSlotIndices = <int>{};
    for (final p in teamList) {
      if (p.slotIndex != null && p.slotIndex!.isNotEmpty) {
        final idx = int.tryParse(p.slotIndex!);
        if (idx != null && idx >= 0 && idx < playersPerTeam) {
          usedSlotIndices.add(idx);
        }
      }
    }
    final slotIndex = getFirstEmptySlotForPosition(positionKey, playersPerTeam, usedSlotIndices);

    final request = JoinGameRequestModel(
      position: positionKey,
      my_diwanya_team: _isMyDiwanyaGame ? _selectedTeam : null,
      slot_index: slotIndex,
    );
    bloc.add(JoinGameEvent(gameId: gameId, request: request));
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is GamesError) {
          context.showMessage(isError: true, state.message);
        } else if (state is JoinGameSuccess) {
          final isPrivate = bloc.gameDetails?.type == 'private';
          final message = isPrivate
              ? LocaleKeys.join_request_sent_successfully.tr()
              : LocaleKeys.successfully_joined_the_game.tr();
          context.showMessage(message);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.join_game.tr())),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Selection (only for My Diwanya games)
                  if (_isMyDiwanyaGame) ...[
                    Text(
                      LocaleKeys.select_joining_team.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    12.heightBox(),
                    _buildTeamSelection(),
                    20.heightBox(),
                  ],
                  // Playing Position Dropdown
                  Text(
                    LocaleKeys.playing_position.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  12.heightBox(),
                  _buildPositionDropdown(),
                  20.heightBox(),
                  // Football Pitch
                  _buildFootballField(),
                  20.heightBox(),
                  // Join Button
                  _buildJoinButton(state),
                  20.heightBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamSelection() {
    final team1Name = LocaleKeys.team_1.tr();
    final team2Name = LocaleKeys.team_2.tr();
    final userTeam = _userTeamValue;
    final team1Disabled = userTeam == 'team_2';
    final team2Disabled = userTeam == 'team_1';

    return Row(
      children: [
        Expanded(
          child: _buildTeamButton(
            teamName: team1Name,
            teamValue: 'team_1',
            isSelected: _selectedTeam == 'team_1',
            isDisabled: team1Disabled,
          ),
        ),
        12.widthBox(),
        Expanded(
          child: _buildTeamButton(
            teamName: team2Name,
            teamValue: 'team_2',
            isSelected: _selectedTeam == 'team_2',
            isDisabled: team2Disabled,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamButton({
    required String teamName,
    required String teamValue,
    required bool isSelected,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedTeam = teamValue;
                if (_selectedPosition == Position.goalKeeper) {
                  final game = bloc.gameDetails;
                  final gkClosed = teamValue == 'team_1'
                      ? game?.goalkeeperTeam1Close == true
                      : game?.goalkeeperTeam2Close == true;
                  if (gkClosed) _selectedPosition = null;
                }
              });
            },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : AppColors.primaryLiteGrey,
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.borderGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              teamName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDisabled ? AppColors.borderGrey : AppColors.primaryBlack),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionDropdown() {
    final selectable = _selectablePositionsForJoin;
    final value = selectable.contains(_selectedPosition) ? _selectedPosition : null;
    if (_selectedPosition != null && value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedPosition = null);
      });
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Position>(
          value: value,
          hint: Text(LocaleKeys.select_playing_position.tr(), style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down),
          items: selectable.map((Position position) {
            return DropdownMenuItem<Position>(
              value: position,
              child: Text(position.displayName, style: TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (Position? newValue) {
            setState(() {
              _selectedPosition = newValue;
            });
          },
        ),
      ),
    );
  }

  /// Maps position to field coordinates for highlighting
  /// Uses similar logic to game_details_page but shows where the selected position would be
  Map<String, double> _getPositionCoordinates(Position? position) {
    if (position == null) return {'x': 0.5, 'y': 0.5};

    final game = bloc.gameDetails;
    // playersTarget is total players, divide by 2 to get players per team
    final totalPlayers = int.tryParse(game?.playersTarget?.toString() ?? '0') ?? 0;
    final playersPerTeam = totalPlayers ~/ 2;

    // For small formations, use simpler positioning
    if (playersPerTeam <= 4) {
      // Show position in the top team area (where new players typically join)
      if (position == Position.goalKeeper) {
        return {'x': 0.5, 'y': 0.92};
      } else if (position == Position.defender) {
        return playersPerTeam == 2 ? {'x': 0.5, 'y': 0.85} : {'x': 0.3, 'y': 0.85};
      } else if (position == Position.attacker) {
        return playersPerTeam == 2 ? {'x': 0.5, 'y': 0.15} : {'x': 0.5, 'y': 0.12};
      } else if (position == Position.center) {
        return {'x': 0.5, 'y': 0.5};
      } else {
        return {'x': 0.5, 'y': 0.5};
      }
    }

    // For larger formations, use position-based
    if (position == Position.goalKeeper) {
      return {'x': 0.5, 'y': 0.92};
    } else if (position == Position.defender) {
      return {'x': 0.5, 'y': 0.85};
    } else if (position == Position.attacker) {
      return {'x': 0.5, 'y': 0.12};
    } else if (position == Position.center) {
      return {'x': 0.5, 'y': 0.5};
    } else {
      return {'x': 0.5, 'y': 0.5};
    }
  }

  /// Gets position coordinates for a player based on team and formation
  // Map<String, double> _getPlayerPositionCoordinates(
  //   Position? position,
  //   int teamIndex,
  //   int playerIndexInTeam,
  //   int playersPerTeam,
  // ) {
  //   // For standard formations (2v2, 3v3, 4v4, 5v5, 7v7, 9v9, 11v11), use formation-based positioning
  //   if (playersPerTeam <= 11) {
  //     final isTopTeam = teamIndex == 0;
  //     final baseY = isTopTeam ? 0.1 : 0.9;
  //     final yRange = isTopTeam ? 0.3 : -0.3;
  //
  //     switch (playersPerTeam) {
  //       case 2:
  //         final positions = [
  //           {'x': 0.3, 'y': baseY},
  //           {'x': 0.7, 'y': baseY + (yRange * 0.3)},
  //         ];
  //         return positions[playerIndexInTeam % 2];
  //       case 3:
  //         final positions = [
  //           {'x': 0.2, 'y': baseY},
  //           {'x': 0.5, 'y': baseY + (yRange * 0.2)},
  //           {'x': 0.8, 'y': baseY},
  //         ];
  //         return positions[playerIndexInTeam % 3];
  //       case 4:
  //         final positions = [
  //           {'x': 0.15, 'y': baseY},
  //           {'x': 0.4, 'y': baseY + (yRange * 0.15)},
  //           {'x': 0.6, 'y': baseY + (yRange * 0.15)},
  //           {'x': 0.85, 'y': baseY},
  //         ];
  //         return positions[playerIndexInTeam % 4];
  //       case 5: // 5v5
  //         final positions = [
  //           {'x': 0.5, 'y': baseY + (yRange * 0.9)}, // Goalkeeper
  //           {'x': 0.2, 'y': baseY + (yRange * 0.7)}, // Defender left
  //           {'x': 0.5, 'y': baseY + (yRange * 0.7)}, // Defender center
  //           {'x': 0.8, 'y': baseY + (yRange * 0.7)}, // Defender right
  //           {'x': 0.5, 'y': baseY + (yRange * 0.3)}, // Forward
  //         ];
  //         return positions[playerIndexInTeam % 5];
  //       case 7: // 7v7
  //         final positions = [
  //           {'x': 0.5, 'y': baseY + (yRange * 0.95)}, // Goalkeeper
  //           {'x': 0.15, 'y': baseY + (yRange * 0.8)}, // Defender left
  //           {'x': 0.5, 'y': baseY + (yRange * 0.8)}, // Defender center
  //           {'x': 0.85, 'y': baseY + (yRange * 0.8)}, // Defender right
  //           {'x': 0.3, 'y': baseY + (yRange * 0.4)}, // Midfielder left
  //           {'x': 0.7, 'y': baseY + (yRange * 0.4)}, // Midfielder right
  //           {'x': 0.5, 'y': baseY + (yRange * 0.1)}, // Forward
  //         ];
  //         return positions[playerIndexInTeam % 7];
  //       case 9: // 9v9
  //         final positions = [
  //           {'x': 0.5, 'y': baseY + (yRange * 0.95)}, // Goalkeeper
  //           {'x': 0.15, 'y': baseY + (yRange * 0.85)}, // Defender left
  //           {'x': 0.4, 'y': baseY + (yRange * 0.85)}, // Defender left-center
  //           {'x': 0.6, 'y': baseY + (yRange * 0.85)}, // Defender right-center
  //           {'x': 0.85, 'y': baseY + (yRange * 0.85)}, // Defender right
  //           {'x': 0.25, 'y': baseY + (yRange * 0.5)}, // Midfielder left
  //           {'x': 0.5, 'y': baseY + (yRange * 0.5)}, // Midfielder center
  //           {'x': 0.75, 'y': baseY + (yRange * 0.5)}, // Midfielder right
  //           {'x': 0.5, 'y': baseY + (yRange * 0.1)}, // Forward
  //         ];
  //         return positions[playerIndexInTeam % 9];
  //       case 11: // 11v11
  //         final positions = [
  //           {'x': 0.5, 'y': baseY + (yRange * 0.96)}, // Goalkeeper
  //           {'x': 0.1, 'y': baseY + (yRange * 0.88)}, // Defender left
  //           {'x': 0.3, 'y': baseY + (yRange * 0.88)}, // Defender left-center
  //           {'x': 0.5, 'y': baseY + (yRange * 0.88)}, // Defender center
  //           {'x': 0.7, 'y': baseY + (yRange * 0.88)}, // Defender right-center
  //           {'x': 0.9, 'y': baseY + (yRange * 0.88)}, // Defender right
  //           {'x': 0.2, 'y': baseY + (yRange * 0.55)}, // Midfielder left
  //           {'x': 0.5, 'y': baseY + (yRange * 0.55)}, // Midfielder center
  //           {'x': 0.8, 'y': baseY + (yRange * 0.55)}, // Midfielder right
  //           {'x': 0.3, 'y': baseY + (yRange * 0.15)}, // Forward left
  //           {'x': 0.7, 'y': baseY + (yRange * 0.15)}, // Forward right
  //         ];
  //         return positions[playerIndexInTeam % 11];
  //       default:
  //         final x = 0.2 + (playerIndexInTeam % playersPerTeam) * (0.6 / (playersPerTeam - 1));
  //         final y = baseY + (yRange * (playerIndexInTeam % 2) * 0.2);
  //         return {'x': x.clamp(0.1, 0.9), 'y': y.clamp(0.1, 0.9)};
  //     }
  //   }
  //
  //   // For larger formations, use position-based
  //   if (position == null) return {'x': 0.5, 'y': 0.5};
  //
  //   final isTopTeam = teamIndex == 0;
  //   if (position == Position.goalKeeper) {
  //     return {'x': 0.5, 'y': isTopTeam ? 0.92 : 0.08};
  //   } else if (position == Position.defender) {
  //     return {'x': 0.5, 'y': isTopTeam ? 0.85 : 0.15};
  //   } else if (position == Position.attacker) {
  //     return {'x': 0.5, 'y': isTopTeam ? 0.12 : 0.88};
  //   } else if (position == Position.center) {
  //     return {'x': 0.5, 'y': isTopTeam ? 0.4 : 0.6};
  //   } else {
  //     return {'x': 0.5, 'y': isTopTeam ? 0.3 : 0.7};
  //   }
  // }

  Widget _buildFootballField() {
    // final game = bloc.gameDetails;
    // playersTarget is total players, divide by 2 to get players per team
    // final totalPlayers = int.tryParse(game?.playersTarget?.toString() ?? '0') ?? 0;
    // final playersPerTeam = totalPlayers ~/ 2;
    // final players = game?.players ?? [];
    final selectedCoords = _getPositionCoordinates(_selectedPosition);

    // // Split players into teams
    // final team0Players = players.take(playersPerTeam).toList();
    // final team1Players = players.skip(playersPerTeam).take(playersPerTeam).toList();

    return Container(
      height: 420.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primaryLiteGrey,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.asset(AppAssets.grass_profile, height: 420.h, fit: BoxFit.cover),
            // Soccer field lines and players
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    CustomPaint(painter: _SoccerFieldPainter(), child: Container()),
                    // // Team 0 players (top half)
                    // ...team0Players.asMap().entries.map((entry) {
                    //   final playerIndex = entry.key;
                    //   final player = entry.value;
                    //   final coords = _getPlayerPositionCoordinates(
                    //     player.position,
                    //     0, // Team 0
                    //     playerIndex,
                    //     playersPerTeam,
                    //   );
                    //   return Positioned(
                    //     left: coords['x']! * constraints.maxWidth - 25.w,
                    //     top: coords['y']! * constraints.maxHeight - 25.h,
                    //     child: Container(
                    //       width: 50.w,
                    //       height: 50.h,
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: AppColors.primaryWhite, width: 2),
                    //       ),
                    //       child: ClipOval(
                    //         child: player.image != null && player.image!.isNotEmpty
                    //             ? Image.network(
                    //                 player.image!,
                    //                 fit: BoxFit.cover,
                    //                 errorBuilder: (context, error, stackTrace) {
                    //                   return Container(
                    //                     color: AppColors.primaryLiteGrey,
                    //                     child: Icon(
                    //                       Icons.person,
                    //                       color: AppColors.primaryColor,
                    //                       size: 30,
                    //                     ),
                    //                   );
                    //                 },
                    //               )
                    //             : Container(
                    //                 color: AppColors.primaryLiteGrey,
                    //                 child: Icon(
                    //                   Icons.person,
                    //                   color: AppColors.primaryColor,
                    //                   size: 30,
                    //                 ),
                    //               ),
                    //       ),
                    //     ),
                    //   );
                    // }),
                    // // Team 1 players (bottom half)
                    // ...team1Players.asMap().entries.map((entry) {
                    //   final playerIndex = entry.key;
                    //   final player = entry.value;
                    //   final coords = _getPlayerPositionCoordinates(
                    //     player.position,
                    //     1, // Team 1
                    //     playerIndex,
                    //     playersPerTeam,
                    //   );
                    //   return Positioned(
                    //     left: coords['x']! * constraints.maxWidth - 25.w,
                    //     top: coords['y']! * constraints.maxHeight - 25.h,
                    //     child: Container(
                    //       width: 50.w,
                    //       height: 50.h,
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         border: Border.all(color: AppColors.primaryWhite, width: 2),
                    //       ),
                    //       child: ClipOval(
                    //         child: player.image != null && player.image!.isNotEmpty
                    //             ? Image.network(
                    //                 player.image!,
                    //                 fit: BoxFit.cover,
                    //                 errorBuilder: (context, error, stackTrace) {
                    //                   return Container(
                    //                     color: AppColors.primaryLiteGrey,
                    //                     child: Icon(
                    //                       Icons.person,
                    //                       color: AppColors.primaryColor,
                    //                       size: 30,
                    //                     ),
                    //                   );
                    //                 },
                    //               )
                    //             : Container(
                    //                 color: AppColors.primaryLiteGrey,
                    //                 child: Icon(
                    //                   Icons.person,
                    //                   color: AppColors.primaryColor,
                    //                   size: 30,
                    //                 ),
                    //               ),
                    //       ),
                    //     ),
                    //   );
                    // }),

                    // Highlighted selected position
                    if (_selectedPosition != null)
                      Positioned(
                        left: selectedCoords['x']! * constraints.maxWidth - 30.w,
                        top: selectedCoords['y']! * constraints.maxHeight - 30.h,
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryColor, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(Icons.person_add, color: AppColors.primaryWhite, size: 30),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(GamesState state) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: ElevatedButton(
        onPressed: state is GamesLoading ? null : _joinGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                LocaleKeys.join.tr(),
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// Custom painter for soccer field lines
class _SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryWhite.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.15, paint);

    // Penalty box (top)
    final topPenaltyBox = Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height * 0.25);
    canvas.drawRect(topPenaltyBox, paint);

    // Penalty box (bottom)
    final bottomPenaltyBox = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.75,
      size.width * 0.6,
      size.height * 0.25,
    );
    canvas.drawRect(bottomPenaltyBox, paint);

    // Goal area (top)
    final topGoalArea = Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, size.height * 0.12);
    canvas.drawRect(topGoalArea, paint);

    // Goal area (bottom)
    final bottomGoalArea = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.88,
      size.width * 0.4,
      size.height * 0.12,
    );
    canvas.drawRect(bottomGoalArea, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
